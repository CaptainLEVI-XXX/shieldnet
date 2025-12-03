use dep::shieldnet_lib::{Note, verify_merkle_path};

fn main(
    // Private Input (Just 1 note for simplicity)
    in_amount: Field,
    in_asset_id: Field,
    in_blinding: Field,
    in_priv_key: Field,
    in_path: [Field; 2],
    in_siblings: [Field; 2],

    // Private Output (Change back to self)
    change_amount: Field,
    change_blinding: Field,
    change_pub_key: Field,

    // Public Inputs
    merkle_root: pub Field,
    nullifier: pub Field,
    change_commitment: pub Field,
    
    // The External Interaction
    recipient: pub Field,    // Public Starknet Address
    withdraw_amount: pub Field, // Amount to turn public
    relayer_fee: pub Field,
) {
    // 1. Verify Input Note
    let input_note = Note { amount: in_amount, asset_id: in_asset_id, blinding: in_blinding, owner_key: in_priv_key };
    verify_merkle_path(merkle_root, input_note.commitment(), in_path, in_siblings);
    assert(nullifier == input_note.nullifier(in_priv_key, 0));

    // 2. Verify Change Note
    let change_note = Note { amount: change_amount, asset_id: in_asset_id, blinding: change_blinding, owner_key: change_pub_key };
    assert(change_commitment == change_note.commitment());

    // 3. Verify Value Conservation
    // Input Note = Public Withdraw + Private Change + Relayer Fee
    let total_out = withdraw_amount + change_amount + relayer_fee;
    
    assert(in_amount == total_out, "Withdrawal math incorrect");
    
    // Implicit Check:
    // By declaring 'recipient' and 'withdraw_amount' as pub, 
    // we force the Verifier Contract to ensure those exact values are used
    // in the Starknet transfer logic.
}