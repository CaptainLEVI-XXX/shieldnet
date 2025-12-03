Starknet Sepolia Deployment Info: 

ShieldNet:
depth =
Contract deployed at: 0x6582ba9fe8f7d2aa18298c3f1803cf3e8e4efde5282bba8abac3606f12559ad
Class hash: 0x5415e41504db4bcd092e38d333942630fd37314f87793dc1650489ee3de499d


verifier_transfer
Contract deployed at: 0x208601b7cb7e23a32d2856f1df1b272c054c08964558f5d104839f456ab090
Class hash: 0x476b4fa74aa8b8ffab9d98c999ff88130c905139eeca3dcb64beebaf77e7483

verifier_transact...
Contract deployed at: 0x506b6031b6f6a55ab4d417671d7f4051c42ce8c023f976b382d2e099a1087bc
Class hash: 0x28b78eb7e239cc42a3794208cdcd30013a4e96bc9842adf076555b7e9702088

verifier_unshield...
Contract deployed at: 0x7aa6b260fa830fee4b98cbf14d422ea9357f885026712f853a341b2f3c355c5
Class hash: 0x7fc3315e98b5afc67ae80c0e29b4f96341f505a8b4af4ff2d04ef3c4219db6f



depth 20
Contract deployed at: 0x3e8b8ac9e193dff4c508de6eaa7cef3b42b9dad3f040ee6fc8aa5d386c6850b
Class hash: 0x5415e41504db4bcd092e38d333942630fd37314f87793dc1650489ee3de499d


 mkdir -p public/circuits           

cp ~/desktop/shieldnet/circuits/transfer/target/transfer.json public/circuits/
cp ~/desktop/shieldnet/circuits/unshield/target/unshield.json public/circuits/
cp ~/desktop/shieldnet/circuits/transact/target/transact.json public/circuits/

cp ~/desktop/shieldnet/circuits/transfer/target/vk public/circuits/transfer_vk.bin
cp ~/desktop/shieldnet/circuits/unshield/target/vk public/circuits/unshield_vk.bin
cp ~/desktop/shieldnet/circuits/transact/target/vk public/circuits/transact_vk.bin