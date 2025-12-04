### ShieldNet.
Contract deployed: 0x42db592b9fc606a5a0297a88a2cd7cd74f213e832557ef1d2d786df6e6c824
Class hash: 0x32bc388d09a39dfe49d75c7985bf45e553f88ab5f87578236623d1ede559cb2

#### verifier_transfer: 
Contract deployed at: 0x329f2ba902c220ec8fe17485a5960aaacf45c3e5fafc61d0d30fd5c0c76519
Class hash: 0x465522dad4f410b3598b2f800ab85407ce0239d7acbe206d199bc88e8f7c015

#### verifier_transact:
Contract deployed at: 0x3c10cc5273b2faecc9dc77911324975b43ff9e927018dca6ff9663be7691ffd
Class hash: 0x49ca8bce890f108b6537de6a7aac9bef3edaae140fe45a49c919310d884dbd8

##### verifier_unshield: 
Contract deployed at: 0xfc8c288926c8eaf4bd364343e28d699f9373a781c3a4622216baeef6aeece8
Class hash: 0x6f4f12865a4430e1fd37b4ae0b5ef80fd2f46466cf5bee5791887214b531fdb



mkdir -p public/circuits           

cp ~/desktop/shieldnet/circuits/transfer/target/transfer.json public/circuits/
cp ~/desktop/shieldnet/circuits/unshield/target/unshield.json public/circuits/
cp ~/desktop/shieldnet/circuits/transact/target/transact.json public/circuits/

cp ~/desktop/shieldnet/circuits/transfer/target/vk public/circuits/transfer_vk.bin
cp ~/desktop/shieldnet/circuits/unshield/target/vk public/circuits/unshield_vk.bin
cp ~/desktop/shieldnet/circuits/transact/target/vk public/circuits/transact_vk.bin
