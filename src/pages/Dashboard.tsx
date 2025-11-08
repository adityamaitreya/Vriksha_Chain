import { Header } from "@/components/Header";
import { StatsCards } from "@/components/StatsCards";
import { SupplyChainFlow } from "@/components/SupplyChainFlow";
import { ProductTracker } from "@/components/ProductTracker";
import { QualityMetrics } from "@/components/QualityMetrics";
import { SmartContractExample } from "@/components/SmartContractExample";
import { BatchRegistrationQR } from "@/components/BatchRegistrationQR";
import { BatchManagement } from "@/components/BatchManagement";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { useBatches } from "@/hooks/useFirebaseData";
import { Database, Package } from "lucide-react";
import { Link } from "react-router-dom";
import heroImage from "@/assets/herbal-supply-chain-hero.jpg";
import vrikshaLogo from "@/assets/vriksha-chain-logo.png";

const Dashboard = () => {
  const { batches, loading } = useBatches();

  return (
    <div className="min-h-screen bg-gradient-to-br from-background via-muted/30 to-background">
      <Header />
      
      <main className="container mx-auto px-4 py-8 space-y-8">
        {/* Hero Section */}
        <div className="relative rounded-2xl overflow-hidden mb-12">
          <div 
            className="h-96 bg-cover bg-center bg-no-repeat"
            style={{ backgroundImage: `url(${heroImage})` }}
          >
            <div className="absolute inset-0 bg-gradient-to-r from-background/90 via-background/70 to-transparent"></div>
            <div className="relative h-full flex items-center">
              <div className="container mx-auto px-8">
                <div className="max-w-2xl space-y-6">
                  <div className="flex items-center space-x-4">
                    <img 
                      src={vrikshaLogo} 
                      alt="VrikshaChain Logo" 
                      className="w-16 h-16 object-contain"
                    />
                    <h1 className="text-4xl md:text-6xl font-bold bg-gradient-to-r from-nature-primary via-leaf to-nature-accent bg-clip-text text-transparent">
                      VrikshaChain
                    </h1>
                  </div>
                  <p className="text-xl text-foreground/80 leading-relaxed">
                    Complete supply chain traceability for herbal and medicinal plants. 
                    From farm to pharmacy, ensure quality, authenticity, and compliance.
                  </p>
                  <div className="flex flex-wrap gap-3">
                    <div className="px-4 py-2 bg-nature-primary/10 text-nature-primary rounded-full text-sm font-medium">
                      Blockchain Verified
                    </div>
                    <div className="px-4 py-2 bg-leaf/10 text-leaf rounded-full text-sm font-medium">
                      Real-time Tracking
                    </div>
                    <div className="px-4 py-2 bg-earth/10 text-earth rounded-full text-sm font-medium">
                      Quality Assured
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* No Data Warning */}
        {!loading && batches.length === 0 && (
          <Card className="border-blue-200 bg-blue-50">
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div className="flex items-center space-x-3">
                  <Package className="w-8 h-8 text-blue-600" />
                  <div>
                    <h3 className="font-semibold text-blue-900">No batches in database</h3>
                    <p className="text-sm text-blue-700">Create your first batch to get started (Real-time sync enabled)</p>
                  </div>
                </div>
                <BatchManagement />
              </div>
            </CardContent>
          </Card>
        )}

        {/* Batch Management */}
        <div className="mb-8 flex items-center justify-between">
          <div>
            <h2 className="text-2xl font-bold text-nature-primary mb-2">Batch Management</h2>
            <p className="text-muted-foreground">Create and manage batches with real-time Firebase sync</p>
          </div>
          <BatchManagement />
        </div>

        {/* Batch Registration QR Code Generator */}
        <div className="mb-8">
          <BatchRegistrationQR baseUrl={window.location.origin} />
        </div>

        <StatsCards />
        
        <div className="grid lg:grid-cols-2 gap-8">
          <SupplyChainFlow />
          <ProductTracker />
        </div>

        <QualityMetrics />
        
        <SmartContractExample />
      </main>
    </div>
  );
};

export default Dashboard;
