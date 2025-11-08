import { Header } from "@/components/Header";
import { StatsCards } from "@/components/StatsCards";
import { SupplyChainFlow } from "@/components/SupplyChainFlow";
import { ProductTracker } from "@/components/ProductTracker";
import { QualityMetrics } from "@/components/QualityMetrics";
import { SmartContractExample } from "@/components/SmartContractExample";
import heroImage from "@/assets/herbal-supply-chain-hero.jpg";
import vrikshaLogo from "@/assets/vriksha-chain-logo.png";

const Index = () => {
  return (
    <div className="min-h-screen bg-gradient-to-br from-background via-muted/30 to-background overflow-x-hidden">
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

export default Index;