import type { Note, SerializedNote } from '../types'
import { STORAGE_KEYS } from '../constants'

function serializeNote(note: Note): SerializedNote {
  return {
    amount: note.amount.toString(),
    assetId: note.assetId,
    blinding: note.blinding.toString(),
    ownerKey: note.ownerKey.toString(),
    commitment: note.commitment.toString(),
    nullifier: note.nullifier.toString(),
    leafIndex: note.leafIndex,
    spent: note.spent,
    createdAt: note.createdAt,
  }
}

function deserializeNote(data: SerializedNote): Note {
  return {
    amount: BigInt(data.amount),
    assetId: data.assetId,
    blinding: BigInt(data.blinding),
    ownerKey: BigInt(data.ownerKey),
    commitment: BigInt(data.commitment),
    nullifier: BigInt(data.nullifier),
    leafIndex: data.leafIndex,
    spent: data.spent,
    createdAt: data.createdAt,
  }
}

export function saveNotes(notes: Note[]): void {
  localStorage.setItem(STORAGE_KEYS.NOTES, JSON.stringify(notes.map(serializeNote)))
}

export function loadNotes(): Note[] {
  const data = localStorage.getItem(STORAGE_KEYS.NOTES)
  if (!data) return []
  try {
    return JSON.parse(data).map(deserializeNote)
  } catch {
    return []
  }
}

export function savePrivateKey(key: bigint): void {
  localStorage.setItem(STORAGE_KEYS.PRIVATE_KEY, key.toString())
}

export function loadPrivateKey(): bigint | null {
  const data = localStorage.getItem(STORAGE_KEYS.PRIVATE_KEY)
  if (!data) return null
  try {
    return BigInt(data)
  } catch {
    return null
  }
}