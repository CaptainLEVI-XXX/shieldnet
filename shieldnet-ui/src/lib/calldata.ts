import { CallData, cairo } from 'starknet'

export function buildDepositCalldata(commitment: bigint, amount: bigint): string[] {
  return CallData.compile({
    commitment: cairo.felt(commitment.toString()),
    amount: cairo.uint256(amount),
  })
}

export function buildWithdrawCalldata(
  proof: string[],
  merkleRoot: bigint,
  nullifier1: bigint,
  nullifier2: bigint,
  changeCommitment: bigint,
  recipient: string,
  amount: bigint,
  relayer: string,
  fee: bigint
): string[] {
  return CallData.compile({
    proof,
    merkle_root: cairo.felt(merkleRoot.toString()),
    nullifier_1: cairo.felt(nullifier1.toString()),
    nullifier_2: cairo.felt(nullifier2.toString()),
    change_commitment: cairo.felt(changeCommitment.toString()),
    recipient,
    amount: cairo.uint256(amount),
    relayer,
    fee: cairo.uint256(fee),
  })
}

export function buildTransferCalldata(
  proof: string[],
  merkleRoot: bigint,
  nullifier1: bigint,
  nullifier2: bigint,
  commitment1: bigint,
  commitment2: bigint,
  relayer: string,
  fee: bigint,
  encryptedNote1: string[],
  encryptedNote2: string[]
): string[] {
  return CallData.compile({
    proof,
    merkle_root: cairo.felt(merkleRoot.toString()),
    nullifier_1: cairo.felt(nullifier1.toString()),
    nullifier_2: cairo.felt(nullifier2.toString()),
    commitment_1: cairo.felt(commitment1.toString()),
    commitment_2: cairo.felt(commitment2.toString()),
    relayer,
    fee: cairo.uint256(fee),
    encrypted_note_1: encryptedNote1,
    encrypted_note_2: encryptedNote2,
  })
}

export function buildTransactCalldata(
  proof: string[],
  merkleRoot: bigint,
  nullifier: bigint,
  partialCommitment: bigint,
  targetContract: string,
  defiCalldata: string[],
  inputAmount: bigint,
  inputAsset: string,
  outputAsset: string,
  minOutputAmount: bigint,
  relayer: string,
  fee: bigint,
  encryptedMetadata: string[]
): string[] {
  return CallData.compile({
    proof,
    merkle_root: cairo.felt(merkleRoot.toString()),
    nullifier: cairo.felt(nullifier.toString()),
    partial_commitment: cairo.felt(partialCommitment.toString()),
    target_contract: targetContract,
    calldata: defiCalldata,
    input_amount: cairo.uint256(inputAmount),
    input_asset: inputAsset,
    output_asset: outputAsset,
    min_output_amount: cairo.uint256(minOutputAmount),
    relayer,
    fee: cairo.uint256(fee),
    encrypted_note_metadata: encryptedMetadata,
  })
}