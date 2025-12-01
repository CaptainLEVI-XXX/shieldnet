import { useState, useCallback, useEffect, useMemo } from 'react'
import { Contract, Account, RpcProvider, constants } from 'starknet'
import type { Note, TxState } from '../types'
import { SHIELD_POOL_ADDRESS, STRK_ADDRESS } from '../constants'
import { computeCommitment, computeNullifier, randomFieldElement, derivePublicKey, generatePrivateKey } from '../lib/crypto'
import { saveNotes, loadNotes, loadPrivateKey, savePrivateKey } from '../lib/storage'

// ABIs - minimal for now
const ERC20_ABI = [
  {
    name: 'approve',
    type: 'function',
    inputs: [
      { name: 'spender', type: 'core::starknet::contract_address::ContractAddress' },
      { name: 'amount', type: 'core::integer::u256' },
    ],
    outputs: [{ type: 'core::bool' }],
    state_mutability: 'external',
  },
] as const

const SHIELD_POOL_ABI = [
  {
    name: 'deposit',
    type: 'function',
    inputs: [
      { name: 'commitment', type: 'core::felt252' },
      { name: 'amount', type: 'core::integer::u256' },
    ],
    outputs: [{ type: 'core::integer::u32' }],
    state_mutability: 'external',
  },
  {
    name: 'get_merkle_root',
    type: 'function',
    inputs: [],
    outputs: [{ type: 'core::felt252' }],
    state_mutability: 'view',
  },
] as const

const provider = new RpcProvider({ nodeUrl: constants.NetworkName.SN_SEPOLIA })

export function useShieldNet(walletObject: any) {
  const [txState, setTxState] = useState<TxState>({ status: 'idle', message: '' })
  const [notes, setNotes] = useState<Note[]>([])

  // Private key management
  const privateKey = useMemo(() => {
    let key = loadPrivateKey()
    if (!key) {
      key = generatePrivateKey()
      savePrivateKey(key)
    }
    return key
  }, [])

  const publicKey = useMemo(() => derivePublicKey(privateKey), [privateKey])

  // Load notes
  useEffect(() => {
    setNotes(loadNotes())
  }, [])

  // Deposit
  const deposit = useCallback(async (amount: bigint) => {
    if (!walletObject) throw new Error('No wallet connected')

    try {
      setTxState({ status: 'approving', message: 'Approving STRK...' })

      const blinding = randomFieldElement()
      const assetId = BigInt(STRK_ADDRESS)
      const commitment = computeCommitment(amount, assetId, blinding, publicKey)
      const nullifier = computeNullifier(commitment, privateKey, 0n)

      // Build multicall for approve + deposit
      const calls = [
        {
          contractAddress: STRK_ADDRESS,
          entrypoint: 'approve',
          calldata: [SHIELD_POOL_ADDRESS, '0x' + amount.toString(16), '0x0'], // u256 as low, high
        },
        {
          contractAddress: SHIELD_POOL_ADDRESS,
          entrypoint: 'deposit',
          calldata: ['0x' + commitment.toString(16), '0x' + amount.toString(16), '0x0'],
        },
      ]

      setTxState({ status: 'submitting', message: 'Depositing...' })

      // Execute via wallet
      const result = await walletObject.request({
        type: 'wallet_addInvokeTransaction',
        params: { calls },
      })

      // Wait for transaction
      await provider.waitForTransaction(result.transaction_hash)

      // Save note
      const newNote: Note = {
        amount,
        assetId: STRK_ADDRESS,
        blinding,
        ownerKey: publicKey,
        commitment,
        nullifier,
        leafIndex: 0,
        spent: false,
        createdAt: Date.now(),
      }

      const updated = [...notes, newNote]
      saveNotes(updated)
      setNotes(updated)

      setTxState({ status: 'confirmed', message: 'Deposit successful!', txHash: result.transaction_hash })
      return newNote
    } catch (err: any) {
      console.error('Deposit error:', err)
      setTxState({ status: 'error', message: 'Deposit failed', error: err.message })
      throw err
    }
  }, [walletObject, privateKey, publicKey, notes])

  const getUnspentNotes = useCallback(() => notes.filter(n => !n.spent), [notes])
  const getShieldedBalance = useCallback(() => getUnspentNotes().reduce((s, n) => s + n.amount, 0n), [getUnspentNotes])
  const resetTxState = useCallback(() => setTxState({ status: 'idle', message: '' }), [])

  return {
    privateKey,
    publicKey,
    notes,
    txState,
    deposit,
    getUnspentNotes,
    getShieldedBalance,
    resetTxState,
  }
}