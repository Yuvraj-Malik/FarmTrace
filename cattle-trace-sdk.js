// ---------- START PATCH: reliable env loading + defensive checks ----------
// (This section is well-written and left as-is)
require('dotenv').config();
const { ethers } = require('ethers');

// --- START: ABI (truncated for brevity) ---
const CATTLE_TRACE_ABI = [
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "trustedForwarder",
          "type": "address"
        }
      ],
      "stateMutability": "nonpayable",
      "type": "constructor"
    },
    {
      "inputs": [],
      "name": "CattleDoesNotExist",
      "type": "error"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "sender",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        },
        {
          "internalType": "address",
          "name": "owner",
          "type": "address"
        }
      ],
      "name": "ERC721IncorrectOwner",
      "type": "error"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "operator",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        }
      ],
      "name": "ERC721InsufficientApproval",
      "type": "error"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "approver",
          "type": "address"
        }
      ],
      "name": "ERC721InvalidApprover",
      "type": "error"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "operator",
          "type": "address"
        }
      ],
      "name": "ERC721InvalidOperator",
      "type": "error"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "owner",
          "type": "address"
        }
      ],
      "name": "ERC721InvalidOwner",
      "type": "error"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "receiver",
          "type": "address"
        }
      ],
      "name": "ERC721InvalidReceiver",
      "type": "error"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "sender",
          "type": "address"
        }
      ],
      "name": "ERC721InvalidSender",
      "type": "error"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        }
      ],
      "name": "ERC721NonexistentToken",
      "type": "error"
    },
    {
      "inputs": [],
      "name": "InvalidAddress",
      "type": "error"
    },
    {
      "inputs": [],
      "name": "NotCattleOwner",
      "type": "error"
    },
    {
      "inputs": [],
      "name": "NotRegisteredVet",
      "type": "error"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "owner",
          "type": "address"
        }
      ],
      "name": "OwnableInvalidOwner",
      "type": "error"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "account",
          "type": "address"
        }
      ],
      "name": "OwnableUnauthorizedAccount",
      "type": "error"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "internalType": "address",
          "name": "owner",
          "type": "address"
        },
        {
          "indexed": true,
          "internalType": "address",
          "name": "approved",
          "type": "address"
        },
        {
          "indexed": true,
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        }
      ],
      "name": "Approval",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "internalType": "address",
          "name": "owner",
          "type": "address"
        },
        {
          "indexed": true,
          "internalType": "address",
          "name": "operator",
          "type": "address"
        },
        {
          "indexed": false,
          "internalType": "bool",
          "name": "approved",
          "type": "bool"
        }
      ],
      "name": "ApprovalForAll",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "internalType": "uint256",
          "name": "cattleId",
          "type": "uint256"
        },
        {
          "indexed": true,
          "internalType": "address",
          "name": "from",
          "type": "address"
        },
        {
          "indexed": true,
          "internalType": "address",
          "name": "to",
          "type": "address"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "price",
          "type": "uint256"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "timestamp",
          "type": "uint256"
        }
      ],
      "name": "CattleOwnershipTransferred",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "internalType": "uint256",
          "name": "cattleId",
          "type": "uint256"
        },
        {
          "indexed": false,
          "internalType": "string",
          "name": "tagId",
          "type": "string"
        },
        {
          "indexed": true,
          "internalType": "address",
          "name": "owner",
          "type": "address"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "timestamp",
          "type": "uint256"
        }
      ],
      "name": "CattleRegistered",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "internalType": "uint256",
          "name": "cattleId",
          "type": "uint256"
        },
        {
          "indexed": false,
          "internalType": "string",
          "name": "recordType",
          "type": "string"
        },
        {
          "indexed": false,
          "internalType": "string",
          "name": "ipfsHash",
          "type": "string"
        },
        {
          "indexed": true,
          "internalType": "address",
          "name": "submittedBy",
          "type": "address"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "timestamp",
          "type": "uint256"
        }
      ],
      "name": "MedicalRecordAdded",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "internalType": "address",
          "name": "previousOwner",
          "type": "address"
        },
        {
          "indexed": true,
          "internalType": "address",
          "name": "newOwner",
          "type": "address"
        }
      ],
      "name": "OwnershipTransferred",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "internalType": "address",
          "name": "from",
          "type": "address"
        },
        {
          "indexed": true,
          "internalType": "address",
          "name": "to",
          "type": "address"
        },
        {
          "indexed": true,
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        }
      ],
      "name": "Transfer",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "internalType": "address",
          "name": "vetAddress",
          "type": "address"
        },
        {
          "indexed": false,
          "internalType": "bytes32",
          "name": "licenseHash",
          "type": "bytes32"
        }
      ],
      "name": "VeterinarianRegistered",
      "type": "event"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "cattleId",
          "type": "uint256"
        },
        {
          "internalType": "string",
          "name": "recordType",
          "type": "string"
        },
        {
          "internalType": "string",
          "name": "ipfsHash",
          "type": "string"
        },
        {
          "internalType": "uint96",
          "name": "timestamp",
          "type": "uint96"
        }
      ],
      "name": "addMedicalRecord",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "to",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        }
      ],
      "name": "approve",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "owner",
          "type": "address"
        }
      ],
      "name": "balanceOf",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "string[]",
          "name": "tagIds",
          "type": "string[]"
        },
        {
          "internalType": "string[]",
          "name": "breeds",
          "type": "string[]"
        },
        {
          "internalType": "string[]",
          "name": "locations",
          "type": "string[]"
        },
        {
          "internalType": "uint96[]",
          "name": "dobs",
          "type": "uint96[]"
        }
      ],
      "name": "batchRegisterCattle",
      "outputs": [
        {
          "internalType": "uint256[]",
          "name": "cattleIds",
          "type": "uint256[]"
        }
      ],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "name": "cattleData",
      "outputs": [
        {
          "internalType": "address",
          "name": "owner",
          "type": "address"
        },
        {
          "internalType": "uint96",
          "name": "dob",
          "type": "uint96"
        },
        {
          "internalType": "string",
          "name": "tagId",
          "type": "string"
        },
        {
          "internalType": "string",
          "name": "breed",
          "type": "string"
        },
        {
          "internalType": "string",
          "name": "location",
          "type": "string"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        }
      ],
      "name": "getApproved",
      "outputs": [
        {
          "internalType": "address",
          "name": "",
          "type": "address"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "getCattleCount",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "cattleId",
          "type": "uint256"
        }
      ],
      "name": "getMedicalHistory",
      "outputs": [
        {
          "components": [
            {
              "internalType": "address",
              "name": "submittedBy",
              "type": "address"
            },
            {
              "internalType": "uint96",
              "name": "timestamp",
              "type":"uint96"
            },
            {
              "internalType": "string",
              "name": "recordType",
              "type": "string"
            },
            {
              "internalType": "string",
              "name": "ipfsHash",
              "type": "string"
            }
          ],
          "internalType": "struct CattleTrace.MedicalRecord[]",
          "name": "",
          "type": "tuple[]"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "owner",
          "type": "address"
        },
        {
          "internalType": "address",
          "name": "operator",
          "type": "address"
        }
      ],
      "name": "isApprovedForAll",
      "outputs": [
        {
          "internalType": "bool",
          "name": "",
          "type": "bool"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "",
          "type": "address"
        }
      ],
      "name": "isRegisteredVet",
      "outputs": [
        {
          "internalType": "bool",
          "name": "",
          "type": "bool"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "forwarder",
          "type": "address"
        }
      ],
      "name": "isTrustedForwarder",
      "outputs": [
        {
          "internalType": "bool",
          "name": "",
          "type": "bool"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "name",
      "outputs": [
        {
          "internalType": "string",
          "name": "",
          "type": "string"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "owner",
      "outputs": [
        {
          "internalType": "address",
          "name": "",
          "type": "address"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        }
      ],
      "name": "ownerOf",
      "outputs": [
        {
          "internalType": "address",
          "name": "",
          "type": "address"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "string",
          "name": "tagId",
          "type": "string"
        },
        {
          "internalType": "string",
          "name": "breed",
          "type": "string"
        },
        {
          "internalType": "string",
          "name": "location",
          "type": "string"
        },
        {
          "internalType": "uint96",
          "name": "dob",
          "type": "uint96"
        }
      ],
      "name": "registerCattle",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "vetAddress",
          "type": "address"
        },
        {
          "internalType": "string",
          "name": "licenseId",
          "type": "string"
        }
      ],
      "name": "registerVeterinarian",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "renounceOwnership",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "from",
          "type": "address"
        },
        {
          "internalType": "address",
          "name": "to",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        }
      ],
      "name": "safeTransferFrom",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "from",
          "type": "address"
        },
        {
          "internalType": "address",
          "name": "to",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        },
        {
          "internalType": "bytes",
          "name": "data",
          "type": "bytes"
        }
      ],
      "name": "safeTransferFrom",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "operator",
          "type": "address"
        },
        {
          "internalType": "bool",
          "name": "approved",
          "type": "bool"
        }
      ],
      "name": "setApprovalForAll",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "bytes4",
          "name": "interfaceId",
          "type": "bytes4"
        }
      ],
      "name": "supportsInterface",
      "outputs": [
        {
          "internalType": "bool",
          "name": "",
          "type": "bool"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "symbol",
      "outputs": [
        {
          "internalType": "string",
          "name": "",
          "type": "string"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        }
      ],
      "name": "tokenURI",
      "outputs": [
        {
          "internalType": "string",
          "name": "",
          "type": "string"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "cattleId",
          "type": "uint256"
        },
        {
          "internalType": "address",
          "name": "newOwner",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "price",
          "type": "uint256"
        }
      ],
      "name": "transferCattle",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "from",
          "type": "address"
        },
        {
          "internalType": "address",
          "name": "to",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        }
      ],
      "name": "transferFrom",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "newOwner",
          "type": "address"
        }
      ],
      "name": "transferOwnership",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "trustedForwarder",
      "outputs": [
        {
          "internalType": "address",
          "name": "",
          "type": "address"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "",
          "type": "address"
        }
      ],
      "name": "veterinarianLicenseHash",
      "outputs": [
        {
          "internalType": "bytes32",
          "name": "",
          "type": "bytes32"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    }
  ]
// --- END: ABI ---

// pick RPC and contract address from common env names (backwards-compatible)
const RPC_URL = process.env.RPC_URL || process.env.SEPOLIA_RPC_URL || process.env.SEPOLIA_RPC;
const PRIVATE_KEY = process.env.PRIVATE_KEY || process.env.PRIVATEKEY;
const CONTRACT_ADDRESS = process.env.CATTLE_CONTRACT_ADDRESS || process.env.CONTRACT_ADDRESS || process.env.CATTLE_ADDRESS;

// fail fast with helpful message
if (!RPC_URL) {
  console.error('✖ Missing RPC URL. Set RPC_URL or SEPOLIA_RPC_URL in your .env');
  process.exit(1);
}
if (!PRIVATE_KEY) {
  console.error('✖ Missing PRIVATE_KEY in your .env');
  process.exit(1);
}
if (!CONTRACT_ADDRESS) {
  console.error('✖ Missing contract address. Set CONTRACT_ADDRESS or CATTLE_CONTRACT_ADDRESS in your .env');
  process.exit(1);
}

// initialize provider and wallet
const provider = new ethers.JsonRpcProvider(RPC_URL);
const wallet = new ethers.Wallet(PRIVATE_KEY, provider);

// show safe debug info (do NOT print private key)
console.log('Using RPC URL:', RPC_URL.startsWith('http') ? RPC_URL.split('://')[1].slice(0, 24) + '...' : '...');
console.log('Using contract address:', CONTRACT_ADDRESS);
console.log('Using wallet address:', wallet.address);

// create contract
const contract = new ethers.Contract(CONTRACT_ADDRESS, CATTLE_TRACE_ABI, wallet);
// ---------- END PATCH ----------


  const ERROR_CODES = {
    INVALID_ADDRESS: 'INVALID_ADDRESS',
    INVALID_CATTLE_ID: 'INVALID_CATTLE_ID',
    INVALID_AMOUNT: 'INVALID_AMOUNT',
    INVALID_DATA: 'INVALID_DATA',
    CONTRACT_ERROR: 'CONTRACT_ERROR',
    NOT_AUTHORIZED: 'NOT_AUTHORIZED',
    CATTLE_NOT_FOUND: 'CATTLE_NOT_FOUND',
    NOT_VET: 'NOT_VET',
    NOT_OWNER: 'NOT_OWNER'
};

// ============================================
// CATTLE REGISTRATION FUNCTIONS
// ============================================

/**
 * Register a single cattle
 * @param {string} tagId - Unique cattle tag identifier
 * @param {string} breed - Cattle breed
 * @param {string} location - Current location
 * @param {number} dob - Date of birth (Unix timestamp)
 * @returns {Promise<Object>} Transaction receipt with cattle ID
 */
async function registerCattle(tagId, breed, location, dob) {
    try {
        // CORRECTION: Removed 'ownerAddress' param. The 'wallet' is the signer
        // and will be the owner, as per _msgSender() in the contract.
        console.log(`Registering cattle: ${tagId} for owner: ${wallet.address}`);
        
        // CORRECTION: Removed 'signerContract' logic. The 'contract' instance
        // is already connected to the 'wallet' and is the correct signer.
        const tx = await contract.registerCattle(tagId, breed, location, dob);
        const receipt = await tx.wait();
        
        // CORRECTION: Use receipt.getLogs() for efficient event parsing (ethers v6).
        const eventLogs = receipt.getLogs(contract.filters.CattleRegistered());
        
        let cattleId = null;
        if (eventLogs.length > 0) {
            cattleId = eventLogs[0].args.cattleId.toString();
        } else {
            console.warn("Could not find CattleRegistered event in transaction logs.");
            // Fallback: Check all logs just in case
            for (const log of receipt.logs) {
                try {
                    const parsed = contract.interface.parseLog(log);
                    if (parsed && parsed.name === 'CattleRegistered') {
                        cattleId = parsed.args.cattleId.toString();
                        break;
                    }
                } catch {}
            }
        }
        
        return {
            success: true,
            cattleId,
            transactionHash: receipt.hash,
            blockNumber: receipt.blockNumber,
            gasUsed: receipt.gasUsed.toString()
        };
    } catch (error) {
        console.error('Error registering cattle:', error);
        throw new Error(`Failed to register cattle: ${error.message}`);
    }
}

/**
 * Batch register multiple cattle
 * @param {Array<Object>} cattleArray - Array of cattle objects with tagId, breed, location, dob
 * @returns {Promise<Object>} Transaction receipt with cattle IDs
 */
async function batchRegisterCattle(cattleArray) {
    try {
        // CORRECTION: Removed 'ownerAddress' param.
        console.log(`Batch registering ${cattleArray.length} cattle for owner: ${wallet.address}`);
        
        const tagIds = cattleArray.map(c => c.tagId);
        const breeds = cattleArray.map(c => c.breed);
        const locations = cattleArray.map(c => c.location);
        const dobs = cattleArray.map(c => c.dob);
        
        const tx = await contract.batchRegisterCattle(tagIds, breeds, locations, dobs);
        const receipt = await tx.wait();
        
        // CORRECTION: Use receipt.getLogs() for efficient event parsing.
        const eventLogs = receipt.getLogs(contract.filters.CattleRegistered());
        const cattleIds = eventLogs.map(log => log.args.cattleId.toString());
        
        return {
            success: true,
            cattleIds,
            count: cattleIds.length,
            transactionHash: receipt.hash,
            blockNumber: receipt.blockNumber,
            gasUsed: receipt.gasUsed.toString()
        };
    } catch (error) {
        console.error('Error batch registering cattle:', error);
        throw new Error(`Failed to batch register cattle: ${error.message}`);
    }
}

// ============================================
// CATTLE QUERY FUNCTIONS
// ============================================

/**
 * Get cattle data by ID
 * @param {number} cattleId - Cattle token ID
 * @returns {Promise<Object>} Cattle data
 */
async function getCattleData(cattleId) {
    try {
        const data = await contract.cattleData(cattleId);
        // This check is useful if cattleId 0 is queried, which might not revert
        if (data.owner === ethers.ZeroAddress) {
            throw new Error('Cattle does not exist or has no data');
        }
        return {
            owner: data.owner,
            dob: data.dob.toString(),
            dobDate: new Date(Number(data.dob) * 1000).toISOString(),
            tagId: data.tagId,
            breed: data.breed,
            location: data.location
        };
    } catch (error) {
        console.error(`Error getting cattle data for ID ${cattleId}:`, error);
        throw new Error(`Failed to get cattle data: ${error.message}`);
    }
}

/**
 * Get all cattle owned by an address
 * @param {string} ownerAddress - Owner's wallet address
 * @returns {Promise<Array>} Array of cattle IDs
 */
async function getCattleByOwner(ownerAddress) {
    try {
        const balance = await contract.balanceOf(ownerAddress);
        const numBalance = Number(balance);

        // OPTIMIZATION: If balance is 0, no need to loop.
        if (numBalance === 0) {
            return [];
        }

        const cattleIds = [];
        const totalCount = await contract.getCattleCount();
        
        // Iterate through all cattle to find owned ones
        // Note: This is inefficient but necessary without ERC721Enumerable
        for (let i = 1; i <= Number(totalCount); i++) {
            try {
                const owner = await contract.ownerOf(i);
                if (owner.toLowerCase() === ownerAddress.toLowerCase()) {
                    cattleIds.push(i);
                }

                // OPTIMIZATION: If we've found all owned cattle, stop looping.
                if (cattleIds.length === numBalance) {
                    break;
                }

            } catch {
                // Token doesn't exist or was burned, ignore and continue
                continue;
            }
        }
        
        return cattleIds;
    } catch (error) {
        console.error('Error getting cattle by owner:', error);
        throw new Error(`Failed to get cattle by owner: ${error.message}`);
    }
}

/**
 * Get total cattle count
 * @returns {Promise<number>} Total number of cattle registered
 */
async function getCattleCount() {
    try {
        const count = await contract.getCattleCount();
        return Number(count);
    } catch (error) {
        console.error('Error getting cattle count:', error);
        throw new Error(`Failed to get cattle count: ${error.message}`);
    }
}

// ============================================
// MEDICAL RECORD FUNCTIONS
// ============================================

/**
 * Add medical record (vet only)
 * @param {number} cattleId - Cattle token ID
 * @param {string} recordType - Type of medical record
 * @param {string} ipfsHash - IPFS hash of the medical document
 * @param {number} timestamp - Record timestamp
 * @returns {Promise<Object>} Transaction receipt
 */
async function addMedicalRecord(cattleId, recordType, ipfsHash, timestamp) {
    try {
        // CORRECTION: Removed 'vetAddress' param. The signer 'wallet' must be the vet.
        console.log(`Adding medical record for cattle ${cattleId} by vet: ${wallet.address}`);
        
        // CORRECTION: Client-side check against the 'wallet.address'
        // This fails fast before sending a transaction that would revert.
        const isVet = await contract.isRegisteredVet(wallet.address);
        if (!isVet) {
            throw new Error('Signer wallet is not a registered veterinarian');
        }
        
        const tx = await contract.addMedicalRecord(cattleId, recordType, ipfsHash, timestamp);
        const receipt = await tx.wait();
        
        return {
            success: true,
            transactionHash: receipt.hash,
            blockNumber: receipt.blockNumber,
            gasUsed: receipt.gasUsed.toString()
        };
    } catch (error) {
        console.error('Error adding medical record:', error);
        // Provide more specific error if it's our custom check
        if (error.message.includes('Signer wallet')) {
            throw error;
        }
        throw new Error(`Failed to add medical record: ${error.message}`);
    }
}

/**
 * Get medical history for a cattle
 * @param {number} cattleId - Cattle token ID
 * @returns {Promise<Array>} Array of medical records
 */
async function getMedicalHistory(cattleId) {
    try {
        const history = await contract.getMedicalHistory(cattleId);
        
        return history.map(record => ({
            submittedBy: record.submittedBy,
            timestamp: record.timestamp.toString(),
            timestampDate: new Date(Number(record.timestamp) * 1000).toISOString(),
            recordType: record.recordType,
            ipfsHash: record.ipfsHash
        }));
    } catch (error) {
        console.error('Error getting medical history:', error);
        throw new Error(`Failed to get medical history: ${error.message}`);
    }
}

// ============================================
// OWNERSHIP TRANSFER FUNCTIONS
// ============================================

/**
 * Transfer cattle ownership
 * @param {number} cattleId - Cattle token ID
 * @param {string} toAddress - New owner address
 * @param {number} price - Sale price in wei
 * @returns {Promise<Object>} Transaction receipt
 */
async function transferCattle(cattleId, toAddress, price) {
    try {
        // CORRECTION: Removed 'fromAddress' param. The 'wallet' must be the sender.
        console.log(`Transferring cattle ${cattleId} from ${wallet.address} to ${toAddress}`);
        
        // CORRECTION: Client-side check against 'wallet.address'
        const currentOwner = await contract.ownerOf(cattleId);
        if (currentOwner.toLowerCase() !== wallet.address.toLowerCase()) {
            throw new Error('Signer wallet is not the cattle owner');
        }
        
        const tx = await contract.transferCattle(cattleId, toAddress, price);
        const receipt = await tx.wait();
        
        return {
            success: true,
            transactionHash: receipt.hash,
            blockNumber: receipt.blockNumber,
            gasUsed: receipt.gasUsed.toString()
        };
    } catch (error) {
        console.error('Error transferring cattle:', error);
        if (error.message.includes('Signer wallet')) {
            throw error;
        }
        throw new Error(`Failed to transfer cattle: ${error.message}`);
    }
}

// ============================================
// VETERINARIAN MANAGEMENT FUNCTIONS
// ============================================

/**
 * Register a veterinarian (owner only)
 * @param {string} vetAddress - Veterinarian's wallet address
 * @param {string} licenseId - License ID
 * @returns {Promise<Object>} Transaction receipt
 */
async function registerVeterinarian(vetAddress, licenseId) {
    try {
        // This function is correct. The 'wallet' must be the contract owner
        // and the 'onlyOwner' modifier on the contract will enforce this.
        console.log(`Registering veterinarian: ${vetAddress} by owner: ${wallet.address}`);
        
        const tx = await contract.registerVeterinarian(vetAddress, licenseId);
        const receipt = await tx.wait();
        
        return {
            success: true,
            transactionHash: receipt.hash,
            blockNumber: receipt.blockNumber,
            gasUsed: receipt.gasUsed.toString()
        };
    } catch (error) {
        console.error('Error registering veterinarian:', error);
        throw new Error(`Failed to register veterinarian: ${error.message}`);
    }
}

/**
 * Check if address is a registered veterinarian
 * @param {string} vetAddress - Address to check
 * @returns {Promise<boolean>} True if registered
 */
async function isRegisteredVet(vetAddress) {
    try {
        return await contract.isRegisteredVet(vetAddress);
    } catch (error) {
        console.error('Error checking vet registration:', error);
        throw new Error(`Failed to check vet registration: ${error.message}`);
    }
}

/**
 * Get veterinarian license hash
 * @param {string} vetAddress - Veterinarian's address
 * @returns {Promise<string>} License hash
 */
async function getVetLicenseHash(vetAddress) {
    try {
        const hash = await contract.veterinarianLicenseHash(vetAddress);
        return hash;
    } catch (error) {
        console.error('Error getting vet license hash:', error);
        throw new Error(`Failed to get vet license hash: ${error.message}`);
    }
}

// ============================================
// EVENT LISTENING FUNCTIONS
// ============================================

/**
 * Listen for CattleRegistered events
 * @param {Function} callback - Callback function to handle events
 */
function listenCattleRegistered(callback) {
    // CORRECTION: Use explicit filter for robustness (ethers v6 style)
    contract.on(contract.filters.CattleRegistered(), (cattleId, tagId, owner, timestamp, event) => {
        callback({
            cattleId: cattleId.toString(),
            tagId,
            owner,
            timestamp: timestamp.toString(),
            // CORRECTION: event.log.transactionHash is correct for ethers v6
            transactionHash: event.log.transactionHash
        });
    });
}

/**
 * Listen for MedicalRecordAdded events
 * @param {Function} callback - Callback function to handle events
 */
function listenMedicalRecordAdded(callback) {
    // CORRECTION: Use explicit filter
    contract.on(contract.filters.MedicalRecordAdded(), (cattleId, recordType, ipfsHash, submittedBy, timestamp, event) => {
        callback({
            cattleId: cattleId.toString(),
            recordType,
            ipfsHash,
            submittedBy,
            timestamp: timestamp.toString(),
            transactionHash: event.log.transactionHash
        });
    });
}

/**
 * Listen for CattleOwnershipTransferred events
 * @param {Function} callback - Callback function to handle events
 */
function listenCattleOwnershipTransferred(callback) {
    // CORRECTION: Use explicit filter
    contract.on(contract.filters.CattleOwnershipTransferred(), (cattleId, from, to, price, timestamp, event) => {
        callback({
            cattleId: cattleId.toString(),
            from,
            to,
            price: price.toString(),
            timestamp: timestamp.toString(),
            transactionHash: event.log.transactionHash
        });
    });
}

module.exports = {
    // Cattle management
    registerCattle,
    batchRegisterCattle,
    getCattleData,
    getCattleByOwner,
    getCattleCount,
    transferCattle,
    
    // Medical records
    addMedicalRecord,
    getMedicalHistory,
    
    // Veterinarian management
    registerVeterinarian,
    isRegisteredVet,
    getVetLicenseHash,
    
    // Event listeners
    listenCattleRegistered,
    listenMedicalRecordAdded,
    listenCattleOwnershipTransferred,
    
    // Constants
    ERROR_CODES,

    // Expose for advanced use
    provider,
    wallet,
    contract
};