// import { Noir } from "@noir-lang/noir_js";
// import { UltraHonkBackend } from "@aztec/bb.js";
// import { getZKHonkCallData, init as initGaraga } from 'garaga';
// import initNoirC from "@noir-lang/noirc_abi";
// import initACVM from "@noir-lang/acvm_js";

// // Circuit artifacts will be loaded
// let transferCircuit: { bytecode: string; abi: any } | null = null;
// let unshieldCircuit: { bytecode: string; abi: any } | null = null;
// let transactCircuit: { bytecode: string; abi: any } | null = null;

// // Verification keys
// let transferVk: Uint8Array | null = null;
// let unshieldVk: Uint8Array | null = null;
// let transactVk: Uint8Array | null = null;

// let isInitialized = false;

// // Helper functions
// function hexToUint8Array(hex: string): Uint8Array {
//   const sanitisedHex = BigInt(hex).toString(16).padStart(64, '0');
//   const len = sanitisedHex.length / 2;
//   const u8 = new Uint8Array(len);
//   let i = 0;
//   let j = 0;
//   while (i < len) {
//     u8[i] = parseInt(sanitisedHex.slice(j, j + 2), 16);
//     i += 1;
//     j += 2;
//   }
//   return u8;
// }

// function flattenUint8Arrays(arrays: Uint8Array[]): Uint8Array {
//   const totalLength = arrays.reduce((acc, val) => acc + val.length, 0);
//   const result = new Uint8Array(totalLength);
//   let offset = 0;
//   for (const arr of arrays) {
//     result.set(arr, offset);
//     offset += arr.length;
//   }
//   return result;
// }

// export function flattenFieldsAsArray(fields: string[]): Uint8Array {
//   const flattenedPublicInputs = fields.map(hexToUint8Array);
//   return flattenUint8Arrays(flattenedPublicInputs);
// }

// // Convert bigint to hex string for circuit inputs
// export function toHex(value: bigint): string {
//   return '0x' + value.toString(16);
// }

// // Convert array to circuit-compatible format
// export function arrayToCircuitFormat(arr: bigint[]): string[] {
//   return arr.map(v => toHex(v));
// }

// // Initialize WASM modules
// export async function initWasm(): Promise<void> {
//   if (isInitialized) return;
  
//   try {
//     // Dynamic imports for WASM
//     const acvmUrl = new URL('@noir-lang/acvm_js/web/acvm_js_bg.wasm', import.meta.url).href;
//     const noircUrl = new URL('@noir-lang/noirc_abi/web/noirc_abi_wasm_bg.wasm', import.meta.url).href;
    
//     await Promise.all([
//       initACVM(fetch(acvmUrl)),
//       initNoirC(fetch(noircUrl)),
//     ]);
    
//     await initGaraga();
    
//     isInitialized = true;
//     console.log('WASM initialization complete');
//   } catch (error) {
//     console.error('Failed to initialize WASM:', error);
//     throw error;
//   }
// }

// // Load circuit from JSON file
// async function loadCircuit(name: string): Promise<{ bytecode: string; abi: any }> {
//   const response = await fetch(`/circuits/${name}.json`);
//   if (!response.ok) throw new Error(`Failed to load ${name} circuit`);
//   const data = await response.json();
//   return {
//     bytecode: data.bytecode,
//     abi: data.abi,
//   };
// }

// // Load verification key
// async function loadVk(name: string): Promise<Uint8Array> {
//   const response = await fetch(`/circuits/${name}_vk.bin`);
//   if (!response.ok) throw new Error(`Failed to load ${name} verification key`);
//   const arrayBuffer = await response.arrayBuffer();
//   return new Uint8Array(arrayBuffer);
// }

// // Initialize all circuits and VKs
// export async function initCircuits(): Promise<void> {
//   try {
//     await initWasm();
    
//     // Load circuits in parallel
//     const [transfer, unshield, transact] = await Promise.all([
//       loadCircuit('transfer').catch(() => null),
//       loadCircuit('unshield').catch(() => null),
//       loadCircuit('transact').catch(() => null),
//     ]);
    
//     transferCircuit = transfer;
//     unshieldCircuit = unshield;
//     transactCircuit = transact;
    
//     // Load VKs in parallel
//     const [tvk, uvk, xvk] = await Promise.all([
//       loadVk('transfer').catch(() => null),
//       loadVk('unshield').catch(() => null),
//       loadVk('transact').catch(() => null),
//     ]);
    
//     transferVk = tvk;
//     unshieldVk = uvk;
//     transactVk = xvk;
    
//     console.log('Circuits loaded:', {
//       transfer: !!transferCircuit,
//       unshield: !!unshieldCircuit,
//       transact: !!transactCircuit,
//     });
//   } catch (err) {
//     console.warn('Circuit loading failed:', err);
//   }
// }

// // Generate proof and prepare Starknet calldata
// export interface ProofResult {
//   proof: Uint8Array;
//   publicInputs: string[];
//   calldata: bigint[];
// }

// async function generateProofWithCalldata(
//   circuit: { bytecode: string; abi: any },
//   vk: Uint8Array,
//   inputs: Record<string, any>
// ): Promise<ProofResult> {
//   // Create Noir instance
//   const noir = new Noir({
//     bytecode: circuit.bytecode,
//     abi: circuit.abi,
//     debug_symbols: '',
//     file_map: {} as any,
//   });
  
//   // Execute to get witness
//   console.log('Generating witness with inputs:', inputs);
//   const { witness } = await noir.execute(inputs);
  
//   // Generate proof with Starknet ZK option
//   console.log('Generating proof...');
//   const backend = new UltraHonkBackend(circuit.bytecode, { threads: 1 });
//   const proof = await backend.generateProof(witness, { starknetZK: true });
//   backend.destroy();
  
//   console.log('Proof generated:', proof);
  
//   // Prepare calldata using garaga
//   const calldata = getZKHonkCallData(
//     proof.proof,
//     flattenFieldsAsArray(proof.publicInputs),
//     vk,
//     1 // HonkFlavor.STARKNET
//   );
  
//   console.log('Calldata prepared:', calldata);
  
//   return {
//     proof: proof.proof,
//     publicInputs: proof.publicInputs,
//     calldata: calldata.slice(1), // Remove first element (length)
//   };
// }

// // Transfer proof inputs interface
// export interface TransferInputs {
//   // Private inputs
//   priv_key: bigint;
  
//   // Input notes (2)
//   in_amounts: [bigint, bigint];
//   in_asset_ids: [bigint, bigint];
//   in_blindings: [bigint, bigint];
//   in_owner_keys: [bigint, bigint];
//   in_indices: [bigint, bigint];
//   in_merkle_paths: [bigint[], bigint[]];
  
//   // Output notes (2)
//   out_amounts: [bigint, bigint];
//   out_blindings: [bigint, bigint];
//   out_owner_keys: [bigint, bigint];
  
//   // Public inputs
//   merkle_root: bigint;
//   relayer_fee: bigint;
// }

// export async function generateTransferProof(inputs: TransferInputs): Promise<ProofResult> {
//   if (!transferCircuit || !transferVk) {
//     throw new Error('Transfer circuit not loaded');
//   }
  
//   // Format inputs for circuit
//   const circuitInputs = {
//     priv_key: toHex(inputs.priv_key),
    
//     in_amounts: inputs.in_amounts.map(toHex),
//     in_asset_ids: inputs.in_asset_ids.map(toHex),
//     in_blindings: inputs.in_blindings.map(toHex),
//     in_owner_keys: inputs.in_owner_keys.map(toHex),
//     in_indices: inputs.in_indices.map(toHex),
//     in_merkle_paths: inputs.in_merkle_paths.map(path => path.map(toHex)),
    
//     out_amounts: inputs.out_amounts.map(toHex),
//     out_blindings: inputs.out_blindings.map(toHex),
//     out_owner_keys: inputs.out_owner_keys.map(toHex),
    
//     merkle_root: toHex(inputs.merkle_root),
//     relayer_fee: toHex(inputs.relayer_fee),
//   };
  
//   return generateProofWithCalldata(transferCircuit, transferVk, circuitInputs);
// }

// // Unshield proof inputs interface
// export interface UnshieldInputs {
//   // Private inputs
//   priv_key: bigint;
  
//   // Input notes (2)
//   in_amounts: [bigint, bigint];
//   in_asset_ids: [bigint, bigint];
//   in_blindings: [bigint, bigint];
//   in_owner_keys: [bigint, bigint];
//   in_indices: [bigint, bigint];
//   in_merkle_paths: [bigint[], bigint[]];
  
//   // Change note
//   change_amount: bigint;
//   change_blinding: bigint;
  
//   // Public inputs
//   merkle_root: bigint;
//   recipient: bigint;
//   withdraw_amount: bigint;
//   relayer_fee: bigint;
// }

// export async function generateUnshieldProof(inputs: UnshieldInputs): Promise<ProofResult> {
//   if (!unshieldCircuit || !unshieldVk) {
//     throw new Error('Unshield circuit not loaded');
//   }
  
//   const circuitInputs = {
//     priv_key: toHex(inputs.priv_key),
    
//     in_amounts: inputs.in_amounts.map(toHex),
//     in_asset_ids: inputs.in_asset_ids.map(toHex),
//     in_blindings: inputs.in_blindings.map(toHex),
//     in_owner_keys: inputs.in_owner_keys.map(toHex),
//     in_indices: inputs.in_indices.map(toHex),
//     in_merkle_paths: inputs.in_merkle_paths.map(path => path.map(toHex)),
    
//     change_amount: toHex(inputs.change_amount),
//     change_blinding: toHex(inputs.change_blinding),
    
//     merkle_root: toHex(inputs.merkle_root),
//     recipient: toHex(inputs.recipient),
//     withdraw_amount: toHex(inputs.withdraw_amount),
//     relayer_fee: toHex(inputs.relayer_fee),
//   };
  
//   return generateProofWithCalldata(unshieldCircuit, unshieldVk, circuitInputs);
// }

// // Transact proof inputs interface
// export interface TransactInputs {
//   // Private inputs
//   priv_key: bigint;
  
//   // Input note
//   in_amount: bigint;
//   in_asset_id: bigint;
//   in_blinding: bigint;
//   in_owner_key: bigint;
//   in_index: bigint;
//   in_merkle_path: bigint[];
  
//   // Output partial commitment components
//   out_blinding: bigint;
  
//   // Public inputs
//   merkle_root: bigint;
//   target_contract: bigint;
//   calldata_hash: bigint;
//   relayer_fee: bigint;
// }

// export async function generateTransactProof(inputs: TransactInputs): Promise<ProofResult> {
//   if (!transactCircuit || !transactVk) {
//     throw new Error('Transact circuit not loaded');
//   }
  
//   const circuitInputs = {
//     priv_key: toHex(inputs.priv_key),
    
//     in_amount: toHex(inputs.in_amount),
//     in_asset_id: toHex(inputs.in_asset_id),
//     in_blinding: toHex(inputs.in_blinding),
//     in_owner_key: toHex(inputs.in_owner_key),
//     in_index: toHex(inputs.in_index),
//     in_merkle_path: inputs.in_merkle_path.map(toHex),
    
//     out_blinding: toHex(inputs.out_blinding),
    
//     merkle_root: toHex(inputs.merkle_root),
//     target_contract: toHex(inputs.target_contract),
//     calldata_hash: toHex(inputs.calldata_hash),
//     relayer_fee: toHex(inputs.relayer_fee),
//   };
  
//   return generateProofWithCalldata(transactCircuit, transactVk, circuitInputs);
// }

// // Check if circuits are loaded
// export function areCircuitsLoaded(): {
//   transfer: boolean;
//   unshield: boolean;
//   transact: boolean;
// } {
//   return {
//     transfer: !!transferCircuit && !!transferVk,
//     unshield: !!unshieldCircuit && !!unshieldVk,
//     transact: !!transactCircuit && !!transactVk,
//   };
// }


// This file contains heavy imports - only import dynamically!

import { Noir } from '@noir-lang/noir_js'
import { UltraHonkBackend } from '@aztec/bb.js'
import { getZKHonkCallData, init as initGaraga } from 'garaga'
import initNoirC from '@noir-lang/noirc_abi'
import initACVM from '@noir-lang/acvm_js'

let isInitialized = false

// Helpers
function hexToUint8Array(hex: string): Uint8Array {
  const sanitisedHex = BigInt(hex).toString(16).padStart(64, '0')
  const len = sanitisedHex.length / 2
  const u8 = new Uint8Array(len)
  for (let i = 0; i < len; i++) {
    u8[i] = parseInt(sanitisedHex.slice(i * 2, i * 2 + 2), 16)
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

function toHex(value: bigint): string {
  return '0x' + value.toString(16)
}

// Initialize WASM
async function ensureInitialized(): Promise<void> {
  if (isInitialized) return
  
  console.log('Initializing WASM modules...')
  
  // Fetch WASM files
  const acvmWasm = await fetch(new URL('@noir-lang/acvm_js/web/acvm_js_bg.wasm', import.meta.url))
  const noircWasm = await fetch(new URL('@noir-lang/noirc_abi/web/noirc_abi_wasm_bg.wasm', import.meta.url))
  
  await Promise.all([
    initACVM(acvmWasm),
    initNoirC(noircWasm),
  ])
  
  await initGaraga()
  
  isInitialized = true
  console.log('WASM initialized!')
}

// Load circuit
async function loadCircuit(name: string): Promise<{ bytecode: string; abi: any }> {
  const response = await fetch(`/circuits/${name}.json`)
  if (!response.ok) throw new Error(`Failed to load ${name} circuit`)
  const data = await response.json()
  return { bytecode: data.bytecode, abi: data.abi }
}

// Load VK
async function loadVk(name: string): Promise<Uint8Array> {
  // Try different paths
  const path = 
    `/circuits/${name}/target/vk`
  
  // for (const path of paths) {
    try {
      const response = await fetch(path)
      if (response.ok) {
        const buf = await response.arrayBuffer()
        return new Uint8Array(buf)
      }
    } catch {
      throw new Error(`Failed to load VK for ${name}`)
    }
  // }
  
  throw new Error(`Failed to load VK for ${name}`)
}

export interface ProofResult {
  calldata: bigint[]
  publicInputs: string[]
}

// Core proof generation
async function generateProof(
  circuitName: string,
  inputs: Record<string, any>
): Promise<ProofResult> {
  await ensureInitialized()
  
  console.log(`Loading ${circuitName} circuit...`)
  const [circuit, vk] = await Promise.all([
    loadCircuit(circuitName),
    loadVk(circuitName),
  ])
  
  console.log('Creating Noir instance...')
  const noir = new Noir({
    bytecode: circuit.bytecode,
    abi: circuit.abi,
    debug_symbols: '',
    file_map: {} as any,
  })
  
  console.log('Generating witness...')
  const { witness } = await noir.execute(inputs)
  
  console.log('Generating proof (this may take 30-60 seconds)...')
  const backend = new UltraHonkBackend(circuit.bytecode, { threads: 1 })
  const proof = await backend.generateProof(witness, { starknetZK: true })
  backend.destroy()
  
  console.log('Preparing Starknet calldata...')
  const calldata = getZKHonkCallData(
    proof.proof,
    flattenFieldsAsArray(proof.publicInputs),
    vk,
    1 // STARKNET flavor
  )
  
  return {
    calldata: calldata.slice(1), // Remove length prefix
    publicInputs: proof.publicInputs,
  }
}

// === UNSHIELD (Withdraw) ===
export interface UnshieldInputs {
  priv_key: bigint
  in_amounts: [bigint, bigint]
  in_blindings: [bigint, bigint]
  in_owner_keys: [bigint, bigint]
  in_indices: [bigint, bigint]
  in_merkle_paths: [bigint[], bigint[]]
  change_amount: bigint
  change_blinding: bigint
  merkle_root: bigint
  recipient: bigint
  withdraw_amount: bigint
  relayer_fee: bigint
}

export async function generateUnshieldProof(inputs: UnshieldInputs): Promise<ProofResult> {
  const formatted = {
    priv_key: toHex(inputs.priv_key),
    in_amounts: inputs.in_amounts.map(toHex),
    in_blindings: inputs.in_blindings.map(toHex),
    in_owner_keys: inputs.in_owner_keys.map(toHex),
    in_indices: inputs.in_indices.map(toHex),
    in_merkle_paths: inputs.in_merkle_paths.map(p => p.map(toHex)),
    change_amount: toHex(inputs.change_amount),
    change_blinding: toHex(inputs.change_blinding),
    merkle_root: toHex(inputs.merkle_root),
    recipient: toHex(inputs.recipient),
    withdraw_amount: toHex(inputs.withdraw_amount),
    relayer_fee: toHex(inputs.relayer_fee),
  }
  return generateProof('unshield', formatted)
}

// === TRANSFER ===
export interface TransferInputs {
  priv_key: bigint
  in_amounts: [bigint, bigint]
  in_blindings: [bigint, bigint]
  in_owner_keys: [bigint, bigint]
  in_indices: [bigint, bigint]
  in_merkle_paths: [bigint[], bigint[]]
  out_amounts: [bigint, bigint]
  out_blindings: [bigint, bigint]
  out_owner_keys: [bigint, bigint]
  merkle_root: bigint
  relayer_fee: bigint
}

export async function generateTransferProof(inputs: TransferInputs): Promise<ProofResult> {
  const formatted = {
    priv_key: toHex(inputs.priv_key),
    in_amounts: inputs.in_amounts.map(toHex),
    in_blindings: inputs.in_blindings.map(toHex),
    in_owner_keys: inputs.in_owner_keys.map(toHex),
    in_indices: inputs.in_indices.map(toHex),
    in_merkle_paths: inputs.in_merkle_paths.map(p => p.map(toHex)),
    out_amounts: inputs.out_amounts.map(toHex),
    out_blindings: inputs.out_blindings.map(toHex),
    out_owner_keys: inputs.out_owner_keys.map(toHex),
    merkle_root: toHex(inputs.merkle_root),
    relayer_fee: toHex(inputs.relayer_fee),
  }
  return generateProof('transfer', formatted)
}

// === TRANSACT ===
export interface TransactInputs {
  priv_key: bigint
  in_amount: bigint
  in_blinding: bigint
  in_owner_key: bigint
  in_index: bigint
  in_merkle_path: bigint[]
  out_blinding: bigint
  merkle_root: bigint
  target_contract: bigint
  calldata_hash: bigint
  relayer_fee: bigint
}

export async function generateTransactProof(inputs: TransactInputs): Promise<ProofResult> {
  const formatted = {
    priv_key: toHex(inputs.priv_key),
    in_amount: toHex(inputs.in_amount),
    in_blinding: toHex(inputs.in_blinding),
    in_owner_key: toHex(inputs.in_owner_key),
    in_index: toHex(inputs.in_index),
    in_merkle_path: inputs.in_merkle_path.map(toHex),
    out_blinding: toHex(inputs.out_blinding),
    merkle_root: toHex(inputs.merkle_root),
    target_contract: toHex(inputs.target_contract),
    calldata_hash: toHex(inputs.calldata_hash),
    relayer_fee: toHex(inputs.relayer_fee),
  }
  return generateProof('transact', formatted)
}