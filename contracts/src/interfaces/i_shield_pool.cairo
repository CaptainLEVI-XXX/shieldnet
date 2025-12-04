use starknet::ContractAddress;

#[derive(Drop, Copy, Serde, starknet::Store)]
pub struct PoolConfig {
    pub asset: ContractAddress,
    pub tree_depth: u8,
    pub is_active: bool,
}

#[derive(Drop, starknet::Event)]
pub struct DepositEvent {
    pub commitment: felt252,
    pub leaf_index: u32,
    pub amount: u256,
    pub timestamp: u64,
}

#[derive(Drop, starknet::Event)]
pub struct WithdrawEvent {
    pub nullifier: felt252,
    pub recipient: ContractAddress,
    pub amount: u256,
}

#[derive(Drop, starknet::Event)]
pub struct TransferEvent {
    pub nullifier: felt252,
    pub commitment_1: felt252,
    pub commitment_2: felt252,
    pub relayer_fee: u256,
}

#[derive(Drop, starknet::Event)]
pub struct TransactEvent {
    pub nullifier: felt252,
    pub target_contract: ContractAddress,
    pub input_amount: u256,
    pub output_asset: ContractAddress,
    pub output_amount: u256,
    pub output_commitment: felt252,
}

#[starknet::interface]
pub trait IShieldPool<TContractState> {
    fn deposit(ref self: TContractState, commitment: felt252, amount: u256) -> u32;
    
    fn withdraw(
        ref self: TContractState,
        proof: Span<felt252>,
        merkle_root: felt252,
        nullifier: felt252,
        change_commitment: felt252,
        recipient: ContractAddress,
        amount: u256,
        relayer: ContractAddress,
        fee: u256,
    );
    
    fn transfer(
        ref self: TContractState,
        proof: Span<felt252>,
        merkle_root: felt252,
        nullifier: felt252,
        commitment_1: felt252,
        commitment_2: felt252,
        relayer: ContractAddress,
        fee: u256,
        encrypted_note_1: Span<felt252>,
        encrypted_note_2: Span<felt252>,
    );
    
    fn transact(
        ref self: TContractState,
        proof: Span<felt252>,
        merkle_root: felt252,
        nullifier: felt252,
        partial_commitment: felt252,
        target_contract: ContractAddress,
        calldata: Span<felt252>,
        input_amount: u256,
        input_asset: ContractAddress,
        output_asset: ContractAddress,
        min_output_amount: u256,
        relayer: ContractAddress,
        fee: u256,
        encrypted_note_metadata: Span<felt252>,
    );
    
    fn get_merkle_root(self: @TContractState) -> felt252;
    fn is_nullifier_spent(self: @TContractState, nullifier_hash: felt252) -> bool;
    fn get_pool_config(self: @TContractState) -> PoolConfig;
    fn get_deposit_count(self: @TContractState) -> u32;
    fn is_valid_root(self: @TContractState, root: felt252) -> bool;
}