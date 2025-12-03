import { useState, useCallback } from 'react'
import { connect, disconnect } from '@starknet-io/get-starknet'

export function useWallet() {
  const [address, setAddress] = useState<string | null>(null)
  const [isConnected, setIsConnected] = useState(false)
  const [wallet, setWallet] = useState<any>(null)

  const connectWallet = useCallback(async () => {
    try {
      const starknet = await connect()
      if (!starknet) throw new Error('No wallet found')
      
      const accounts = await starknet.request({ type: 'wallet_requestAccounts' })
      
      setAddress(accounts[0] || null)
      setIsConnected(true)
      setWallet(starknet)
      
      return starknet
    } catch (err) {
      console.error('Connect error:', err)
      throw err
    }
  }, [])

  const disconnectWallet = useCallback(async () => {
    await disconnect()
    setAddress(null)
    setIsConnected(false)
    setWallet(null)
  }, [])

  return {
    address,
    isConnected,
    wallet,
    connect: connectWallet,
    disconnect: disconnectWallet,
  }
}