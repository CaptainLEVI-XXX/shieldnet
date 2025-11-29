use shieldnet_lib::{Note, verify_merkle_path};

fn main(
    // Input Note 1
    in1_amount: Field,
    in1_asset_id: Field,
    in1_blinding: Field,
    in1_priv_key: Field,
    in1_path: [Field; 20],
    in1_siblings: [Field; 20],
    
    // Input Note 2 (Optional, set amount=0 if unused)
    in2_amount: Field,
    in2_asset_id: Field,
    in2_blinding: Field,
    in2_priv_key: Field,
    in2_path: [Field; 20],
    in2_siblings: [Field; 20],

    // Output Note 1 (Destination)
    out1_amount: Field,
    out1_blinding: Field,
    out1_pub_key: Field, // Recipient's public key

    // Output Note 2 (Change)
    out2_amount: Field,
    out2_blinding: Field,
    out2_pub_key: Field, // Usually sender's public key

    merkle_root: pub Field,
    nullifier_1: pub Field,
    nullifier_2: pub Field,
    commitment_1: pub Field,
    commitment_2: pub Field,
    relayer_fee: pub Field,
) {
    // Reconstruct Input Notes
    // We assume asset_id must match for inputs (no cross-asset mixing in transfer)
    assert(in1_asset_id == in2_asset_id);
    
    let note1 = Note { amount: in1_amount, asset_id: in1_asset_id, blinding: in1_blinding, owner_key: in1_priv_key };
    let note2 = Note { amount: in2_amount, asset_id: in2_asset_id, blinding: in2_blinding, owner_key: in2_priv_key };

    // Verify Membership (Do these notes actually exist?)
    if in1_amount != 0 {
        verify_merkle_path(merkle_root, note1.commitment(), in1_path, in1_siblings);
        // Verify user derived the nullifier correctly
        assert(nullifier_1 == note1.nullifier(in1_priv_key, 0));
    }

    if in2_amount != 0 {
        verify_merkle_path(merkle_root, note2.commitment(), in2_path, in2_siblings);
        assert(nullifier_2 == note2.nullifier(in2_priv_key, 1));
    }

    // Construct Output Notes & Check Commitments
    // Note: The circuit doesn't care who owns outputs, just that the math adds up.
    let out_note1 = Note { amount: out1_amount, asset_id: in1_asset_id, blinding: out1_blinding, owner_key: out1_pub_key };
    let out_note2 = Note { amount: out2_amount, asset_id: in1_asset_id, blinding: out2_blinding, owner_key: out2_pub_key };

    assert(commitment_1 == out_note1.commitment());
    assert(commitment_2 == out_note2.commitment());

    // THE GOLDEN RULE: Conservation of Value
    // Input = Output + Fee
    let total_in = in1_amount + in2_amount;
    let total_out = out1_amount + out2_amount + relayer_fee;

    assert(total_in == total_out, "Value mismatch: Money created or destroyed");
}