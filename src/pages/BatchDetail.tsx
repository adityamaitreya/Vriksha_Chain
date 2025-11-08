import { Header } from "@/components/Header";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import { useParams, Link } from "react-router-dom";
import { CheckCircle, Factory, Package, Truck, Store, Sprout, ArrowLeft, Edit, MapPin, Calendar, Package2, AlertCircle } from "lucide-react";
import { BatchQRCode } from "@/components/BatchQRCode";
import { BatchManagement } from "@/components/BatchManagement";
import { useBatch, updateBatch } from "@/hooks/useFirebaseData";
import { Button } from "@/components/ui/button";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { useToast } from "@/hooks/use-toast";
import { useState } from "react";

type Step = {
  id: string;
  label: string;
  location: string;
  timestamp: string;
  icon: JSX.Element;
  status: "completed" | "current" | "upcoming";
};

const statusOrder = ['Created', 'Harvested', 'Processing', 'Quality Check', 'Packaged', 'In Transit', 'In Distribution', 'Delivered', 'Completed'];

const buildRoute = (batch: any): Step[] => {
  if (!batch) return [];
  
  const currentStatus = batch.status || 'Created';
  const currentIndex = statusOrder.indexOf(currentStatus);
  const harvestDate = batch.harvestDate ? new Date(batch.harvestDate).toISOString() : new Date().toISOString();
  
  const statusSteps = [
    { id: "harvest", label: "Harvest", statusKey: "Harvested", icon: <Sprout className="w-4 h-4" /> },
    { id: "processing", label: "Processing", statusKey: "Processing", icon: <Factory className="w-4 h-4" /> },
    { id: "quality", label: "Quality Check", statusKey: "Quality Check", icon: <AlertCircle className="w-4 h-4" /> },
    { id: "packaging", label: "Packaging", statusKey: "Packaged", icon: <Package className="w-4 h-4" /> },
    { id: "distribution", label: "Distribution", statusKey: "In Distribution", icon: <Truck className="w-4 h-4" /> },
    { id: "delivered", label: "Delivered", statusKey: "Delivered", icon: <CheckCircle className="w-4 h-4" /> },
  ];

  return statusSteps.map((step, idx) => {
    const stepIndex = statusOrder.indexOf(step.statusKey);
    let stepStatus: "completed" | "current" | "upcoming";
    
    if (stepIndex < currentIndex) {
      stepStatus = "completed";
    } else if (stepIndex === currentIndex) {
      stepStatus = "current";
    } else {
      stepStatus = "upcoming";
    }

    const timestamp = stepStatus === "completed" 
      ? new Date(new Date(harvestDate).getTime() + (idx + 1) * 24 * 3600_000).toLocaleDateString()
      : stepStatus === "current" 
        ? (batch.lastUpdated ? new Date(batch.lastUpdated).toLocaleString() : "In Progress")
        : "Pending";

    return {
      ...step,
      location: step.statusKey === currentStatus && batch.currentLocation 
        ? batch.currentLocation 
        : `${step.label} Location`,
      timestamp,
      status: stepStatus
    };
  });
};

const statusColor = (status: Step["status"]) => {
  switch (status) {
    case "completed": return "bg-green-100 text-green-800";
    case "current": return "bg-blue-100 text-blue-800";
    default: return "bg-gray-100 text-gray-800";
  }
};

const getStatusBadgeColor = (status: string) => {
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

const BatchDetail = () => {
  const { id = "" } = useParams();
  const { batch, loading, error } = useBatch(id);
  const { toast } = useToast();
  const [updatingStatus, setUpdatingStatus] = useState(false);
  
  const steps = buildRoute(batch);

  const handleStatusUpdate = async (newStatus: string) => {
    if (!batch || !id) return;
    
    setUpdatingStatus(true);
    try {
      await updateBatch(id, { 
        status: newStatus,
        currentLocation: batch.currentLocation || 'Location updated'
      });
      toast({
        title: "Status updated",
        description: `Batch status has been updated to ${newStatus}.`,
      });
    } catch (error: any) {
      toast({
        title: "Error",
        description: error.message || "Failed to update status",
        variant: "destructive",
      });
    } finally {
      setUpdatingStatus(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-background via-muted/30 to-background">
      <Header />
      <main className="container mx-auto px-4 py-8 space-y-8">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold text-nature-primary">
              {loading ? "Loading..." : batch ? `Batch ${batch.batchNumber || id}` : "Batch Not Found"}
            </h1>
            <p className="text-muted-foreground">Real-time tracking from harvest to customer</p>
          </div>
          <div className="flex items-center gap-2">
            {batch && <BatchManagement batchId={batch.id} />}
            <Link to="/supply-chain" className="inline-flex items-center text-sm text-nature-primary hover:underline">
              <ArrowLeft className="w-4 h-4 mr-1" /> Back to Supply Chain
            </Link>
          </div>
        </div>

        {loading && (
          <div className="space-y-4">
            <Card>
              <CardContent className="p-6">
                <Skeleton className="h-6 w-1/3 mb-4" />
                <Skeleton className="h-4 w-1/2" />
              </CardContent>
            </Card>
          </div>
        )}

        {error && (
          <Card className="border-red-200 bg-red-50">
            <CardContent className="p-6">
              <p className="text-red-800">Error loading batch: {error.message}</p>
            </CardContent>
          </Card>
        )}

        {!loading && !error && batch && (
          <>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
              <BatchQRCode batchId={id} baseUrl={window.location.origin} />
              
              <Card>
                <CardHeader>
                  <CardTitle>Batch Information</CardTitle>
                  <CardDescription>Real-time batch details</CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div>
                    <div className="text-sm text-muted-foreground mb-1">Product Name</div>
                    <div className="font-semibold">{batch.productName || 'N/A'}</div>
                  </div>
                  
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <div className="text-sm text-muted-foreground mb-1">Quantity</div>
                      <div className="font-medium">{batch.quantity || 'N/A'}</div>
                    </div>
                    <div>
                      <div className="text-sm text-muted-foreground mb-1">Quality</div>
                      <Badge variant="outline">{batch.quality || 'Unknown'}</Badge>
                    </div>
                  </div>
                  
                  <div>
                    <div className="text-sm text-muted-foreground mb-1 flex items-center gap-1">
                      <MapPin className="w-3 h-3" /> Origin
                    </div>
                    <div className="font-medium">{batch.origin || 'N/A'}</div>
                  </div>
                  
                  <div>
                    <div className="text-sm text-muted-foreground mb-1 flex items-center gap-1">
                      <MapPin className="w-3 h-3" /> Current Location
                    </div>
                    <div className="font-medium">{batch.currentLocation || 'Not set'}</div>
                  </div>
                  
                  <div>
                    <div className="text-sm text-muted-foreground mb-1 flex items-center gap-1">
                      <Calendar className="w-3 h-3" /> Harvest Date
                    </div>
                    <div className="font-medium">
                      {batch.harvestDate ? new Date(batch.harvestDate).toLocaleDateString() : 'N/A'}
                    </div>
                  </div>
                  
                  <div>
                    <div className="text-sm text-muted-foreground mb-2">Status</div>
                    <div className="flex items-center gap-2">
                      <Badge className={getStatusBadgeColor(batch.status)}>
                        {batch.status}
                      </Badge>
                      <Select
                        value={batch.status}
                        onValueChange={handleStatusUpdate}
                        disabled={updatingStatus}
                      >
                        <SelectTrigger className="w-[200px]">
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="Created">Created</SelectItem>
                          <SelectItem value="Harvested">Harvested</SelectItem>
                          <SelectItem value="Processing">Processing</SelectItem>
                          <SelectItem value="Quality Check">Quality Check</SelectItem>
                          <SelectItem value="Packaged">Packaged</SelectItem>
                          <SelectItem value="In Transit">In Transit</SelectItem>
                          <SelectItem value="In Distribution">In Distribution</SelectItem>
                          <SelectItem value="Delivered">Delivered</SelectItem>
                          <SelectItem value="Completed">Completed</SelectItem>
                          <SelectItem value="Cancelled">Cancelled</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                  </div>
                  
                  {batch.lastUpdated && (
                    <div>
                      <div className="text-sm text-muted-foreground mb-1">Last Updated</div>
                      <div className="text-sm">{new Date(batch.lastUpdated).toLocaleString()}</div>
                    </div>
                  )}
                </CardContent>
              </Card>
            </div>

            <Card>
              <CardHeader>
                <CardTitle>Route Timeline</CardTitle>
                <CardDescription>Chronological journey of the batch (Real-time)</CardDescription>
              </CardHeader>
              <CardContent>
                <ol className="relative border-s pl-6">
                  {steps.map((s, idx) => (
                    <li key={s.id} className="mb-8 ms-6">
                      <span className={`absolute -start-3 flex h-6 w-6 items-center justify-center rounded-full ${statusColor(s.status)}`}>
                        {s.icon}
                      </span>
                      <div className="flex items-center justify-between">
                        <h3 className="font-semibold">{idx + 1}. {s.label}</h3>
                        <span className="text-xs text-muted-foreground">{s.timestamp}</span>
                      </div>
                      <p className="text-sm text-muted-foreground">{s.location}</p>
                    </li>
                  ))}
                </ol>
              </CardContent>
            </Card>
          </>
        )}

        {!loading && !error && !batch && (
          <Card>
            <CardContent className="p-12 text-center">
              <Package2 className="w-12 h-12 text-muted-foreground mx-auto mb-4" />
              <p className="text-muted-foreground mb-4">Batch not found</p>
              <Link to="/supply-chain">
                <Button variant="outline">
                  <ArrowLeft className="w-4 h-4 mr-2" /> Back to Supply Chain
                </Button>
              </Link>
            </CardContent>
          </Card>
        )}
      </main>
    </div>
  );
};

export default BatchDetail;



