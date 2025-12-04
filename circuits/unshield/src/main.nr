use dep::shieldnet_lib::{Note, verify_merkle_path};

fn main(
    // PRIVATE INPUT 
    in_amount: Field,
    in_asset_id: Field,
    in_blinding: Field,
    in_priv_key: Field,
    in_path: [Field; 5],
    in_siblings: [Field; 5],

    // PRIVATE CHANGE OUTPUT 
    change_amount: Field,
    change_blinding: Field,
    change_pub_key: Field,

    // PUBLIC INPUTS 
    merkle_root: pub Field,
    nullifier: pub Field,
    change_commitment: pub Field,
    
    // Interaction Details
    recipient: pub Field,
    withdraw_amount: pub Field,
    relayer_fee: pub Field,
) {
    //  Verify Input
    let note_in = Note { 
        amount: in_amount, 
        asset_id: in_asset_id, 
        blinding: in_blinding, 
        owner_key: in_priv_key 
    };
    
    let index = verify_merkle_path(merkle_root, note_in.commitment(), in_path, in_siblings);
    assert(nullifier == note_in.nullifier(in_priv_key, index));

    // Verify Change Note
    let note_change = Note { 
        amount: change_amount, 
        asset_id: in_asset_id, // Change must be same asset
        blinding: change_blinding, 
        owner_key: change_pub_key 
    };
    assert(change_commitment == note_change.commitment());

    //  Value Conservation
    // Input = Withdraw Amount (Public) + Change (Private) + Fee
    let total_out = withdraw_amount + change_amount + relayer_fee;
    assert(in_amount == total_out, "Value mismatch");
}