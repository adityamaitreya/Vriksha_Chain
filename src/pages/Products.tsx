import { Header } from "@/components/Header";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Skeleton } from "@/components/ui/skeleton";
import { Search, Filter, Eye, Package, Leaf, Droplets, Thermometer } from "lucide-react";
import { useBatches } from "@/hooks/useFirebaseData";
import { useState } from "react";
import { Link } from "react-router-dom";
import { BatchManagement } from "@/components/BatchManagement";

const Products = () => {
  const { batches, loading, error } = useBatches();
  const [searchTerm, setSearchTerm] = useState("");

  const getStatusColor = (status: string) => {
    switch (status) {
      case "Delivered":
      case "Completed": return "bg-green-100 text-green-800";
      case "In Transit":
      case "In Distribution": return "bg-blue-100 text-blue-800";
      case "Quality Check": return "bg-yellow-100 text-yellow-800";
      case "Processing": return "bg-orange-100 text-orange-800";
      case "Harvested": return "bg-purple-100 text-purple-800";
      default: return "bg-gray-100 text-gray-800";
    }
  };

  const getQualityColor = (quality: string) => {
    switch (quality) {
      case "Premium": return "bg-purple-100 text-purple-800";
      case "Standard": return "bg-blue-100 text-blue-800";
      default: return "bg-gray-100 text-gray-800";
    }
  };

  const filterBatches = (status?: string) => {
    let filtered = batches;
    
    if (searchTerm) {
      filtered = filtered.filter(b => 
        b.productName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        b.batchNumber?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        b.origin?.toLowerCase().includes(searchTerm.toLowerCase())
      );
    }
    
    if (status) {
      filtered = filtered.filter(b => b.status === status);
    }
    
    return filtered;
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-background via-muted/30 to-background">
      <Header />
      
      <main className="container mx-auto px-4 py-8 space-y-8">
        {/* Page Header */}
        <div className="flex items-center justify-between">
          <div className="space-y-2">
            <h1 className="text-3xl font-bold text-nature-primary">Batch Catalog</h1>
            <p className="text-muted-foreground">
              Manage and track all batches with real-time Firebase sync
            </p>
          </div>
          <BatchManagement />
        </div>

        {/* Search and Filters */}
        <Card>
          <CardHeader>
            <CardTitle>Search & Filter Batches</CardTitle>
            <CardDescription>Find specific batches or filter by status</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="flex flex-col md:flex-row gap-4">
              <div className="relative flex-1">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground w-4 h-4" />
                <Input 
                  placeholder="Search by product name, batch ID, or origin..." 
                  className="pl-10"
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                />
              </div>
              <Button variant="outline" className="flex items-center gap-2">
                <Filter className="w-4 h-4" />
                Filter
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
          <div className="grid gap-4">
            {[...Array(3)].map((_, i) => (
              <Card key={i}>
                <CardContent className="p-6">
                  <div className="flex items-start space-x-4">
                    <Skeleton className="w-12 h-12 rounded-lg" />
                    <div className="flex-1 space-y-2">
                      <Skeleton className="h-6 w-1/3" />
                      <Skeleton className="h-4 w-1/2" />
                      <Skeleton className="h-4 w-2/3" />
                    </div>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        )}

        {/* Products Tabs */}
        {!loading && !error && (
          <Tabs defaultValue="all" className="space-y-6">
            <TabsList className="grid w-full grid-cols-4">
              <TabsTrigger value="all">All Batches ({batches.length})</TabsTrigger>
              <TabsTrigger value="active">Active ({filterBatches().filter(b => !['Delivered', 'Completed', 'Cancelled'].includes(b.status)).length})</TabsTrigger>
              <TabsTrigger value="in-transit">In Transit ({filterBatches().filter(b => b.status === 'In Transit' || b.status === 'In Distribution').length})</TabsTrigger>
              <TabsTrigger value="delivered">Delivered ({filterBatches().filter(b => b.status === 'Delivered' || b.status === 'Completed').length})</TabsTrigger>
            </TabsList>

            <TabsContent value="all" className="space-y-4">
              <div className="grid gap-4">
                {filterBatches().length === 0 ? (
                  <Card>
                    <CardContent className="p-12 text-center">
                      <Package className="w-12 h-12 text-muted-foreground mx-auto mb-4" />
                      <p className="text-muted-foreground mb-4">No batches found</p>
                      <BatchManagement />
                    </CardContent>
                  </Card>
                ) : (
                  filterBatches().map((batch) => (
                    <Card key={batch.id} className="hover:shadow-md transition-shadow">
                      <CardContent className="p-6">
                        <div className="flex items-start justify-between">
                          <div className="flex items-start space-x-4">
                            <div className="w-12 h-12 bg-nature-primary/10 rounded-lg flex items-center justify-center">
                              <Leaf className="w-6 h-6 text-nature-primary" />
                            </div>
                            <div className="space-y-2">
                              <div>
                                <h3 className="font-semibold text-lg">{batch.productName || 'Unnamed Product'}</h3>
                                <p className="text-sm text-muted-foreground">
                                  Origin: {batch.origin || 'Not set'}
                                </p>
                              </div>
                              <div className="flex items-center space-x-4 text-sm">
                                <div className="flex items-center space-x-1">
                                  <Package className="w-4 h-4 text-muted-foreground" />
                                  <span>Batch: {batch.batchNumber || batch.id}</span>
                                </div>
                                <div className="flex items-center space-x-1">
                                  <Droplets className="w-4 h-4 text-muted-foreground" />
                                  <span>Qty: {batch.quantity || 'N/A'}</span>
                                </div>
                                {batch.lastUpdated && (
                                  <div className="flex items-center space-x-1">
                                    <Thermometer className="w-4 h-4 text-muted-foreground" />
                                    <span>Updated: {new Date(batch.lastUpdated).toLocaleDateString()}</span>
                                  </div>
                                )}
                              </div>
                            </div>
                          </div>
                          
                          <div className="flex items-center space-x-3">
                            <div className="text-right space-y-2">
                              <Badge className={getStatusColor(batch.status)}>
                                {batch.status}
                              </Badge>
                              <Badge className={getQualityColor(batch.quality)}>
                                {batch.quality}
                              </Badge>
                            </div>
                            <div className="flex space-x-2">
                              <Link to={`/batch/${batch.id}`}>
                                <Button variant="ghost" size="icon">
                                  <Eye className="w-4 h-4" />
                                </Button>
                              </Link>
                              <BatchManagement batchId={batch.id} />
                            </div>
                          </div>
                        </div>
                      </CardContent>
                    </Card>
                  ))
                )}
              </div>
            </TabsContent>

          <TabsContent value="active" className="space-y-4">
            <div className="grid gap-4">
              {filterBatches().filter(b => !['Delivered', 'Completed', 'Cancelled'].includes(b.status)).length === 0 ? (
                <Card>
                  <CardContent className="p-12 text-center">
                    <Package className="w-12 h-12 text-muted-foreground mx-auto mb-4" />
                    <p className="text-muted-foreground">No active batches</p>
                  </CardContent>
                </Card>
              ) : (
                filterBatches().filter(b => !['Delivered', 'Completed', 'Cancelled'].includes(b.status)).map((batch) => (
                  <Card key={batch.id} className="hover:shadow-md transition-shadow">
                    <CardContent className="p-6">
                      <div className="flex items-start justify-between">
                        <div className="flex items-start space-x-4">
                          <div className="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
                            <Leaf className="w-6 h-6 text-green-600" />
                          </div>
                          <div className="space-y-2">
                            <div>
                              <h3 className="font-semibold text-lg">{batch.productName || 'Unnamed Product'}</h3>
                              <p className="text-sm text-muted-foreground">
                                Origin: {batch.origin || 'Not set'}
                              </p>
                            </div>
                            <div className="flex items-center space-x-4 text-sm">
                              <div className="flex items-center space-x-1">
                                <Package className="w-4 h-4 text-muted-foreground" />
                                <span>Batch: {batch.batchNumber || batch.id}</span>
                              </div>
                              <div className="flex items-center space-x-1">
                                <Droplets className="w-4 h-4 text-muted-foreground" />
                                <span>Qty: {batch.quantity || 'N/A'}</span>
                              </div>
                            </div>
                          </div>
                        </div>
                        
                        <div className="flex items-center space-x-3">
                          <Badge className={getStatusColor(batch.status)}>
                            {batch.status}
                          </Badge>
                          <Badge className={getQualityColor(batch.quality)}>
                            {batch.quality}
                          </Badge>
                          <div className="flex space-x-2">
                            <Link to={`/batch/${batch.id}`}>
                              <Button variant="ghost" size="icon">
                                <Eye className="w-4 h-4" />
                              </Button>
                            </Link>
                            <BatchManagement batchId={batch.id} />
                          </div>
                        </div>
                      </div>
                    </CardContent>
                  </Card>
                ))
              )}
            </div>
          </TabsContent>

          <TabsContent value="in-transit" className="space-y-4">
            <div className="grid gap-4">
              {filterBatches().filter(b => b.status === 'In Transit' || b.status === 'In Distribution').length === 0 ? (
                <Card>
                  <CardContent className="p-12 text-center">
                    <Package className="w-12 h-12 text-muted-foreground mx-auto mb-4" />
                    <p className="text-muted-foreground">No batches in transit</p>
                  </CardContent>
                </Card>
              ) : (
                filterBatches().filter(b => b.status === 'In Transit' || b.status === 'In Distribution').map((batch) => (
                  <Card key={batch.id} className="hover:shadow-md transition-shadow border-blue-200">
                    <CardContent className="p-6">
                      <div className="flex items-start justify-between">
                        <div className="flex items-start space-x-4">
                          <div className="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
                            <Leaf className="w-6 h-6 text-blue-600" />
                          </div>
                          <div className="space-y-2">
                            <div>
                              <h3 className="font-semibold text-lg">{batch.productName || 'Unnamed Product'}</h3>
                              <p className="text-sm text-muted-foreground">
                                Origin: {batch.origin || 'Not set'}
                              </p>
                            </div>
                            <div className="flex items-center space-x-4 text-sm">
                              <div className="flex items-center space-x-1">
                                <Package className="w-4 h-4 text-muted-foreground" />
                                <span>Batch: {batch.batchNumber || batch.id}</span>
                              </div>
                              <div className="flex items-center space-x-1">
                                <Droplets className="w-4 h-4 text-muted-foreground" />
                                <span>Qty: {batch.quantity || 'N/A'}</span>
                              </div>
                            </div>
                          </div>
                        </div>
                        
                        <div className="flex items-center space-x-3">
                          <Badge className={getStatusColor(batch.status)}>
                            {batch.status}
                          </Badge>
                          <div className="flex space-x-2">
                            <Link to={`/batch/${batch.id}`}>
                              <Button variant="ghost" size="icon">
                                <Eye className="w-4 h-4" />
                              </Button>
                            </Link>
                            <BatchManagement batchId={batch.id} />
                          </div>
                        </div>
                      </div>
                    </CardContent>
                  </Card>
                ))
              )}
            </div>
          </TabsContent>

          <TabsContent value="delivered" className="space-y-4">
            <div className="grid gap-4">
              {filterBatches().filter(b => b.status === 'Delivered' || b.status === 'Completed').length === 0 ? (
                <Card>
                  <CardContent className="p-12 text-center">
                    <Package className="w-12 h-12 text-muted-foreground mx-auto mb-4" />
                    <p className="text-muted-foreground">No delivered batches</p>
                  </CardContent>
                </Card>
              ) : (
                filterBatches().filter(b => b.status === 'Delivered' || b.status === 'Completed').map((batch) => (
                  <Card key={batch.id} className="hover:shadow-md transition-shadow border-green-200">
                    <CardContent className="p-6">
                      <div className="flex items-start justify-between">
                        <div className="flex items-start space-x-4">
                          <div className="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
                            <Leaf className="w-6 h-6 text-green-600" />
                          </div>
                          <div className="space-y-2">
                            <div>
                              <h3 className="font-semibold text-lg">{batch.productName || 'Unnamed Product'}</h3>
                              <p className="text-sm text-muted-foreground">
                                Origin: {batch.origin || 'Not set'}
                              </p>
                            </div>
                            <div className="flex items-center space-x-4 text-sm">
                              <div className="flex items-center space-x-1">
                                <Package className="w-4 h-4 text-muted-foreground" />
                                <span>Batch: {batch.batchNumber || batch.id}</span>
                              </div>
                              <div className="flex items-center space-x-1">
                                <Droplets className="w-4 h-4 text-muted-foreground" />
                                <span>Qty: {batch.quantity || 'N/A'}</span>
                              </div>
                            </div>
                          </div>
                        </div>
                        
                        <div className="flex items-center space-x-3">
                          <Badge className={getStatusColor(batch.status)}>
                            {batch.status}
                          </Badge>
                          <div className="flex space-x-2">
                            <Link to={`/batch/${batch.id}`}>
                              <Button variant="ghost" size="icon">
                                <Eye className="w-4 h-4" />
                              </Button>
                            </Link>
                          </div>
                        </div>
                      </div>
                    </CardContent>
                  </Card>
                ))
              )}
            </div>
          </TabsContent>
        </Tabs>
        )}
      </main>
    </div>
  );
};

export default Products;
