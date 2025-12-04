"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const dotenv_1 = __importDefault(require("dotenv"));
const starknet_1 = require("starknet");
dotenv_1.default.config();
const app = (0, express_1.default)();
app.use((0, cors_1.default)());
app.use(express_1.default.json());
// ============================================================================
// CONFIGURATION
// ============================================================================
const RPC_URL = process.env.RPC_URL || 'https://starknet-sepolia.public.blastapi.io';
const RELAYER_ADDRESS = process.env.RELAYER_ADDRESS;
const RELAYER_PRIVATE_KEY = process.env.RELAYER_PRIVATE_KEY;
const SHIELD_POOL_ADDRESS = process.env.SHIELD_POOL_ADDRESS;
// Initialize Starknet Provider and Account
const provider = new starknet_1.RpcProvider({ nodeUrl: RPC_URL });
const relayerAccount = new starknet_1.Account(provider, RELAYER_ADDRESS, RELAYER_PRIVATE_KEY);
console.log(`🚀 Relayer Service Starting...`);
console.log(`📝 Relayer Address: ${RELAYER_ADDRESS}`);
console.log(`🔗 Connected to RPC: ${RPC_URL}`);
// ============================================================================
// HELPER: Validation
// ============================================================================
// We simulate the transaction before sending it to save gas on failed TXs.
async function simulateTransaction(call) {
    try {
        const simulation = await relayerAccount.simulateTransaction([call]);
        // Check if any trace suggests a Revert
        if (simulation[0].revert_reason) {
            throw new Error(`Simulation Reverted: ${simulation[0].revert_reason}`);
        }
        return true;
    }
    catch (error) {
        console.error("Simulation failed:", error.message);
        return false;
    }
}
// ============================================================================
// ENDPOINT: /relay
// ============================================================================
app.post('/relay', async (req, res) => {
    try {
        const { type, // 'transfer' | 'withdraw' | 'transact'
        proof, public_inputs } = req.body;
        if (!proof || !public_inputs || !type) {
            res.status(400).json({ error: "Missing parameters" });
            return;
        }
        console.log(`Received Relay Request: ${type}`);
        // 1. Construct CallData based on operation type
        // We match the arguments of the Cairo Contract EXACTLY
        let call;
        if (type === 'transfer') {
            // Unpack public inputs from JSON
            // Note: Ensure your frontend sends these with correct keys
            const { merkle_root, nullifier_1, nullifier_2, commitment_1, commitment_2, relayer_fee, encrypted_note_1, encrypted_note_2 } = public_inputs;
            // Security Check: Is the user paying ME?
            // In the circuit, the user commits to paying 'relayer_fee' to 'relayer_address'
            // We must verify the payload specifies OUR address as the relayer.
            if (public_inputs.relayer !== RELAYER_ADDRESS) {
                // In a real prod relayer, you might accept it if the fee is high enough
                // regardless of address, but usually we enforce address match.
                res.status(400).json({ error: "Invalid Relayer Address in payload" });
                return;
            }
            // Compile Calldata
            const transferCallData = starknet_1.CallData.compile({
                proof: proof, // Array of felts
                merkle_root: merkle_root,
                nullifier_1: nullifier_1,
                nullifier_2: nullifier_2 || 0, // Handle 1-input optimization
                commitment_1: commitment_1,
                commitment_2: commitment_2,
                relayer: RELAYER_ADDRESS,
                fee: relayer_fee,
                encrypted_note_1: encrypted_note_1,
                encrypted_note_2: encrypted_note_2
            });
            call = {
                contractAddress: SHIELD_POOL_ADDRESS,
                entrypoint: 'transfer',
                calldata: transferCallData
            };
        }
        else if (type === 'withdraw') {
            const { merkle_root, nullifier, change_commitment, recipient, amount, relayer_fee } = public_inputs;
            const withdrawCallData = starknet_1.CallData.compile({
                proof: proof,
                merkle_root: merkle_root,
                nullifier_1: nullifier,
                nullifier_2: 0, // Unused in basic withdraw
                change_commitment: change_commitment,
                recipient: recipient,
                amount: amount,
                relayer: RELAYER_ADDRESS,
                fee: relayer_fee
            });
            call = {
                contractAddress: SHIELD_POOL_ADDRESS,
                entrypoint: 'withdraw',
                calldata: withdrawCallData
            };
        }
        else {
            res.status(400).json({ error: "Unknown transaction type" });
            return;
        }
        // 2. Simulate / Safety Check
        // If the ZK Proof is invalid OR the Nullifier is spent, this simulation will fail.
        console.log("Simulating transaction...");
        const isValid = await simulateTransaction(call);
        if (!isValid) {
            res.status(400).json({ error: "Transaction simulation failed. Invalid Proof or Spent Nullifier." });
            return;
        }
        // 3. Execute Transaction (Pay Gas)
        console.log("Broadcasting transaction...");
        const result = await relayerAccount.execute(call);
        console.log(`Transaction Hash: ${result.transaction_hash}`);
        await provider.waitForTransaction(result.transaction_hash);
        // 4. Return Result
        res.status(200).json({
            status: "success",
            txHash: result.transaction_hash
        });
    }
    catch (error) {
        console.error("Relay Error:", error);
        res.status(500).json({ error: error.message });
    }
});
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
//# sourceMappingURL=server.js.map