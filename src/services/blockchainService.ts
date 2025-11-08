import { ethers } from 'ethers';
import BatchTrackingABI from '../contracts/BatchTracking.json';

interface BlockchainConfig {
  rpcUrl: string;
  contractAddress: string;
  chainId: number;
}

class BlockchainService {
  private static instance: BlockchainService;
  private provider: ethers.JsonRpcProvider | null = null;
  private signer: ethers.Wallet | ethers.HDNodeWallet | null = null;
  private contract: ethers.Contract | null = null;
  private config: BlockchainConfig = {
    rpcUrl: 'http://127.0.0.1:8545', // Local Ganache
    contractAddress: '', // Will be set after deployment
    chainId: 1337, // Ganache chain ID
  };

  private constructor() {}

  static getInstance(): BlockchainService {
    if (!BlockchainService.instance) {
      BlockchainService.instance = new BlockchainService();
    }
    return BlockchainService.instance;
  }

  async initialize(contractAddress: string, privateKey?: string): Promise<void> {
    try {
      console.log('🔗 Initializing blockchain service...');
      
      this.config.contractAddress = contractAddress;
      
      // Initialize provider
      this.provider = new ethers.JsonRpcProvider(this.config.rpcUrl);
      
      // Initialize signer
      if (privateKey) {
        this.signer = new ethers.Wallet(privateKey, this.provider);
      } else {
        // Generate random wallet for testing
        const wallet = ethers.Wallet.createRandom();
        this.signer = wallet.connect(this.provider);
        console.log('🆕 New wallet created:', this.signer.address);
        console.log('⚠️  Save this private key:', wallet.privateKey);
      }
      
      // Initialize contract
      this.contract = new ethers.Contract(
        this.config.contractAddress,
        BatchTrackingABI.abi,
        this.signer
      );
      
      console.log('✅ Blockchain service initialized');
      console.log('📄 Contract:', this.config.contractAddress);
      console.log('👛 Wallet:', this.signer.address);
      
      const balance = await this.getBalance();
      console.log('💰 Balance:', balance, 'ETH');
    } catch (error) {
      console.error('❌ Error initializing blockchain:', error);
      throw error;
    }
  }

  async getBalance(): Promise<string> {
    if (!this.provider || !this.signer) throw new Error('Not initialized');
    const balance = await this.provider.getBalance(this.signer.address);
    return ethers.formatEther(balance);
  }

  getWalletAddress(): string {
    if (!this.signer) throw new Error('Not initialized');
    return this.signer.address;
  }

  async isConnected(): Promise<boolean> {
    try {
      if (!this.provider) return false;
      await this.provider.getBlockNumber();
      return true;
    } catch {
      return false;
    }
  }

  // ============== BATCH FUNCTIONS ==============

  async createBatch(
    batchId: string,
    productName: string,
    variety: string,
    quantity: number,
    unit: string,
    location: string,
    harvestDate: Date,
    expiryDate: Date,
    nfcTagId: string
  ): Promise<string> {
    if (!this.contract) throw new Error('Contract not initialized');

    try {
      console.log('📦 Creating batch on blockchain:', batchId);

      const tx = await this.contract.createBatch(
        batchId,
        productName,
        variety,
        BigInt(quantity),
        unit,
        location,
        BigInt(Math.floor(harvestDate.getTime() / 1000)),
        BigInt(Math.floor(expiryDate.getTime() / 1000)),
        nfcTagId,
        {
          gasLimit: 3000000,
        }
      );

      console.log('📤 Transaction sent:', tx.hash);
      const receipt = await tx.wait();
      console.log('✅ Batch created in block:', receipt.blockNumber);

      return tx.hash;
    } catch (error) {
      console.error('❌ Error creating batch:', error);
      throw error;
    }
  }

  async getBatch(batchId: string): Promise<any> {
    if (!this.contract) throw new Error('Contract not initialized');

    try {
      const result = await this.contract.getBatch(batchId);

      return {
        productName: result[0],
        variety: result[1],
        quantity: Number(result[2]),
        unit: result[3],
        location: result[4],
        harvestDate: new Date(Number(result[5]) * 1000),
        expiryDate: new Date(Number(result[6]) * 1000),
        nfcTagId: result[7],
        creator: result[8],
        timestamp: new Date(Number(result[9]) * 1000),
      };
    } catch (error) {
      console.error('❌ Error getting batch:', error);
      return null;
    }
  }

  async addQualityMetric(
    metricId: string,
    batchId: string,
    metricType: string,
    value: string,
    unit: string
  ): Promise<string> {
    if (!this.contract) throw new Error('Contract not initialized');

    try {
      const tx = await this.contract.addQualityMetric(
        metricId,
        batchId,
        metricType,
        value,
        unit,
        { gasLimit: 2000000 }
      );

      console.log('📊 Quality metric added:', tx.hash);
      await tx.wait();

      return tx.hash;
    } catch (error) {
      console.error('❌ Error adding quality metric:', error);
      throw error;
    }
  }

  async authenticateNFC(
    authId: string,
    batchId: string,
    nfcTagId: string,
    location: string
  ): Promise<{ txHash: string; isValid: boolean }> {
    if (!this.contract) throw new Error('Contract not initialized');

    try {
      console.log('🔐 Authenticating NFC on blockchain...');

      const tx = await this.contract.authenticateNFC(
        authId,
        batchId,
        nfcTagId,
        location,
        { gasLimit: 2000000 }
      );

      console.log('📤 Transaction sent:', tx.hash);
      const receipt = await tx.wait();

      // Check if authentication was successful
      const batch = await this.getBatch(batchId);
      const isValid = batch && batch.nfcTagId === nfcTagId;

      console.log('✅ NFC authenticated. Valid:', isValid);

      return {
        txHash: tx.hash,
        isValid,
      };
    } catch (error) {
      console.error('❌ Error authenticating NFC:', error);
      throw error;
    }
  }

  async getTotalBatches(): Promise<number> {
    if (!this.contract) throw new Error('Contract not initialized');

    try {
      const total = await this.contract.getTotalBatches();
      return Number(total);
    } catch (error) {
      console.error('❌ Error getting total batches:', error);
      return 0;
    }
  }

  async getAllBatchIds(): Promise<string[]> {
    if (!this.contract) throw new Error('Contract not initialized');

    try {
      const ids = await this.contract.getAllBatchIds();
      return ids;
    } catch (error) {
      console.error('❌ Error getting batch IDs:', error);
      return [];
    }
  }

  async getBatchQualityMetrics(batchId: string): Promise<string[]> {
    if (!this.contract) throw new Error('Contract not initialized');

    try {
      const metrics = await this.contract.getBatchQualityMetrics(batchId);
      return metrics;
    } catch (error) {
      console.error('❌ Error getting quality metrics:', error);
      return [];
    }
  }

  async getBatchAuthentications(batchId: string): Promise<string[]> {
    if (!this.contract) throw new Error('Contract not initialized');

    try {
      const auths = await this.contract.getBatchAuthentications(batchId);
      return auths;
    } catch (error) {
      console.error('❌ Error getting authentications:', error);
      return [];
    }
  }

  // ============== EVENT LISTENERS ==============

  onBatchCreated(callback: (batchId: string, productName: string, creator: string) => void): void {
    if (!this.contract) throw new Error('Contract not initialized');

    this.contract.on('BatchCreated', (batchId, productName, creator) => {
      console.log('📦 Batch created event:', { batchId, productName, creator });
      callback(batchId, productName, creator);
    });
  }

  onNFCAuthenticated(
    callback: (authId: string, batchId: string, nfcTagId: string, isValid: boolean) => void
  ): void {
    if (!this.contract) throw new Error('Contract not initialized');

    this.contract.on('NFCAuthenticated', (authId, batchId, nfcTagId, isValid) => {
      console.log('🔐 NFC authenticated event:', { authId, batchId, nfcTagId, isValid });
      callback(authId, batchId, nfcTagId, isValid);
    });
  }

  removeAllListeners(): void {
    if (this.contract) {
      this.contract.removeAllListeners();
    }
  }
}

export default BlockchainService;
