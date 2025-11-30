#[starknet::component]
pub mod NullifierRegistryComponent {
    use starknet::storage::{
        StoragePointerReadAccess, 
        StoragePointerWriteAccess,
        StorageMapReadAccess, 
        StorageMapWriteAccess,
        Map
    };

    
    #[storage]
    pub struct Storage {
        nullifiers: Map<felt252, bool>,
        spent_count: u64,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {}

    #[generate_trait]
    pub impl InternalImpl<
        TContractState, 
        +HasComponent<TContractState>
    > of InternalTrait<TContractState> {
        
        fn is_spent(self: @ComponentState<TContractState>, nullifier_hash: felt252) -> bool {
            self.nullifiers.read(nullifier_hash)
        }
        
        fn mark_spent(ref self: ComponentState<TContractState>, nullifier_hash: felt252) {
            let already_spent = self.nullifiers.read(nullifier_hash);
            assert(!already_spent, 'Nullifier already spent');
            
            self.nullifiers.write(nullifier_hash, true);
            
            let current_count = self.spent_count.read();
            self.spent_count.write(current_count + 1);
        }
        
        fn get_spent_count(self: @ComponentState<TContractState>) -> u64 {
            self.spent_count.read()
        }
    }
}