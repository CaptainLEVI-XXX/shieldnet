use dep::shieldnet_lib::{Note, verify_merkle_path, hash_2};

fn main(
    // Private Input
    in_amount: Field,
    in_asset_id: Field,
    in_blinding: Field,
    in_priv_key: Field,
    in_path: [Field; 2],
    in_siblings: [Field; 2],

    // Private Secret for the FUTURE output note
    out_blinding: Field,
    out_owner_key: Field,

    // Public Inputs
    merkle_root: pub Field,
    nullifier: pub Field,
    
    // DeFi Specifics
    target_contract: pub Field, // e.g. JediSwap Router
    calldata_hash: pub Field,   // Hash of the swap instructions
    
    // The "Transient" Commitment (Partial)
    // This is hash(blinding, owner_key) only. Amount and Asset are added by contract later.
    partial_commitment: pub Field,
    relayer_fee: pub Field
) {
    // 1. Verify Input Note (Spending the USDC)
    let input_note = Note { amount: in_amount, asset_id: in_asset_id, blinding: in_blinding, owner_key: in_priv_key };
    verify_merkle_path(merkle_root, input_note.commitment(), in_path, in_siblings);
    assert(nullifier == input_note.nullifier(in_priv_key, 0));

    // 2. Verify the Partial Commitment
    // We prove we know the secrets for the funds that will return from DeFi
    let computed_partial = hash_2(out_blinding, out_owner_key);
    assert(computed_partial == partial_commitment);

    // 3. Fee Check
    // We ensure the input amount covers the fee. 
    // The rest (in_amount - fee) is sent to the DeFi adapter.
    assert(in_amount as u64 >= relayer_fee as u64);
    
    // Note: We do not check exact output amounts here because 
    // we don't know the result of the swap yet.
}