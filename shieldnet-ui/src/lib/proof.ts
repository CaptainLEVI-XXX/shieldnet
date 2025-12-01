import { Noir } from '@noir-lang/noir_js'
import { UltraHonkBackend } from '@aztec/bb.js'

// Circuit artifacts will be loaded from public folder
let transferCircuit: any = null
let unshieldCircuit: any = null
let transactCircuit: any = null

async function loadCircuit(name: string) {
  const response = await fetch(`/circuits/${name}.json`)
  if (!response.ok) throw new Error(`Failed to load ${name} circuit`)
  return response.json()
}

export async function initCircuits() {
  try {
    const [transfer, unshield, transact] = await Promise.all([
      loadCircuit('transfer'),
      loadCircuit('unshield'),
      loadCircuit('transact'),
    ])
    transferCircuit = transfer
    unshieldCircuit = unshield
    transactCircuit = transact
    console.log('Circuits loaded')
  } catch (err) {
    console.warn('Circuits not loaded:', err)
  }
}

export async function generateProof(
  circuitType: 'transfer' | 'unshield' | 'transact',
  inputs: Record<string, any>
): Promise<{ proof: Uint8Array; publicInputs: string[] }> {
  let circuit: any
  switch (circuitType) {
    case 'transfer':
      circuit = transferCircuit
      break
    case 'unshield':
      circuit = unshieldCircuit
      break
    case 'transact':
      circuit = transactCircuit
      break
  }

  if (!circuit) {
    throw new Error(`${circuitType} circuit not loaded`)
  }

  const backend = new UltraHonkBackend(circuit.bytecode)
  const noir = new Noir(circuit)

  const { witness } = await noir.execute(inputs)
  const proof = await backend.generateProof(witness)

  return {
    proof: proof.proof,
    publicInputs: proof.publicInputs.map(String),
  }
}

// Convert proof to calldata format for Starknet
export function proofToCalldata(proof: Uint8Array): string[] {
  return Array.from(proof).map(b => '0x' + b.toString(16).padStart(2, '0'))
}