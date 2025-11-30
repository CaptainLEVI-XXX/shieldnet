#[starknet::contract]
pub mod ShieldPool {
    use starknet::{
        ContractAddress,
        get_caller_address,
        get_block_timestamp,
        get_contract_address,
        syscalls::call_contract_syscall,
        SyscallResultTrait,
        contract_address_const,
    };
    use starknet::storage::{
        StoragePointerReadAccess, 
        StoragePointerWriteAccess,
    };
    // use openzeppelin_token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};
    use crate::interfaces::i_erc20::{IERC20Dispatcher, IERC20DispatcherTrait};
    use crate::interfaces::i_verifier::{
        IUltraStarknetZKHonkVerifierDispatcher, 
        IUltraStarknetZKHonkVerifierDispatcherTrait
    };
    
    use crate::interfaces::i_shield_pool::{
        PoolConfig,
        DepositEvent, 
        WithdrawEvent, 
        TransferEvent, 
        TransactEvent,
        IShieldPool
    };
    use crate::helpers::poseidon_utils::{hash_4, hash_span};
    use crate::helpers::merkle_tree::MerkleTreeComponent;
    use crate::helpers::nullifier_registry::NullifierRegistryComponent;
    
    component!(path: MerkleTreeComponent, storage: merkle_tree, event: MerkleTreeEvent);
    component!(path: NullifierRegistryComponent, storage: nullifier_registry, event: NullifierRegistryEvent);

    pub impl MerkleTreeImpl = MerkleTreeComponent::InternalImpl<ContractState>;
    
    pub impl NullifierRegistryImpl = NullifierRegistryComponent::InternalImpl<ContractState>;
    
    #[storage]
    pub struct Storage {
        config: PoolConfig,
        #[substorage(v0)]
        merkle_tree: MerkleTreeComponent::Storage,
        #[substorage(v0)]
        nullifier_registry: NullifierRegistryComponent::Storage,
        transfer_verifier: ContractAddress,
        unshield_verifier: ContractAddress,
        transact_verifier: ContractAddress,
        owner: ContractAddress,
        total_deposits: u256,
        total_withdrawals: u256,
    }

    
    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        Deposit: DepositEvent,
        Withdraw: WithdrawEvent,
        Transfer: TransferEvent,
        Transact: TransactEvent,
        #[flat]
        MerkleTreeEvent: MerkleTreeComponent::Event,
        #[flat]
        NullifierRegistryEvent: NullifierRegistryComponent::Event,
    }
    
    #[constructor]
    fn constructor(
        ref self: ContractState,
        asset: ContractAddress,
        denomination: u256,
        tree_depth: u8,
        transfer_verifier: ContractAddress,
        unshield_verifier: ContractAddress,
        transact_verifier: ContractAddress,
        owner: ContractAddress,
    ) {
        self.config.write(PoolConfig {
            asset,
            denomination,
            tree_depth,
            is_active: true,
        });
        
        self.merkle_tree.initialize(tree_depth);
        
        self.transfer_verifier.write(transfer_verifier);
        self.unshield_verifier.write(unshield_verifier);
        self.transact_verifier.write(transact_verifier);
        self.owner.write(owner);
    }

    // EXTERNAL IMPLEMENTATION
    
    #[abi(embed_v0)]
    impl ShieldPoolImpl of IShieldPool<ContractState> {
        
        
        fn deposit(ref self: ContractState, commitment: felt252) -> u32 {
            let config = self.config.read();
            assert(config.is_active, 'Pool is paused');
            assert(commitment != 0, 'Invalid commitment');
            
            let caller = get_caller_address();
            let this_contract = get_contract_address();
            
            if config.asset != contract_address_const::<0>() {
                let token = IERC20Dispatcher { contract_address: config.asset };
                let success = token.transfer_from(caller, this_contract, config.denomination);
                assert(success, 'Token transfer failed');
            }
            
            let leaf_index = self.merkle_tree.insert(commitment);
            
            let current_deposits = self.total_deposits.read();
            self.total_deposits.write(current_deposits + config.denomination);
            
            self.emit(DepositEvent {
                commitment,
                leaf_index,
                timestamp: get_block_timestamp(),
            });
            
            leaf_index
        }
        
        fn withdraw(
            ref self: ContractState,
            proof: Span<felt252>,
            merkle_root: felt252,
            nullifier_hash: felt252,
            recipient: ContractAddress,
            relayer: ContractAddress,
            fee: u256,
        ) {
            let config = self.config.read();
            assert(config.is_active, 'Pool is paused');
            assert(nullifier_hash != 0, 'Invalid nullifier');
            assert(recipient != contract_address_const::<0>(), 'Invalid recipient');
            
            assert(!self.nullifier_registry.is_spent(nullifier_hash), 'Nullifier already spent');
            assert(self.merkle_tree.is_known_root(merkle_root), 'Unknown merkle root');
            
            let verifier = IUltraStarknetZKHonkVerifierDispatcher { 
                contract_address: self.unshield_verifier.read() 
            };
            
            let proof_result = verifier.verify_ultra_starknet_zk_honk_proof(proof);
            assert(proof_result.is_some(), 'Invalid proof');
            
            let public_inputs = proof_result.unwrap();
            self._verify_unshield_public_inputs(
                public_inputs,
                merkle_root,
                nullifier_hash,
                recipient,
                fee
            );
            
            self.nullifier_registry.mark_spent(nullifier_hash);
            
            let withdraw_amount = config.denomination - fee;
            
            if config.asset != contract_address_const::<0>() {
                let token = IERC20Dispatcher { contract_address: config.asset };
                
                let success = token.transfer(recipient, withdraw_amount);
                assert(success, 'Transfer to recipient failed');
                
                if fee > 0 && relayer != contract_address_const::<0>() {
                    let fee_success = token.transfer(relayer, fee);
                    assert(fee_success, 'Fee transfer failed');
                }
            }
            
            let current_withdrawals = self.total_withdrawals.read();
            self.total_withdrawals.write(current_withdrawals + config.denomination);
            
            self.emit(WithdrawEvent {
                nullifier_hash,
                recipient,
                amount: withdraw_amount,
            });
        }
        
        fn transfer(
            ref self: ContractState,
            proof: Span<felt252>,
            merkle_root: felt252,
            nullifier_1: felt252,
            nullifier_2: felt252,
            commitment_1: felt252,
            commitment_2: felt252,
            relayer: ContractAddress,
            fee: u256,
        ) {
            let config = self.config.read();
            assert(config.is_active, 'Pool is paused');
            assert(nullifier_1 != 0, 'Invalid nullifier 1');
            assert(nullifier_2 != 0, 'Invalid nullifier 2');
            assert(nullifier_1 != nullifier_2, 'Duplicate nullifiers');
            assert(commitment_1 != 0, 'Invalid commitment 1');
            assert(commitment_2 != 0, 'Invalid commitment 2');
            
            assert(!self.nullifier_registry.is_spent(nullifier_1), 'Nullifier 1 already spent');
            assert(!self.nullifier_registry.is_spent(nullifier_2), 'Nullifier 2 already spent');
            assert(self.merkle_tree.is_known_root(merkle_root), 'Unknown merkle root');
            
            let verifier = IUltraStarknetZKHonkVerifierDispatcher { 
                contract_address: self.transfer_verifier.read() 
            };
            
            let proof_result = verifier.verify_ultra_starknet_zk_honk_proof(proof);
            assert(proof_result.is_some(), 'Invalid proof');
            
            let public_inputs = proof_result.unwrap();
            self._verify_transfer_public_inputs(
                public_inputs,
                merkle_root,
                nullifier_1,
                nullifier_2,
                commitment_1,
                commitment_2,
                fee
            );
            
            self.nullifier_registry.mark_spent(nullifier_1);
            self.nullifier_registry.mark_spent(nullifier_2);
            
            self.merkle_tree.insert(commitment_1);
            self.merkle_tree.insert(commitment_2);
            
            if fee > 0 && relayer != contract_address_const::<0>() {
                    let token = IERC20Dispatcher { contract_address: config.asset };
                    token.transfer(relayer, fee);
            }
            
            self.emit(TransferEvent {
                nullifier_1,
                nullifier_2,
                commitment_1,
                commitment_2,
                relayer_fee: fee,
            });
        }
        
        fn transact(
            ref self: ContractState,
            proof: Span<felt252>,
            merkle_root: felt252,
            nullifier: felt252,
            partial_commitment: felt252,
            target_contract: ContractAddress,
            calldata_hash: felt252,
            calldata: Span<felt252>,
            output_asset: ContractAddress,
            min_output_amount: u256,
            relayer: ContractAddress,
            fee: u256,
        ) {
            let config = self.config.read();
            assert(config.is_active, 'Pool is paused');
            assert(nullifier != 0, 'Invalid nullifier');
            assert(partial_commitment != 0, 'Invalid partial commitment');
            assert(target_contract != contract_address_const::<0>(), 'Invalid target');
            
            assert(!self.nullifier_registry.is_spent(nullifier), 'Nullifier already spent');
            assert(self.merkle_tree.is_known_root(merkle_root), 'Unknown merkle root');
            
            let computed_calldata_hash = hash_span(calldata);
            assert(computed_calldata_hash == calldata_hash, 'Calldata hash mismatch');
            
            let verifier = IUltraStarknetZKHonkVerifierDispatcher { 
                contract_address: self.transact_verifier.read() 
            };
            
            let proof_result = verifier.verify_ultra_starknet_zk_honk_proof(proof);
            assert(proof_result.is_some(), 'Invalid proof');
            
            let public_inputs = proof_result.unwrap();
            self._verify_transact_public_inputs(
                public_inputs,
                merkle_root,
                nullifier,
                partial_commitment,
                target_contract,
                calldata_hash,
                fee
            );
            
            self.nullifier_registry.mark_spent(nullifier);
            
            let input_amount = config.denomination - fee;
            
            if config.asset != contract_address_const::<0>() {
                let token = IERC20Dispatcher { contract_address: config.asset };
                let approve_success = token.approve(target_contract, input_amount);
                assert(approve_success, 'Approve failed');
            }
            
            let _result = call_contract_syscall(
                target_contract,
                selector!("execute"),
                calldata
            ).unwrap_syscall();
            
            let this_contract = get_contract_address();
            let output_token = IERC20Dispatcher { contract_address: output_asset };
            let output_amount = output_token.balance_of(this_contract);
            
            assert(output_amount >= min_output_amount, 'Slippage too high');
            
            let output_amount_felt: felt252 = output_amount.try_into().unwrap();
            let output_asset_felt: felt252 = output_asset.into();
            let final_commitment = hash_4(
                output_amount_felt,
                output_asset_felt,
                partial_commitment,
                0
            );
            
            self.merkle_tree.insert(final_commitment);
            
            if fee > 0 && relayer != contract_address_const::<0>(){
                    let fee_token = IERC20Dispatcher { contract_address: config.asset };
                    fee_token.transfer(relayer, fee);
            }
            
            self.emit(TransactEvent {
                nullifier,
                target_contract,
                calldata_hash,
                input_amount,
                output_asset,
                output_amount,
                output_commitment: final_commitment,
                relayer_fee: fee,
            });
        }
        
        fn get_merkle_root(self: @ContractState) -> felt252 {
            self.merkle_tree.get_root()
        }
        
        fn is_nullifier_spent(self: @ContractState, nullifier_hash: felt252) -> bool {
            self.nullifier_registry.is_spent(nullifier_hash)
        }
        
        fn get_pool_config(self: @ContractState) -> PoolConfig {
            self.config.read()
        }
        
        fn get_deposit_count(self: @ContractState) -> u32 {
            self.merkle_tree.get_next_index()
        }
        
        fn is_valid_root(self: @ContractState, root: felt252) -> bool {
            self.merkle_tree.is_known_root(root)
        }
    }
    
    #[generate_trait]
    impl InternalImpl<ContractState> of InternalTrait<ContractState> {
        
        fn _verify_unshield_public_inputs(
            self: @ContractState,
            public_inputs: Span<u256>,
            expected_merkle_root: felt252,
            expected_nullifier_hash: felt252,
            expected_recipient: ContractAddress,
            expected_fee: u256,
        ) {
            assert(public_inputs.len() >= 6, 'Not enough public inputs');
            
            let proof_merkle_root: felt252 = (*public_inputs.at(0)).try_into().unwrap();
            let proof_nullifier: felt252 = (*public_inputs.at(1)).try_into().unwrap();
            let proof_recipient: felt252 = (*public_inputs.at(3)).try_into().unwrap();
            let proof_fee: u256 = *public_inputs.at(5);
            
            assert(proof_merkle_root == expected_merkle_root, 'Merkle root mismatch');
            assert(proof_nullifier == expected_nullifier_hash, 'Nullifier mismatch');
            
            let expected_recipient_felt: felt252 = expected_recipient.into();
            assert(proof_recipient == expected_recipient_felt, 'Recipient mismatch');
            assert(proof_fee == expected_fee, 'Fee mismatch');
        }
        
        fn _verify_transfer_public_inputs(
            self: @ContractState,
            public_inputs: Span<u256>,
            expected_merkle_root: felt252,
            expected_nullifier_1: felt252,
            expected_nullifier_2: felt252,
            expected_commitment_1: felt252,
            expected_commitment_2: felt252,
            expected_fee: u256,
        ) {
            assert(public_inputs.len() >= 6, 'Not enough public inputs');
            
            let proof_merkle_root: felt252 = (*public_inputs.at(0)).try_into().unwrap();
            let proof_nullifier_1: felt252 = (*public_inputs.at(1)).try_into().unwrap();
            let proof_nullifier_2: felt252 = (*public_inputs.at(2)).try_into().unwrap();
            let proof_commitment_1: felt252 = (*public_inputs.at(3)).try_into().unwrap();
            let proof_commitment_2: felt252 = (*public_inputs.at(4)).try_into().unwrap();
            let proof_fee: u256 = *public_inputs.at(5);
            
            assert(proof_merkle_root == expected_merkle_root, 'Merkle root mismatch');
            assert(proof_nullifier_1 == expected_nullifier_1, 'Nullifier 1 mismatch');
            assert(proof_nullifier_2 == expected_nullifier_2, 'Nullifier 2 mismatch');
            assert(proof_commitment_1 == expected_commitment_1, 'Commitment 1 mismatch');
            assert(proof_commitment_2 == expected_commitment_2, 'Commitment 2 mismatch');
            assert(proof_fee == expected_fee, 'Fee mismatch');
        }
        
        fn _verify_transact_public_inputs(
            self: @ContractState,
            public_inputs: Span<u256>,
            expected_merkle_root: felt252,
            expected_nullifier: felt252,
            expected_partial_commitment: felt252,
            expected_target_contract: ContractAddress,
            expected_calldata_hash: felt252,
            expected_fee: u256,
        ) {
            assert(public_inputs.len() >= 6, 'Not enough public inputs');
            
            let proof_merkle_root: felt252 = (*public_inputs.at(0)).try_into().unwrap();
            let proof_nullifier: felt252 = (*public_inputs.at(1)).try_into().unwrap();
            let proof_target: felt252 = (*public_inputs.at(2)).try_into().unwrap();
            let proof_calldata_hash: felt252 = (*public_inputs.at(3)).try_into().unwrap();
            let proof_partial_commitment: felt252 = (*public_inputs.at(4)).try_into().unwrap();
            let proof_fee: u256 = *public_inputs.at(5);
            
            assert(proof_merkle_root == expected_merkle_root, 'Merkle root mismatch');
            assert(proof_nullifier == expected_nullifier, 'Nullifier mismatch');
            
            let expected_target_felt: felt252 = expected_target_contract.into();
            assert(proof_target == expected_target_felt, 'Target contract mismatch');
            assert(proof_calldata_hash == expected_calldata_hash, 'Calldata hash mismatch');
            assert(proof_partial_commitment == expected_partial_commitment, 'Partial commitment mismatch');
            assert(proof_fee == expected_fee, 'Fee mismatch');
        }
    }
    #[generate_trait]
    impl AdminImpl of AdminTrait {
        
        fn _only_owner(self: @ContractState) {
            let caller = get_caller_address();
            let owner = self.owner.read();
            assert(caller == owner, 'Only owner');
        }
        
        fn pause(ref self: ContractState) {
            self._only_owner();
            let mut config = self.config.read();
            config.is_active = false;
            self.config.write(config);
        }
        
        fn unpause(ref self: ContractState) {
            self._only_owner();
            let mut config = self.config.read();
            config.is_active = true;
            self.config.write(config);
        }
        
        fn set_transfer_verifier(ref self: ContractState, new_verifier: ContractAddress) {
            self._only_owner();
            self.transfer_verifier.write(new_verifier);
        }
        
        fn set_unshield_verifier(ref self: ContractState, new_verifier: ContractAddress) {
            self._only_owner();
            self.unshield_verifier.write(new_verifier);
        }
        
        fn set_transact_verifier(ref self: ContractState, new_verifier: ContractAddress) {
            self._only_owner();
            self.transact_verifier.write(new_verifier);
        }
    }
}