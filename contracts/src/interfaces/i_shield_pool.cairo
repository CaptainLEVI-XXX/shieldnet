use starknet::ContractAddress;

pub type Commitment = felt252;
pub type NullifierHash = felt252;
pub type MerkleRoot = felt252;

#[derive(Drop, Serde, Copy, starknet::Store)]
pub struct PoolConfig {
    pub asset: ContractAddress,
    pub denomination: u256,
    pub tree_depth: u8,
    pub is_active: bool,
}

#[derive(Drop, Serde, starknet::Event)]
pub struct DepositEvent {
    #[key]
    pub commitment: Commitment,
    pub leaf_index: u32,
    pub timestamp: u64,
}

#[derive(Drop, Serde, starknet::Event)]
pub struct WithdrawEvent {
    #[key]
    pub nullifier_hash: NullifierHash,
    pub recipient: ContractAddress,
    pub amount: u256,
}

#[derive(Drop, Serde, starknet::Event)]
pub struct TransferEvent {
    #[key]
    pub nullifier_1: NullifierHash,
    #[key]
    pub nullifier_2: NullifierHash,
    pub commitment_1: Commitment,
    pub commitment_2: Commitment,
    pub relayer_fee: u256,
}

#[derive(Drop, Serde, starknet::Event)]
pub struct TransactEvent {
    #[key]
    pub nullifier: NullifierHash,
    pub target_contract: ContractAddress,
    pub calldata_hash: felt252,
    pub input_amount: u256,
    pub output_asset: ContractAddress,
    pub output_amount: u256,
    pub output_commitment: Commitment,
    pub relayer_fee: u256,
}

#[starknet::interface]
pub trait IShieldPool<TContractState> {
    fn deposit(ref self: TContractState, commitment: Commitment) -> u32;
    
    fn withdraw(
        ref self: TContractState,
        proof: Span<felt252>,
        merkle_root: MerkleRoot,
        nullifier_hash: NullifierHash,
        recipient: ContractAddress,
        relayer: ContractAddress,
        fee: u256,
    );
    
    fn transfer(
        ref self: TContractState,
        proof: Span<felt252>,
        merkle_root: MerkleRoot,
        nullifier_1: NullifierHash,
        nullifier_2: NullifierHash,
        commitment_1: Commitment,
        commitment_2: Commitment,
        relayer: ContractAddress,
        fee: u256,
    );
    
    fn transact(
        ref self: TContractState,
        proof: Span<felt252>,
        merkle_root: MerkleRoot,
        nullifier: NullifierHash,
        partial_commitment: felt252,
        target_contract: ContractAddress,
        calldata_hash: felt252,
        calldata: Span<felt252>,
        output_asset: ContractAddress,
        min_output_amount: u256,
        relayer: ContractAddress,
        fee: u256,
    );
    
    fn get_merkle_root(self: @TContractState) -> MerkleRoot;
    fn is_nullifier_spent(self: @TContractState, nullifier_hash: NullifierHash) -> bool;
    fn get_pool_config(self: @TContractState) -> PoolConfig;
    fn get_deposit_count(self: @TContractState) -> u32;
    fn is_valid_root(self: @TContractState, root: MerkleRoot) -> bool;
}