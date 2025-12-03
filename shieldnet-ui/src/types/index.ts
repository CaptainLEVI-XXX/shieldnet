export interface Note {
  amount: bigint
  assetId: string
  blinding: bigint
  ownerKey: bigint
  commitment: bigint
  nullifier: bigint
  leafIndex: number
  spent: boolean
  createdAt: number
}

export interface SerializedNote {
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

export type TxStatus = 
  | 'idle' 
  | 'approving' 
  | 'generating_witness' 
  | 'generating_proof' 
  | 'preparing_calldata' 
  | 'submitting' 
  | 'confirmed' 
  | 'error'

export interface TxState {
  status: TxStatus
  message: string
  txHash?: string
  error?: string
}