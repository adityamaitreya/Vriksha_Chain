import { useState } from "react";
import { Header } from "@/components/Header";
import { SupplyChainFlow } from "@/components/SupplyChainFlow";
import { ProductTracker } from "@/components/ProductTracker";
import { BatchManagement } from "@/components/BatchManagement";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Skeleton } from "@/components/ui/skeleton";
import { Search, Filter, MapPin, Clock, CheckCircle, AlertCircle, Package, Truck } from "lucide-react";
import { Link } from "react-router-dom";
import { useBatches } from "@/hooks/useFirebaseData";

const SupplyChain = () => {
  const { batches, loading, error } = useBatches();
  const [searchTerm, setSearchTerm] = useState("");

  const getStatusColor = (status: string) => {
    switch (status) {
      case "Delivered":
      case "Completed": return "bg-green-100 text-green-800";
      case "In Transit":
      case "In Distribution": return "bg-blue-100 text-blue-800";
      case "Quality Check": return "bg-yellow-100 text-yellow-800";
      case "Harvested": return "bg-purple-100 text-purple-800";
      case "Processing": return "bg-orange-100 text-orange-800";
      default: return "bg-gray-100 text-gray-800";
    }
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case "Delivered":
      case "Completed": return <CheckCircle className="w-4 h-4" />;
      case "In Transit":
      case "In Distribution": return <Truck className="w-4 h-4" />;
      case "Quality Check": return <AlertCircle className="w-4 h-4" />;
      case "Harvested":
      case "Created": return <Package className="w-4 h-4" />;
      default: return <Clock className="w-4 h-4" />;
    }
  };

  const calculateProgress = (status: string): number => {
    const statusOrder = ['Created', 'Harvested', 'Processing', 'Quality Check', 'Packaged', 'In Transit', 'In Distribution', 'Delivered', 'Completed'];
    const index = statusOrder.indexOf(status);
    if (index === -1) return 0;
    return Math.round(((index + 1) / statusOrder.length) * 100);
  };

  const getNextStop = (status: string): string => {
    switch (status) {
      case "Created": return "Harvest";
      case "Harvested": return "Processing Plant";
      case "Processing": return "Quality Check";
      case "Quality Check": return "Packaging";
      case "Packaged": return "Distribution";
      case "In Transit": return "Distribution Center";
      case "In Distribution": return "Retail";
      case "Delivered": return "Customer";
      default: return "Next Stage";
    }
  };

  const filteredBatches = batches.filter(batch => {
    if (!searchTerm) return true;
    const search = searchTerm.toLowerCase();
    return (
      batch.batchNumber?.toLowerCase().includes(search) ||
      batch.productName?.toLowerCase().includes(search) ||
      batch.currentLocation?.toLowerCase().includes(search) ||
      batch.origin?.toLowerCase().includes(search)
    );
  });

  return (
    <div className="min-h-screen bg-gradient-to-br from-background via-muted/30 to-background">
      <Header />
      
      <main className="container mx-auto px-4 py-8 space-y-8">
        {/* Page Header */}
        <div className="flex items-center justify-between">
          <div className="space-y-4">
            <h1 className="text-3xl font-bold text-nature-primary">Supply Chain Management</h1>
            <p className="text-muted-foreground">
              Track and monitor the complete journey of herbal products from farm to consumer (Real-time sync)
            </p>
          </div>
          <BatchManagement />
        </div>

        {/* Search and Filters */}
        <Card>
          <CardHeader>
            <CardTitle>Search & Filter</CardTitle>
            <CardDescription>Find specific batches in the supply chain</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="flex flex-col md:flex-row gap-4">
              <div className="relative flex-1">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground w-4 h-4" />
                <Input 
                  placeholder="Search by product, batch ID, or location..." 
                  className="pl-10"
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                />
              </div>
              <Button variant="outline" className="flex items-center gap-2">
                <Filter className="w-4 h-4" />
                Filter ({filteredBatches.length})
              </Button>
            </div>
          </CardContent>
        </Card>

        {/* Error State */}
        {error && (
          <Card className="border-red-200 bg-red-50">
            <CardContent className="p-6">
              <p className="text-red-800">Error loading batches: {error.message}</p>
            </CardContent>
          </Card>
        )}

        {/* Loading State */}
        {loading && (
          <div className="space-y-4">
            {[...Array(3)].map((_, i) => (
              <Card key={i}>
                <CardContent className="p-6">
                  <div className="flex items-start space-x-4">
                    <Skeleton className="w-10 h-10 rounded-full" />
                    <div className="flex-1 space-y-2">
                      <Skeleton className="h-6 w-1/3" />
                      <Skeleton className="h-4 w-1/2" />
                    </div>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        )}

        {/* Active Batches */}
        {!loading && !error && (
          <Card>
            <CardHeader>
              <CardTitle>Active Batches ({filteredBatches.length})</CardTitle>
              <CardDescription>Real-time tracking of batches in the supply chain</CardDescription>
            </CardHeader>
            <CardContent>
              {filteredBatches.length === 0 ? (
                <div className="text-center py-12">
                  <Package className="w-12 h-12 text-muted-foreground mx-auto mb-4" />
                  <p className="text-muted-foreground mb-4">No batches found</p>
                  <BatchManagement />
                </div>
              ) : (
                <div className="space-y-4">
                  {filteredBatches.map((batch) => {
                    const progress = calculateProgress(batch.status);
                    const nextStop = getNextStop(batch.status);
                    const timestamp = batch.lastUpdated 
                      ? new Date(batch.lastUpdated).toLocaleString()
                      : 'N/A';
                    
                    return (
                      <Link 
                        key={batch.id} 
                        to={`/batch/${batch.id}`} 
                        className="block border rounded-lg p-4 hover:bg-muted/50 transition-colors"
                      >
                        <div className="flex items-center justify-between mb-3">
                          <div className="flex items-center space-x-3">
                            <div className="w-10 h-10 bg-nature-primary/10 rounded-full flex items-center justify-center">
                              {getStatusIcon(batch.status)}
                            </div>
                            <div>
                              <h3 className="font-semibold">{batch.productName || 'Unnamed Product'}</h3>
                              <p className="text-sm text-muted-foreground">Batch: {batch.batchNumber || batch.id}</p>
                            </div>
                          </div>
                          <Badge className={getStatusColor(batch.status)}>
                            {batch.status}
                          </Badge>
                        </div>
                        
                        <div className="grid md:grid-cols-2 gap-4 mb-3">
                          <div className="flex items-center space-x-2 text-sm">
                            <MapPin className="w-4 h-4 text-muted-foreground" />
                            <span>{batch.currentLocation || 'Location not set'}</span>
                          </div>
                          <div className="flex items-center space-x-2 text-sm">
                            <Clock className="w-4 h-4 text-muted-foreground" />
                            <span>{timestamp}</span>
                          </div>
                        </div>
                        
                        <div className="space-y-2">
                          <div className="flex justify-between text-sm">
                            <span>Progress</span>
                            <span>{progress}%</span>
                          </div>
                          <div className="w-full bg-muted rounded-full h-2">
                            <div 
                              className="bg-nature-primary h-2 rounded-full transition-all duration-300"
                              style={{ width: `${progress}%` }}
                            ></div>
                          </div>
                          <p className="text-sm text-muted-foreground">
                            Next: {nextStop}
                          </p>
                        </div>
                      </Link>
                    );
                  })}
                </div>
              )}
            </CardContent>
          </Card>
        )}

        {/* Supply Chain Overview */}
        <div className="grid lg:grid-cols-2 gap-8">
          <SupplyChainFlow />
          <ProductTracker />
        </div>
      </main>
    </div>
  );
};

export default SupplyChain;
