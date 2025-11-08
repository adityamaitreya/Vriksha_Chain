import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { Search, Eye, MapPin, Link as LinkIcon } from "lucide-react";
import { Link } from "react-router-dom";
import { useBatches } from "@/hooks/useFirebaseData";

const getStatusColor = (status: string) => {
  switch (status) {
    case "Quality Check": return "bg-nature-accent/10 text-nature-accent border-nature-accent/20";
    case "In Transit":
    case "In Distribution": return "bg-earth/10 text-earth border-earth/20";
    case "Processing": return "bg-leaf/10 text-leaf border-leaf/20";
    case "Delivered":
    case "Completed": return "bg-green-100 text-green-800";
    default: return "bg-muted text-muted-foreground";
  }
};

const getQualityScore = (quality: string): number => {
  switch (quality) {
    case "Premium": return 95;
    case "Standard": return 85;
    default: return 75;
  }
};

export const ProductTracker = () => {
  const { batches, loading, error } = useBatches();
  
  // Get recent batches (last 5)
  const recentBatches = batches
    .sort((a, b) => {
      const dateA = a.lastUpdated ? new Date(a.lastUpdated).getTime() : 0;
      const dateB = b.lastUpdated ? new Date(b.lastUpdated).getTime() : 0;
      return dateB - dateA;
    })
    .slice(0, 5);

  return (
    <Card className="h-full">
      <CardHeader>
        <CardTitle className="flex items-center justify-between">
          <span>Recent Batches</span>
          <Link to="/supply-chain">
            <Button variant="outline" size="sm">
              <Search className="w-4 h-4 mr-2" />
              View All
            </Button>
          </Link>
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        {loading && (
          <div className="space-y-3">
            {[...Array(3)].map((_, i) => (
              <div key={i} className="p-4 border rounded-lg">
                <Skeleton className="h-4 w-3/4 mb-2" />
                <Skeleton className="h-3 w-1/2" />
              </div>
            ))}
          </div>
        )}

        {error && (
          <div className="text-sm text-red-600 p-4 border border-red-200 rounded-lg">
            Error loading batches: {error.message}
          </div>
        )}

        {!loading && !error && (
          <>
            {recentBatches.length === 0 ? (
              <div className="text-center py-8 text-muted-foreground">
                <p>No batches yet</p>
                <Link to="/supply-chain" className="text-sm text-nature-primary hover:underline mt-2 inline-block">
                  Create a batch
                </Link>
              </div>
            ) : (
              recentBatches.map((batch) => (
                <Link 
                  key={batch.id} 
                  to={`/batch/${batch.id}`}
                  className="block p-4 border rounded-lg hover:shadow-sm transition-shadow"
                >
                  <div className="flex items-start justify-between mb-3">
                    <div>
                      <h3 className="font-semibold">{batch.productName || 'Unnamed Product'}</h3>
                      <p className="text-sm text-muted-foreground flex items-center gap-1">
                        <MapPin className="w-3 h-3" />
                        {batch.origin || 'Origin not set'}
                      </p>
                    </div>
                    <Badge variant="outline" className={getStatusColor(batch.status)}>
                      {batch.status}
                    </Badge>
                  </div>
                  
                  <div className="flex items-center justify-between">
                    <div className="flex items-center space-x-4 text-sm">
                      <span className="text-muted-foreground">
                        {batch.batchNumber || batch.id}
                      </span>
                      <span className="text-muted-foreground">
                        Quality: {getQualityScore(batch.quality)}%
                      </span>
                    </div>
                    <LinkIcon className="w-4 h-4 text-muted-foreground" />
                  </div>
                </Link>
              ))
            )}
            
            {recentBatches.length > 0 && (
              <div className="pt-4 border-t">
                <Link to="/supply-chain">
                  <Button variant="outline" className="w-full">
                    View All Batches ({batches.length})
                  </Button>
                </Link>
              </div>
            )}
          </>
        )}
      </CardContent>
    </Card>
  );
};