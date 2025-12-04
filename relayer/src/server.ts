
import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { 
    Account, 
    RpcProvider,
    stark,
    ec,
} from 'starknet';

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json({ limit: '10mb' }));

// ============================================================================
// CONFIGURATION
// ============================================================================
const RPC_URL = process.env.SEPOLIA_RPC as string || 'https://starknet-sepolia.public.blastapi.io';
const RELAYER_ADDRESS = process.env.ACCOUNT_ADDRESS! as string;
const RELAYER_PRIVATE_KEY = process.env.PRIVATE_KEY! as string;
const SHIELD_POOL_ADDRESS = process.env.SHIELD_POOL_ADDRESS! as string;

if (!RELAYER_ADDRESS || !RELAYER_PRIVATE_KEY || !SHIELD_POOL_ADDRESS) {
    console.error('❌ Missing required environment variables:');
    console.error('   ACCOUNT_ADDRESS, PRIVATE_KEY, SHIELD_POOL_ADDRESS');
    process.exit(1);
}

const provider = new RpcProvider({ nodeUrl: RPC_URL });

// Correct Account constructor for starknet.js v5/v6
const relayerAccount = new Account({
  provider: provider,
  address: RELAYER_ADDRESS,
  signer: RELAYER_PRIVATE_KEY,
});

console.log(`\n⚡ ShieldNet Relayer Starting...`);
console.log(`📝 Relayer Address: ${RELAYER_ADDRESS}`);
console.log(`🔗 RPC: ${RPC_URL}`);
console.log(`🏦 Shield Pool: ${SHIELD_POOL_ADDRESS}`);

// ============================================================================
// HELPER: Safe Simulation
// ============================================================================
async function simulateTransaction(call: any): Promise<{ success: boolean; error?: string }> {
    try {
        // Try simulation, but don't fail if it errors due to RPC issues
        const simulation:any = await relayerAccount.simulateTransaction([call], {
            skipValidate: false,
        });
        
        if (Array.isArray(simulation) && simulation[0]?.transaction_trace?.revert_reason) {
            return { 
                success: false, 
                error: simulation[0].transaction_trace.revert_reason 
            };
        }
        
        return { success: true };
    } catch (error: any) {
        // If simulation fails due to RPC issues, we can try executing anyway
        console.log(`   ⚠️  Simulation warning: ${error.message}`);
        
        // Check if it's a contract-level revert vs RPC issue
        if (error.message?.includes('Contract not found') || 
            error.message?.includes('reverted') ||
            error.message?.includes('REJECTED')) {
            return { success: false, error: error.message };
        }
        
        // For other errors (like fee estimation issues), allow to proceed
        console.log('   ⚠️  Proceeding without simulation...');
        return { success: true };
    }
}

// ============================================================================
// ENDPOINT: /relay
// ============================================================================
app.post('/relay', async (req, res) => {
    try {
        const { type, calldata, public_inputs } = req.body;

        if (!calldata || !public_inputs || !type) {
            res.status(400).json({ 
                error: "Missing parameters: type, calldata, public_inputs required" 
            });
            return;
        }

        console.log(`\n⚡ Relay Request: ${type}`);
        console.log(`   Calldata length: ${calldata.length}`);
        console.log(`   Public inputs:`, JSON.stringify(public_inputs, null, 2));

        // Ensure calldata is string array
        const calldataStrings = calldata.map((x: any) => x.toString());

        // Parse proof length from first element
        const proofLen = parseInt(calldataStrings[0]);
        console.log(`   Proof length: ${proofLen}`);

        // Compute fee as u256
        const feeBigInt = BigInt(public_inputs.relayer_fee || '0');
        const feeLow = (feeBigInt & ((1n << 128n) - 1n)).toString();
        const feeHigh = (feeBigInt >> 128n).toString();

        // Insert relayer address and fee based on type
        if (type === 'withdraw') {
            // Calldata structure for withdraw:
            // [proof_len, proof..., merkle_root, nullifier, change_commitment, recipient, amount_low, amount_high, relayer, fee_low, fee_high]
            // Positions after proof: +1=root, +2=nullifier, +3=change, +4=recipient, +5=amount_low, +6=amount_high, +7=relayer, +8=fee_low, +9=fee_high
            const relayerPos = 1 + proofLen + 6; // After amount_high
            console.log(`   Setting relayer at position ${relayerPos}`);
            calldataStrings[relayerPos] = RELAYER_ADDRESS;
            calldataStrings[relayerPos + 1] = feeLow;
            calldataStrings[relayerPos + 2] = feeHigh;
            
        } else if (type === 'transfer') {
            // Calldata structure for transfer:
            // [proof_len, proof..., merkle_root, nullifier, commitment_1, commitment_2, relayer, fee_low, fee_high, enc1_len, enc1..., enc2_len, enc2...]
            const relayerPos = 1 + proofLen + 4; // After commitment_2
            console.log(`   Setting relayer at position ${relayerPos}`);
            calldataStrings[relayerPos] = RELAYER_ADDRESS;
            calldataStrings[relayerPos + 1] = feeLow;
            calldataStrings[relayerPos + 2] = feeHigh;
            
        } else if (type === 'transact') {
            // More complex structure - needs careful positioning
            const basePos = 1 + proofLen;
            // After: merkle_root, nullifier, partial_commitment, target_contract
            // Then: calldata_len, calldata[], input_amount (u256), input_asset, output_asset, min_output (u256)
            // Then: relayer, fee (u256)
            
            const txLenPos = basePos + 4; // Position of calldata_len
            const txLen = parseInt(calldataStrings[txLenPos] || '0');
            // After calldata: input_amount (2), input_asset (1), output_asset (1), min_output (2) = 6 more
            const relayerPos = txLenPos + 1 + txLen + 6;
            
            console.log(`   Transact calldata_len at ${txLenPos}: ${txLen}`);
            console.log(`   Setting relayer at position ${relayerPos}`);
            
            calldataStrings[relayerPos] = RELAYER_ADDRESS;
            calldataStrings[relayerPos + 1] = feeLow;
            calldataStrings[relayerPos + 2] = feeHigh;
            
        } else {
            res.status(400).json({ error: `Unknown transaction type: ${type}` });
            return;
        }

        const call = {
            contractAddress: SHIELD_POOL_ADDRESS,
            entrypoint: type,
            calldata: calldataStrings,
        };

        console.log(`   Final calldata length: ${calldataStrings.length}`);

        // Try simulation first (but don't require it)
        console.log("   Simulating transaction...");
        const simResult = await simulateTransaction(call);
        
        if (!simResult.success) {
            console.log(`   ❌ Simulation failed: ${simResult.error}`);
            res.status(400).json({ 
                error: "Transaction simulation failed", 
                details: simResult.error 
            });
            return;
        }
        
        console.log("   ✅ Simulation passed (or skipped)");

        // Execute transaction
        console.log("   Broadcasting transaction...");
        
        const result = await relayerAccount.execute(call, {
        });
        
        console.log(`   📤 TX Hash: ${result.transaction_hash}`);
        
        // Wait for confirmation
        console.log("   Waiting for confirmation...");
        const receipt = await provider.waitForTransaction(result.transaction_hash);
        
        if (receipt.statusReceipt === 'REVERTED') {
            console.log(`   ❌ Transaction reverted!`);
            res.status(400).json({
                error: "Transaction reverted on-chain",
                txHash: result.transaction_hash,
                details: receipt.revert_reason || 'Unknown reason'
            });
            return;
        }
        
        console.log(`   ✅ Confirmed! Status: ${receipt.statusReceipt}`);

        res.status(200).json({
            status: "success",
            txHash: result.transaction_hash,
            executionStatus: receipt.statusReceipt
        });

    } catch (error: any) {
        console.error("\n❌ Relay Error:", error.message);
        
        // Provide more helpful error messages
        let errorMessage = error.message;
        
        if (error.message?.includes('Contract not found')) {
            errorMessage = 'Relayer account not deployed or invalid address';
        } else if (error.message?.includes('Insufficient')) {
            errorMessage = 'Insufficient balance for gas fees';
        } else if (error.message?.includes('REJECTED')) {
            errorMessage = 'Transaction rejected by sequencer';
        }
        
        res.status(500).json({ 
            error: errorMessage,
            details: error.message
        });
    }
});

// ============================================================================
// HEALTH CHECK
// ============================================================================
app.get('/health', async (req, res) => {
    try {
        // Quick check if account exists
        await provider.getClassHashAt(RELAYER_ADDRESS);
        
        res.json({ 
            status: 'ok', 
            relayer: RELAYER_ADDRESS,
            pool: SHIELD_POOL_ADDRESS,
            rpc: RPC_URL
        });
    } catch (error: any) {
        res.status(503).json({
            status: 'error',
            message: 'Relayer account not available',
            relayer: RELAYER_ADDRESS,
            error: error.message
        });
    }
});

// ============================================================================
// START SERVER
// ============================================================================
const PORT = process.env.PORT || 3001;

// Verify account before starting
// verifyAccount().then((valid) => {
//     if (!valid) {
//         console.error('\n⚠️  Starting server anyway, but relaying will fail until account is deployed.\n');
//     }
    
    app.listen(PORT, () => {
        console.log(`⚡ Relayer running on http://localhost:${PORT}`);
        console.log(`   Health check: http://localhost:${PORT}/health\n`);
    });