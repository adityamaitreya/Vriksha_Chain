import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { addBatch } from "@/hooks/useFirebaseData";
import { Database, CheckCircle, AlertCircle } from "lucide-react";

const InitializeData = () => {
  const [loading, setLoading] = useState(false);
  const [success, setSuccess] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleInitialize = async () => {
    setLoading(true);
    setError(null);
    setSuccess(false);

    try {
      const sampleBatches = [
        {
          batchNumber: "ASH-2024-001",
          productName: "Ashwagandha Root Powder",
          quantity: "500kg",
          origin: "Rajasthan, India",
          harvestDate: "2024-01-10",
          status: "In Transit",
          quality: "Premium",
          currentLocation: "Distribution Center, Mumbai",
        },
        {
          batchNumber: "TUR-2024-002",
          productName: "Turmeric Curcumin Extract",
          quantity: "300kg",
          origin: "Tamil Nadu, India",
          harvestDate: "2024-01-08",
          status: "Processing",
          quality: "Standard",
          currentLocation: "Processing Plant, Chennai",
        },
        {
          batchNumber: "NEE-2024-003",
          productName: "Neem Leaf Powder",
          quantity: "750kg",
          origin: "Karnataka, India",
          harvestDate: "2024-01-15",
          status: "Quality Check",
          quality: "Premium",
          currentLocation: "Quality Lab, Bangalore",
        },
        {
          batchNumber: "BRA-2024-004",
          productName: "Brahmi Extract",
          quantity: "200kg",
          origin: "Kerala, India",
          harvestDate: "2024-01-12",
          status: "Harvested",
          quality: "Premium",
          currentLocation: "Farm, Kerala",
        },
      ];

      for (const batch of sampleBatches) {
        await addBatch(batch);
      }
      
      setSuccess(true);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to initialize data");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-background via-muted/30 to-background flex items-center justify-center p-4">
      <Card className="w-full max-w-md">
        <CardHeader>
          <div className="flex items-center space-x-2">
            <Database className="w-6 h-6 text-nature-primary" />
            <CardTitle>Initialize Firebase Database</CardTitle>
          </div>
          <CardDescription>
            Load sample data into your Firebase Realtime Database
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="text-sm text-muted-foreground space-y-2">
            <p>This will create:</p>
            <ul className="list-disc list-inside space-y-1 ml-2">
              <li>4 Sample Batches</li>
              <li>Real-time Firebase sync</li>
            </ul>
          </div>

          {success && (
            <Alert className="bg-green-50 border-green-200">
              <CheckCircle className="h-4 w-4 text-green-600" />
              <AlertDescription className="text-green-800">
                Sample data successfully loaded! You can now navigate to the dashboard.
              </AlertDescription>
            </Alert>
          )}

          {error && (
            <Alert className="bg-red-50 border-red-200">
              <AlertCircle className="h-4 w-4 text-red-600" />
              <AlertDescription className="text-red-800">
                {error}
              </AlertDescription>
            </Alert>
          )}

          <div className="flex space-x-2">
            <Button 
              onClick={handleInitialize} 
              disabled={loading || success}
              className="flex-1"
            >
              {loading ? "Initializing..." : success ? "Data Loaded" : "Initialize Sample Data"}
            </Button>
            {success && (
              <Button 
                variant="outline" 
                onClick={() => window.location.href = "/dashboard"}
              >
                Go to Dashboard
              </Button>
            )}
          </div>
        </CardContent>
      </Card>
    </div>
  );
};

export default InitializeData;
