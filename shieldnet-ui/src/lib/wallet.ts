import { connect, disconnect } from "@starknet-io/get-starknet";
import { Contract, RpcProvider, constants } from "starknet";

const provider = new RpcProvider({
  nodeUrl: constants.NetworkName.SN_SEPOLIA,
});

export async function connectWallet() {
  // v4: connect() returns ConnectResult
  const result = await connect();

  if (!result?.provider) {
    throw new Error("Wallet connection failed");
  }

  const account = result.provider;
  const address = account.address;

  return {
    address,
    account,
  };
}

export async function disconnectWallet() {
  await disconnect();
}

export function getContract(abi: any[], address: string, account: any) {
  return new Contract(abi, address, account);
}

export { provider };
