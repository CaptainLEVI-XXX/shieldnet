// use dep::shieldnet_lib::{Note, verify_merkle_path};

// fn main(
//     // PRIVATE INPUT 1 
//     in1_amount: Field,
//     in1_asset_id: Field,
//     in1_blinding: Field,
//     in1_priv_key: Field,
//     in1_path: [Field; 2],
//     in1_siblings: [Field; 2],

//     // PRIVATE INPUT 2 
//     // If user only has 1 note, they fill this with ZEROs (Dummy Note)
//     in2_amount: Field,
//     in2_asset_id: Field,
//     in2_blinding: Field,
//     in2_priv_key: Field,
//     in2_path: [Field; 2],
//     in2_siblings: [Field; 2],

//     // PRIVATE OUTPUT (Change) 
//     change_amount: Field,
//     change_blinding: Field,
//     change_pub_key: Field,

//     // PUBLIC INPUTS 
//     merkle_root: pub Field,
    
//     // We now reveal TWO nullifiers to prevent double-spending either note
//     nullifier_1: pub Field,
//     nullifier_2: pub Field,
    
//     change_commitment: pub Field,
    
//     // External Interaction (Withdrawal details)
//     recipient: pub Field,       // Public Address
//     withdraw_amount: pub Field, // Public Amount
//     relayer_fee: pub Field,
// ) {
//     // Validation of Inputs

//     // Rule: You cannot mix assets. 
//     // You cannot merge 5 ETH + 50 USDC. 
//     // If in2 is used (amount > 0), IDs must match.
//     if in2_amount != 0 {
//         assert(in1_asset_id == in2_asset_id, "Cannot mix different asset types");
//     }

//     // Verify Input Note 1
//     let note1 = Note { 
//         amount: in1_amount, 
//         asset_id: in1_asset_id, 
//         blinding: in1_blinding, 
//         owner_key: in1_priv_key 
//     };
    
//     // Prove Note 1 exists in the tree
//     verify_merkle_path(merkle_root, note1.commitment(), in1_path, in1_siblings);
    
//     // Prove we derived the correct nullifier for Note 1
//     // Note: We use index '0' for the first nullifier
//     assert(nullifier_1 == note1.nullifier(in1_priv_key, 0));


//     // Verify Input Note 2 (Optional)
//     let note2 = Note { 
//         amount: in2_amount, 
//         asset_id: in2_asset_id, 
//         blinding: in2_blinding, 
//         owner_key: in2_priv_key 
//     };

//     if in2_amount != 0 {
//         // Only verify Merkle proof if the note actually carries value
//         verify_merkle_path(merkle_root, note2.commitment(), in2_path, in2_siblings);
        
//         // Check nullifier (using index '1' for uniqueness)
//         assert(nullifier_2 == note2.nullifier(in2_priv_key, 1));
//     } else {
//         // If amount is 0, this is a dummy note. 
//         // We ensure the nullifier provided is also 0 to keep state clean.
//         assert(nullifier_2 == 0);
//     }

//     // Validation of Output (Change)
    
//     // We assume the change note is the same asset as input 1
//     let change_note = Note { 
//         amount: change_amount, 
//         asset_id: in1_asset_id, 
//         blinding: change_blinding, 
//         owner_key: change_pub_key 
//     };
    
//     // Ensure the public commitment matches the private note details
//     assert(change_commitment == change_note.commitment());

//     // Conservation of Value
    
//     // Calculate Total Input
//     let total_in = in1_amount + in2_amount;

//     // Calculate Total Output (Public Withdraw + Private Change + Fee)
//     let total_out = withdraw_amount + change_amount + relayer_fee;

//     // The Equation that secures the money
//     assert(total_in == total_out, "Inputs must equal Outputs + Fee");
// }





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