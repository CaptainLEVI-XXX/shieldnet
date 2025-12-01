import { useState, useCallback } from 'react'
import { connect, disconnect } from '@starknet-io/get-starknet'
import type { WalletState } from '../types'

export function useWallet() {
  const [wallet, setWallet] = useState<WalletState>({
    address: null,
    isConnected: false,
  })
  const [account, setAccount] = useState<any>(null)

  const connectWallet = useCallback(async () => {
    try {
      const starknet = await connect()
      if (!starknet) throw new Error('No wallet found')
      
      // v4 API - request permissions
      const result = await starknet.request({ type: 'wallet_requestAccounts' })
      const address = result[0]
      
      // Get account from wallet
      const walletAccount = await starknet.request({ type: 'wallet_requestAccounts' })
      
      setWallet({
        address: address || null,
        isConnected: true,
      })
      
      // Store the starknet object for later use
      setAccount(starknet)
      
      return starknet
    } catch (err) {
      console.error('Connect error:', err)
      throw err
    }
  }, [])

  const disconnectWallet = useCallback(async () => {
    await disconnect()
    setWallet({ address: null, isConnected: false })
    setAccount(null)
  }, [])

  return {
    ...wallet,
    account,
    connect: connectWallet,
    disconnect: disconnectWallet,
  }
}