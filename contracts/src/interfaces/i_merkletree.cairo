#[starknet::interface]
pub trait IMerkleTree {
    fn initialize(ref self: MerkleTreeStorage, depth: u8);
    fn insert(ref self: MerkleTreeStorage, leaf: felt252) -> u32;
    fn compute_insert(
        ref self: MerkleTreeStorage,
        leaf: felt252,
        index: u32,
        depth: u8,
    ) -> felt252;

    fn is_known_root(self: @MerkleTreeStorage, root: felt252) -> bool;
}
