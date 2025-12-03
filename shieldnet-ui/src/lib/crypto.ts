import { hash } from 'starknet'

export function poseidonHash(inputs: bigint[]): bigint {
  const feltInputs = inputs.map(i => '0x' + i.toString(16))
  return BigInt(hash.computePoseidonHashOnElements(feltInputs))
}

export function hash2(a: bigint, b: bigint): bigint {
  return poseidonHash([a, b])
}

export function hash3(a: bigint, b: bigint, c: bigint): bigint {
  return poseidonHash([a, b, c])
}

export function hash4(a: bigint, b: bigint, c: bigint, d: bigint): bigint {
  return poseidonHash([a, b, c, d])
}

// commitment = hash4(amount, asset_id, blinding, owner_key)
export function computeCommitment(
  amount: bigint,
  assetId: bigint,
  blinding: bigint,
  ownerKey: bigint
): bigint {
  return hash4(amount, assetId, blinding, ownerKey)
}

// nullifier = hash3(commitment, priv_key, index)
export function computeNullifier(
  commitment: bigint,
  privKey: bigint,
  index: bigint
): bigint {
  return hash3(commitment, privKey, index)
}

// partial_commitment = hash2(blinding, owner_key)
export function computePartialCommitment(blinding: bigint, ownerKey: bigint): bigint {
  return hash2(blinding, ownerKey)
}

export function randomFieldElement(): bigint {
  const bytes = new Uint8Array(32)
  crypto.getRandomValues(bytes)
  bytes[0] &= 0x0f // 252 bits
  let result = 0n
  for (let i = 0; i < 32; i++) {
    result = (result << 8n) | BigInt(bytes[i])
  }
  return result
}

export function generatePrivateKey(): bigint {
  return randomFieldElement()
}

export function derivePublicKey(privKey: bigint): bigint {
  return poseidonHash([privKey])
}