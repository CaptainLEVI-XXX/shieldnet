use dep::shieldnet_lib::{Note, verify_merkle_path, hash_2};

fn main(
    // PRIVATE INPUT 
    in_amount: Field,
    in_asset_id: Field,
    in_blinding: Field,
    in_priv_key: Field,
    in_path: [Field; 5],
    in_siblings: [Field; 5],

    //  PRIVATE OUTPUTS (Secrets)
    out1_amount: Field,
    out1_blinding: Field,
    out1_pub_key: Field,
    
    out2_amount: Field,
    out2_blinding: Field,
    out2_pub_key: Field,

    //  PUBLIC INPUTS
    merkle_root: pub Field,
    nullifier: pub Field,     
    commitment_1: pub Field,
    commitment_2: pub Field,
    relayer_fee: pub Field,
) {
    //  Verify Input Ownership & Existence
    let note_in = Note { 
        amount: in_amount, 
        asset_id: in_asset_id, 
        blinding: in_blinding, 
        owner_key: in_priv_key 
    };
    
    // Check Merkle Proof and get the Index
    let index = verify_merkle_path(merkle_root, note_in.commitment(), in_path, in_siblings);
    
    // Check Nullifier correctness
    assert(nullifier == note_in.nullifier(in_priv_key, index));

    //  Verify Output Commitments
    // We construct the notes inside the circuit to ensure they match the public commitments
    let out1 = Note { 
        amount: out1_amount, 
        asset_id: in_asset_id, // Asset ID must stay same
        blinding: out1_blinding, 
        owner_key: out1_pub_key 
    };
    
    let out2 = Note { 
        amount: out2_amount, 
        asset_id: in_asset_id, 
        blinding: out2_blinding, 
        owner_key: out2_pub_key 
    };
    
    assert(commitment_1 == out1.commitment());
    assert(commitment_2 == out2.commitment());

    // Value Conservation
    // Input = Output 1 + Output 2 + Fee
    let total_out = out1_amount + out2_amount + relayer_fee;
    assert(in_amount == total_out, "Value mismatch: Input != Outputs + Fee");
}