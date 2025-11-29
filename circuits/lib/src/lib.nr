use std::hash::poseidon::bn254;
//Hashing Wrapper (Standardizing Poseidon)
pub fn hash_2(a: Field, b: Field) -> Field {
    bn254::hash_2([a, b])
}

pub fn hash_3(a: Field, b: Field, c: Field) -> Field {
    bn254::hash_3([a, b, c])
}

pub fn hash_4(a: Field, b: Field, c: Field, d: Field) -> Field {
    bn254::hash_4([a, b, c, d])
}

// The Core Data Structure: A Private Note
pub struct Note {
    amount: Field,
    asset_id: Field,     // Address of the token (ETH/USDC)
    blinding: Field,     // Randomness
    owner_key: Field     // User's private key derivative
}

impl Note {
    //Calculate the public commitment (what goes on-chain)
    pub fn commitment(self) -> Field {
        hash_4(self.amount, self.asset_id, self.blinding, self.owner_key)
    }

    // Calculate the nullifier (the "spent" tag)
    // Note: Requires the full private key to prove ownership
    pub fn nullifier(self, priv_key: Field, index: Field) -> Field {
        // We hash the commitment + priv_key to ensure only owner can spend
        // We add index to ensure uniqueness if spending multiple notes
        hash_3(self.commitment(), priv_key, index)
    }
}

// Merkle Tree Verification
// Verifies that a specific leaf exists in the tree root
pub fn verify_merkle_path(
    root: Field,
    leaf: Field,
    path_indices: [Field; 20],
    siblings: [Field; 20]
) {
    let mut current = leaf;
    for i in 0..20 {
        let sibling = siblings[i];
        let is_right = path_indices[i];
        
        // If is_right == 1, current is on right: hash(sibling, current)
        // If is_right == 0, current is on left:  hash(current, sibling)
        if is_right == 1 {
            current = hash_2(sibling, current);
        } else {
            current = hash_2(current, sibling);
        }
    }
    assert(current == root, "Merkle membership check failed");
}