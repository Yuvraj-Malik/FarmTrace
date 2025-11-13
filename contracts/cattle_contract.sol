// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Import OpenZeppelin contracts (v5 compatible)
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/metatx/ERC2771Context.sol";

/**
 * @title CattleTrace
 * @dev Gas-optimized cattle tracking NFT contract with EIP-2771 support.
 */
contract CattleTrace is ERC721, Ownable, ERC2771Context {
    // ============================================
    // STATE VARIABLES (Optimized)
    // ============================================
    
    // Use uint96 instead of uint256 for counter (saves gas, supports 79B+ cattle)
    uint96 private _cattleIdCounter;
    
    // ============================================
    // STRUCTS (Optimized for storage packing)
    // ============================================

    struct Cattle {
        address owner;          // 20 bytes - slot 0
        uint96 dob;            // 12 bytes - slot 0 (packed with owner)
        string tagId;          // slot 1
        string breed;          // slot 2
        string location;       // slot 3
    }

    struct MedicalRecord {
        address submittedBy;    // 20 bytes - slot 0
        uint96 timestamp;      // 12 bytes - slot 0 (packed)
        string recordType;     // slot 1
        string ipfsHash;       // slot 2
    }

    // ============================================
    // MAPPINGS
    // ============================================
    
    mapping(uint256 => Cattle) public cattleData;
    mapping(uint256 => MedicalRecord[]) private _medicalHistory;
    mapping(address => bool) public isRegisteredVet;
    // Store license as bytes32 hash instead of string to save gas
    mapping(address => bytes32) public veterinarianLicenseHash;

    // ============================================
    // EVENTS
    // ============================================
    
    event CattleRegistered(
        uint256 indexed cattleId,
        string tagId,
        address indexed owner,
        uint256 timestamp
    );

    event MedicalRecordAdded(
        uint256 indexed cattleId,
        string recordType,
        string ipfsHash,
        address indexed submittedBy,
        uint256 timestamp
    );

    event CattleOwnershipTransferred(
        uint256 indexed cattleId,
        address indexed from,
        address indexed to,
        uint256 price,
        uint256 timestamp
    );

    event VeterinarianRegistered(address indexed vetAddress, bytes32 licenseHash);

    // ============================================
    // ERRORS (Custom errors save gas vs require strings)
    // ============================================
    
    error InvalidAddress();
    error NotRegisteredVet();
    error CattleDoesNotExist();
    error NotCattleOwner();

    // ============================================
    // MODIFIERS
    // ============================================
    
    modifier onlyVet() {
        if (!isRegisteredVet[_msgSender()]) revert NotRegisteredVet();
        _;
    }

    // ============================================
    // CONSTRUCTOR
    // ============================================
    
    constructor(address trustedForwarder)
        ERC721("CattleTrace", "CATTLE")
        Ownable(msg.sender)
        ERC2771Context(trustedForwarder)
    {}

    // ============================================
    // EXTERNAL FUNCTIONS
    // ============================================

    /// @notice Register a new veterinarian (owner-only)
    /// @dev License is hashed to save gas on storage
    function registerVeterinarian(address vetAddress, string calldata licenseId)
        external
        onlyOwner
    {
        if (vetAddress == address(0)) revert InvalidAddress();
        
        isRegisteredVet[vetAddress] = true;
        veterinarianLicenseHash[vetAddress] = keccak256(bytes(licenseId));
        
        emit VeterinarianRegistered(vetAddress, keccak256(bytes(licenseId)));
    }

    /// @notice Register a new cattle NFT
    /// @dev Uses calldata for strings to save gas
    function registerCattle(
        string calldata tagId,
        string calldata breed,
        string calldata location,
        uint96 dob
    ) external returns (uint256) {
        // Unchecked for gas savings - overflow extremely unlikely with uint96
        unchecked {
            ++_cattleIdCounter;
        }
        
        uint256 newCattleId = _cattleIdCounter;
        address sender = _msgSender();

        _safeMint(sender, newCattleId);

        // Store cattle data with owner for easier queries
        cattleData[newCattleId] = Cattle({
            owner: sender,
            dob: dob,
            tagId: tagId,
            breed: breed,
            location: location
        });

        emit CattleRegistered(newCattleId, tagId, sender, block.timestamp);
        
        return newCattleId;
    }

    /// @notice Add a medical record for a specific cattle (vet-only)
    /// @dev Uses calldata for strings to save gas
    function addMedicalRecord(
        uint256 cattleId,
        string calldata recordType,
        string calldata ipfsHash,
        uint96 timestamp
    ) external onlyVet {
        if (_ownerOf(cattleId) == address(0)) revert CattleDoesNotExist();

        address sender = _msgSender();

        _medicalHistory[cattleId].push(
            MedicalRecord({
                submittedBy: sender,
                timestamp: timestamp,
                recordType: recordType,
                ipfsHash: ipfsHash
            })
        );

        emit MedicalRecordAdded(cattleId, recordType, ipfsHash, sender, timestamp);
    }

    /// @notice Transfer cattle NFT with price record
    function transferCattle(
        uint256 cattleId,
        address newOwner,
        uint256 price
    ) external {
        address currentOwner = ownerOf(cattleId);
        address sender = _msgSender();
        
        if (sender != currentOwner) revert NotCattleOwner();

        // Update owner in cattleData
        cattleData[cattleId].owner = newOwner;

        _safeTransfer(currentOwner, newOwner, cattleId, "");

        emit CattleOwnershipTransferred(
            cattleId,
            currentOwner,
            newOwner,
            price,
            block.timestamp
        );
    }

    /// @notice Retrieve full medical history of a cattle
    function getMedicalHistory(uint256 cattleId)
        external
        view
        returns (MedicalRecord[] memory)
    {
        return _medicalHistory[cattleId];
    }

    /// @notice Get cattle count (for frontend)
    function getCattleCount() external view returns (uint256) {
        return _cattleIdCounter;
    }

   /// @notice Batch register multiple cattle (gas efficient for farms)
function batchRegisterCattle(
    string[] calldata tagIds,
    string[] calldata breeds,
    string[] calldata locations,
    uint96[] calldata dobs
) external returns (uint256[] memory cattleIds) {
    uint256 length = tagIds.length;
    require(
        length == breeds.length &&
        length == locations.length &&
        length == dobs.length,
        "Array length mismatch"
    );

    cattleIds = new uint256[](length);
    address sender = _msgSender();

    for (uint256 i = 0; i < length;) {
        cattleIds[i] = _registerSingleCattle(
            sender,
            tagIds[i],
            breeds[i],
            locations[i],
            dobs[i]
        );

        unchecked {
            ++i;
        }
    }

    return cattleIds;
}

/// @dev Internal helper to avoid stack too deep
function _registerSingleCattle(
    address sender,
    string calldata tagId,
    string calldata breed,
    string calldata location,
    uint96 dob
) private returns (uint256) {
    unchecked {
        ++_cattleIdCounter;
    }
    
    uint256 newCattleId = _cattleIdCounter;

    _safeMint(sender, newCattleId);

    cattleData[newCattleId] = Cattle({
        owner: sender,
        dob: dob,
        tagId: tagId,
        breed: breed,
        location: location
    });

    emit CattleRegistered(newCattleId, tagId, sender, block.timestamp);

    return newCattleId;
}
    // ============================================
    // ERC2771 OVERRIDES
    // ============================================

    function _msgSender()
        internal
        view
        virtual
        override(Context, ERC2771Context)
        returns (address)
    {
        return ERC2771Context._msgSender();
    }

    function _msgData()
        internal
        view
        virtual
        override(Context, ERC2771Context)
        returns (bytes calldata)
    {
        return ERC2771Context._msgData();
    }

    function _contextSuffixLength()
        internal
        view
        virtual
        override(Context, ERC2771Context)
        returns (uint256)
    {
        return ERC2771Context._contextSuffixLength();
    }
}