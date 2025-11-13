const { expect } = require("chai");
const { ethers } = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");

describe("CattleTrace", function () {
  let cattleTrace;
  let forwarder;
  let owner;
  let farmer1;
  let farmer2;
  let vet1;
  let vet2;
  let consumer;

  beforeEach(async function () {
    [owner, farmer1, farmer2, vet1, vet2, consumer] = await ethers.getSigners();

    // Deploy MinimalForwarder
    const MinimalForwarder = await ethers.getContractFactory("MinimalForwarder");
    forwarder = await MinimalForwarder.deploy();
    await forwarder.waitForDeployment();

    // Deploy CattleTrace
    const CattleTrace = await ethers.getContractFactory("CattleTrace");
    cattleTrace = await CattleTrace.deploy(await forwarder.getAddress());
    await cattleTrace.waitForDeployment();
  });

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      expect(await cattleTrace.owner()).to.equal(owner.address);
    });

    it("Should set the correct name and symbol", async function () {
      expect(await cattleTrace.name()).to.equal("CattleTrace");
      expect(await cattleTrace.symbol()).to.equal("CATTLE");
    });

    it("Should initialize with zero cattle count", async function () {
      expect(await cattleTrace.getCattleCount()).to.equal(0);
    });
  });

  describe("Veterinarian Management", function () {
    it("Should allow owner to register veterinarian", async function () {
      await cattleTrace.registerVeterinarian(vet1.address, "VET-LICENSE-001");
      expect(await cattleTrace.isRegisteredVet(vet1.address)).to.be.true;
      
      // License is stored as hash
      const expectedHash = ethers.keccak256(ethers.toUtf8Bytes("VET-LICENSE-001"));
      expect(await cattleTrace.veterinarianLicenseHash(vet1.address)).to.equal(expectedHash);
    });

    it("Should emit VeterinarianRegistered event", async function () {
      const expectedHash = ethers.keccak256(ethers.toUtf8Bytes("VET-LICENSE-001"));
      
      await expect(cattleTrace.registerVeterinarian(vet1.address, "VET-LICENSE-001"))
        .to.emit(cattleTrace, "VeterinarianRegistered")
        .withArgs(vet1.address, expectedHash);
    });

    it("Should not allow non-owner to register veterinarian", async function () {
      await expect(
        cattleTrace.connect(farmer1).registerVeterinarian(vet1.address, "VET-LICENSE-001")
      ).to.be.revertedWithCustomError(cattleTrace, "OwnableUnauthorizedAccount");
    });

    it("Should not allow registering zero address as veterinarian", async function () {
      await expect(
        cattleTrace.registerVeterinarian(ethers.ZeroAddress, "VET-LICENSE-001")
      ).to.be.revertedWithCustomError(cattleTrace, "InvalidAddress");
    });

    it("Should allow registering multiple veterinarians", async function () {
      await cattleTrace.registerVeterinarian(vet1.address, "VET-LICENSE-001");
      await cattleTrace.registerVeterinarian(vet2.address, "VET-LICENSE-002");

      expect(await cattleTrace.isRegisteredVet(vet1.address)).to.be.true;
      expect(await cattleTrace.isRegisteredVet(vet2.address)).to.be.true;
    });
  });

  describe("Cattle Registration", function () {
    it("Should allow anyone to register cattle", async function () {
      const dob = Math.floor(Date.now() / 1000) - 31536000;
      
      await cattleTrace.connect(farmer1).registerCattle(
        "TAG001",
        "Holstein",
        "Farm A, Location A",
        dob
      );

      const cattleId = 1;
      expect(await cattleTrace.ownerOf(cattleId)).to.equal(farmer1.address);
      
      const cattle = await cattleTrace.cattleData(cattleId);
      expect(cattle.tagId).to.equal("TAG001");
      expect(cattle.breed).to.equal("Holstein");
      expect(cattle.location).to.equal("Farm A, Location A");
      expect(cattle.owner).to.equal(farmer1.address);
    });

    it("Should emit CattleRegistered event", async function () {
      const dob = Math.floor(Date.now() / 1000) - 31536000;
      
      await expect(
        cattleTrace.connect(farmer1).registerCattle(
          "TAG001",
          "Holstein",
          "Farm A",
          dob
        )
      ).to.emit(cattleTrace, "CattleRegistered");
    });

    it("Should mint NFT to caller", async function () {
      const dob = Math.floor(Date.now() / 1000);
      
      await cattleTrace.connect(farmer1).registerCattle(
        "TAG001",
        "Holstein",
        "Farm A",
        dob
      );

      expect(await cattleTrace.balanceOf(farmer1.address)).to.equal(1);
    });

    it("Should increment cattle count", async function () {
      const dob = Math.floor(Date.now() / 1000);
      
      await cattleTrace.connect(farmer1).registerCattle(
        "TAG001",
        "Holstein",
        "Farm A",
        dob
      );

      expect(await cattleTrace.getCattleCount()).to.equal(1);

      await cattleTrace.connect(farmer2).registerCattle(
        "TAG002",
        "Angus",
        "Farm B",
        dob
      );

      expect(await cattleTrace.getCattleCount()).to.equal(2);
    });

    it("Should return the cattle ID", async function () {
      const dob = Math.floor(Date.now() / 1000);
      
      const tx = await cattleTrace.connect(farmer1).registerCattle(
        "TAG001",
        "Holstein",
        "Farm A",
        dob
      );

      expect(await cattleTrace.ownerOf(1)).to.equal(farmer1.address);
    });
  });

  describe("Medical Records", function () {
    let cattleId;
    let timestamp;

    beforeEach(async function () {
      await cattleTrace.registerVeterinarian(vet1.address, "VET-LICENSE-001");
      
      const dob = Math.floor(Date.now() / 1000) - 31536000;
      await cattleTrace.connect(farmer1).registerCattle(
        "TAG001",
        "Holstein",
        "Farm A",
        dob
      );
      cattleId = 1;
      timestamp = Math.floor(Date.now() / 1000);
    });

    it("Should allow registered vet to add medical record", async function () {
      await cattleTrace.connect(vet1).addMedicalRecord(
        cattleId,
        "Vaccination",
        "QmHash123",
        timestamp
      );

      const records = await cattleTrace.getMedicalHistory(cattleId);
      expect(records.length).to.equal(1);
      expect(records[0].recordType).to.equal("Vaccination");
      expect(records[0].ipfsHash).to.equal("QmHash123");
      expect(records[0].submittedBy).to.equal(vet1.address);
    });

    it("Should emit MedicalRecordAdded event", async function () {
      await expect(
        cattleTrace.connect(vet1).addMedicalRecord(
          cattleId,
          "Vaccination",
          "QmHash123",
          timestamp
        )
      ).to.emit(cattleTrace, "MedicalRecordAdded")
        .withArgs(cattleId, "Vaccination", "QmHash123", vet1.address, timestamp);
    });

    it("Should not allow non-vet to add medical record", async function () {
      await expect(
        cattleTrace.connect(farmer1).addMedicalRecord(
          cattleId,
          "Vaccination",
          "QmHash123",
          timestamp
        )
      ).to.be.revertedWithCustomError(cattleTrace, "NotRegisteredVet");
    });

    it("Should not allow adding record to non-existent cattle", async function () {
      await expect(
        cattleTrace.connect(vet1).addMedicalRecord(
          999,
          "Vaccination",
          "QmHash123",
          timestamp
        )
      ).to.be.revertedWithCustomError(cattleTrace, "CattleDoesNotExist");
    });

    it("Should allow multiple medical records", async function () {
      await cattleTrace.connect(vet1).addMedicalRecord(
        cattleId,
        "Vaccination",
        "QmHash123",
        timestamp
      );

      await cattleTrace.connect(vet1).addMedicalRecord(
        cattleId,
        "Checkup",
        "QmHash456",
        timestamp + 86400
      );

      const records = await cattleTrace.getMedicalHistory(cattleId);
      expect(records.length).to.equal(2);
      expect(records[0].recordType).to.equal("Vaccination");
      expect(records[1].recordType).to.equal("Checkup");
    });

    it("Should track which vet submitted each record", async function () {
      await cattleTrace.registerVeterinarian(vet2.address, "VET-LICENSE-002");

      await cattleTrace.connect(vet1).addMedicalRecord(
        cattleId,
        "Vaccination",
        "QmHash123",
        timestamp
      );

      await cattleTrace.connect(vet2).addMedicalRecord(
        cattleId,
        "Treatment",
        "QmHash456",
        timestamp
      );

      const records = await cattleTrace.getMedicalHistory(cattleId);
      expect(records[0].submittedBy).to.equal(vet1.address);
      expect(records[1].submittedBy).to.equal(vet2.address);
    });
  });

  describe("Cattle Transfer", function () {
    let cattleId;

    beforeEach(async function () {
      const dob = Math.floor(Date.now() / 1000) - 31536000;
      await cattleTrace.connect(farmer1).registerCattle(
        "TAG001",
        "Holstein",
        "Farm A",
        dob
      );
      cattleId = 1;
    });

    it("Should allow owner to transfer cattle", async function () {
      await cattleTrace.connect(farmer1).transferCattle(cattleId, farmer2.address, ethers.parseEther("1"));

      expect(await cattleTrace.ownerOf(cattleId)).to.equal(farmer2.address);
    });

    it("Should emit CattleOwnershipTransferred event with price", async function () {
      const price = ethers.parseEther("1.5");
      
      await expect(
        cattleTrace.connect(farmer1).transferCattle(cattleId, farmer2.address, price)
      ).to.emit(cattleTrace, "CattleOwnershipTransferred");
    });

    it("Should not allow non-owner to transfer cattle", async function () {
      await expect(
        cattleTrace.connect(farmer2).transferCattle(cattleId, consumer.address, ethers.parseEther("1"))
      ).to.be.revertedWithCustomError(cattleTrace, "NotCattleOwner");
    });

    it("Should transfer NFT ownership", async function () {
      expect(await cattleTrace.balanceOf(farmer1.address)).to.equal(1);
      expect(await cattleTrace.balanceOf(farmer2.address)).to.equal(0);

      await cattleTrace.connect(farmer1).transferCattle(cattleId, farmer2.address, ethers.parseEther("1"));

      expect(await cattleTrace.balanceOf(farmer1.address)).to.equal(0);
      expect(await cattleTrace.balanceOf(farmer2.address)).to.equal(1);
    });

    it("Should allow transferring with zero price", async function () {
      await cattleTrace.connect(farmer1).transferCattle(cattleId, farmer2.address, 0);
      expect(await cattleTrace.ownerOf(cattleId)).to.equal(farmer2.address);
    });

    it("Should update owner in cattle data", async function () {
      await cattleTrace.connect(farmer1).transferCattle(cattleId, farmer2.address, ethers.parseEther("1"));

      const cattle = await cattleTrace.cattleData(cattleId);
      expect(cattle.owner).to.equal(farmer2.address);
      expect(cattle.tagId).to.equal("TAG001");
      expect(cattle.breed).to.equal("Holstein");
    });
  });

  describe("Medical History Queries", function () {
    let cattleId;

    beforeEach(async function () {
      await cattleTrace.registerVeterinarian(vet1.address, "VET-LICENSE-001");
      
      const dob = Math.floor(Date.now() / 1000) - 31536000;
      await cattleTrace.connect(farmer1).registerCattle(
        "TAG001",
        "Holstein",
        "Farm A",
        dob
      );
      cattleId = 1;
    });

    it("Should return empty array for cattle with no medical records", async function () {
      const records = await cattleTrace.getMedicalHistory(cattleId);
      expect(records.length).to.equal(0);
    });

    it("Should return all medical records in order", async function () {
      const timestamp = Math.floor(Date.now() / 1000);

      await cattleTrace.connect(vet1).addMedicalRecord(
        cattleId,
        "Vaccination",
        "QmHash1",
        timestamp
      );

      await cattleTrace.connect(vet1).addMedicalRecord(
        cattleId,
        "Checkup",
        "QmHash2",
        timestamp + 86400
      );

      await cattleTrace.connect(vet1).addMedicalRecord(
        cattleId,
        "Treatment",
        "QmHash3",
        timestamp + 172800
      );

      const records = await cattleTrace.getMedicalHistory(cattleId);
      expect(records.length).to.equal(3);
      expect(records[0].recordType).to.equal("Vaccination");
      expect(records[1].recordType).to.equal("Checkup");
      expect(records[2].recordType).to.equal("Treatment");
    });
  });

  describe("ERC721 Functionality", function () {
    let cattleId;

    beforeEach(async function () {
      const dob = Math.floor(Date.now() / 1000);
      await cattleTrace.connect(farmer1).registerCattle(
        "TAG001",
        "Holstein",
        "Farm A",
        dob
      );
      cattleId = 1;
    });

    it("Should support ERC721 interface", async function () {
      expect(await cattleTrace.supportsInterface("0x80ac58cd")).to.be.true;
    });

    it("Should allow standard ERC721 transfers", async function () {
      await cattleTrace.connect(farmer1).transferFrom(farmer1.address, farmer2.address, cattleId);
      expect(await cattleTrace.ownerOf(cattleId)).to.equal(farmer2.address);
    });

    it("Should allow approvals", async function () {
      await cattleTrace.connect(farmer1).approve(farmer2.address, cattleId);
      expect(await cattleTrace.getApproved(cattleId)).to.equal(farmer2.address);
    });

    it("Should allow approved address to transfer", async function () {
      await cattleTrace.connect(farmer1).approve(farmer2.address, cattleId);
      await cattleTrace.connect(farmer2).transferFrom(farmer1.address, consumer.address, cattleId);
      expect(await cattleTrace.ownerOf(cattleId)).to.equal(consumer.address);
    });
  });

  describe("Edge Cases", function () {
    it("Should handle querying non-existent cattle", async function () {
      await expect(
        cattleTrace.ownerOf(999)
      ).to.be.revertedWithCustomError(cattleTrace, "ERC721NonexistentToken");
    });

    it("Should allow empty strings in cattle data", async function () {
      await cattleTrace.connect(farmer1).registerCattle(
        "",
        "",
        "",
        0
      );

      const cattle = await cattleTrace.cattleData(1);
      expect(cattle.tagId).to.equal("");
      expect(cattle.breed).to.equal("");
      expect(cattle.location).to.equal("");
    });

    it("Should handle medical history for non-existent cattle", async function () {
      const records = await cattleTrace.getMedicalHistory(999);
      expect(records.length).to.equal(0);
    });
  });
});