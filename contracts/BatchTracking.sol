// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BatchTracking {
    // Structs
    struct Batch {
        string batchId;
        string productName;
        string variety;
        uint256 quantity;
        string unit;
        string location;
        uint256 harvestDate;
        uint256 expiryDate;
        string nfcTagId;
        address creator;
        uint256 timestamp;
        bool exists;
    }
    
    struct QualityMetric {
        string metricId;
        string batchId;
        string metricType;
        string value;
        string unit;
        uint256 timestamp;
        address inspector;
        bool exists;
    }
    
    struct NFCAuthentication {
        string authId;
        string batchId;
        string nfcTagId;
        uint256 timestamp;
        string location;
        bool isValid;
    }
    
    // State variables
    mapping(string => Batch) public batches;
    mapping(string => QualityMetric) public qualityMetrics;
    mapping(string => NFCAuthentication) public nfcAuthentications;
    mapping(string => string[]) public batchQualityMetrics;
    mapping(string => string[]) public batchAuthentications;
    mapping(string => uint256) public nfcAuthenticationCount;
    
    string[] public batchIds;
    string[] public qualityMetricIds;
    string[] public authenticationIds;
    
    // Events
    event BatchCreated(
        string indexed batchId,
        string productName,
        address indexed creator,
        uint256 timestamp
    );
    
    event QualityMetricAdded(
        string indexed metricId,
        string indexed batchId,
        string metricType,
        address indexed inspector
    );
    
    event NFCAuthenticated(
        string indexed authId,
        string indexed batchId,
        string nfcTagId,
        bool isValid,
        uint256 timestamp
    );
    
    // Modifiers
    modifier batchExists(string memory batchId) {
        require(batches[batchId].exists, "Batch does not exist");
        _;
    }
    
    // Functions
    function createBatch(
        string memory _batchId,
        string memory _productName,
        string memory _variety,
        uint256 _quantity,
        string memory _unit,
        string memory _location,
        uint256 _harvestDate,
        uint256 _expiryDate,
        string memory _nfcTagId
    ) public {
        require(!batches[_batchId].exists, "Batch already exists");
        require(bytes(_batchId).length > 0, "Batch ID cannot be empty");
        require(bytes(_productName).length > 0, "Product name cannot be empty");
        require(_quantity > 0, "Quantity must be greater than 0");
        
        batches[_batchId] = Batch({
            batchId: _batchId,
            productName: _productName,
            variety: _variety,
            quantity: _quantity,
            unit: _unit,
            location: _location,
            harvestDate: _harvestDate,
            expiryDate: _expiryDate,
            nfcTagId: _nfcTagId,
            creator: msg.sender,
            timestamp: block.timestamp,
            exists: true
        });
        
        batchIds.push(_batchId);
        
        emit BatchCreated(_batchId, _productName, msg.sender, block.timestamp);
    }
    
    function addQualityMetric(
        string memory _metricId,
        string memory _batchId,
        string memory _metricType,
        string memory _value,
        string memory _unit
    ) public batchExists(_batchId) {
        require(!qualityMetrics[_metricId].exists, "Metric already exists");
        require(bytes(_metricId).length > 0, "Metric ID cannot be empty");
        
        qualityMetrics[_metricId] = QualityMetric({
            metricId: _metricId,
            batchId: _batchId,
            metricType: _metricType,
            value: _value,
            unit: _unit,
            timestamp: block.timestamp,
            inspector: msg.sender,
            exists: true
        });
        
        qualityMetricIds.push(_metricId);
        batchQualityMetrics[_batchId].push(_metricId);
        
        emit QualityMetricAdded(_metricId, _batchId, _metricType, msg.sender);
    }
    
    function authenticateNFC(
        string memory _authId,
        string memory _batchId,
        string memory _nfcTagId,
        string memory _location
    ) public batchExists(_batchId) returns (bool) {
        require(bytes(_authId).length > 0, "Auth ID cannot be empty");
        
        // Verify NFC tag matches
        bool isValid = keccak256(abi.encodePacked(batches[_batchId].nfcTagId)) == 
                       keccak256(abi.encodePacked(_nfcTagId));
        
        nfcAuthentications[_authId] = NFCAuthentication({
            authId: _authId,
            batchId: _batchId,
            nfcTagId: _nfcTagId,
            timestamp: block.timestamp,
            location: _location,
            isValid: isValid
        });
        
        authenticationIds.push(_authId);
        batchAuthentications[_batchId].push(_authId);
        nfcAuthenticationCount[_nfcTagId]++;
        
        emit NFCAuthenticated(_authId, _batchId, _nfcTagId, isValid, block.timestamp);
        
        return isValid;
    }
    
    function getBatch(string memory _batchId) public view returns (
        string memory productName,
        string memory variety,
        uint256 quantity,
        string memory unit,
        string memory location,
        uint256 harvestDate,
        uint256 expiryDate,
        string memory nfcTagId,
        address creator,
        uint256 timestamp
    ) {
        Batch memory batch = batches[_batchId];
        require(batch.exists, "Batch does not exist");
        
        return (
            batch.productName,
            batch.variety,
            batch.quantity,
            batch.unit,
            batch.location,
            batch.harvestDate,
            batch.expiryDate,
            batch.nfcTagId,
            batch.creator,
            batch.timestamp
        );
    }
    
    function getBatchQualityMetrics(string memory _batchId) 
        public 
        view 
        returns (string[] memory) 
    {
        return batchQualityMetrics[_batchId];
    }
    
    function getBatchAuthentications(string memory _batchId) 
        public 
        view 
        returns (string[] memory) 
    {
        return batchAuthentications[_batchId];
    }
    
    function getTotalBatches() public view returns (uint256) {
        return batchIds.length;
    }
    
    function getAllBatchIds() public view returns (string[] memory) {
        return batchIds;
    }
    
    function getNFCAuthCount(string memory _nfcTagId) public view returns (uint256) {
        return nfcAuthenticationCount[_nfcTagId];
    }
    
    function getAuthenticationDetails(string memory _authId) public view returns (
        string memory batchId,
        string memory nfcTagId,
        uint256 timestamp,
        string memory location,
        bool isValid
    ) {
        NFCAuthentication memory auth = nfcAuthentications[_authId];
        return (
            auth.batchId,
            auth.nfcTagId,
            auth.timestamp,
            auth.location,
            auth.isValid
        );
    }
}
