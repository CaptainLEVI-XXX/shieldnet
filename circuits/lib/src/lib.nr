// use std::hash::poseidon::bn254;
// //Hashing Wrapper (Standardizing Poseidon)

// // Starknet prime: 2^251 + 17*2^192 + 1
// // We'll use a masking approach to ensure outputs fit

// // Simple approach: mask to 251 bits
// // This is cryptographically safe as it's still a large field
// fn mask_to_stark_field(value: Field) -> Field {
//     // Convert to bytes, mask top bits, convert back
//     // For simplicity, we can use the value directly if < prime
//     // Otherwise, we need explicit reduction
    
//     // A practical approach: use the lower 251 bits
//     // This maintains collision resistance while ensuring fit
//     let bytes = value.to_be_bytes::<32>();
    
//     // Clear the top 5 bits (256 - 251 = 5)
//     let mut masked_bytes = bytes;
//     masked_bytes[0] = masked_bytes[0] & 0x07; // Keep only bottom 3 bits of first byte
    
//     Field::from_be_bytes::<32>(masked_bytes)
// }

// pub fn hash_2(a: Field, b: Field) -> Field {
//     let h = bn254::hash_2([a, b]);
//     mask_to_stark_field(h)
// }

// pub fn hash_3(a: Field, b: Field, c: Field) -> Field {
//     let h = bn254::hash_3([a, b, c]);
//     mask_to_stark_field(h)
// }

// pub fn hash_4(a: Field, b: Field, c: Field, d: Field) -> Field {
//     let h = bn254::hash_4([a, b, c, d]);
//     mask_to_stark_field(h)
// }

// // The Core Data Structure: A Private Note
// pub struct Note {
//     pub amount: Field,
//     pub asset_id: Field,     // Address of the token (ETH/USDC)
//     pub blinding: Field,     // Randomness
//     pub owner_key: Field     // User's private key derivative
// }

// impl Note {
//     //Calculate the public commitment (what goes on-chain)
//     pub fn commitment(self) -> Field {
//         hash_4(self.amount, self.asset_id, self.blinding, self.owner_key)
//     }

//     // Calculate the nullifier (the "spent" tag)
//     // Note: Requires the full private key to prove ownership
//     pub fn nullifier(self, priv_key: Field, index: Field) -> Field {
//         // We hash the commitment + priv_key to ensure only owner can spend
//         // We add index to ensure uniqueness if spending multiple notes
//         hash_3(self.commitment(), priv_key, index)
//     }
// }

// // Merkle Tree Verification
// // Verifies that a specific leaf exists in the tree root
// pub fn verify_merkle_path(
//     root: Field,
//     leaf: Field,
//     path_indices: [Field; 5],
//     siblings: [Field; 5]
// ) {
//     let mut current = leaf;
//     for i in 0..5 {
//         let sibling = siblings[i];
//         let is_right = path_indices[i];
        
//         // If is_right == 1, current is on right: hash(sibling, current)
//         // If is_right == 0, current is on left:  hash(current, sibling)
//         if is_right == 1 {
//             current = hash_2(sibling, current);
//         } else {
//             current = hash_2(current, sibling);
//         }
//     }
//     assert(current == root, "Merkle membership check failed");
// }


use std::hash::poseidon::bn254;

// 2^251 as a field element
global TWO_POW_251: Field = 0x0800000000000000000000000000000000000000000000000000000000000000;

// Unconstrained = NO circuit constraints, just computation
unconstrained fn compute_quotient_and_masked(value: Field) -> (Field, u8) {
    let bytes = value.to_be_bytes::<32>();
    let top_bits = bytes[0] >> 3;  // Top 5 bits = quotient
    
    let mut masked_bytes = bytes;
    masked_bytes[0] = bytes[0] & 0x07;  // Keep only bottom 3 bits
    let masked = Field::from_be_bytes::<32>(masked_bytes);
    
    (masked, top_bits)
}

fn mask_to_stark_field(value: Field) -> Field {
    let (masked, quotient_u8) = unsafe {
        compute_quotient_and_masked(value)
    };

    // Convert u8 -> Field
    let quotient = quotient_u8 as u32;
    let quotient_f = Field::from(quotient);

    assert(quotient < 32, "quotient overflow");

    assert(
        value == masked + quotient_f * TWO_POW_251,
        "mask verification failed"
    );

    masked
}


// Hash functions with optimized masking
pub fn hash_2(a: Field, b: Field) -> Field {
    let h = bn254::hash_2([a, b]);
    mask_to_stark_field(h)
}

pub fn hash_3(a: Field, b: Field, c: Field) -> Field {
    let h = bn254::hash_3([a, b, c]);
    mask_to_stark_field(h)
}

pub fn hash_4(a: Field, b: Field, c: Field, d: Field) -> Field {
    let h = bn254::hash_4([a, b, c, d]);
    mask_to_stark_field(h)
}

// Rest of your Note struct and verify_merkle_path stay the same
pub struct Note {
    pub amount: Field,
    pub asset_id: Field,
    pub blinding: Field,
    pub owner_key: Field
}

impl Note {
    pub fn commitment(self) -> Field {
        hash_4(self.amount, self.asset_id, self.blinding, self.owner_key)
    }

    pub fn nullifier(self, priv_key: Field, index: Field) -> Field {
        hash_3(self.commitment(), priv_key, index)
    }
}

pub fn verify_merkle_path(
    root: Field,
    leaf: Field,
    path_indices: [Field; 2],  // Your depth
    siblings: [Field; 2]
) {
    let mut current = leaf;
    for i in 0..2 {
        let sibling = siblings[i];
        let is_right = path_indices[i];
        
        if is_right == 1 {
            current = hash_2(sibling, current);
        } else {
            current = hash_2(current, sibling);
        }
    }
    assert(current == root, "Merkle membership check failed");
}