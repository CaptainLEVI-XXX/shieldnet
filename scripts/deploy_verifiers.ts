import { Account, json, RpcProvider, Contract } from "starknet";
import fs from "fs";
import dotenv from "dotenv";
import path from "path";

const envPath = path.join(__dirname, ".env");
dotenv.config({ path: envPath });

const provider = new RpcProvider({ nodeUrl: process.env.SEPOLIA_RPC as string });

const owner_private_key = process.env.PRIVATE_KEY as string;
const owner_account_address = process.env.ACCOUNT_ADDRESS as string;

// v8 uses object-based constructor
const myAccount = new Account({
  provider: provider,
  address: owner_account_address,
  signer: owner_private_key,
});

async function declareAndDeployVerifier(directory: string) {
  const devDir = path.join(__dirname, "..", directory, "target", "dev");

  if (!fs.existsSync(devDir)) {
    throw new Error(`Missing target/dev directory for ${directory}: ${devDir}`);
  }

  const files = fs.readdirSync(devDir);

  const sierraFile =
    files.find(
      (f) =>
        f.endsWith(".contract_class.json") &&
        f.includes("UltraStarknetZKHonkVerifier")
    ) ?? files.find((f) => f.endsWith(".contract_class.json"));

  const casmFile =
    files.find(
      (f) =>
        f.endsWith(".compiled_contract_class.json") &&
        f.includes("UltraStarknetZKHonkVerifier")
    ) ?? files.find((f) => f.endsWith(".compiled_contract_class.json"));

  if (!sierraFile || !casmFile) {
    throw new Error(`Missing contract files in ${devDir}`);
  }

  // Read and parse the contract JSON files (not just filenames!)
  const sierraPath = path.join(devDir, sierraFile);
  const casmPath = path.join(devDir, casmFile);

  const compiledSierra = json.parse(fs.readFileSync(sierraPath, "utf8"));
  const compiledCasm = json.parse(fs.readFileSync(casmPath, "utf8"));

  console.log(`Declaring and deploying ${directory}...`);

  // Use Contract.factory() - it's async in v8
  const myContract = await Contract.factory({
    contract: compiledSierra,      // Parsed JSON, not filename
    casm: compiledCasm,            // Parsed JSON, not filename
    account: myAccount,
    constructorCalldata: [],
  });

  console.log("Contract deployed at:", myContract.address);
  console.log("Class hash:", myContract.classHash);

  return myContract;
}

async function main() {
  const directories = [
    "verifier_transfer",
    "verifier_transact",
    "verifier_unshield",
  ];

  for (const dir of directories) {
    await declareAndDeployVerifier(dir);
  }
}

if (require.main === module) {
  console.log("Declaring and deploying verifiers...");
  main().catch((err) => {
    console.error(err);
    process.exit(1);
  });
}