import { useState, useEffect, useMemo, useRef } from 'react'
import { connect, disconnect } from '@starknet-io/get-starknet'
import { RpcProvider } from 'starknet'
import { buildPoseidon } from 'circomlibjs'
import { 
  Shield, Wallet, LogOut, Loader2, CheckCircle, AlertCircle, 
  ArrowDownToLine, ArrowUpFromLine, ArrowLeftRight, Zap, 
  Key, Copy, Check 
} from 'lucide-react'

import { init } from 'garaga';

// ==================== CONFIGURATION ====================
const SHIELD_POOL_ADDRESS = '0x6582ba9fe8f7d2aa18298c3f1803cf3e8e4efde5282bba8abac3606f12559ad' // UPDATE if changed
const STRK_ADDRESS = '0x04718f5a0Fc34cC1AF16A1cdee98fFB20C31f5cD61D6Ab07201858f4287c938D'
const RPC_URL = 'https://starknet-sepolia.infura.io/v3/44bdf2d1c8594cc9b16832398af754d7'
const CIRCUIT_MERKLE_DEPTH = 2

// Mask for 251 bits - matches circuit's mask_to_stark_field
const MASK_251 = (1n << 251n) - 1n

// ==================== BN254 POSEIDON WITH MASKING ====================
let poseidonInstance: any = null

async function initPoseidon() {
  if (!poseidonInstance) {
    poseidonInstance = await buildPoseidon()
  }
  return poseidonInstance
}

function F2BigInt(poseidon: any, val: any): bigint {
  return BigInt(poseidon.F.toString(val))
}

// Mask to 251 bits - EXACTLY matches circuit's mask_to_stark_field
function maskToStarkField(value: bigint): bigint {
  return value & MASK_251
}

// Raw BN254 hash (before masking)
async function bn254HashRaw(inputs: bigint[]): Promise<bigint> {
  const poseidon = await initPoseidon()
  const hash = poseidon(inputs.map(x => x.toString()))
  return F2BigInt(poseidon, hash)
}

// Masked hash functions - match circuit's hash_2, hash_3, hash_4
async function hash2(a: bigint, b: bigint): Promise<bigint> {
  const raw = await bn254HashRaw([a, b])
  const masked = maskToStarkField(raw)
  return masked
}

async function hash3(a: bigint, b: bigint, c: bigint): Promise<bigint> {
  const raw = await bn254HashRaw([a, b, c])
  const masked = maskToStarkField(raw)
  return masked
}

async function hash4(a: bigint, b: bigint, c: bigint, d: bigint): Promise<bigint> {
  const raw = await bn254HashRaw([a, b, c, d])
  const masked = maskToStarkField(raw)
  return masked
}

// commitment = hash_4(amount, asset_id, blinding, owner_key) with masking
async function computeCommitment(amount: bigint, assetId: bigint, blinding: bigint, ownerKey: bigint): Promise<bigint> {
  const commitment = await hash4(amount, assetId, blinding, ownerKey)
  console.log('computeCommitment:', {
    amount: toHex(amount),
    assetId: toHex(assetId),
    blinding: toHex(blinding),
    ownerKey: toHex(ownerKey),
    commitment: toHex(commitment)
  })
  return commitment
}

// nullifier = hash_3(commitment, priv_key, index) with masking
async function computeNullifier(commitment: bigint, privKey: bigint, index: bigint): Promise<bigint> {
  const nullifier = await hash3(commitment, privKey, index)
  console.log('computeNullifier:', {
    commitment: toHex(commitment),
    privKey: toHex(privKey),
    index: index.toString(),
    nullifier: toHex(nullifier)
  })
  return nullifier
}

function randomFieldElement(): bigint {
  const bytes = new Uint8Array(31)
  crypto.getRandomValues(bytes)
  let result = 0n
  for (const byte of bytes) {
    result = (result << 8n) | BigInt(byte)
  }
  // Ensure fits in 251 bits
  return result & MASK_251
}

async function derivePublicKey(privKey: bigint): Promise<bigint> {
  // pubkey = hash([privKey]) with masking
  const raw = await bn254HashRaw([privKey])
  return maskToStarkField(raw)
}

// ==================== MERKLE TREE ====================
class MerkleTree {
  depth: number
  leaves: bigint[]
  zeroValues: bigint[]
  initialized: boolean = false
  
  constructor(depth: number) {
    this.depth = depth
    this.leaves = []
    this.zeroValues = []
  }
  
  async init(): Promise<void> {
    if (this.initialized) return
    this.zeroValues = await this.computeZeroValues()
    this.initialized = true
    console.log('MerkleTree initialized, zero values computed')
  }
  
  async computeZeroValues(): Promise<bigint[]> {
    const zeros: bigint[] = [0n]
    for (let i = 1; i <= this.depth; i++) {
      zeros[i] = await hash2(zeros[i - 1], zeros[i - 1])
    }
    return zeros
  }
  
  insert(leaf: bigint): number {
    const index = this.leaves.length
    this.leaves.push(leaf)
    console.log(`Inserted leaf at index ${index}: ${toHex(leaf)}`)
    return index
  }
  
  async getRoot(): Promise<bigint> {
    await this.init()
    if (this.leaves.length === 0) return this.zeroValues[this.depth]
    
    let layer = [...this.leaves]
    
    for (let level = 0; level < this.depth; level++) {
      const nextLayer: bigint[] = []
      const levelSize = Math.ceil(layer.length / 2)
      
      for (let i = 0; i < levelSize; i++) {
        const left = layer[i * 2] ?? this.zeroValues[level]
        const right = layer[i * 2 + 1] ?? this.zeroValues[level]
        nextLayer.push(await hash2(left, right))
      }
      
      layer = nextLayer
    }
    
    return layer[0] ?? this.zeroValues[this.depth]
  }
  
  async getProof(index: number): Promise<{ siblings: bigint[], pathBits: bigint[] }> {
    await this.init()
    const siblings: bigint[] = []
    const pathBits: bigint[] = []
    let layer = [...this.leaves]
    let currentIndex = index
    
    for (let level = 0; level < this.depth; level++) {
      const isRight = currentIndex % 2
      pathBits.push(BigInt(isRight))
      
      const siblingIndex = isRight === 0 ? currentIndex + 1 : currentIndex - 1
      const sibling = layer[siblingIndex] ?? this.zeroValues[level]
      siblings.push(sibling)
      
      const nextLayer: bigint[] = []
      const layerSize = Math.max(Math.ceil(layer.length / 2), 1)
      
      for (let i = 0; i < layerSize; i++) {
        const left = layer[i * 2] ?? this.zeroValues[level]
        const right = layer[i * 2 + 1] ?? this.zeroValues[level]
        nextLayer.push(await hash2(left, right))
      }
      
      layer = nextLayer
      currentIndex = Math.floor(currentIndex / 2)
    }
    
    return { siblings, pathBits }
  }
}

// ==================== STORAGE ====================
// Using v4 to ensure fresh start with new masking
const STORAGE_VERSION = 'v4'

interface NoteData {
  amount: string
  assetId: string
  blinding: string
  ownerKey: string
  commitment: string
  nullifier: string
  leafIndex: number
  spent: boolean
  createdAt: number
}

function saveNotes(notes: NoteData[]): void {
  localStorage.setItem(`shieldnet_notes_${STORAGE_VERSION}`, JSON.stringify(notes))
}

function loadNotes(): NoteData[] {
  try {
    const data = localStorage.getItem(`shieldnet_notes_${STORAGE_VERSION}`)
    return data ? JSON.parse(data) : []
  } catch {
    return []
  }
}

function getOrCreatePrivateKey(): bigint {
  const key = `shieldnet_privkey_${STORAGE_VERSION}`
  const stored = localStorage.getItem(key)
  if (stored) return BigInt(stored)
  const newKey = randomFieldElement()
  localStorage.setItem(key, newKey.toString())
  return newKey
}

// ==================== UTILS ====================
function parseUnits(value: string, decimals: number): bigint {
  if (!value) return 0n
  const [int = '0', frac = ''] = value.split('.')
  return BigInt(int + frac.padEnd(decimals, '0').slice(0, decimals))
}

function formatUnits(value: bigint, decimals: number): string {
  const str = value.toString().padStart(decimals + 1, '0')
  const int = str.slice(0, -decimals) || '0'
  const frac = str.slice(-decimals).replace(/0+$/, '')
  return frac ? `${int}.${frac}` : int
}

function truncateAddress(addr: string): string {
  return `${addr.slice(0, 6)}...${addr.slice(-4)}`
}

function toHex(n: bigint): string {
  return '0x' + n.toString(16)
}

// ==================== PROOF GENERATION ====================
function hexToUint8Array(hex: string): Uint8Array {
  const sanitised = BigInt(hex).toString(16).padStart(64, '0')
  const len = sanitised.length / 2
  const u8 = new Uint8Array(len)
  for (let i = 0; i < len; i++) {
    u8[i] = parseInt(sanitised.slice(i * 2, i * 2 + 2), 16)
  }
  return u8
}

function flattenFieldsAsArray(fields: string[]): Uint8Array {
  const arrays = fields.map(hexToUint8Array)
  const totalLength = arrays.reduce((acc, val) => acc + val.length, 0)
  const result = new Uint8Array(totalLength)
  let offset = 0
  for (const arr of arrays) {
    result.set(arr, offset)
    offset += arr.length
  }
  return result
}

// async function generateProof(
//   circuitName: string,
//   inputs: Record<string, any>,
//   onStatus: (msg: string) => void
// ): Promise<{ calldata: bigint[] }> {
//   onStatus('Loading proof system...')
  
//   const [
//     { Noir },
//     { UltraHonkBackend },
//     { getZKHonkCallData, init: initGaraga },
//     { default: initACVM },
//     { default: initNoirC },
//   ] = await Promise.all([
//     import('@noir-lang/noir_js'),
//     import('@aztec/bb.js'),
//     import('garaga'),
//     import('@noir-lang/acvm_js'),
//     import('@noir-lang/noirc_abi'),
//   ])
  
//   onStatus('Initializing WASM...')
  
//   try {
//     await Promise.all([
//       initACVM(new URL('@noir-lang/acvm_js/web/acvm_js_bg.wasm', import.meta.url)),
//       initNoirC(new URL('@noir-lang/noirc_abi/web/noirc_abi_wasm_bg.wasm', import.meta.url)),
//     ])
//   } catch (e) {
//     console.log('WASM init (may already be done)')
//   }
  
//   await initGaraga()
  
//   onStatus('Loading circuit...')
  
//   const circuitRes = await fetch(`/circuits/${circuitName}.json`)
//   if (!circuitRes.ok) throw new Error(`Circuit ${circuitName}.json not found`)
//   const circuit = await circuitRes.json()
  
//   const vkRes = await fetch(`/circuits/${circuitName}_vk.bin`)
//   if (!vkRes.ok) throw new Error(`VK ${circuitName}_vk.bin not found`)
//   const vk = new Uint8Array(await vkRes.arrayBuffer())
  
//   onStatus('Generating witness...')
  
//   const noir = new Noir({
//     bytecode: circuit.bytecode,
//     abi: circuit.abi,
//     debug_symbols: '',
//     file_map: {} as any,
//   })
  
//   console.log('Executing circuit with inputs:', inputs)
//   const { witness } = await noir.execute(inputs)
  
//   onStatus('Generating ZK proof (30-60s)...')
  
//   const backend = new UltraHonkBackend(circuit.bytecode, { threads: 1 })
//   const proof = await backend.generateProof(witness, { starknetZK: true })
//   backend.destroy()
  
//   onStatus('Preparing calldata...')
  
//   const calldata = getZKHonkCallData(
//     proof.proof,
//     flattenFieldsAsArray(proof.publicInputs),
//     vk,
//     1
//   )
  
//   return { calldata: calldata.slice(1) }
// }

async function generateProof(
  circuitName: string,
  inputs: Record<string, any>,
  onStatus: (msg: string) => void
): Promise<{ calldata: bigint[] }> {
  onStatus('Loading proof system...')
  
  try {
    // Import dependencies
    const [
      { Noir },
      { UltraHonkBackend },
      { getZKHonkCallData, init: initGaraga },
      { default: initACVM },
      { default: initNoirC },
    ] = await Promise.all([
      import('@noir-lang/noir_js'),
      import('@aztec/bb.js'),
      import('garaga'),
      import('@noir-lang/acvm_js'),
      import('@noir-lang/noirc_abi'),
    ])
    
    console.log('✅ Imports loaded')
    
    onStatus('Initializing WASM...')
    
    // Load circuit first to get paths
    const circuitRes = await fetch(`/circuits/${circuitName}.json`)
    if (!circuitRes.ok) throw new Error(`Circuit ${circuitName}.json not found`)
    const circuit = await circuitRes.json()
    
    const vkRes = await fetch(`/circuits/${circuitName}_vk.bin`)
    if (!vkRes.ok) throw new Error(`VK ${circuitName}_vk.bin not found`)
    const vk = new Uint8Array(await vkRes.arrayBuffer())
    
    console.log('✅ Circuit loaded, bytecode length:', circuit.bytecode.length)
    console.log('✅ VK loaded, size:', vk.length)
    
    // Initialize WASM using fetch approach 
    const acvmUrl = new URL('@noir-lang/acvm_js/web/acvm_js_bg.wasm', import.meta.url).href
    const noircUrl = new URL('@noir-lang/noirc_abi/web/noirc_abi_wasm_bg.wasm', import.meta.url).href
    
    await Promise.all([
      initACVM(fetch(acvmUrl)),
      initNoirC(fetch(noircUrl)),
    ])
    
    console.log('✅ WASM initialized')
    
    // Initialize Garaga
    await initGaraga()
    console.log('✅ Garaga initialized')
    
    onStatus('Generating witness...')
    
    // Create Noir instance
    const noir = new Noir({
      bytecode: circuit.bytecode,
      abi: circuit.abi as any,
      debug_symbols: '',
      file_map: {} as any,
    })
    
    console.log('Executing circuit with inputs...')
    const { witness } = await noir.execute(inputs)
    console.log('✅ Witness generated, size:', witness.length)
    
    onStatus('Generating ZK proof (this may take 2-3 minutes)...')
    
    // IMPORTANT: Use threads: 1 for browser environment
    const backend = new UltraHonkBackend(circuit.bytecode, { threads: 1 })
    console.log('✅ Backend created')
    
    // Generate proof with timeout to prevent hanging
    const proof = await backend.generateProof(witness, { starknetZK: true })
    console.log('✅ Proof generated, size:', proof.proof.length)
    
    backend.destroy()
    
    onStatus('Preparing calldata...')
    
    // Initialize Garaga again (as done in tutorial)
    await init()
    
    const calldata = getZKHonkCallData(
      proof.proof,
      flattenFieldsAsArray(proof.publicInputs),
      vk,
      1 // HonkFlavor.STARKNET
    )
    
    console.log('✅ Calldata ready, length:', calldata.length)
    
    return { calldata: calldata.slice(1) }
    
  } catch (error: any) {
    console.error('❌ Proof generation failed:', error)
    throw new Error(`Proof generation failed: ${error.message}`)
  }
}

// ==================== MAIN APP ====================
type Tab = 'deposit' | 'withdraw' | 'transfer' | 'transact' | 'notes'
type Status = 'idle' | 'loading' | 'success' | 'error'

const provider = new RpcProvider({ nodeUrl: RPC_URL })

export default function App() {
  const [walletObj, setWalletObj] = useState<any>(null)
  const [address, setAddress] = useState<string | null>(null)
  const [isConnected, setIsConnected] = useState(false)
  
  const [activeTab, setActiveTab] = useState<Tab>('deposit')
  const [notes, setNotes] = useState<NoteData[]>([])
  const [status, setStatus] = useState<Status>('idle')
  const [statusMsg, setStatusMsg] = useState('')
  const [txHash, setTxHash] = useState<string | null>(null)
  
  const [amount, setAmount] = useState('')
  const [recipient, setRecipient] = useState('')
  const [recipientKey, setRecipientKey] = useState('')
  const [targetContract, setTargetContract] = useState('')
  const [minOutput, setMinOutput] = useState('')
  const [copied, setCopied] = useState(false)
  
  const [publicKey, setPublicKey] = useState<bigint>(0n)
  const [isInitialized, setIsInitialized] = useState(false)
  const privateKey = useMemo(() => getOrCreatePrivateKey(), [])
  
  const merkleTreeRef = useRef<MerkleTree>(new MerkleTree(CIRCUIT_MERKLE_DEPTH))
  
  // Initialize
  useEffect(() => {
    async function init() {
      console.log('=== INITIALIZING SHIELDNET ===')
      console.log('Storage version:', STORAGE_VERSION)
      
      await initPoseidon()
      console.log('Poseidon initialized')
      
      const pubKey = await derivePublicKey(privateKey)
      setPublicKey(pubKey)
      console.log('Private key:', toHex(privateKey))
      console.log('Public key:', toHex(pubKey))
      
      const loaded = loadNotes()
      setNotes(loaded)
      console.log('Loaded', loaded.length, 'notes')
      
      const tree = new MerkleTree(CIRCUIT_MERKLE_DEPTH)
      await tree.init()
      
      for (const note of loaded) {
        tree.insert(BigInt(note.commitment))
      }
      merkleTreeRef.current = tree
      
      if (loaded.length > 0) {
        const root = await tree.getRoot()
        console.log('Merkle root:', toHex(root))
      }
      
      setIsInitialized(true)
      console.log('=== INITIALIZATION COMPLETE ===')
    }
    init()
  }, [privateKey])
  
  const unspentNotes = notes.filter(n => !n.spent)
  const shieldedBalance = unspentNotes.reduce((sum, n) => sum + BigInt(n.amount), 0n)
  
  // ==================== WALLET ====================
  async function connectWallet() {
    try {
      setStatus('loading')
      setStatusMsg('Connecting...')
      const starknet = await connect()
      if (!starknet) throw new Error('No wallet found')
      const accounts = await starknet.request({ type: 'wallet_requestAccounts' })
      setWalletObj(starknet)
      setAddress(accounts[0] || null)
      setIsConnected(true)
      setStatus('idle')
      setStatusMsg('')
    } catch (err: any) {
      setStatus('error')
      setStatusMsg(err.message)
    }
  }
  
  async function disconnectWallet() {
    await disconnect()
    setWalletObj(null)
    setAddress(null)
    setIsConnected(false)
  }
  
  // ==================== DEPOSIT ====================
  async function handleDeposit() {
    if (!walletObj || !address || !isInitialized) return
    if (!amount || parseUnits(amount, 18) <= 0n) {
      setStatus('error')
      setStatusMsg('Enter valid amount')
      return
    }
    
    try {
      setStatus('loading')
      setStatusMsg('Computing commitment...')
      
      const amountWei = parseUnits(amount, 18)
      const blinding = randomFieldElement()
      const assetId = BigInt(STRK_ADDRESS)
      
      console.log('=== DEPOSIT ===')
      console.log('Amount (wei):', amountWei.toString())
      console.log('Amount (hex):', toHex(amountWei))
      console.log('Asset ID:', toHex(assetId))
      console.log('Blinding:', toHex(blinding))
      console.log('Owner Key (pubKey):', toHex(publicKey))
      
      const commitment = await computeCommitment(amountWei, assetId, blinding, privateKey)
      console.log('Commitment:', toHex(commitment))
      
      // Verify commitment fits in Starknet field
      const STARK_PRIME = BigInt('0x800000000000011000000000000000000000000000000000000000000000001')
      if (commitment >= STARK_PRIME) {
        throw new Error('Commitment exceeds Starknet field - masking not working correctly')
      }
      console.log('Commitment fits in Starknet field: true')
      
      setStatusMsg('Preparing transaction...')
      
      const calls = [
        {
          contract_address: STRK_ADDRESS,
          entry_point: 'approve',
          calldata: [SHIELD_POOL_ADDRESS, toHex(amountWei), '0x0'],
        },
        {
          contract_address: SHIELD_POOL_ADDRESS,
          entry_point: 'deposit',
          calldata: [toHex(commitment), toHex(amountWei), '0x0'],
        },
      ]
      
      setStatusMsg('Confirm in wallet...')
      
      const result = await walletObj.request({
        type: 'wallet_addInvokeTransaction',
        params: { calls },
      })
      
      setStatusMsg('Waiting for confirmation...')
      await provider.waitForTransaction(result.transaction_hash)
      
      const leafIndex = merkleTreeRef.current.insert(commitment)
      const nullifier = await computeNullifier(commitment, privateKey, BigInt(leafIndex))
      
      console.log('Leaf index:', leafIndex)
      console.log('Nullifier:', toHex(nullifier))
      
      const newRoot = await merkleTreeRef.current.getRoot()
      console.log('New merkle root:', toHex(newRoot))
      
      const newNote: NoteData = {
        amount: amountWei.toString(),
        assetId: STRK_ADDRESS,
        blinding: blinding.toString(),
        ownerKey: privateKey.toString(),
        commitment: commitment.toString(),
        nullifier: nullifier.toString(),
        leafIndex,
        spent: false,
        createdAt: Date.now(),
      }
      
      const updated = [...notes, newNote]
      saveNotes(updated)
      setNotes(updated)
      
      setTxHash(result.transaction_hash)
      setStatus('success')
      setStatusMsg('Deposit successful!')
      setAmount('')
    } catch (err: any) {
      console.error('Deposit error:', err)
      setStatus('error')
      setStatusMsg(err.message || 'Failed')
    }
  }
  
  // ==================== WITHDRAW ====================
  // async function handleWithdraw() {
  //   if (!walletObj || !address || !isInitialized) return
  //   if (!amount || !recipient) {
  //     setStatus('error')
  //     setStatusMsg('Enter amount and recipient')
  //     return
  //   }
    
  //   const amountWei = parseUnits(amount, 18)
    
  //   try {
  //     setStatus('loading')
  //     setStatusMsg('Selecting notes...')
      
  //     const selected: NoteData[] = []
  //     let total = 0n
  //     for (const note of unspentNotes) {
  //       selected.push(note)
  //       total += BigInt(note.amount)
  //       if (total >= amountWei && selected.length <= 2) break
  //     }
      
  //     if (total < amountWei) throw new Error('Insufficient balance')
      
  //     // Pad to 2 notes with dummy
  //     while (selected.length < 2) {
  //       const dummyBlinding = randomFieldElement()
  //       const dummyCommitment = await computeCommitment(0n, BigInt(STRK_ADDRESS), dummyBlinding, publicKey)
        
  //       selected.push({
  //         amount: '0',
  //         assetId: STRK_ADDRESS,
  //         blinding: dummyBlinding.toString(),
  //         ownerKey: publicKey.toString(),
  //         commitment: dummyCommitment.toString(),
  //         nullifier: '0',
  //         leafIndex: 0,
  //         spent: false,
  //         createdAt: Date.now(),
  //       })
  //     }
      
  //     setStatusMsg('Computing proofs...')
      
  //     // Change note
  //     const changeAmount = total - amountWei
  //     const changeBlinding = randomFieldElement()
  //     const changeCommitment = await computeCommitment(changeAmount, BigInt(STRK_ADDRESS), changeBlinding, publicKey)
      
  //     // Get merkle proofs
  //     const proof1 = await merkleTreeRef.current.getProof(selected[0].leafIndex)
  //     const proof2 = await merkleTreeRef.current.getProof(selected[1].leafIndex)
      
  //     const merkleRoot = await merkleTreeRef.current.getRoot()
      
  //     // IMPORTANT: Circuit uses fixed indices 0 and 1, not leaf indices
  //     const nullifier1 = await computeNullifier(BigInt(selected[0].commitment), privateKey, 0n)
  //     const nullifier2 = BigInt(selected[1].amount) > 0n 
  //       ? await computeNullifier(BigInt(selected[1].commitment), privateKey, 1n)
  //       : 0n
      
  //     const recipientField = BigInt(recipient)
      
  //     console.log('=== WITHDRAW DEBUG ===')
  //     console.log('Note 1:')
  //     console.log('  Amount:', selected[0].amount)
  //     console.log('  Asset:', selected[0].assetId)
  //     console.log('  Blinding:', toHex(BigInt(selected[0].blinding)))
  //     console.log('  OwnerKey:', toHex(BigInt(selected[0].ownerKey)))
  //     console.log('  Commitment (stored):', toHex(BigInt(selected[0].commitment)))
      
  //     // Recompute commitment to verify
  //     const recomputedCommitment1 = await computeCommitment(
  //       BigInt(selected[0].amount),
  //       BigInt(selected[0].assetId),
  //       BigInt(selected[0].blinding),
  //       BigInt(selected[0].ownerKey)
  //     )
  //     console.log('  Commitment (recomputed):', toHex(recomputedCommitment1))
  //     console.log('  Commitments match:', recomputedCommitment1 === BigInt(selected[0].commitment))
      
  //     console.log('Note 2:')
  //     console.log('  Amount:', selected[1].amount)
  //     console.log('  Commitment:', toHex(BigInt(selected[1].commitment)))
      
  //     console.log('Merkle:')
  //     console.log('  Root:', toHex(merkleRoot))
  //     console.log('  PathBits[0]:', proof1.pathBits.slice(0, 5).map(b => b.toString()))
  //     console.log('  Siblings[0] (first 3):', proof1.siblings.slice(0, 3).map(s => toHex(s)))
      
  //     // Verify merkle proof locally
  //     console.log('=== LOCAL MERKLE VERIFICATION ===')
  //     let current = BigInt(selected[0].commitment)
  //     console.log('Starting leaf:', toHex(current))
      
  //     for (let i = 0; i < CIRCUIT_MERKLE_DEPTH; i++) {
  //       const sibling = proof1.siblings[i]
  //       const isRight = proof1.pathBits[i]
        
  //       let newCurrent: bigint
  //       if (isRight === 1n) {
  //         newCurrent = await hash2(sibling, current)
  //       } else {
  //         newCurrent = await hash2(current, sibling)
  //       }
        
  //       if (i < 3) {
  //         console.log(`Level ${i}: isRight=${isRight}, sibling=${toHex(sibling).slice(0, 20)}..., result=${toHex(newCurrent).slice(0, 20)}...`)
  //       }
  //       current = newCurrent
  //     }
  //     console.log('Computed root:', toHex(current))
  //     console.log('Expected root:', toHex(merkleRoot))
  //     console.log('Match:', current === merkleRoot)
      
  //     if (current !== merkleRoot) {
  //       throw new Error('Local merkle verification failed - commitment or tree mismatch')
  //     }
      
  //     // Build circuit inputs
  //     const circuitInputs = {
  //       in1_amount: toHex(BigInt(selected[0].amount)),
  //       in1_asset_id: toHex(BigInt(selected[0].assetId)),
  //       in1_blinding: toHex(BigInt(selected[0].blinding)),
  //       in1_priv_key: toHex(privateKey),
  //       in1_path: proof1.pathBits.map(b => toHex(b)),
  //       in1_siblings: proof1.siblings.map(s => toHex(s)),
        
  //       in2_amount: toHex(BigInt(selected[1].amount)),
  //       in2_asset_id: toHex(BigInt(selected[1].assetId)),
  //       in2_blinding: toHex(BigInt(selected[1].blinding)),
  //       in2_priv_key: toHex(privateKey),
  //       in2_path: proof2.pathBits.map(b => toHex(b)),
  //       in2_siblings: proof2.siblings.map(s => toHex(s)),
        
  //       change_amount: toHex(changeAmount),
  //       change_blinding: toHex(changeBlinding),
  //       change_pub_key: toHex(publicKey),
        
  //       merkle_root: toHex(merkleRoot),
  //       nullifier_1: toHex(nullifier1),
  //       nullifier_2: toHex(nullifier2),
  //       change_commitment: toHex(changeCommitment),
  //       recipient: toHex(recipientField),
  //       withdraw_amount: toHex(amountWei),
  //       relayer_fee: toHex(0n),
  //     }
      
  //     console.log('=== CIRCUIT INPUTS ===')
  //     console.log('in1_amount:', circuitInputs.in1_amount)
  //     console.log('in1_asset_id:', circuitInputs.in1_asset_id)
  //     console.log('in1_blinding:', circuitInputs.in1_blinding)
  //     console.log('in1_priv_key:', circuitInputs.in1_priv_key)
  //     console.log('merkle_root:', circuitInputs.merkle_root)
      
  //     setStatusMsg('Generating ZK proof...')
  //     const proofResult = await generateProof('unshield', circuitInputs, setStatusMsg)
      
  //     setStatusMsg('Submitting transaction...')
      
  //     const calls = [{
  //       contract_address: SHIELD_POOL_ADDRESS,
  //       entry_point: 'withdraw',
  //       calldata: [
  //         proofResult.calldata.length.toString(),
  //         ...proofResult.calldata.map(c => toHex(c)),
  //         toHex(merkleRoot),
  //         toHex(nullifier1),
  //         toHex(nullifier2),
  //         toHex(changeCommitment),
  //         toHex(recipientField),
  //         toHex(amountWei),
  //         '0x0',
  //         '0x0',
  //         '0x0',
  //         '0x0',
  //       ],
  //     }]
      
  //     setStatusMsg('Confirm in wallet...')
      
  //     const result = await walletObj.request({
  //       type: 'wallet_addInvokeTransaction',
  //       params: { calls },
  //     })
      
  //     setStatusMsg('Waiting for confirmation...')
  //     await provider.waitForTransaction(result.transaction_hash)
      
  //     let updated = notes.map(n => {
  //       if (selected.some(s => s.commitment === n.commitment && s.leafIndex === n.leafIndex)) {
  //         return { ...n, spent: true }
  //       }
  //       return n
  //     })
      
  //     if (changeAmount > 0n) {
  //       const changeLeafIndex = merkleTreeRef.current.insert(changeCommitment)
  //       const changeNullifier = await computeNullifier(changeCommitment, privateKey, BigInt(changeLeafIndex))
        
  //       updated.push({
  //         amount: changeAmount.toString(),
  //         assetId: STRK_ADDRESS,
  //         blinding: changeBlinding.toString(),
  //         ownerKey: publicKey.toString(),
  //         commitment: changeCommitment.toString(),
  //         nullifier: changeNullifier.toString(),
  //         leafIndex: changeLeafIndex,
  //         spent: false,
  //         createdAt: Date.now(),
  //       })
  //     }
      
  //     saveNotes(updated)
  //     setNotes(updated)
      
  //     setTxHash(result.transaction_hash)
  //     setStatus('success')
  //     setStatusMsg('Withdrawal successful!')
  //     setAmount('')
  //     setRecipient('')
  //   } catch (err: any) {
  //     console.error('Withdraw error:', err)
  //     setStatus('error')
  //     setStatusMsg(err.message || 'Failed')
  //   }
  // }

  async function handleWithdraw() {
  if (!walletObj || !address || !isInitialized) return
  if (!amount || !recipient) {
    setStatus('error')
    setStatusMsg('Enter amount and recipient')
    return
  }
  
  const amountWei = parseUnits(amount, 18)
  
  try {
    setStatus('loading')
    setStatusMsg('Selecting note...')
    
    const selectedNote = unspentNotes.find(n => BigInt(n.amount) >= amountWei)
    if (!selectedNote) throw new Error('No note with sufficient balance')
    
    const changeAmount = BigInt(selectedNote.amount) - amountWei
    const changeBlinding = randomFieldElement()
    const changeCommitment = await computeCommitment(
      changeAmount, 
      BigInt(STRK_ADDRESS), 
      changeBlinding, 
      publicKey
    )
    
    const proof = await merkleTreeRef.current.getProof(selectedNote.leafIndex)
    const merkleRoot = await merkleTreeRef.current.getRoot()
    const nullifier = await computeNullifier(BigInt(selectedNote.commitment), privateKey, 0n)
    
    const circuitInputs = {
      in_amount: toHex(BigInt(selectedNote.amount)),
      in_asset_id: toHex(BigInt(selectedNote.assetId)),
      in_blinding: toHex(BigInt(selectedNote.blinding)),
      in_priv_key: toHex(privateKey),
      in_path: proof.pathBits.map(b => toHex(b)),
      in_siblings: proof.siblings.map(s => toHex(s)),
      change_amount: toHex(changeAmount),
      change_blinding: toHex(changeBlinding),
      change_pub_key: toHex(publicKey),
      merkle_root: toHex(merkleRoot),
      nullifier: toHex(nullifier),
      change_commitment: toHex(changeCommitment),
      recipient: toHex(BigInt(recipient)),
      withdraw_amount: toHex(amountWei),
    }
    
    // Log for CLI testing
    console.log('=== PROVER.TOML ===')
    Object.entries(circuitInputs).forEach(([k, v]) => {
      if (Array.isArray(v)) {
        console.log(`${k} = [${v.map(x => `"${x}"`).join(', ')}]`)
      } else {
        console.log(`${k} = "${v}"`)
      }
    })
    console.log('=== END ===')
    
    setStatusMsg('Generating ZK proof...')
    const proofResult = await generateProof('unshield', circuitInputs, setStatusMsg)
    
    const calls = [{
      contract_address: SHIELD_POOL_ADDRESS,
      entry_point: 'withdraw',
      calldata: [
        proofResult.calldata.length.toString(),
        ...proofResult.calldata.map(c => toHex(c)),
        toHex(merkleRoot),
        toHex(nullifier),
        toHex(changeCommitment),
        toHex(BigInt(recipient)),
        toHex(amountWei),
      ],
    }]
    
    setStatusMsg('Confirm in wallet...')
    const result = await walletObj.request({
      type: 'wallet_addInvokeTransaction',
      params: { calls },
    })
    
    await provider.waitForTransaction(result.transaction_hash)
    
    // Update notes
    let updated = notes.map(n => 
      n.commitment === selectedNote.commitment ? { ...n, spent: true } : n
    )
    
    if (changeAmount > 0n) {
      const changeLeafIndex = merkleTreeRef.current.insert(changeCommitment)
      const changeNullifier = await computeNullifier(changeCommitment, privateKey, BigInt(changeLeafIndex))
      updated.push({
        amount: changeAmount.toString(),
        assetId: STRK_ADDRESS,
        blinding: changeBlinding.toString(),
        ownerKey: publicKey.toString(),
        commitment: changeCommitment.toString(),
        nullifier: changeNullifier.toString(),
        leafIndex: changeLeafIndex,
        spent: false,
        createdAt: Date.now(),
      })
    }
    
    saveNotes(updated)
    setNotes(updated)
    setTxHash(result.transaction_hash)
    setStatus('success')
    setStatusMsg('Withdrawal successful!')
    setAmount('')
    setRecipient('')
  } catch (err: any) {
    console.error('Withdraw error:', err)
    setStatus('error')
    setStatusMsg(err.message || 'Failed')
  }
}
  
  // ==================== TRANSFER & TRANSACT (placeholders) ====================
  async function handleTransfer() {
    setStatus('error')
    setStatusMsg('Transfer not implemented yet')
  }
  
  async function handleTransact() {
    setStatus('error')
    setStatusMsg('Transact not implemented yet')
  }
  
  // ==================== UI ====================
  function copyPublicKey() {
    navigator.clipboard.writeText(toHex(publicKey))
    setCopied(true)
    setTimeout(() => setCopied(false), 2000)
  }
  
  function resetStatus() {
    setStatus('idle')
    setStatusMsg('')
    setTxHash(null)
  }
  
  // Clear all data (for debugging)
  function clearAllData() {
    localStorage.removeItem(`shieldnet_notes_${STORAGE_VERSION}`)
    localStorage.removeItem(`shieldnet_privkey_${STORAGE_VERSION}`)
    window.location.reload()
  }
  
  const isLoading = status === 'loading'
  
  return (
    <div className="min-h-screen p-4">
      <header className="max-w-2xl mx-auto flex items-center justify-between py-4 border-b border-slate-700">
        <div className="flex items-center gap-2">
          <Shield className="w-8 h-8 text-green-500" />
          <span className="text-xl font-bold">ShieldNet</span>
        </div>
        
        {isConnected && address ? (
          <div className="flex items-center gap-3">
            <span className="px-3 py-2 bg-slate-800 rounded-lg text-sm font-mono">
              {truncateAddress(address)}
            </span>
            <button onClick={disconnectWallet} className="p-2 bg-slate-800 rounded-lg hover:bg-slate-700">
              <LogOut className="w-5 h-5" />
            </button>
          </div>
        ) : (
          <button
            onClick={connectWallet}
            disabled={isLoading || !isInitialized}
            className="flex items-center gap-2 px-4 py-2 bg-green-600 rounded-lg hover:bg-green-500 font-medium disabled:opacity-50"
          >
            <Wallet className="w-5 h-5" />
            {isInitialized ? 'Connect' : 'Loading...'}
          </button>
        )}
      </header>
      
      <main className="max-w-2xl mx-auto py-8">
        <div className="text-center mb-8">
          <h1 className="text-4xl font-bold mb-2 bg-gradient-to-r from-green-400 to-green-600 bg-clip-text text-transparent">
            ShieldNet
          </h1>
          <p className="text-slate-400">Private transactions on Starknet</p>
        </div>
        
        <div className="flex gap-1 bg-slate-800 p-1 rounded-xl mb-6">
          {[
            { id: 'deposit', label: 'Shield', icon: ArrowDownToLine },
            { id: 'withdraw', label: 'Unshield', icon: ArrowUpFromLine },
            { id: 'transfer', label: 'Transfer', icon: ArrowLeftRight },
            { id: 'transact', label: 'Transact', icon: Zap },
            { id: 'notes', label: 'Notes', icon: Wallet },
          ].map(tab => {
            const Icon = tab.icon
            const isActive = activeTab === tab.id
            return (
              <button
                key={tab.id}
                onClick={() => { setActiveTab(tab.id as Tab); resetStatus() }}
                className={`flex-1 flex items-center justify-center gap-2 py-3 rounded-lg font-medium transition ${
                  isActive ? 'bg-green-600 text-white' : 'text-slate-400 hover:text-white hover:bg-slate-700'
                }`}
              >
                <Icon className="w-4 h-4" />
                <span className="hidden sm:inline">{tab.label}</span>
              </button>
            )
          })}
        </div>
        
        {status !== 'idle' && (
          <div className={`mb-6 flex items-center gap-3 p-4 rounded-xl ${
            status === 'error' ? 'bg-red-500/10 text-red-400' :
            status === 'success' ? 'bg-green-500/10 text-green-400' :
            'bg-slate-800'
          }`}>
            {isLoading && <Loader2 className="w-5 h-5 animate-spin" />}
            {status === 'success' && <CheckCircle className="w-5 h-5" />}
            {status === 'error' && <AlertCircle className="w-5 h-5" />}
            <span className="flex-1">{statusMsg}</span>
            {!isLoading && (
              <button onClick={resetStatus} className="text-sm underline">Dismiss</button>
            )}
          </div>
        )}
        
        {txHash && (
          <div className="mb-6 text-sm text-slate-400 text-center">
            Tx: <a href={`https://sepolia.starkscan.co/tx/${txHash}`} target="_blank" className="text-green-400 underline">
              {truncateAddress(txHash)}
            </a>
          </div>
        )}
        
        <div className="bg-slate-800/50 border border-slate-700 rounded-2xl p-6">
          {!isConnected ? (
            <div className="text-center py-12">
              <Shield className="w-16 h-16 mx-auto mb-4 text-slate-600" />
              <p className="text-slate-400">Connect wallet to continue</p>
            </div>
          ) : activeTab === 'deposit' ? (
            <div className="space-y-6">
              <div className="text-center">
                <ArrowDownToLine className="w-12 h-12 mx-auto mb-2 text-green-500" />
                <h2 className="text-xl font-bold">Shield Tokens</h2>
                <p className="text-slate-400 text-sm">Deposit STRK into the privacy pool</p>
              </div>
              
              <div className="bg-slate-900 rounded-xl p-4">
                <div className="text-sm text-slate-400">Shielded Balance</div>
                <div className="text-2xl font-bold text-green-400">{formatUnits(shieldedBalance, 18)} STRK</div>
              </div>
              
              <div>
                <label className="block text-sm text-slate-400 mb-2">Amount</label>
                <input
                  type="number"
                  value={amount}
                  onChange={e => setAmount(e.target.value)}
                  placeholder="0.0"
                  disabled={isLoading}
                  className="w-full bg-slate-900 border border-slate-600 rounded-xl px-4 py-3 text-lg focus:outline-none focus:border-green-500 disabled:opacity-50"
                />
              </div>
              
              <button
                onClick={handleDeposit}
                disabled={isLoading || !amount}
                className="w-full py-4 rounded-xl bg-green-600 hover:bg-green-500 disabled:bg-slate-700 disabled:text-slate-500 font-semibold"
              >
                {isLoading ? <Loader2 className="w-5 h-5 animate-spin mx-auto" /> : 'Shield Tokens'}
              </button>
            </div>
            
          ) : activeTab === 'withdraw' ? (
            <div className="space-y-6">
              <div className="text-center">
                <ArrowUpFromLine className="w-12 h-12 mx-auto mb-2 text-green-500" />
                <h2 className="text-xl font-bold">Unshield Tokens</h2>
                <p className="text-slate-400 text-sm">Withdraw to public address</p>
              </div>
              
              <div className="bg-slate-900 rounded-xl p-4">
                <div className="text-sm text-slate-400">Available</div>
                <div className="text-2xl font-bold text-green-400">{formatUnits(shieldedBalance, 18)} STRK</div>
                <div className="text-sm text-slate-500">{unspentNotes.length} notes</div>
              </div>
              
              <div>
                <label className="block text-sm text-slate-400 mb-2">Amount</label>
                <input
                  type="number"
                  value={amount}
                  onChange={e => setAmount(e.target.value)}
                  placeholder="0.0"
                  disabled={isLoading}
                  className="w-full bg-slate-900 border border-slate-600 rounded-xl px-4 py-3 focus:outline-none focus:border-green-500 disabled:opacity-50"
                />
              </div>
              
              <div>
                <label className="block text-sm text-slate-400 mb-2">Recipient Address</label>
                <input
                  type="text"
                  value={recipient}
                  onChange={e => setRecipient(e.target.value)}
                  placeholder="0x..."
                  disabled={isLoading}
                  className="w-full bg-slate-900 border border-slate-600 rounded-xl px-4 py-3 font-mono text-sm focus:outline-none focus:border-green-500 disabled:opacity-50"
                />
                <button onClick={() => setRecipient(address || '')} className="text-sm text-green-500 mt-2">
                  Use my address
                </button>
              </div>
              
              <button
                onClick={handleWithdraw}
                disabled={isLoading || !amount || !recipient}
                className="w-full py-4 rounded-xl bg-green-600 hover:bg-green-500 disabled:bg-slate-700 disabled:text-slate-500 font-semibold"
              >
                {isLoading ? <Loader2 className="w-5 h-5 animate-spin mx-auto" /> : 'Unshield Tokens'}
              </button>
              
              <p className="text-xs text-slate-500 text-center">⚠️ Proof generation takes 30-60 seconds</p>
            </div>
            
          ) : activeTab === 'notes' ? (
            <div className="space-y-6">
              <div className="text-center">
                <Wallet className="w-12 h-12 mx-auto mb-2 text-green-500" />
                <h2 className="text-xl font-bold">Your Notes</h2>
              </div>
              
              <div className="bg-slate-900 rounded-xl p-4">
                <div className="flex items-center justify-between mb-2">
                  <div className="flex items-center gap-2 text-sm text-slate-400">
                    <Key className="w-4 h-4" />
                    Your Public Key
                  </div>
                  <button onClick={copyPublicKey} className="text-green-500">
                    {copied ? <Check className="w-4 h-4" /> : <Copy className="w-4 h-4" />}
                  </button>
                </div>
                <div className="font-mono text-xs bg-slate-800 rounded p-2 break-all">
                  {toHex(publicKey)}
                </div>
              </div>
              
              <div className="bg-gradient-to-r from-green-600/20 to-green-500/10 rounded-xl p-6 border border-green-500/30">
                <div className="text-sm text-green-300">Total Shielded</div>
                <div className="text-3xl font-bold">{formatUnits(shieldedBalance, 18)} STRK</div>
              </div>
              
              <div>
                <h3 className="font-semibold mb-3">Notes ({unspentNotes.length} unspent)</h3>
                {notes.length === 0 ? (
                  <div className="text-center py-8 bg-slate-900 rounded-xl text-slate-400">
                    No notes yet. Deposit to create your first note.
                  </div>
                ) : (
                  <div className="space-y-2 max-h-64 overflow-y-auto">
                    {notes.map((note, i) => (
                      <div key={i} className={`p-4 rounded-xl border ${
                        note.spent ? 'bg-slate-900/50 border-slate-800 opacity-50' : 'bg-slate-900 border-slate-700'
                      }`}>
                        <div className="flex justify-between items-center">
                          <span className="font-semibold">{formatUnits(BigInt(note.amount), 18)} STRK</span>
                          <span className={`text-xs px-2 py-1 rounded ${
                            note.spent ? 'bg-red-500/20 text-red-400' : 'bg-green-500/20 text-green-400'
                          }`}>
                            {note.spent ? 'Spent' : 'Available'}
                          </span>
                        </div>
                        <div className="text-xs text-slate-500 mt-1">
                          Index: {note.leafIndex} • {new Date(note.createdAt).toLocaleString()}
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
              
              <button
                onClick={clearAllData}
                className="w-full py-2 rounded-lg bg-red-600/20 text-red-400 hover:bg-red-600/30 text-sm"
              >
                Clear All Data (Debug)
              </button>
            </div>
          ) : (
            <div className="text-center py-12 text-slate-400">
              {activeTab === 'transfer' ? 'Transfer coming soon' : 'Transact coming soon'}
            </div>
          )}
        </div>
        
        <p className="text-center text-slate-500 text-sm mt-6">Starknet Sepolia • Storage: {STORAGE_VERSION}</p>
      </main>
    </div>
  )
}