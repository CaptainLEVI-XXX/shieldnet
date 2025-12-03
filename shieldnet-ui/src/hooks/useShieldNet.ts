import { useState, useCallback, useEffect, useMemo, useRef } from 'react'
import { RpcProvider, constants } from 'starknet'
import type { Note, TxState, TxStatus } from '../types'
import { SHIELD_POOL_ADDRESS, STRK_ADDRESS, MERKLE_TREE_DEPTH } from '../constants'
import {
  computeCommitment,
  computeNullifier,
  computePartialCommitment,
  randomFieldElement,
  derivePublicKey,
  generatePrivateKey,
  poseidonHash,
} from '../lib/crypto'
import { saveNotes, loadNotes, loadPrivateKey, savePrivateKey } from '../lib/storage'
import { MerkleTree } from '../lib/merkle'

const provider = new RpcProvider({ nodeUrl: constants.NetworkName.SN_SEPOLIA })

function createDummyNote(ownerKey: bigint, privKey: bigint): Note {
  const blinding = randomFieldElement()
  const commitment = computeCommitment(0n, BigInt(STRK_ADDRESS), blinding, ownerKey)
  return {
    amount: 0n,
    assetId: STRK_ADDRESS,
    blinding,
    ownerKey,
    commitment,
    nullifier: computeNullifier(commitment, privKey, 0n),
    leafIndex: 0,
    spent: false,
    createdAt: Date.now(),
  }
}

export function useShieldNet(wallet: any) {
  const [txState, setTxState] = useState<TxState>({ status: 'idle', message: '' })
  const [notes, setNotes] = useState<Note[]>([])
  const merkleTreeRef = useRef(new MerkleTree(MERKLE_TREE_DEPTH))

  const privateKey = useMemo(() => {
    let key = loadPrivateKey()
    if (!key) {
      key = generatePrivateKey()
      savePrivateKey(key)
    }
    return key
  }, [])

  const publicKey = useMemo(() => derivePublicKey(privateKey), [privateKey])

  useEffect(() => {
    const loaded = loadNotes()
    setNotes(loaded)
    loaded.forEach(note => merkleTreeRef.current.insert(note.commitment))
  }, [])

  const updateStatus = useCallback((status: TxStatus, message: string) => {
    setTxState({ status, message })
  }, [])

  // ========== DEPOSIT ==========
  const deposit = useCallback(async (amount: bigint): Promise<Note> => {
    if (!wallet) throw new Error('No wallet')

    try {
      updateStatus('approving', 'Approving & Depositing...')

      const blinding = randomFieldElement()
      const commitment = computeCommitment(amount, BigInt(STRK_ADDRESS), blinding, publicKey)

      const calls = [
        {
          contractAddress: STRK_ADDRESS,
          entrypoint: 'approve',
          calldata: [SHIELD_POOL_ADDRESS, '0x' + amount.toString(16), '0x0'],
        },
        {
          contractAddress: SHIELD_POOL_ADDRESS,
          entrypoint: 'deposit',
          calldata: ['0x' + commitment.toString(16), '0x' + amount.toString(16), '0x0'],
        },
      ]

      updateStatus('submitting', 'Confirming...')

      const result = await wallet.request({
        type: 'wallet_addInvokeTransaction',
        params: { calls },
      })

      await provider.waitForTransaction(result.transaction_hash)

      const leafIndex = merkleTreeRef.current.getLeafCount()
      const nullifier = computeNullifier(commitment, privateKey, BigInt(leafIndex))

      const newNote: Note = {
        amount,
        assetId: STRK_ADDRESS,
        blinding,
        ownerKey: publicKey,
        commitment,
        nullifier,
        leafIndex,
        spent: false,
        createdAt: Date.now(),
      }

      merkleTreeRef.current.insert(commitment)

      const updated = [...notes, newNote]
      saveNotes(updated)
      setNotes(updated)

      setTxState({ status: 'confirmed', message: 'Success!', txHash: result.transaction_hash })
      return newNote
    } catch (err: any) {
      setTxState({ status: 'error', message: 'Failed', error: err.message })
      throw err
    }
  }, [wallet, privateKey, publicKey, notes, updateStatus])

  // ========== WITHDRAW ==========
  const withdraw = useCallback(async (amount: bigint, recipient: string): Promise<string> => {
    if (!wallet) throw new Error('No wallet')

    try {
      const unspent = notes.filter(n => !n.spent)
      if (unspent.length === 0) throw new Error('No notes')

      let selected: Note[] = []
      let total = 0n
      for (const note of unspent) {
        selected.push(note)
        total += note.amount
        if (total >= amount && selected.length <= 2) break
      }
      if (total < amount) throw new Error('Insufficient balance')

      while (selected.length < 2) {
        selected.push(createDummyNote(publicKey, privateKey))
      }

      const changeAmount = total - amount
      const changeBlinding = randomFieldElement()
      const changeCommitment = computeCommitment(changeAmount, BigInt(STRK_ADDRESS), changeBlinding, publicKey)

      updateStatus('generating_witness', 'Loading proof system...')

      // Dynamic import - only loads heavy libraries when needed!
      const { generateUnshieldProof } = await import('../lib/proof')

      const merkleRoot = merkleTreeRef.current.getRoot()

      updateStatus('generating_proof', 'Generating proof (30-60s)...')

      const proofResult = await generateUnshieldProof({
        priv_key: privateKey,
        in_amounts: [selected[0].amount, selected[1].amount],
        in_blindings: [selected[0].blinding, selected[1].blinding],
        in_owner_keys: [selected[0].ownerKey, selected[1].ownerKey],
        in_indices: [BigInt(selected[0].leafIndex), BigInt(selected[1].leafIndex)],
        in_merkle_paths: [
          merkleTreeRef.current.getProof(selected[0].leafIndex),
          merkleTreeRef.current.getProof(selected[1].leafIndex),
        ],
        change_amount: changeAmount,
        change_blinding: changeBlinding,
        merkle_root: merkleRoot,
        recipient: BigInt(recipient),
        withdraw_amount: amount,
        relayer_fee: 0n,
      })

      updateStatus('preparing_calldata', 'Preparing transaction...')

      const nullifier1 = computeNullifier(selected[0].commitment, privateKey, BigInt(selected[0].leafIndex))
      const nullifier2 = computeNullifier(selected[1].commitment, privateKey, BigInt(selected[1].leafIndex))

      const calls = [{
        contractAddress: SHIELD_POOL_ADDRESS,
        entrypoint: 'withdraw',
        calldata: [
          proofResult.calldata.length.toString(),
          ...proofResult.calldata.map((c:any) => '0x' + c.toString(16)),
          '0x' + merkleRoot.toString(16),
          '0x' + nullifier1.toString(16),
          '0x' + nullifier2.toString(16),
          '0x' + changeCommitment.toString(16),
          recipient,
          '0x' + amount.toString(16), '0x0',
          '0x0', '0x0', '0x0',
        ],
      }]

      updateStatus('submitting', 'Submitting...')

      const result = await wallet.request({
        type: 'wallet_addInvokeTransaction',
        params: { calls },
      })

      await provider.waitForTransaction(result.transaction_hash)

      const updated = notes.map(n => selected.some(s => s.commitment === n.commitment) ? { ...n, spent: true } : n)

      if (changeAmount > 0n) {
        const changeNote: Note = {
          amount: changeAmount,
          assetId: STRK_ADDRESS,
          blinding: changeBlinding,
          ownerKey: publicKey,
          commitment: changeCommitment,
          nullifier: computeNullifier(changeCommitment, privateKey, BigInt(merkleTreeRef.current.getLeafCount())),
          leafIndex: merkleTreeRef.current.getLeafCount(),
          spent: false,
          createdAt: Date.now(),
        }
        updated.push(changeNote)
        merkleTreeRef.current.insert(changeCommitment)
      }

      saveNotes(updated)
      setNotes(updated)

      setTxState({ status: 'confirmed', message: 'Success!', txHash: result.transaction_hash })
      return result.transaction_hash
    } catch (err: any) {
      setTxState({ status: 'error', message: 'Failed', error: err.message })
      throw err
    }
  }, [wallet, privateKey, publicKey, notes, updateStatus])

  // ========== TRANSFER ==========
  const transfer = useCallback(async (amount: bigint, recipientPubKey: bigint): Promise<string> => {
    if (!wallet) throw new Error('No wallet')

    try {
      const unspent = notes.filter(n => !n.spent)
      if (unspent.length === 0) throw new Error('No notes')

      let selected: Note[] = []
      let total = 0n
      for (const note of unspent) {
        selected.push(note)
        total += note.amount
        if (total >= amount && selected.length <= 2) break
      }
      if (total < amount) throw new Error('Insufficient balance')

      while (selected.length < 2) {
        selected.push(createDummyNote(publicKey, privateKey))
      }

      const out1Blinding = randomFieldElement()
      const out1Commitment = computeCommitment(amount, BigInt(STRK_ADDRESS), out1Blinding, recipientPubKey)

      const changeAmount = total - amount
      const out2Blinding = randomFieldElement()
      const out2Commitment = computeCommitment(changeAmount, BigInt(STRK_ADDRESS), out2Blinding, publicKey)

      updateStatus('generating_witness', 'Loading proof system...')

      const { generateTransferProof } = await import('../lib/proof')

      const merkleRoot = merkleTreeRef.current.getRoot()

      updateStatus('generating_proof', 'Generating proof (30-60s)...')

      const proofResult = await generateTransferProof({
        priv_key: privateKey,
        in_amounts: [selected[0].amount, selected[1].amount],
        in_blindings: [selected[0].blinding, selected[1].blinding],
        in_owner_keys: [selected[0].ownerKey, selected[1].ownerKey],
        in_indices: [BigInt(selected[0].leafIndex), BigInt(selected[1].leafIndex)],
        in_merkle_paths: [
          merkleTreeRef.current.getProof(selected[0].leafIndex),
          merkleTreeRef.current.getProof(selected[1].leafIndex),
        ],
        out_amounts: [amount, changeAmount],
        out_blindings: [out1Blinding, out2Blinding],
        out_owner_keys: [recipientPubKey, publicKey],
        merkle_root: merkleRoot,
        relayer_fee: 0n,
      })

      updateStatus('preparing_calldata', 'Preparing transaction...')

      const nullifier1 = computeNullifier(selected[0].commitment, privateKey, BigInt(selected[0].leafIndex))
      const nullifier2 = computeNullifier(selected[1].commitment, privateKey, BigInt(selected[1].leafIndex))

      const calls = [{
        contractAddress: SHIELD_POOL_ADDRESS,
        entrypoint: 'transfer',
        calldata: [
          proofResult.calldata.length.toString(),
          ...proofResult.calldata.map(c => '0x' + c.toString(16)),
          '0x' + merkleRoot.toString(16),
          '0x' + nullifier1.toString(16),
          '0x' + nullifier2.toString(16),
          '0x' + out1Commitment.toString(16),
          '0x' + out2Commitment.toString(16),
          '0x0', '0x0', '0x0',
          '0', '0',
        ],
      }]

      updateStatus('submitting', 'Submitting...')

      const result = await wallet.request({
        type: 'wallet_addInvokeTransaction',
        params: { calls },
      })

      await provider.waitForTransaction(result.transaction_hash)

      const updated = notes.map(n => selected.some(s => s.commitment === n.commitment) ? { ...n, spent: true } : n)

      if (changeAmount > 0n) {
        const changeNote: Note = {
          amount: changeAmount,
          assetId: STRK_ADDRESS,
          blinding: out2Blinding,
          ownerKey: publicKey,
          commitment: out2Commitment,
          nullifier: computeNullifier(out2Commitment, privateKey, BigInt(merkleTreeRef.current.getLeafCount())),
          leafIndex: merkleTreeRef.current.getLeafCount(),
          spent: false,
          createdAt: Date.now(),
        }
        updated.push(changeNote)
        merkleTreeRef.current.insert(out2Commitment)
      }

      saveNotes(updated)
      setNotes(updated)

      setTxState({ status: 'confirmed', message: 'Success!', txHash: result.transaction_hash })
      return result.transaction_hash
    } catch (err: any) {
      setTxState({ status: 'error', message: 'Failed', error: err.message })
      throw err
    }
  }, [wallet, privateKey, publicKey, notes, updateStatus])

  // ========== TRANSACT ==========
  const transact = useCallback(async (
    inputAmount: bigint,
    targetContract: string,
    defiCalldata: string[],
    minOutput: bigint
  ): Promise<string> => {
    if (!wallet) throw new Error('No wallet')

    try {
      const unspent = notes.filter(n => !n.spent && n.amount >= inputAmount)
      if (unspent.length === 0) throw new Error('No suitable note')

      const selected = unspent[0]

      const calldataHash = poseidonHash(defiCalldata.map(BigInt))
      const outBlinding = randomFieldElement()
      const partialCommitment = computePartialCommitment(outBlinding, publicKey)

      updateStatus('generating_witness', 'Loading proof system...')

      const { generateTransactProof } = await import('../lib/proof')

      const merkleRoot = merkleTreeRef.current.getRoot()

      updateStatus('generating_proof', 'Generating proof (30-60s)...')

      const proofResult = await generateTransactProof({
        priv_key: privateKey,
        in_amount: selected.amount,
        in_blinding: selected.blinding,
        in_owner_key: selected.ownerKey,
        in_index: BigInt(selected.leafIndex),
        in_merkle_path: merkleTreeRef.current.getProof(selected.leafIndex),
        out_blinding: outBlinding,
        merkle_root: merkleRoot,
        target_contract: BigInt(targetContract),
        calldata_hash: calldataHash,
        relayer_fee: 0n,
      })

      updateStatus('preparing_calldata', 'Preparing transaction...')

      const nullifier = computeNullifier(selected.commitment, privateKey, BigInt(selected.leafIndex))

      const calls = [{
        contractAddress: SHIELD_POOL_ADDRESS,
        entrypoint: 'transact',
        calldata: [
          proofResult.calldata.length.toString(),
          ...proofResult.calldata.map(c => '0x' + c.toString(16)),
          '0x' + merkleRoot.toString(16),
          '0x' + nullifier.toString(16),
          '0x' + partialCommitment.toString(16),
          targetContract,
          defiCalldata.length.toString(),
          ...defiCalldata,
          '0x' + inputAmount.toString(16), '0x0',
          STRK_ADDRESS,
          STRK_ADDRESS,
          '0x' + minOutput.toString(16), '0x0',
          '0x0', '0x0', '0x0',
          '0',
        ],
      }]

      updateStatus('submitting', 'Submitting...')

      const result = await wallet.request({
        type: 'wallet_addInvokeTransaction',
        params: { calls },
      })

      await provider.waitForTransaction(result.transaction_hash)

      const updated = notes.map(n => n.commitment === selected.commitment ? { ...n, spent: true } : n)
      saveNotes(updated)
      setNotes(updated)

      setTxState({ status: 'confirmed', message: 'Success!', txHash: result.transaction_hash })
      return result.transaction_hash
    } catch (err: any) {
      setTxState({ status: 'error', message: 'Failed', error: err.message })
      throw err
    }
  }, [wallet, privateKey, publicKey, notes, updateStatus])

  const getUnspentNotes = useCallback(() => notes.filter(n => !n.spent), [notes])
  const getShieldedBalance = useCallback(() => getUnspentNotes().reduce((s, n) => s + n.amount, 0n), [getUnspentNotes])
  const resetTxState = useCallback(() => setTxState({ status: 'idle', message: '' }), [])

  return {
    privateKey,
    publicKey,
    notes,
    txState,
    deposit,
    withdraw,
    transfer,
    transact,
    getUnspentNotes,
    getShieldedBalance,
    resetTxState,
  }
}