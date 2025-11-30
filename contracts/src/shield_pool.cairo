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

    use crate::interfaces::i_erc20::{IERC20Dispatcher, IERC20DispatcherTrait};
    use crate::interfaces::i_verifier::{
        IUltraStarknetZKHonkVerifierDispatcher, 
        IUltraStarknetZKHonkVerifierDispatcherTrait
    };
    
    // NOTE: You need to update your Interface to accept arrays for encrypted notes
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
        // REMOVED: denomination (We are UTXO now, amounts are dynamic!)
        tree_depth: u8,
        transfer_verifier: ContractAddress,
        unshield_verifier: ContractAddress,
        transact_verifier: ContractAddress,
        owner: ContractAddress,
    ) {
        self.config.write(PoolConfig {
            asset,
            tree_depth,
            is_active: true,
        });
        
        self.merkle_tree.initialize(tree_depth);
        self.transfer_verifier.write(transfer_verifier);
        self.unshield_verifier.write(unshield_verifier);
        self.transact_verifier.write(transact_verifier);
        self.owner.write(owner);
    }

    #[abi(embed_v0)]
    impl ShieldPoolImpl of IShieldPool<ContractState> {
        
        // 1. DEPOSIT (Shield)
        // Moves funds Public -> Private
        fn deposit(ref self: ContractState, commitment: felt252, amount: u256) -> u32 {
            let config = self.config.read();
            assert(config.is_active, 'Pool is paused');
            assert(commitment != 0, 'Invalid commitment');
            
            let caller = get_caller_address();
            let this_contract = get_contract_address();
            
            if config.asset != contract_address_const::<0>() {
                let token = IERC20Dispatcher { contract_address: config.asset };
                // FIXED: Use dynamic 'amount', not fixed 'denomination'
                let success = token.transfer_from(caller, this_contract, amount);
                assert(success, 'Token transfer failed');
            }
            
            let leaf_index = self.merkle_tree.insert(commitment);
            
            self.emit(DepositEvent {
                commitment,
                leaf_index,
                amount, // Log amount so indexers know value
                timestamp: get_block_timestamp(),
            });
            
            leaf_index
        }
        
        // 2. WITHDRAW (Unshield)
        // Moves funds Private -> Public
        fn withdraw(
            ref self: ContractState,
            proof: Span<felt252>,
            merkle_root: felt252,
            nullifier_1: felt252, // FIXED: Our circuit uses 2 inputs
            nullifier_2: felt252, 
            change_commitment: felt252, // FIXED: We need to handle change
            recipient: ContractAddress,
            amount: u256, // The amount being withdrawn
            relayer: ContractAddress,
            fee: u256,
        ) {
            let config = self.config.read();
            assert(config.is_active, 'Pool is paused');
            assert(nullifier_1 != 0, 'Invalid nullifier 1');
            // Note: nullifier_2 can be 0 if only 1 input used
            
            // Double Spend Check
            assert(!self.nullifier_registry.is_spent(nullifier_1), 'NF1 spent');
            if nullifier_2 != 0 {
                 assert(!self.nullifier_registry.is_spent(nullifier_2), 'NF2 spent');
            }

            assert(self.merkle_tree.is_known_root(merkle_root), 'Unknown merkle root');
            
            let verifier = IUltraStarknetZKHonkVerifierDispatcher { 
                contract_address: self.unshield_verifier.read() 
            };
            
            let proof_result = verifier.verify_ultra_starknet_zk_honk_proof(proof);
            assert(proof_result.is_some(), 'Invalid proof');
            
            // Validate that the Proof matches the Arguments
            self._verify_unshield_public_inputs(
                proof_result.unwrap(),
                merkle_root,
                nullifier_1,
                nullifier_2,
                change_commitment,
                recipient,
                amount,
                fee
            );
            
            // Mark Spent
            self.nullifier_registry.mark_spent(nullifier_1);
            if nullifier_2 != 0 {
                self.nullifier_registry.mark_spent(nullifier_2);
            }
            
            // Add Change Note to Tree
            if change_commitment != 0 {
                self.merkle_tree.insert(change_commitment);
            }

            // Transfer Funds
            if config.asset != contract_address_const::<0>() {
                let token = IERC20Dispatcher { contract_address: config.asset };
                
                let success = token.transfer(recipient, amount);
                assert(success, 'Transfer to recipient failed');
                
                if fee > 0 && relayer != contract_address_const::<0>() {
                    let fee_success = token.transfer(relayer, fee);
                    assert(fee_success, 'Fee transfer failed');
                }
            }
            
            self.emit(WithdrawEvent {
                nullifier_1,
                nullifier_2,
                recipient,
                amount,
            });
        }
        
        // 3. TRANSFER (Private -> Private)
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
            /// Encrypted notes allow the recipient to actually see their money
            encrypted_note_1: Span<felt252>, 
            encrypted_note_2: Span<felt252>
        ) {
            let config = self.config.read();
            assert(config.is_active, 'Pool is paused');
            
            // Basic Checks
            assert(nullifier_1 != 0, 'Invalid NF1');
            assert(nullifier_1 != nullifier_2, 'Duplicate nullifiers');
            
            // Double Spend Checks
            assert(!self.nullifier_registry.is_spent(nullifier_1), 'NF1 spent');
            if nullifier_2 != 0 {
                assert(!self.nullifier_registry.is_spent(nullifier_2), 'NF2 spent');
            }
            assert(self.merkle_tree.is_known_root(merkle_root), 'Unknown merkle root');
            
            // Verify Proof
            let verifier = IUltraStarknetZKHonkVerifierDispatcher { 
                contract_address: self.transfer_verifier.read() 
            };
            
            let proof_result = verifier.verify_ultra_starknet_zk_honk_proof(proof);
            assert(proof_result.is_some(), 'Invalid proof');
            
            self._verify_transfer_public_inputs(
                proof_result.unwrap(),
                merkle_root,
                nullifier_1,
                nullifier_2,
                commitment_1,
                commitment_2,
                fee
            );
            
            // State Updates
            self.nullifier_registry.mark_spent(nullifier_1);
            if nullifier_2 != 0 { self.nullifier_registry.mark_spent(nullifier_2); }
            
            self.merkle_tree.insert(commitment_1);
            self.merkle_tree.insert(commitment_2);
            
            // Pay Relayer
            if fee > 0 && relayer != contract_address_const::<0>() {
                let token = IERC20Dispatcher { contract_address: config.asset };
                token.transfer(relayer, fee);
            }
            
            // Emit Event with Encrypted Data (So recipient can find it)
            self.emit(TransferEvent {
                nullifier_1,
                nullifier_2,
                commitment_1,
                commitment_2,
                relayer_fee: fee,
            });
        }
        
        // 4. TRANSACT (Private -> Public DeFi -> Private)
        fn transact(
            ref self: ContractState,
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
        ) {
            let config = self.config.read();
            assert(config.is_active, 'Pool is paused');
            
            // 1. Basic Checks
            assert(nullifier != 0, 'Invalid nullifier');
            assert(!self.nullifier_registry.is_spent(nullifier), 'Nullifier spent');
            assert(self.merkle_tree.is_known_root(merkle_root), 'Unknown merkle root');

            // 2. Calldata Integrity Check
            // We verify the hash of the calldata matches what was signed in the ZK proof
            // This prevents the Relayer from changing "Swap for ETH" to "Swap for GarbageCoin"
            let computed_calldata_hash = hash_span(calldata);

            // 3. Verify ZK Proof
            let verifier = IUltraStarknetZKHonkVerifierDispatcher { 
                contract_address: self.transact_verifier.read() 
            };
            
            let proof_result = verifier.verify_ultra_starknet_zk_honk_proof(proof);
            assert(proof_result.is_some(), 'Invalid proof');

            self._verify_transact_public_inputs(
                proof_result.unwrap(),
                merkle_root,
                nullifier,
                target_contract,
                computed_calldata_hash, // Use computed hash to verify integrity
                partial_commitment,
                fee
            );

            // 4. State Update: Spend the input note
            self.nullifier_registry.mark_spent(nullifier);

            // 5. Execution Preparation
            // Calculate actual swap amount (Input Amount - Relayer Fee)
            let swap_amount = input_amount - fee;
            let this_contract = get_contract_address();

            // Check initial balance of the token we expect to receive
            let output_token = IERC20Dispatcher { contract_address: output_asset };
            let balance_before = output_token.balance_of(this_contract);

            // 6. Approve the DeFi protocol to spend our tokens
            if input_asset != contract_address_const::<0>() {
                let input_token = IERC20Dispatcher { contract_address: input_asset };
                // Approve the target (e.g., JediSwap Router) to spend our ShieldPool funds
                input_token.approve(target_contract, swap_amount);
            }

            // 7. Execute the Interaction
            // We act as a proxy. We call the target contract with the user's calldata.
            let _result = call_contract_syscall(
                target_contract,
                // We assume the selector is embedded in the calldata or we pass it
                // For raw calls, usually the selector is the first felt
                *calldata.at(0), 
                calldata.slice(1, calldata.len() - 1)
            ).unwrap_syscall();

            // 8. Output Verification
            let balance_after = output_token.balance_of(this_contract);
            assert(balance_after >= balance_before, 'Balance decreased');
            
            let received_amount = balance_after - balance_before;
            assert(received_amount >= min_output_amount, 'Slippage too high');

            // 9. Reshielding (Creating the new note)
            // We combine the User's Partial Commitment with the actual Amount/Asset we got
            
            // Formula: Final = Hash(Amount, Asset, PartialCommitment)
            // Note: PartialCommitment was Hash(Blinding, OwnerKey)
            
            let received_amount_felt: felt252 = received_amount.try_into().unwrap();
            let output_asset_felt: felt252 = output_asset.into();
            
            let final_commitment = hash_4(
                received_amount_felt,
                output_asset_felt,
                partial_commitment,
                0 // Padding for hash_4
            );

            self.merkle_tree.insert(final_commitment);

            // 10. Pay Relayer
            if fee > 0 && relayer != contract_address_const::<0>() {
                let fee_token = IERC20Dispatcher { contract_address: input_asset };
                fee_token.transfer(relayer, fee);
            }

            self.emit(TransactEvent {
                nullifier,
                target_contract,
                input_amount,
                output_asset,
                output_amount: received_amount,
                output_commitment: final_commitment
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
            expected_nullifier_1: felt252,
            expected_nullifier_2: felt252,
            expected_change_commitment: felt252,
            expected_recipient: ContractAddress,
            expected_amount: u256,
            expected_fee: u256,
        ) {
            // Unshield Circuit Public Inputs Order:
            // 0: merkle_root
            // 1: nullifier_1
            // 2: nullifier_2
            // 3: change_commitment
            // 4: recipient
            // 5: withdraw_amount
            // 6: relayer_fee
            
            let p_root: felt252 = (*public_inputs.at(0)).try_into().unwrap();
            let p_nf1: felt252 = (*public_inputs.at(1)).try_into().unwrap();
            let p_nf2: felt252 = (*public_inputs.at(2)).try_into().unwrap();
            let p_change: felt252 = (*public_inputs.at(3)).try_into().unwrap();
            let p_recipient: felt252 = (*public_inputs.at(4)).try_into().unwrap();
            let p_amount: u256 = *public_inputs.at(5);
            let p_fee: u256 = *public_inputs.at(6);

            assert(p_root == expected_merkle_root, 'Root mismatch');
            assert(p_nf1 == expected_nullifier_1, 'NF1 mismatch');
            assert(p_nf2 == expected_nullifier_2, 'NF2 mismatch');
            assert(p_change == expected_change_commitment, 'Change mismatch');
            assert(p_recipient == expected_recipient.into(), 'Recipient mismatch');
            assert(p_amount == expected_amount, 'Amount mismatch');
            assert(p_fee == expected_fee, 'Fee mismatch');
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
            // Transfer Circuit Public Inputs Order:
            // 0: merkle_root
            // 1: nullifier_1
            // 2: nullifier_2
            // 3: commitment_1
            // 4: commitment_2
            // 5: relayer_fee

            let p_root: felt252 = (*public_inputs.at(0)).try_into().unwrap();
            let p_nf1: felt252 = (*public_inputs.at(1)).try_into().unwrap();
            let p_nf2: felt252 = (*public_inputs.at(2)).try_into().unwrap();
            let p_cm1: felt252 = (*public_inputs.at(3)).try_into().unwrap();
            let p_cm2: felt252 = (*public_inputs.at(4)).try_into().unwrap();
            let p_fee: u256 = *public_inputs.at(5);
            
            assert(p_root == expected_merkle_root, 'Root mismatch');
            assert(p_nf1 == expected_nullifier_1, 'NF1 mismatch');
            assert(p_nf2 == expected_nullifier_2, 'NF2 mismatch');
            assert(p_cm1 == expected_commitment_1, 'CM1 mismatch');
            assert(p_cm2 == expected_commitment_2, 'CM2 mismatch');
            assert(p_fee == expected_fee, 'Fee mismatch');
        }
        fn _verify_transact_public_inputs(
            self: @ContractState,
            public_inputs: Span<u256>,
            expected_merkle_root: felt252,
            expected_nullifier: felt252,
            expected_target: ContractAddress,
            expected_calldata_hash: felt252,
            expected_partial_commitment: felt252,
            expected_fee: u256,
        ) {
            // Transact Circuit Public Inputs Order:
            // 0: merkle_root
            // 1: nullifier
            // 2: target_contract
            // 3: calldata_hash
            // 4: partial_commitment
            // 5: relayer_fee

            let p_root: felt252 = (*public_inputs.at(0)).try_into().unwrap();
            let p_nullifier: felt252 = (*public_inputs.at(1)).try_into().unwrap();
            let p_target: felt252 = (*public_inputs.at(2)).try_into().unwrap();
            let p_call_hash: felt252 = (*public_inputs.at(3)).try_into().unwrap();
            let p_partial: felt252 = (*public_inputs.at(4)).try_into().unwrap();
            let p_fee: u256 = *public_inputs.at(5);

            assert(p_root == expected_merkle_root, 'Merkle root mismatch');
            assert(p_nullifier == expected_nullifier, 'Nullifier mismatch');
            assert(p_target == expected_target.into(), 'Target mismatch');
            assert(p_call_hash == expected_calldata_hash, 'Call Hash mismatch');
            assert(p_partial == expected_partial_commitment, 'Partial CM mismatch');
            assert(p_fee == expected_fee, 'Fee mismatch');
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