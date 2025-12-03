#!/bin/bash
set -e

echo "Generating verifiers with Garaga..."
echo "Note: This generates verifiers without needing actual proofs"

CIRCUITS=("transact" "transfer" "unshield")

for circuit in "${CIRCUITS[@]}"; do
    echo ""
    echo "Processing $circuit..."
    
    cd "circuits/$circuit"


    echo "Compiling circuit..."
    nargo compile

    
    # Step 2: Generate verifying key (doesn't need witness!)
    echo "  Generating verifying key..."
    # bb write_vk --scheme ultra_honk \
    # -b ./target/${circuit}.json \
    # -o ./target/vk
    bb write_vk --scheme ultra_honk --oracle_hash starknet -b target/$circuit.json -o target
    
    cd ../..


done

echo ""
echo "============================================"
echo "Verifier generation complete!"
echo "Check verifiers/ for output"
echo "============================================"