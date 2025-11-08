import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Copy, Code } from "lucide-react";

const smartContractCode = `// VrikshaChain Smart Contract (Solidity)
pragma solidity ^0.8.0;

contract VrikshaChain {
    struct Batch {
        string productName;
        string origin;
        uint256 harvestDate;
        address farmer;
        uint8 qualityScore;
        bool organic;
        string[] certifications;
    }
    
    mapping(string => Batch) public batches;
    mapping(address => bool) public authorizedFarms;
    
    event BatchCreated(string batchId, string productName);
    event QualityUpdated(string batchId, uint8 newScore);
    
    function createBatch(
        string memory _batchId,
        string memory _productName,
        string memory _origin,
        uint8 _qualityScore,
        bool _organic
    ) public {
        require(authorizedFarms[msg.sender], "Unauthorized farm");
        require(_qualityScore <= 100, "Invalid quality score");
        
        batches[_batchId] = Batch({
            productName: _productName,
            origin: _origin,
            harvestDate: block.timestamp,
            farmer: msg.sender,
            qualityScore: _qualityScore,
            organic: _organic,
            certifications: new string[](0)
        });
        
        emit BatchCreated(_batchId, _productName);
    }
    
    function updateQuality(string memory _batchId, uint8 _newScore) 
        external 
        onlyAuthorized 
    {
        batches[_batchId].qualityScore = _newScore;
        emit QualityUpdated(_batchId, _newScore);
    }
}`;

export const SmartContractExample = () => {
  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Code className="w-5 h-5 text-nature-primary" />
            Smart Contract Example
          </div>
          <Button variant="outline" size="sm">
            <Copy className="w-4 h-4 mr-2" />
            Copy Code
          </Button>
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="bg-muted/30 rounded-lg p-4 border">
          <pre className="text-sm overflow-x-auto">
            <code className="text-foreground/90 leading-relaxed">
              {smartContractCode}
            </code>
          </pre>
        </div>
        <div className="mt-4 p-4 bg-nature-primary/5 rounded-lg border border-nature-primary/20">
          <h4 className="font-semibold text-nature-primary mb-2">Contract Features</h4>
          <ul className="text-sm space-y-1 text-muted-foreground">
            <li>• Immutable batch creation and tracking</li>
            <li>• Quality score validation and updates</li>
            <li>• Authorized farm verification</li>
            <li>• Event logging for transparency</li>
            <li>• Certification management</li>
          </ul>
        </div>
      </CardContent>
    </Card>
  );
};