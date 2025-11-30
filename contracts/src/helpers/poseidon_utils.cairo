use core::poseidon::PoseidonTrait;
use core::hash::HashStateTrait;
use core::poseidon::poseidon_hash_span;

pub fn hash_1(input: felt252) -> felt252 {
    let mut state = PoseidonTrait::new();
    state = state.update(input);
    state.finalize()
}

pub fn hash_2(a: felt252, b: felt252) -> felt252 {
    let mut state = PoseidonTrait::new();
    state = state.update(a);
    state = state.update(b);
    state.finalize()
}

pub fn hash_3(a: felt252, b: felt252, c: felt252) -> felt252 {
    let mut state = PoseidonTrait::new();
    state = state.update(a);
    state = state.update(b);
    state = state.update(c);
    state.finalize()
}

pub fn hash_4(a: felt252, b: felt252, c: felt252, d: felt252) -> felt252 {
    let mut state = PoseidonTrait::new();
    state = state.update(a);
    state = state.update(b);
    state = state.update(c);
    state = state.update(d);
    state.finalize()
}

pub fn hash_span(inputs: Span<felt252>) -> felt252 {
    poseidon_hash_span(inputs)
}

