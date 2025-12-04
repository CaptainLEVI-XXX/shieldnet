# ShieldNet Protocol Documentation

## Overview

ShieldNet is a privacy-preserving protocol built on Starknet that enables anonymous token transfers and DeFi interactions using Zero-Knowledge (ZK) proofs. It implements a UTXO-like note system where users deposit tokens into a shielded pool and can later withdraw, transfer, or interact with DeFi protocols without revealing their identity.

---

## Architecture
```
┌─────────────────────────────────────────────────────────────────────┐
│                          USER INTERFACE                             │
│                            Frontend                                 │
└────────────────────────────────┬────────────────────────────────────┘
                                 │
                    ┌────────────┴────────────┐
                    ▼                         ▼
┌──────────────────────────┐    ┌──────────────────────────┐
│      DIRECT EXECUTION    │    │    RELAYER EXECUTION     │
│   (User signs & pays)    │    │  (Anonymous, Relayer     │
│                          │    │   pays gas)              │
└──────────────────────────┘    └──────────────────────────┘
                    │                         │
                    └────────────┬────────────┘
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│                     STARKNET BLOCKCHAIN                              │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    ShieldPool Contract                       │   │
│  │  ┌─────────────┐ ┌─────────────┐ ┌──────────────────────┐   │   │
│  │  │ Merkle Tree │ │  Nullifier  │ │   ZK Verifiers       │   │   │
│  │  │ (Deposits)  │ │  Registry   │ │ (Noir UltraHonk)     │   │   │
│  │  └─────────────┘ └─────────────┘ └──────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Core Concepts

### 1. Notes (UTXOs)

A **Note** represents ownership of tokens in the shielded pool. Each note contains:
```
Note = {
  amount: Field,      // Token amount
  asset_id: Field,    // Token contract address
  blinding: Field,    // Random value for privacy
  owner_key: Field    // Owner's private/public key
}
```

**Commitment** (stored on-chain):
```
commitment = Hash4(amount, asset_id, blinding, owner_key)
```

The commitment is a hash of the note data, revealing nothing about the contents.

### 2. Nullifiers

A **Nullifier** is used to mark a note as spent without revealing which note:
```
nullifier = Hash3(commitment, private_key, leaf_index)
```

- Same note always produces same nullifier (prevents double-spend)
- Cannot derive commitment from nullifier (privacy preserved)

### 3. Merkle Tree

All commitments are stored in a Merkle tree:
```
                    Root
                   /    \
                H01      H23
               /  \     /  \
             H0   H1   H2   H3
             |    |    |    |
            C0   C1   C2   C3  (Commitments)
```

To prove ownership of a note, user provides:
- The commitment
- Merkle proof (sibling hashes + path bits)
- Proof verifies commitment is in the tree without revealing which one

### 4. Zero-Knowledge Proofs

We use **Noir circuits** compiled to **UltraHonk proofs** for Starknet:

- Proves knowledge of note data without revealing it
- Proves note exists in Merkle tree
- Proves nullifier is correctly computed
- Proves value conservation (inputs = outputs)

---



## ⚡ Key Features

### 1\. Private Transfers

Send crypto to anyone on Starknet without the world knowing who sent it, who received it, or how much was sent.

  * **Mechanism:** Uses the `transfer` circuit.
  * **Privacy:** Observer sees a proof and a new commitment, but cannot link it to the sender.
  * **Encryption:** The sender encrypts the note data with the recipient's public key so only they can claim the funds.

### 2\. The "Transact" Feature (DeFi)

ShieldNet's killer feature. It allows users to interact with **any public Starknet and Ztarknet dApp** anonymously.

**How it works (The Adapter Pattern):**

1.  **Proof Generation:** User generates a proof authorizing a swap (e.g., "Swap 100 USDC for ETH").
2.  **Transient Unshielding:** The ShieldPool contract temporarily unlocks the funds.
3.  **Execution:** The contract calls the external dApp (e.g., JediSwap).
4.  **Auto-Reshielding:** The returned assets (ETH) are immediately encapsulated into a new Private Note.
5.  **Result:** The public blockchain sees `ShieldPool <-> JediSwap`, but the actual user initiating the swap remains hidden.


## Operations

### 1. Deposit (Shield)

**Purpose**: Convert public tokens to private notes

**Flow**:
```
1. User computes: commitment = Hash4(amount, asset, blinding, publicKey)
2. User calls: approve(ShieldPool, amount)
3. User calls: deposit(commitment, amount)
4. Contract: transfers tokens, inserts commitment in Merkle tree
5. User: stores note data locally
```

**What's Public**: Deposit amount, commitment
**What's Private**: Note contents (blinding, owner)
```
┌──────────┐      ┌─────────────┐      ┌─────────────┐
│  User    │─────▶│ ERC20       │─────▶│ ShieldPool  │
│  Wallet  │      │ approve()   │      │ deposit()   │
└──────────┘      └─────────────┘      └─────────────┘
                                              │
                                              ▼
                                       ┌─────────────┐
                                       │ Merkle Tree │
                                       │ + Commitment│
                                       └─────────────┘
```

### 2. Withdraw (Unshield)

**Purpose**: Convert private notes back to public tokens

**Circuit**: `unshield.nr`

**Public Inputs**:
- merkle_root
- nullifier
- change_commitment
- recipient
- withdraw_amount
- relayer_fee

**Private Inputs**:
- Note data (amount, asset, blinding, private_key)
- Merkle proof (path_bits, siblings)
- Change note data

**Constraints Proven**:
1. Note commitment matches: `Hash4(note) == commitment`
2. Commitment in tree: `verify_merkle_proof(commitment, path, siblings) == root`
3. Nullifier correct: `Hash3(commitment, privKey, index) == nullifier`
4. Change commitment correct: `Hash4(changeNote) == change_commitment`
5. Value conservation: `input_amount == withdraw_amount + change_amount + fee`

**Flow**:
```
1. User generates ZK proof with circuit inputs
2. If using relayer:
   a. User sends proof + public inputs to relayer
   b. Relayer calls withdraw(), pays gas
   c. User receives tokens anonymously
3. If direct:
   a. User calls withdraw() directly (less private)
```

### 3. Transfer (Private → Private)

**Purpose**: Send shielded tokens to another user

**Circuit**: `transfer.nr`

**Public Inputs**:
- merkle_root
- nullifier (single input)
- commitment_1 (to recipient)
- commitment_2 (change to self)
- relayer_fee

**Private Inputs**:
- Input note data
- Merkle proof
- Output 1: amount, blinding, recipient_pub_key
- Output 2: change_amount, blinding, self_pub_key

**Constraints Proven**:
1. Input note valid and in tree
2. Nullifier correct
3. Output commitments correctly computed
4. Value conservation: `input == output1 + output2 + fee`

**Flow**:
```
┌──────────┐                    ┌──────────────┐
│  Sender  │───ZK Proof────────▶│   Relayer    │
│          │   + encrypted      │              │
│          │   note metadata    └──────┬───────┘
└──────────┘                           │
                                       ▼
                              ┌─────────────────┐
                              │   ShieldPool    │
                              │  transfer()     │
                              │                 │
                              │ • Mark nullifier│
                              │ • Add commit_1  │
                              │ • Add commit_2  │
                              │ • Emit event    │
                              └─────────────────┘
                                       │
                              ┌────────┴────────┐
                              ▼                 ▼
                       ┌──────────┐      ┌──────────┐
                       │ Recipient│      │  Sender  │
                       │ (new note│      │ (change) │
                       │ commitment)     └──────────┘
                       └──────────┘
```

### 4. Transact (Anonymous DeFi)

**Purpose**: Interact with DeFi protocols (swap, lend, borrow) anonymously

**Circuit**: `transact.nr`

**Public Inputs**:
- merkle_root
- nullifier
- target_contract (DeFi protocol address)
- calldata_hash (hash of DeFi call parameters)
- partial_commitment (for reshielding output)
- relayer_fee

**Private Inputs**:
- Input note data
- Merkle proof
- Output blinding and owner key

**Key Concept - Partial Commitment**:
```
partial_commitment = Hash2(out_blinding, out_owner_key)

// After DeFi execution, contract computes:
final_commitment = Hash4(received_amount, output_asset, partial_commitment, 0)
```

This allows reshielding DeFi output without knowing the exact output amount in advance.

**Flow**:
```
┌──────────┐         ┌──────────┐         ┌─────────────┐
│   User   │──proof─▶│  Relayer │──call──▶│ ShieldPool  │
└──────────┘         └──────────┘         │  transact() │
                                          └──────┬──────┘
                                                 │
                    ┌────────────────────────────┤
                    ▼                            ▼
             ┌─────────────┐             ┌─────────────┐
             │   DeFi      │◀───swap────│  Token      │
             │  Protocol   │             │  Transfer   │
             │ (JediSwap)  │────output──▶│             │
             └─────────────┘             └─────────────┘
                                                │
                                                ▼
                                         ┌─────────────┐
                                         │ Reshield    │
                                         │ Output as   │
                                         │ New Note    │
                                         └─────────────┘
```

---

## Cryptographic Primitives

### Poseidon Hash (BN254)

We use BN254 Poseidon hash for all commitments and nullifiers:
```typescript
// Hash functions with 251-bit masking for Starknet compatibility
hash2(a, b) = mask_251(poseidon([a, b]))
hash3(a, b, c) = mask_251(poseidon([a, b, c]))
hash4(a, b, c, d) = mask_251(poseidon([a, b, c, d]))
```

**Why Masking?**
- BN254 Poseidon outputs 256-bit values
- Starknet field (felt252) is 251 bits
- We mask top 5 bits: `value & ((1 << 251) - 1)`

### Key Derivation
```typescript
privateKey = random_251_bit_field_element()
publicKey = hash1(privateKey) = mask_251(poseidon([privateKey]))
```

---

### Privacy Properties

| Property | With Relayer | Without Relayer |
|----------|--------------|-----------------|
| Sender Hidden | ✅ | ❌ (gas payer visible) |
| Amount Hidden | ✅ (in change) | ✅ |
| Recipient Hidden | ❌ (for withdraw) | ❌ |
| Note Contents | ✅ | ✅ |

---
