use dep::shieldnet_lib::{Note, verify_merkle_path};

fn main(
    // PRIVATE INPUT
    in_amount: Field,
    in_asset_id: Field,
    in_blinding: Field,
    in_priv_key: Field,
    in_path: [Field; 2],
    in_siblings: [Field; 2],

    // PRIVATE OUTPUT (Change) 
    change_amount: Field,
    change_blinding: Field,
    change_pub_key: Field,

    // PUBLIC INPUTS 
    merkle_root: pub Field,
    nullifier: pub Field,
    change_commitment: pub Field,
    recipient: pub Field,
    withdraw_amount: pub Field,
) {
    // Verify Input Note
    let note = Note { 
        amount: in_amount, 
        asset_id: in_asset_id, 
        blinding: in_blinding, 
        owner_key: in_priv_key 
    };
    
    // Prove note exists in tree
    verify_merkle_path(merkle_root, note.commitment(), in_path, in_siblings);
    
    // Prove nullifier is correct
    assert(nullifier == note.nullifier(in_priv_key, 0));

    // Validate change output
    let change_note = Note { 
        amount: change_amount, 
        asset_id: in_asset_id, 
        blinding: change_blinding, 
        owner_key: change_pub_key 
    };
    
    assert(change_commitment == change_note.commitment());

    // Conservation of value
    assert(in_amount == withdraw_amount + change_amount);
}