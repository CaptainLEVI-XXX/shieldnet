#[starknet::interface]
pub trait IUltraStarknetZKHonkVerifier<TContractState> {
    /// Verify proof and return public inputs if valid
    /// Returns None if proof is invalid, Some(public_inputs) if valid
    fn verify_ultra_starknet_zk_honk_proof(
        self: @TContractState, 
        full_proof_with_hints: Span<felt252>,
    ) -> Option<Span<u256>>;
}
