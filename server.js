// server.js
// This file creates a web server to use your SDK.

const express = require('express');
const sdk = require('./cattle-trace-sdk.js'); // Import your SDK

const app = express();
app.use(express.json()); // Middleware to parse JSON bodies
const PORT = 3000;

console.log("CattleTrace SDK loaded. Server starting...");
console.log(`SDK is configured to use wallet: ${sdk.wallet.address}`);

// ============================================
// CATTLE ENDPOINTS
// ============================================

// GET /cattle/count
app.get('/cattle/count', async (req, res) => {
    try {
        const count = await sdk.getCattleCount();
        res.json({ success: true, count });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

// GET /cattle/:id
app.get('/cattle/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const data = await sdk.getCattleData(id);
        res.json({ success: true, data });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

// GET /owner/:address
app.get('/owner/:address', async (req, res) => {
    try {
        const { address } = req.params;
        const cattleIds = await sdk.getCattleByOwner(address);
        res.json({ success: true, owner: address, cattleIds });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

// POST /cattle/register
app.post('/cattle/register', async (req, res) => {
    try {
        const { tagId, breed, location, dob } = req.body;
        if (!tagId || !breed || !location || !dob) {
            return res.status(400).json({ success: false, message: "Missing required fields: tagId, breed, location, dob" });
        }
        const result = await sdk.registerCattle(tagId, breed, location, dob);
        res.status(201).json({ success: true, ...result });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

// POST /cattle/batch-register
app.post('/cattle/batch-register', async (req, res) => {
    try {
        const { cattleArray } = req.body;
        if (!cattleArray || !Array.isArray(cattleArray) || cattleArray.length === 0) {
            return res.status(400).json({ success: false, message: "Request body must be an object { cattleArray: [...] } with at least one cattle." });
        }
        const result = await sdk.batchRegisterCattle(cattleArray);
        res.status(201).json({ success: true, ...result });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

// POST /cattle/transfer/:id
app.post('/cattle/transfer/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { toAddress, price } = req.body;
        if (!toAddress || price === undefined) {
             return res.status(400).json({ success: false, message: "Missing required fields: toAddress, price" });
        }
        const result = await sdk.transferCattle(id, toAddress, price);
        res.json({ success: true, ...result });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

// ============================================
// VETERINARIAN ENDPOINTS
// ============================================

// POST /vet/register
app.post('/vet/register', async (req, res) => {
    try {
        const { vetAddress, licenseId } = req.body;
        if (!vetAddress || !licenseId) {
            return res.status(400).json({ success: false, message: "Missing required fields: vetAddress, licenseId" });
        }
        // This will only work if the server's wallet is the contract owner
        const result = await sdk.registerVeterinarian(vetAddress, licenseId);
        res.status(201).json({ success: true, ...result });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

// GET /vet/check/:address
app.get('/vet/check/:address', async (req, res) => {
    try {
        const { address } = req.params;
        const isVet = await sdk.isRegisteredVet(address);
        res.json({ success: true, address, isRegisteredVet: isVet });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

// ============================================
// MEDICAL RECORD ENDPOINTS
// ============================================

// GET /medical/:id
app.get('/medical/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const history = await sdk.getMedicalHistory(id);
        res.json({ success: true, cattleId: id, history });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

// POST /medical/:id
app.post('/medical/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { recordType, ipfsHash, timestamp } = req.body;
        if (!recordType || !ipfsHash || !timestamp) {
            return res.status(400).json({ success: false, message: "Missing required fields: recordType, ipfsHash, timestamp" });
        }
        // This will only work if the server's wallet is a registered vet
        const result = await sdk.addMedicalRecord(id, recordType, ipfsHash, timestamp);
        res.status(201).json({ success: true, ...result });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});


// ============================================
// SERVER START
// ============================================
app.listen(PORT, () => {
    console.log(`CattleTrace server running on http://localhost:${PORT}`);
});