#[starknet::component]
pub mod MerkleTreeComponent {
    use starknet::storage::{
        StoragePointerReadAccess, 
        StoragePointerWriteAccess,
        StorageMapReadAccess, 
        StorageMapWriteAccess,
        Map
    };
    use crate::helpers::poseidon_utils::hash_2;

    pub const MAX_DEPTH: u8 = 20;
    pub const ROOT_HISTORY_SIZE: u32 = 100;


    #[storage]
    pub struct Storage {
        root: felt252,
        next_index: u32,
        depth: u8,
        filled_subtrees: Map<u8, felt252>,
        roots: Map<u32, felt252>,
        current_root_index: u32,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {}

    #[generate_trait]
    pub impl InternalImpl<
        TContractState, 
        +HasComponent<TContractState>
    > of InternalTrait<TContractState> {
        
        fn initialize(ref self: ComponentState<TContractState>, depth: u8) {
            assert(depth <= MAX_DEPTH, 'Depth too large');
            
            self.depth.write(depth);
            self.next_index.write(0);
            self.current_root_index.write(0);
            
            let mut current_zero: felt252 = 0;
            let mut i: u8 = 0;
            while i != depth {
                self.filled_subtrees.write(i, current_zero);
                current_zero = hash_2(current_zero, current_zero);
                i += 1;
            };
            
            self.root.write(current_zero);
            self.roots.write(0, current_zero);
        }
        
        fn insert(ref self: ComponentState<TContractState>, leaf: felt252) -> u32 {
            let next_index = self.next_index.read();
            let depth = self.depth.read();
            
            let max_size: u32 = Self::pow2(depth.into());
            assert(next_index < max_size, 'Merkle tree is full');
            
            let new_root = self._insert_leaf(leaf, next_index, depth);
            
            let new_root_index = (self.current_root_index.read() + 1) % ROOT_HISTORY_SIZE;
            self.current_root_index.write(new_root_index);
            self.roots.write(new_root_index, new_root);
            self.root.write(new_root);
            
            self.next_index.write(next_index + 1);
            
            next_index
        }
        
        fn _insert_leaf(
            ref self: ComponentState<TContractState>,
            leaf: felt252,
            index: u32,
            depth: u8
        ) -> felt252 {
            let mut current_hash = leaf;
            let mut current_index = index;
            let mut i: u8 = 0;
            
            while i != depth {
                let is_left = (current_index % 2) == 0;
                
                if is_left {
                    let zero_value = Self::get_zero_value(i);
                    self.filled_subtrees.write(i, current_hash);
                    current_hash = hash_2(current_hash, zero_value);
                } else {
                    let sibling = self.filled_subtrees.read(i);
                    current_hash = hash_2(sibling, current_hash);
                }
                
                current_index = current_index / 2;
                i += 1;
            };
            
            current_hash
        }
        
        fn get_root(self: @ComponentState<TContractState>) -> felt252 {
            self.root.read()
        }
        
        fn get_next_index(self: @ComponentState<TContractState>) -> u32 {
            self.next_index.read()
        }
        
        fn is_known_root(self: @ComponentState<TContractState>, root: felt252) -> bool {
            if root == 0 {
                return false;
            }
            
            let current_root = self.root.read();
            if root == current_root {
                return true;
            }
            
            let current_index = self.current_root_index.read();
            let mut i: u32 = 0;
            while i != ROOT_HISTORY_SIZE {
                let idx = if current_index >= i {
                    current_index - i
                } else {
                    ROOT_HISTORY_SIZE - (i - current_index)
                };
                
                let historical_root = self.roots.read(idx);
                if historical_root == root {
                    return true;
                }
                
                if historical_root == 0 {
                    break;
                }
                
                i += 1;
            };
            
            false
        }

        fn get_zero_value(level: u8) -> felt252 {
            let mut zero: felt252 = 0;
            let mut i: u8 = 0;
            while i != level {
                zero = hash_2(zero, zero);
                i += 1;
            };
            zero
        }
        
    fn pow2(n: u32) -> u32 {
            let mut result: u32 = 1;
            let mut i: u32 = 0;
            while i != n {
                result = result * 2;
                i += 1;
            };
            result
        }
        
    }
}