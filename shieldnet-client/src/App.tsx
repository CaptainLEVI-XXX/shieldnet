import { useState, useEffect, useMemo, useRef } from 'react'
import { connect, disconnect } from '@starknet-io/get-starknet'
import { RpcProvider } from 'starknet'
import { buildPoseidon } from 'circomlibjs'
import { 
  Shield, Wallet, LogOut, Loader2, CheckCircle, AlertCircle, 
  ArrowDownToLine, ArrowUpFromLine, Send, Key, Copy, Check,
  Zap, Eye, EyeOff, RefreshCw, ExternalLink, Layers
} from 'lucide-react'
import { init } from 'garaga'

// ============================================================================
// CONFIGURATION
// ============================================================================
const SHIELD_POOL_ADDRESS = '0x42db592b9fc606a5a0297a88a2cd7cd74f213e832557ef1d2d786df6e6c824'
const STRK_ADDRESS = '0x04718f5a0Fc34cC1AF16A1cdee98fFB20C31f5cD61D6Ab07201858f4287c938D'
const RPC_URL = 'https://starknet-sepolia.infura.io/v3/'
const RELAYER_URL = 'http://localhost:3001'
const CIRCUIT_MERKLE_DEPTH = 5
const MASK_251 = (1n << 251n) - 1n
const STORAGE_VERSION = 'v4'

// ============================================================================
// BN254 POSEIDON WITH MASKING
// ============================================================================
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

function maskToStarkField(value: bigint): bigint {
  return value & MASK_251
}

async function bn254HashRaw(inputs: bigint[]): Promise<bigint> {
  const poseidon = await initPoseidon()
  const hash = poseidon(inputs.map(x => x.toString()))
  return F2BigInt(poseidon, hash)
}

async function hash2(a: bigint, b: bigint): Promise<bigint> {
  const raw = await bn254HashRaw([a, b])
  return maskToStarkField(raw)
}

async function hash3(a: bigint, b: bigint, c: bigint): Promise<bigint> {
  const raw = await bn254HashRaw([a, b, c])
  return maskToStarkField(raw)
}

async function hash4(a: bigint, b: bigint, c: bigint, d: bigint): Promise<bigint> {
  const raw = await bn254HashRaw([a, b, c, d])
  return maskToStarkField(raw)
}

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
  return result & MASK_251
}

async function derivePublicKey(privKey: bigint): Promise<bigint> {
  const raw = await bn254HashRaw([privKey])
  return maskToStarkField(raw)
}

// ============================================================================
// MERKLE TREE
// ============================================================================
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

// ============================================================================
// STORAGE
// ============================================================================
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

// ============================================================================
// UTILS
// ============================================================================
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

// ============================================================================
// PROOF GENERATION
// ============================================================================
async function generateProof(
  circuitName: string,
  inputs: Record<string, any>,
  onStatus: (msg: string) => void
): Promise<{ calldata: bigint[] }> {
  onStatus('Loading proof system...')
  
  try {
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
    
    onStatus('Initializing WASM...')
    
    const circuitRes = await fetch(`/circuits/${circuitName}.json`)
    if (!circuitRes.ok) throw new Error(`Circuit ${circuitName}.json not found`)
    const circuit = await circuitRes.json()
    
    const vkRes = await fetch(`/circuits/${circuitName}_vk.bin`)
    if (!vkRes.ok) throw new Error(`VK ${circuitName}_vk.bin not found`)
    const vk = new Uint8Array(await vkRes.arrayBuffer())
    
    const acvmUrl = new URL('@noir-lang/acvm_js/web/acvm_js_bg.wasm', import.meta.url).href
    const noircUrl = new URL('@noir-lang/noirc_abi/web/noirc_abi_wasm_bg.wasm', import.meta.url).href
    
    await Promise.all([
      initACVM(fetch(acvmUrl)),
      initNoirC(fetch(noircUrl)),
    ])
    
    await initGaraga()
    
    onStatus('Generating witness...')
    
    const noir = new Noir({
      bytecode: circuit.bytecode,
      abi: circuit.abi as any,
      debug_symbols: '',
      file_map: {} as any,
    })
    
    const { witness } = await noir.execute(inputs)
    
    onStatus('Generating ZK proof (2-3 minutes)...')
    
    const backend = new UltraHonkBackend(circuit.bytecode, { threads: 1 })
    const proof = await backend.generateProof(witness, { starknetZK: true })
    backend.destroy()
    
    onStatus('Preparing calldata...')
    
    await init()
    
    const calldata = getZKHonkCallData(
      proof.proof,
      flattenFieldsAsArray(proof.publicInputs),
      vk,
      1
    )
    
    return { calldata: calldata.slice(1) }
    
  } catch (error: any) {
    throw new Error(`Proof generation failed: ${error.message}`)
  }
}

// ============================================================================
// RELAYER API
// ============================================================================
async function relayTransaction(
  type: 'withdraw' | 'transfer',
  calldata: string[],
  publicInputs: Record<string, any>
): Promise<string> {
  const response = await fetch(`${RELAYER_URL}/relay`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      type,
      calldata,
      public_inputs: publicInputs,
    }),
  })
  
  const data = await response.json()
  
  if (!response.ok) {
    throw new Error(data.error || data.details || 'Relay failed')
  }
  
  return data.txHash
}

async function checkRelayerHealth(): Promise<boolean> {
  try {
    const response = await fetch(`${RELAYER_URL}/health`)
    return response.ok
  } catch {
    return false
  }
}

// ============================================================================
// MAIN APP
// ============================================================================
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
  const [relayerOnline, setRelayerOnline] = useState(false)
  
  const [depositAmount, setDepositAmount] = useState('')
  const [withdrawAmount, setWithdrawAmount] = useState('')
  const [withdrawRecipient, setWithdrawRecipient] = useState('')
  const [transferAmount, setTransferAmount] = useState('')
  const [transferRecipientKey, setTransferRecipientKey] = useState('')
  const [showPrivateKey, setShowPrivateKey] = useState(false)
  const [copied, setCopied] = useState<string | null>(null)
  
  const [publicKey, setPublicKey] = useState<bigint>(0n)
  const [isInitialized, setIsInitialized] = useState(false)
  const privateKey = useMemo(() => getOrCreatePrivateKey(), [])
  
  const merkleTreeRef = useRef<MerkleTree>(new MerkleTree(CIRCUIT_MERKLE_DEPTH))
  
  useEffect(() => {
    async function initApp() {
      await initPoseidon()
      const pubKey = await derivePublicKey(privateKey)
      setPublicKey(pubKey)
      
      const loaded = loadNotes()
      setNotes(loaded)
      
      const tree = new MerkleTree(CIRCUIT_MERKLE_DEPTH)
      await tree.init()
      
      for (const note of loaded) {
        tree.insert(BigInt(note.commitment))
      }
      merkleTreeRef.current = tree
      
      const online = await checkRelayerHealth()
      setRelayerOnline(online)
      
      setIsInitialized(true)
    }
    initApp()
  }, [privateKey])
  
  useEffect(() => {
    const interval = setInterval(async () => {
      const online = await checkRelayerHealth()
      setRelayerOnline(online)
    }, 10000)
    return () => clearInterval(interval)
  }, [])
  
  const unspentNotes = notes.filter(n => !n.spent)
  const shieldedBalance = unspentNotes.reduce((sum, n) => sum + BigInt(n.amount), 0n)
  
  async function connectWallet() {
    try {
      setStatus('loading')
      setStatusMsg('Connecting wallet...')
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
  
  async function handleDeposit() {
    if (!walletObj || !address || !isInitialized) return
    if (!depositAmount || parseUnits(depositAmount, 18) <= 0n) {
      setStatus('error')
      setStatusMsg('Enter a valid amount')
      return
    }
    
    try {
      setStatus('loading')
      setStatusMsg('Computing commitment...')
      
      const amountWei = parseUnits(depositAmount, 18)
      const blinding = randomFieldElement()
      const assetId = BigInt(STRK_ADDRESS)
      
      const commitment = await computeCommitment(amountWei, assetId, blinding, privateKey)
      
      const STARK_PRIME = BigInt('0x800000000000011000000000000000000000000000000000000000000000001')
      if (commitment >= STARK_PRIME) {
        throw new Error('Commitment exceeds Starknet field')
      }
      
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
      setDepositAmount('')
    } catch (err: any) {
      setStatus('error')
      setStatusMsg(err.message || 'Deposit failed')
    }
  }

  async function handleWithdraw() {
    if (!isInitialized) return
    if (!withdrawAmount || !withdrawRecipient) {
      setStatus('error')
      setStatusMsg('Enter amount and recipient')
      return
    }
    
    if (!relayerOnline) {
      setStatus('error')
      setStatusMsg('Relayer is offline')
      return
    }
    
    const amountWei = parseUnits(withdrawAmount, 18)
    
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
        recipient: toHex(BigInt(withdrawRecipient)),
        withdraw_amount: toHex(amountWei),
        relayer_fee: toHex(0n),
      }
      
      setStatusMsg('Generating ZK proof...')
      const proofResult = await generateProof('unshield', circuitInputs, setStatusMsg)
      
      const amountLow = (amountWei & ((1n << 128n) - 1n)).toString()
      const amountHigh = (amountWei >> 128n).toString()
      
      const calldata = [
        proofResult.calldata.length.toString(),
        ...proofResult.calldata.map(x => x.toString()),
        toHex(merkleRoot),
        toHex(nullifier),
        toHex(changeCommitment),
        withdrawRecipient,
        amountLow,
        amountHigh,
        '0x0',
        '0', '0',
      ]
      
      setStatusMsg('Sending to relayer...')
      
      const finalTxHash = await relayTransaction('withdraw', calldata, {
        merkle_root: toHex(merkleRoot),
        nullifier: toHex(nullifier),
        change_commitment: toHex(changeCommitment),
        recipient: withdrawRecipient,
        amount_low: amountLow,
        amount_high: amountHigh,
      })
      
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
      setTxHash(finalTxHash)
      setStatus('success')
      setStatusMsg('Withdrawal successful!')
      setWithdrawAmount('')
      setWithdrawRecipient('')
    } catch (err: any) {
      setStatus('error')
      setStatusMsg(err.message || 'Withdrawal failed')
    }
  }

  async function handleTransfer() {
    if (!isInitialized) return
    if (!transferAmount || !transferRecipientKey) {
      setStatus('error')
      setStatusMsg('Enter amount and recipient public key')
      return
    }
    
    if (!relayerOnline) {
      setStatus('error')
      setStatusMsg('Relayer is offline')
      return
    }
    
    const amountWei = parseUnits(transferAmount, 18)
    
    try {
      setStatus('loading')
      setStatusMsg('Selecting note...')
      
      const selectedNote = unspentNotes.find(n => BigInt(n.amount) >= amountWei)
      if (!selectedNote) throw new Error('No note with sufficient balance')
      
      const changeAmount = BigInt(selectedNote.amount) - amountWei
      
      const out1Blinding = randomFieldElement()
      const out1PubKey = BigInt(transferRecipientKey)
      const commitment1 = await computeCommitment(amountWei, BigInt(STRK_ADDRESS), out1Blinding, out1PubKey)
      
      const out2Blinding = randomFieldElement()
      const commitment2 = changeAmount > 0n
        ? await computeCommitment(changeAmount, BigInt(STRK_ADDRESS), out2Blinding, publicKey)
        : 0n
      
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
        out1_amount: toHex(amountWei),
        out1_blinding: toHex(out1Blinding),
        out1_pub_key: toHex(out1PubKey),
        out2_amount: toHex(changeAmount),
        out2_blinding: toHex(out2Blinding),
        out2_pub_key: toHex(publicKey),
        merkle_root: toHex(merkleRoot),
        nullifier: toHex(nullifier),
        commitment_1: toHex(commitment1),
        commitment_2: toHex(commitment2),
        relayer_fee: toHex(0n),
      }
      
      setStatusMsg('Generating ZK proof...')
      const proofResult = await generateProof('transfer', circuitInputs, setStatusMsg)
      
      const encryptedNote1 = [toHex(commitment1), toHex(out1Blinding), toHex(amountWei)]
      const encryptedNote2 = changeAmount > 0n 
        ? [toHex(commitment2), toHex(out2Blinding), toHex(changeAmount)]
        : []
      
      const calldata = [
        proofResult.calldata.length.toString(),
        ...proofResult.calldata.map(x => x.toString()),
        toHex(merkleRoot),
        toHex(nullifier),
        toHex(commitment1),
        toHex(commitment2),
        '0x0',
        '0', '0',
        encryptedNote1.length.toString(),
        ...encryptedNote1,
        encryptedNote2.length.toString(),
        ...encryptedNote2,
      ]
      
      setStatusMsg('Sending to relayer...')
      
      const finalTxHash = await relayTransaction('transfer', calldata, {
        merkle_root: toHex(merkleRoot),
        nullifier: toHex(nullifier),
        commitment_1: toHex(commitment1),
        commitment_2: toHex(commitment2),
        encrypted_note_1: encryptedNote1,
        encrypted_note_2: encryptedNote2,
      })
      
      let updated = notes.map(n => 
        n.commitment === selectedNote.commitment ? { ...n, spent: true } : n
      )
      
      merkleTreeRef.current.insert(commitment1)
      
      if (changeAmount > 0n) {
        const changeLeafIndex = merkleTreeRef.current.insert(commitment2)
        const changeNullifier = await computeNullifier(commitment2, privateKey, BigInt(changeLeafIndex))
        updated.push({
          amount: changeAmount.toString(),
          assetId: STRK_ADDRESS,
          blinding: out2Blinding.toString(),
          ownerKey: publicKey.toString(),
          commitment: commitment2.toString(),
          nullifier: changeNullifier.toString(),
          leafIndex: changeLeafIndex,
          spent: false,
          createdAt: Date.now(),
        })
      }
      
      saveNotes(updated)
      setNotes(updated)
      setTxHash(finalTxHash)
      setStatus('success')
      setStatusMsg('Transfer successful!')
      setTransferAmount('')
      setTransferRecipientKey('')
    } catch (err: any) {
      setStatus('error')
      setStatusMsg(err.message || 'Transfer failed')
    }
  }
  
  function copyToClipboard(text: string, key: string) {
    navigator.clipboard.writeText(text)
    setCopied(key)
    setTimeout(() => setCopied(null), 2000)
  }
  
  function resetStatus() {
    setStatus('idle')
    setStatusMsg('')
    setTxHash(null)
  }
  
  function clearAllData() {
    if (confirm('This will delete all your notes and private key. Are you sure?')) {
      localStorage.removeItem(`shieldnet_notes_${STORAGE_VERSION}`)
      localStorage.removeItem(`shieldnet_privkey_${STORAGE_VERSION}`)
      window.location.reload()
    }
  }
  
  const isLoading = status === 'loading'

  // Colors
  const colors = {
    bg: '#0f172a',
    card: '#1e293b',
    cardBorder: '#334155',
    primary: '#10b981',
    primaryHover: '#34d399',
    secondary: '#3b82f6',
    purple: '#8b5cf6',
    orange: '#f59e0b',
    red: '#ef4444',
    textWhite: '#ffffff',
    textLight: '#e2e8f0',
    textMuted: '#94a3b8',
    inputBg: '#0f172a',
  }
  
  return (
    <div style={{ 
      minHeight: '100vh', 
      backgroundColor: colors.bg,
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'flex-start',
      padding: '0',
      margin: '0',
    }}>
      {/* Header */}
      <header style={{ 
        width: '100%',
        maxWidth: '480px',
        padding: '16px 20px',
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        borderBottom: `1px solid ${colors.cardBorder}`,
        boxSizing: 'border-box',
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          <div style={{ 
            width: '36px', 
            height: '36px', 
            backgroundColor: colors.primary, 
            borderRadius: '8px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center'
          }}>
            <Shield style={{ width: '20px', height: '20px', color: colors.textWhite }} />
          </div>
          <span style={{ fontSize: '18px', fontWeight: '700', color: colors.textWhite }}>ShieldNet</span>
        </div>
        
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          <div style={{ 
            display: 'flex', 
            alignItems: 'center', 
            gap: '6px',
            padding: '6px 10px',
            backgroundColor: colors.card,
            borderRadius: '6px',
            border: `1px solid ${colors.cardBorder}`
          }}>
            <div style={{ 
              width: '8px', 
              height: '8px', 
              borderRadius: '50%', 
              backgroundColor: relayerOnline ? colors.primary : colors.red 
            }} />
            <span style={{ fontSize: '12px', color: colors.textMuted }}>Relayer</span>
          </div>
          
          {isConnected && address ? (
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <span style={{ 
                padding: '6px 10px',
                backgroundColor: colors.card,
                borderRadius: '6px',
                fontSize: '13px',
                fontFamily: 'monospace',
                color: colors.textWhite,
                border: `1px solid ${colors.cardBorder}`
              }}>
                {truncateAddress(address)}
              </span>
              <button 
                onClick={disconnectWallet}
                style={{ 
                  padding: '6px',
                  backgroundColor: colors.card,
                  border: `1px solid ${colors.cardBorder}`,
                  borderRadius: '6px',
                  cursor: 'pointer',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center'
                }}
              >
                <LogOut style={{ width: '16px', height: '16px', color: colors.red }} />
              </button>
            </div>
          ) : (
            <button
              onClick={connectWallet}
              disabled={isLoading || !isInitialized}
              style={{ 
                display: 'flex',
                alignItems: 'center',
                gap: '6px',
                padding: '8px 16px',
                backgroundColor: colors.primary,
                color: colors.textWhite,
                border: 'none',
                borderRadius: '6px',
                fontWeight: '600',
                fontSize: '13px',
                cursor: 'pointer',
                opacity: (isLoading || !isInitialized) ? 0.5 : 1
              }}
            >
              <Wallet style={{ width: '16px', height: '16px' }} />
              {isInitialized ? 'Connect' : 'Loading...'}
            </button>
          )}
        </div>
      </header>
      
      {/* Main Content */}
      <main style={{ 
        width: '100%',
        maxWidth: '480px',
        padding: '20px',
        boxSizing: 'border-box',
      }}>
        {/* Balance Card */}
        <div style={{ 
          padding: '20px',
          backgroundColor: `${colors.primary}15`,
          border: `1px solid ${colors.primary}40`,
          borderRadius: '12px',
          marginBottom: '20px'
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '8px' }}>
            <Shield style={{ width: '18px', height: '18px', color: colors.primary }} />
            <span style={{ fontSize: '14px', color: colors.primary, fontWeight: '500' }}>Shielded Balance</span>
          </div>
          <p style={{ fontSize: '28px', fontWeight: '700', color: colors.textWhite, margin: '0 0 4px 0' }}>
            {formatUnits(shieldedBalance, 18)} <span style={{ fontSize: '16px', color: colors.textMuted }}>STRK</span>
          </p>
          <p style={{ fontSize: '13px', color: colors.textMuted, margin: 0 }}>{unspentNotes.length} notes available</p>
        </div>
        
        {/* Tabs */}
        <div style={{ 
          display: 'flex',
          gap: '4px',
          padding: '4px',
          backgroundColor: colors.card,
          borderRadius: '10px',
          marginBottom: '20px',
          border: `1px solid ${colors.cardBorder}`
        }}>
          {([
            { id: 'deposit', label: 'Shield', icon: ArrowDownToLine },
            { id: 'withdraw', label: 'Unshield', icon: ArrowUpFromLine },
            { id: 'transfer', label: 'Transfer', icon: Send },
            { id: 'transact', label: 'Transact', icon: Layers },
            { id: 'notes', label: 'Notes', icon: Wallet },
          ] as const).map(tab => {
            const Icon = tab.icon
            const isActive = activeTab === tab.id
            return (
              <button
                key={tab.id}
                onClick={() => { setActiveTab(tab.id); resetStatus() }}
                style={{ 
                  flex: 1,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  gap: '4px',
                  padding: '10px 4px',
                  backgroundColor: isActive ? colors.primary : 'transparent',
                  color: isActive ? colors.textWhite : colors.textMuted,
                  border: 'none',
                  borderRadius: '6px',
                  fontSize: '11px',
                  fontWeight: '600',
                  cursor: 'pointer',
                }}
              >
                <Icon style={{ width: '14px', height: '14px' }} />
                <span style={{ display: 'none' }}>{tab.label}</span>
              </button>
            )
          })}
        </div>
        
        {/* Status Message */}
        {status !== 'idle' && (
          <div style={{ 
            display: 'flex',
            alignItems: 'center',
            gap: '10px',
            padding: '12px',
            backgroundColor: status === 'error' ? `${colors.red}20` : status === 'success' ? `${colors.primary}20` : `${colors.secondary}20`,
            border: `1px solid ${status === 'error' ? `${colors.red}50` : status === 'success' ? `${colors.primary}50` : `${colors.secondary}50`}`,
            borderRadius: '10px',
            marginBottom: '16px'
          }}>
            {isLoading && <Loader2 style={{ width: '18px', height: '18px', color: colors.secondary, animation: 'spin 1s linear infinite' }} />}
            {status === 'success' && <CheckCircle style={{ width: '18px', height: '18px', color: colors.primary }} />}
            {status === 'error' && <AlertCircle style={{ width: '18px', height: '18px', color: colors.red }} />}
            <span style={{ flex: 1, fontSize: '14px', color: status === 'error' ? colors.red : status === 'success' ? colors.primary : colors.secondary }}>
              {statusMsg}
            </span>
            {!isLoading && (
              <button onClick={resetStatus} style={{ background: 'none', border: 'none', color: colors.textMuted, cursor: 'pointer', fontSize: '16px' }}>×</button>
            )}
          </div>
        )}
        
        {/* Transaction Link */}
        {txHash && (
          <div style={{ 
            padding: '12px',
            backgroundColor: colors.card,
            borderRadius: '10px',
            marginBottom: '16px',
            border: `1px solid ${colors.cardBorder}`
          }}>
            <a
              href={`https://sepolia.starkscan.co/tx/${txHash}`}
              target="_blank"
              rel="noopener noreferrer"
              style={{ 
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                color: colors.primary,
                textDecoration: 'none',
                fontSize: '14px'
              }}
            >
              <span>View Transaction</span>
              <ExternalLink style={{ width: '16px', height: '16px' }} />
            </a>
          </div>
        )}
        
        {/* Main Card */}
        <div style={{ 
          backgroundColor: colors.card,
          border: `1px solid ${colors.cardBorder}`,
          borderRadius: '12px',
          padding: '24px'
        }}>
          {/* DEPOSIT TAB */}
          {activeTab === 'deposit' && (
            <div>
              <div style={{ textAlign: 'center', paddingBottom: '20px', borderBottom: `1px solid ${colors.cardBorder}`, marginBottom: '20px' }}>
                <div style={{ 
                  width: '50px', 
                  height: '50px', 
                  margin: '0 auto 12px',
                  backgroundColor: `${colors.primary}20`,
                  borderRadius: '12px',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center'
                }}>
                  <ArrowDownToLine style={{ width: '24px', height: '24px', color: colors.primary }} />
                </div>
                <h2 style={{ fontSize: '18px', fontWeight: '600', color: colors.textWhite, margin: '0 0 4px' }}>Shield Tokens</h2>
                <p style={{ fontSize: '14px', color: colors.textMuted, margin: 0 }}>Deposit STRK into privacy pool</p>
              </div>
              
              {!isConnected ? (
                <div style={{ textAlign: 'center', padding: '40px 0' }}>
                  <Wallet style={{ width: '40px', height: '40px', color: colors.textMuted, margin: '0 auto 12px' }} />
                  <p style={{ color: colors.textMuted, fontSize: '14px' }}>Connect wallet to deposit</p>
                </div>
              ) : (
                <>
                  <div style={{ marginBottom: '20px' }}>
                    <label style={{ display: 'block', fontSize: '14px', color: colors.textLight, marginBottom: '8px' }}>Amount (STRK)</label>
                    <input
                      type="number"
                      value={depositAmount}
                      onChange={e => setDepositAmount(e.target.value)}
                      placeholder="0.0"
                      disabled={isLoading}
                      style={{ 
                        width: '100%',
                        padding: '14px',
                        backgroundColor: colors.inputBg,
                        border: `1px solid ${colors.cardBorder}`,
                        borderRadius: '10px',
                        color: colors.textWhite,
                        fontSize: '16px',
                        outline: 'none',
                        boxSizing: 'border-box'
                      }}
                    />
                  </div>
                  
                  <button
                    onClick={handleDeposit}
                    disabled={isLoading || !depositAmount}
                    style={{ 
                      width: '100%',
                      padding: '14px',
                      backgroundColor: (isLoading || !depositAmount) ? colors.cardBorder : colors.primary,
                      color: colors.textWhite,
                      border: 'none',
                      borderRadius: '10px',
                      fontSize: '16px',
                      fontWeight: '600',
                      cursor: (isLoading || !depositAmount) ? 'not-allowed' : 'pointer'
                    }}
                  >
                    {isLoading ? 'Processing...' : 'Shield Tokens'}
                  </button>
                </>
              )}
            </div>
          )}
          
          {/* WITHDRAW TAB */}
          {activeTab === 'withdraw' && (
            <div>
              <div style={{ textAlign: 'center', paddingBottom: '20px', borderBottom: `1px solid ${colors.cardBorder}`, marginBottom: '20px' }}>
                <div style={{ 
                  width: '50px', 
                  height: '50px', 
                  margin: '0 auto 12px',
                  backgroundColor: `${colors.secondary}20`,
                  borderRadius: '12px',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center'
                }}>
                  <ArrowUpFromLine style={{ width: '24px', height: '24px', color: colors.secondary }} />
                </div>
                <h2 style={{ fontSize: '18px', fontWeight: '600', color: colors.textWhite, margin: '0 0 4px' }}>Unshield Tokens</h2>
                <p style={{ fontSize: '14px', color: colors.textMuted, margin: 0 }}>Withdraw via relayer anonymously</p>
              </div>
              
              {!relayerOnline && (
                <div style={{ 
                  display: 'flex',
                  alignItems: 'center',
                  gap: '8px',
                  padding: '12px',
                  backgroundColor: `${colors.orange}20`,
                  border: `1px solid ${colors.orange}50`,
                  borderRadius: '8px',
                  marginBottom: '16px'
                }}>
                  <AlertCircle style={{ width: '18px', height: '18px', color: colors.orange }} />
                  <span style={{ fontSize: '14px', color: colors.orange }}>Relayer offline</span>
                </div>
              )}
              
              <div style={{ marginBottom: '16px' }}>
                <label style={{ display: 'block', fontSize: '14px', color: colors.textLight, marginBottom: '8px' }}>Amount (STRK)</label>
                <input
                  type="number"
                  value={withdrawAmount}
                  onChange={e => setWithdrawAmount(e.target.value)}
                  placeholder="0.0"
                  disabled={isLoading}
                  style={{ 
                    width: '100%',
                    padding: '14px',
                    backgroundColor: colors.inputBg,
                    border: `1px solid ${colors.cardBorder}`,
                    borderRadius: '10px',
                    color: colors.textWhite,
                    fontSize: '16px',
                    outline: 'none',
                    boxSizing: 'border-box'
                  }}
                />
              </div>
              
              <div style={{ marginBottom: '20px' }}>
                <label style={{ display: 'block', fontSize: '14px', color: colors.textLight, marginBottom: '8px' }}>Recipient Address</label>
                <input
                  type="text"
                  value={withdrawRecipient}
                  onChange={e => setWithdrawRecipient(e.target.value)}
                  placeholder="0x..."
                  disabled={isLoading}
                  style={{ 
                    width: '100%',
                    padding: '14px',
                    backgroundColor: colors.inputBg,
                    border: `1px solid ${colors.cardBorder}`,
                    borderRadius: '10px',
                    color: colors.textWhite,
                    fontSize: '14px',
                    fontFamily: 'monospace',
                    outline: 'none',
                    boxSizing: 'border-box'
                  }}
                />
                {address && (
                  <button 
                    onClick={() => setWithdrawRecipient(address)}
                    style={{ marginTop: '8px', background: 'none', border: 'none', color: colors.secondary, fontSize: '13px', cursor: 'pointer' }}
                  >
                    Use my address
                  </button>
                )}
              </div>
              
              <button
                onClick={handleWithdraw}
                disabled={isLoading || !withdrawAmount || !withdrawRecipient || !relayerOnline}
                style={{ 
                  width: '100%',
                  padding: '14px',
                  backgroundColor: (isLoading || !withdrawAmount || !withdrawRecipient || !relayerOnline) ? colors.cardBorder : colors.secondary,
                  color: colors.textWhite,
                  border: 'none',
                  borderRadius: '10px',
                  fontSize: '16px',
                  fontWeight: '600',
                  cursor: (isLoading || !withdrawAmount || !withdrawRecipient || !relayerOnline) ? 'not-allowed' : 'pointer'
                }}
              >
                {isLoading ? 'Processing...' : 'Unshield Anonymously'}
              </button>
              
              <p style={{ textAlign: 'center', fontSize: '13px', color: colors.textMuted, marginTop: '16px' }}>
                ⚡ Proof generation takes 2-3 minutes
              </p>
            </div>
          )}
          
          {/* TRANSFER TAB */}
          {activeTab === 'transfer' && (
            <div>
              <div style={{ textAlign: 'center', paddingBottom: '20px', borderBottom: `1px solid ${colors.cardBorder}`, marginBottom: '20px' }}>
                <div style={{ 
                  width: '50px', 
                  height: '50px', 
                  margin: '0 auto 12px',
                  backgroundColor: `${colors.purple}20`,
                  borderRadius: '12px',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center'
                }}>
                  <Send style={{ width: '24px', height: '24px', color: colors.purple }} />
                </div>
                <h2 style={{ fontSize: '18px', fontWeight: '600', color: colors.textWhite, margin: '0 0 4px' }}>Private Transfer</h2>
                <p style={{ fontSize: '14px', color: colors.textMuted, margin: 0 }}>Send shielded tokens anonymously</p>
              </div>
              
              {!relayerOnline && (
                <div style={{ 
                  display: 'flex',
                  alignItems: 'center',
                  gap: '8px',
                  padding: '12px',
                  backgroundColor: `${colors.orange}20`,
                  border: `1px solid ${colors.orange}50`,
                  borderRadius: '8px',
                  marginBottom: '16px'
                }}>
                  <AlertCircle style={{ width: '18px', height: '18px', color: colors.orange }} />
                  <span style={{ fontSize: '14px', color: colors.orange }}>Relayer offline</span>
                </div>
              )}
              
              <div style={{ marginBottom: '16px' }}>
                <label style={{ display: 'block', fontSize: '14px', color: colors.textLight, marginBottom: '8px' }}>Amount (STRK)</label>
                <input
                  type="number"
                  value={transferAmount}
                  onChange={e => setTransferAmount(e.target.value)}
                  placeholder="0.0"
                  disabled={isLoading}
                  style={{ 
                    width: '100%',
                    padding: '14px',
                    backgroundColor: colors.inputBg,
                    border: `1px solid ${colors.cardBorder}`,
                    borderRadius: '10px',
                    color: colors.textWhite,
                    fontSize: '16px',
                    outline: 'none',
                    boxSizing: 'border-box'
                  }}
                />
              </div>
              
              <div style={{ marginBottom: '20px' }}>
                <label style={{ display: 'block', fontSize: '14px', color: colors.textLight, marginBottom: '8px' }}>Recipient Public Key</label>
                <input
                  type="text"
                  value={transferRecipientKey}
                  onChange={e => setTransferRecipientKey(e.target.value)}
                  placeholder="0x..."
                  disabled={isLoading}
                  style={{ 
                    width: '100%',
                    padding: '14px',
                    backgroundColor: colors.inputBg,
                    border: `1px solid ${colors.cardBorder}`,
                    borderRadius: '10px',
                    color: colors.textWhite,
                    fontSize: '14px',
                    fontFamily: 'monospace',
                    outline: 'none',
                    boxSizing: 'border-box'
                  }}
                />
                <p style={{ fontSize: '12px', color: colors.textMuted, marginTop: '8px' }}>Get from recipient's Notes tab</p>
              </div>
              
              <button
                onClick={handleTransfer}
                disabled={isLoading || !transferAmount || !transferRecipientKey || !relayerOnline}
                style={{ 
                  width: '100%',
                  padding: '14px',
                  backgroundColor: (isLoading || !transferAmount || !transferRecipientKey || !relayerOnline) ? colors.cardBorder : colors.purple,
                  color: colors.textWhite,
                  border: 'none',
                  borderRadius: '10px',
                  fontSize: '16px',
                  fontWeight: '600',
                  cursor: (isLoading || !transferAmount || !transferRecipientKey || !relayerOnline) ? 'not-allowed' : 'pointer'
                }}
              >
                {isLoading ? 'Processing...' : 'Send Privately'}
              </button>
            </div>
          )}
          
          {/* TRANSACT TAB */}
          {activeTab === 'transact' && (
            <div>
              <div style={{ textAlign: 'center', paddingBottom: '20px', borderBottom: `1px solid ${colors.cardBorder}`, marginBottom: '20px' }}>
                <div style={{ 
                  width: '50px', 
                  height: '50px', 
                  margin: '0 auto 12px',
                  backgroundColor: `${colors.orange}20`,
                  borderRadius: '12px',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center'
                }}>
                  <Layers style={{ width: '24px', height: '24px', color: colors.orange }} />
                </div>
                <h2 style={{ fontSize: '18px', fontWeight: '600', color: colors.textWhite, margin: '0 0 4px' }}>Anonymous DeFi</h2>
                <p style={{ fontSize: '14px', color: colors.textMuted, margin: 0 }}>Interact with protocols privately</p>
              </div>
              
              <div style={{ textAlign: 'center', padding: '30px 0' }}>
                <div style={{ 
                  width: '60px', 
                  height: '60px', 
                  margin: '0 auto 16px',
                  backgroundColor: `${colors.orange}15`,
                  border: `1px solid ${colors.orange}30`,
                  borderRadius: '16px',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center'
                }}>
                  <Zap style={{ width: '30px', height: '30px', color: colors.orange }} />
                </div>
                <h3 style={{ fontSize: '16px', fontWeight: '600', color: colors.textWhite, margin: '0 0 8px' }}>Coming Soon</h3>
                <p style={{ fontSize: '14px', color: colors.textMuted, maxWidth: '260px', margin: '0 auto' }}>
                  Anonymous swaps, lending, and more DeFi protocols.
                </p>
                
                <div style={{ display: 'flex', justifyContent: 'center', gap: '8px', marginTop: '16px', flexWrap: 'wrap' }}>
                  {['zkLend', 'JediSwap', 'Nostra'].map(p => (
                    <span key={p} style={{ 
                      padding: '6px 12px',
                      backgroundColor: colors.inputBg,
                      border: `1px solid ${colors.cardBorder}`,
                      borderRadius: '6px',
                      fontSize: '12px',
                      color: colors.textMuted
                    }}>
                      {p}
                    </span>
                  ))}
                </div>
              </div>
            </div>
          )}
          
          {/* NOTES TAB */}
          {activeTab === 'notes' && (
            <div>
              <div style={{ textAlign: 'center', paddingBottom: '20px', borderBottom: `1px solid ${colors.cardBorder}`, marginBottom: '20px' }}>
                <div style={{ 
                  width: '50px', 
                  height: '50px', 
                  margin: '0 auto 12px',
                  backgroundColor: `${colors.primary}20`,
                  borderRadius: '12px',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center'
                }}>
                  <Wallet style={{ width: '24px', height: '24px', color: colors.primary }} />
                </div>
                <h2 style={{ fontSize: '18px', fontWeight: '600', color: colors.textWhite, margin: '0 0 4px' }}>My Notes</h2>
                <p style={{ fontSize: '14px', color: colors.textMuted, margin: 0 }}>Manage keys and notes</p>
              </div>
              
              {/* Public Key */}
              <div style={{ 
                backgroundColor: `${colors.primary}15`,
                border: `1px solid ${colors.primary}40`,
                borderRadius: '10px',
                padding: '14px',
                marginBottom: '14px'
              }}>
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '8px' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                    <Key style={{ width: '14px', height: '14px', color: colors.primary }} />
                    <span style={{ fontSize: '13px', color: colors.primary, fontWeight: '500' }}>Public Key</span>
                  </div>
                  <button 
                    onClick={() => copyToClipboard(toHex(publicKey), 'pub')}
                    style={{ background: 'none', border: 'none', cursor: 'pointer', padding: '4px' }}
                  >
                    {copied === 'pub' ? <Check style={{ width: '14px', height: '14px', color: colors.primary }} /> : <Copy style={{ width: '14px', height: '14px', color: colors.primary }} />}
                  </button>
                </div>
                <p style={{ 
                  fontFamily: 'monospace',
                  fontSize: '11px',
                  backgroundColor: colors.inputBg,
                  borderRadius: '6px',
                  padding: '10px',
                  wordBreak: 'break-all',
                  color: colors.textWhite,
                  margin: 0
                }}>
                  {toHex(publicKey)}
                </p>
                <p style={{ fontSize: '11px', color: colors.textMuted, marginTop: '6px' }}>Share to receive transfers</p>
              </div>
              
              {/* Private Key */}
              <div style={{ 
                backgroundColor: `${colors.red}10`,
                border: `1px solid ${colors.red}30`,
                borderRadius: '10px',
                padding: '14px',
                marginBottom: '14px'
              }}>
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '8px' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                    <Key style={{ width: '14px', height: '14px', color: colors.red }} />
                    <span style={{ fontSize: '13px', color: colors.red, fontWeight: '500' }}>Private Key</span>
                  </div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                    <button 
                      onClick={() => setShowPrivateKey(!showPrivateKey)}
                      style={{ background: 'none', border: 'none', cursor: 'pointer', padding: '4px' }}
                    >
                      {showPrivateKey ? <EyeOff style={{ width: '14px', height: '14px', color: colors.red }} /> : <Eye style={{ width: '14px', height: '14px', color: colors.red }} />}
                    </button>
                    {showPrivateKey && (
                      <button 
                        onClick={() => copyToClipboard(toHex(privateKey), 'priv')}
                        style={{ background: 'none', border: 'none', cursor: 'pointer', padding: '4px' }}
                      >
                        {copied === 'priv' ? <Check style={{ width: '14px', height: '14px', color: colors.red }} /> : <Copy style={{ width: '14px', height: '14px', color: colors.red }} />}
                      </button>
                    )}
                  </div>
                </div>
                {showPrivateKey ? (
                  <p style={{ 
                    fontFamily: 'monospace',
                    fontSize: '11px',
                    backgroundColor: colors.inputBg,
                    borderRadius: '6px',
                    padding: '10px',
                    wordBreak: 'break-all',
                    color: colors.textWhite,
                    margin: 0
                  }}>
                    {toHex(privateKey)}
                  </p>
                ) : (
                  <p style={{ fontSize: '13px', color: colors.textMuted, margin: 0 }}>Click eye to reveal</p>
                )}
                <p style={{ fontSize: '11px', color: colors.red, marginTop: '6px' }}>⚠️ Never share this!</p>
              </div>
              
              {/* Notes List */}
              <div>
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '12px' }}>
                  <h3 style={{ fontSize: '14px', fontWeight: '600', color: colors.textWhite, margin: 0 }}>Notes ({unspentNotes.length} available)</h3>
                  <button 
                    onClick={() => window.location.reload()}
                    style={{ background: 'none', border: 'none', cursor: 'pointer', padding: '4px' }}
                  >
                    <RefreshCw style={{ width: '14px', height: '14px', color: colors.textMuted }} />
                  </button>
                </div>
                
                {notes.length === 0 ? (
                  <div style={{ textAlign: 'center', padding: '24px', backgroundColor: colors.inputBg, borderRadius: '10px' }}>
                    <Wallet style={{ width: '28px', height: '28px', color: colors.textMuted, margin: '0 auto 8px' }} />
                    <p style={{ fontSize: '13px', color: colors.textMuted, margin: 0 }}>No notes yet</p>
                  </div>
                ) : (
                  <div style={{ maxHeight: '160px', overflowY: 'auto' }}>
                    {notes.map((note, i) => (
                      <div 
                        key={i} 
                        style={{ 
                          padding: '12px',
                          backgroundColor: note.spent ? colors.inputBg : colors.card,
                          border: `1px solid ${colors.cardBorder}`,
                          borderRadius: '8px',
                          marginBottom: '8px',
                          opacity: note.spent ? 0.5 : 1
                        }}
                      >
                        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                          <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                            <Shield style={{ width: '14px', height: '14px', color: note.spent ? colors.textMuted : colors.primary }} />
                            <span style={{ fontSize: '14px', fontWeight: '600', color: colors.textWhite }}>{formatUnits(BigInt(note.amount), 18)} STRK</span>
                          </div>
                          <span style={{ 
                            fontSize: '10px',
                            padding: '3px 6px',
                            backgroundColor: note.spent ? `${colors.red}20` : `${colors.primary}20`,
                            color: note.spent ? colors.red : colors.primary,
                            borderRadius: '4px'
                          }}>
                            {note.spent ? 'Spent' : 'Available'}
                          </span>
                        </div>
                        <p style={{ fontSize: '11px', color: colors.textMuted, marginTop: '6px' }}>
                          Index: {note.leafIndex} • {new Date(note.createdAt).toLocaleDateString()}
                        </p>
                      </div>
                    ))}
                  </div>
                )}
              </div>
              
              <button
                onClick={clearAllData}
                style={{ 
                  width: '100%',
                  marginTop: '14px',
                  padding: '10px',
                  backgroundColor: `${colors.red}15`,
                  border: `1px solid ${colors.red}40`,
                  borderRadius: '8px',
                  color: colors.red,
                  fontSize: '13px',
                  fontWeight: '500',
                  cursor: 'pointer'
                }}
              >
                Clear All Data
              </button>
            </div>
          )}
        </div>
        
        {/* Footer */}
        <p style={{ marginTop: '20px', fontSize: '12px', color: colors.textMuted, textAlign: 'center' }}>
          Starknet Sepolia • v{STORAGE_VERSION}
        </p>
      </main>
      
      <style>{`
        @keyframes spin {
          from { transform: rotate(0deg); }
          to { transform: rotate(360deg); }
        }
        input::placeholder {
          color: #64748b;
        }
        * {
          box-sizing: border-box;
        }
      `}</style>
    </div>
  )
}