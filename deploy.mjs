import { Web3 } from 'web3';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function deploy() {
  try {
    console.log('🚀 Starting deployment...\n');
    
    // Connect to Ganache
    const web3 = new Web3('http://127.0.0.1:8545');
    console.log('✅ Connected to Ganache');
    
    // Get accounts
    const accounts = await web3.eth.getAccounts();
    console.log('📝 Deploying from account:', accounts[0]);
    console.log('💰 Balance:', web3.utils.fromWei(await web3.eth.getBalance(accounts[0]), 'ether'), 'ETH\n');
    
    // Read contract
    const contractPath = path.join(__dirname, 'build', 'contracts', 'BatchTracking.json');
    if (!fs.existsSync(contractPath)) {
      throw new Error('Contract not compiled! Run: npx truffle compile --config truffle-config.cjs');
    }
    
    const contractJson = JSON.parse(fs.readFileSync(contractPath, 'utf8'));
    const abi = contractJson.abi;
    const bytecode = contractJson.bytecode;
    
    console.log('📄 Contract loaded');
    console.log('📦 Bytecode length:', bytecode.length, 'bytes\n');
    
    // Deploy contract
    const contract = new web3.eth.Contract(abi);
    console.log('⏳ Deploying contract...');
    
    const deployTx = contract.deploy({
      data: bytecode,
      arguments: []
    });
    
    const gas = await deployTx.estimateGas({from: accounts[0]});
    console.log('⛽ Estimated gas:', gas);
    
    const deployedContract = await deployTx.send({
      from: accounts[0],
      gas: gas + 100000n, // Add buffer
      gasPrice: await web3.eth.getGasPrice()
    });
    
    console.log('\n🎉 SUCCESS! Contract deployed!');
    console.log('\n📋 DEPLOYMENT DETAILS:');
    console.log('=====================================');
    console.log('Contract Address:', deployedContract.options.address);
    console.log('Deployer:', accounts[0]);
    console.log('Network:', 'development (Ganache)');
    console.log('=====================================\n');
    
    console.log('📝 NEXT STEPS:');
    console.log('1. Copy the contract address above');
    console.log('2. Save it in your Flutter app');
    console.log('3. Copy ABI to Flutter assets:');
    console.log('   xcopy /Y build\\contracts\\BatchTracking.json app\\assets\\contracts\\\n');
    
    // Save deployment info
    const deploymentInfo = {
      address: deployedContract.options.address,
      deployer: accounts[0],
      network: 'development',
      timestamp: new Date().toISOString(),
      gasUsed: gas.toString()
    };
    
    fs.writeFileSync(
      path.join(__dirname, 'deployment.json'),
      JSON.stringify(deploymentInfo, null, 2)
    );
    console.log('💾 Deployment info saved to deployment.json');
    
  } catch (error) {
    console.error('\n❌ DEPLOYMENT FAILED:');
    console.error(error.message);
    process.exit(1);
  }
}

deploy();
