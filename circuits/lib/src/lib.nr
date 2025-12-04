
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



// 1. Hashing Wrapper (Standardizing Poseidon BN254)
pub fn hash_2(a: Field, b: Field) -> Field {
    mask_to_stark_field(std::hash::poseidon::bn254::hash_2([a, b]))
}

pub fn hash_3(a: Field, b: Field, c: Field) -> Field {
    mask_to_stark_field(std::hash::poseidon::bn254::hash_3([a, b, c]))
}

pub fn hash_4(a: Field, b: Field, c: Field, d: Field) -> Field {
    mask_to_stark_field(std::hash::poseidon::bn254::hash_4([a, b, c, d]))
}

// The Core Data Structure: A Private Note
pub struct Note {
    pub amount: Field,
    pub asset_id: Field,
    pub blinding: Field,
    pub owner_key: Field
}

impl Note {
    // Calculate the public commitment
    pub fn commitment(self) -> Field {
        hash_4(self.amount, self.asset_id, self.blinding, self.owner_key)
    }

    // Nullifier depends on the LEAF INDEX (Position in Tree)
    // This prevents "Index Swapping" attacks.
    pub fn nullifier(self, priv_key: Field, leaf_index: Field) -> Field {
        hash_3(self.commitment(), priv_key, leaf_index)
    }
}

// Merkle Tree Verification (Returns the Calculated Index)
// - Proves 'leaf' is in 'root'
// - Returns the exact index (0, 1, 2...) where it was found
pub fn verify_merkle_path(
    root: Field,
    leaf: Field,
    path_indices: [Field; 5], // 0 for left, 1 for right
    siblings: [Field; 5]
) -> Field {
    let mut current = leaf;
    let mut calculated_index: Field = 0;
    let mut power_of_two: Field = 1;

    for i in 0..5 {
        let sibling = siblings[i];
        let direction_bit = path_indices[i];

        // Ensure direction is boolean (0 or 1)
        assert(direction_bit * (direction_bit - 1) == 0, "Path index must be 0 or 1");

        // Reconstruct the Index:
        // If we went right (1), add the power of two for this level
        calculated_index = calculated_index + (direction_bit * power_of_two);
        power_of_two = power_of_two * 2;

        // Hash up the tree
        // Note: We use the bit to swap order (Branchless logic)
        // If right (1): hash(sibling, current)
        // If left (0):  hash(current, sibling)
        if direction_bit == 1 {
            current = hash_2(sibling, current);
        } else {
            current = hash_2(current, sibling);
        }
    }

    assert(current == root, "Merkle membership check failed");
    
    // Return the verified position
    calculated_index
}