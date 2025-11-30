use starknet::ContractAddress;

pub type Commitment = felt252;
pub type NullifierHash = felt252;
pub type MerkleRoot = felt252;

#[derive(Drop, Serde, Copy, starknet::Store)]
pub struct PoolConfig {
    pub asset: ContractAddress,
    pub tree_depth: u8,
    pub is_active: bool,
}

#[derive(Drop, Serde, starknet::Event)]
pub struct DepositEvent {
    #[key]
    pub commitment: Commitment,
    pub leaf_index: u32,
    pub timestamp: u64,
    pub amount: u256,
}

#[derive(Drop, Serde, starknet::Event)]
pub struct WithdrawEvent {
    #[key]
    pub nullifier_1: NullifierHash,
    #[key]
    pub nullifier_2: NullifierHash,
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
    pub nullifier: NullifierHash,
    pub target_contract: ContractAddress,
    pub input_amount: u256,
    pub output_asset: ContractAddress,
    pub output_amount: u256,
    pub output_commitment: Commitment
}

#[starknet::interface]
pub trait IShieldPool<TContractState> {
    fn deposit(ref self: TContractState, commitment: Commitment, amount: u256) -> u32;
    
    fn withdraw(
            ref self: TContractState,
            proof: Span<felt252>,
            merkle_root: felt252,
            nullifier_1: felt252, 
            nullifier_2: felt252, 
            change_commitment: felt252, // FIXED: We need to handle change
            recipient: ContractAddress,
            amount: u256, // The amount being withdrawn
            relayer: ContractAddress,
            fee: u256,
        );
    
     fn transfer(
            ref self: TContractState,
            proof: Span<felt252>,
            merkle_root: felt252,
            nullifier_1: felt252,
            nullifier_2: felt252,
            commitment_1: felt252,
            commitment_2: felt252,
            relayer: ContractAddress,
            fee: u256,
            encrypted_note_1: Span<felt252>, 
            encrypted_note_2: Span<felt252>
        );
    
     fn transact(
            ref self: TContractState,
            proof: Span<felt252>,
            merkle_root: felt252,
            nullifier: felt252,
            partial_commitment: felt252, // Hash(Blinding, OwnerKey) only!
            target_contract: ContractAddress,
            calldata: Span<felt252>,
            input_amount: u256, // How much to take from the input note
            input_asset: ContractAddress, // What we are selling
            output_asset: ContractAddress, // What we expect to buy
            min_output_amount: u256, // Slippage protection
            relayer: ContractAddress,
            fee: u256,
            encrypted_note_metadata: Span<felt252> // So user can decrypt the new note
        );
    
    fn get_merkle_root(self: @TContractState) -> MerkleRoot;
    fn is_nullifier_spent(self: @TContractState, nullifier_hash: NullifierHash) -> bool;
    fn get_pool_config(self: @TContractState) -> PoolConfig;
    fn get_deposit_count(self: @TContractState) -> u32;
    fn is_valid_root(self: @TContractState, root: MerkleRoot) -> bool;
}