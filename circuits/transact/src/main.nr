use dep::shieldnet_lib::{Note, verify_merkle_path, hash_2};

fn main(
    // PRIVATE INPUT 
    in_amount: Field,
    in_asset_id: Field,
    in_blinding: Field,
    in_priv_key: Field,
    in_path: [Field; 5],
    in_siblings: [Field; 5],

    // OUTPUT SECRETS 
    out_blinding: Field,
    out_owner_key: Field,

    // PUBLIC INPUTS
    merkle_root: pub Field,
    nullifier: pub Field,
    
    target_contract: pub Field, 
    calldata_hash: pub Field,   
    partial_commitment: pub Field,
    relayer_fee: pub Field
) {
    //Verify Input
    let note_in = Note { 
        amount: in_amount, 
        asset_id: in_asset_id, 
        blinding: in_blinding, 
        owner_key: in_priv_key 
    };
    
    let index = verify_merkle_path(merkle_root, note_in.commitment(), in_path, in_siblings);
    assert(nullifier == note_in.nullifier(in_priv_key, index));

    //  Verify Partial Commitment
    // This locks the destination of the funds returning from DeFi
    let computed_partial = hash_2(out_blinding, out_owner_key);
    assert(computed_partial == partial_commitment);

    //  Fee Check
    // Input must be large enough to pay the Relayer
    // The rest (in_amount - fee) goes to the Target Contract
    assert(in_amount as u128 >= relayer_fee as u128, "Insufficient funds for fee");
}