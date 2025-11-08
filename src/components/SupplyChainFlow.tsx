import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { ArrowRight, Sprout, Factory, Truck, Store } from "lucide-react";
import { useBatches } from "@/hooks/useFirebaseData";

const stageStatusMap: Record<string, string[]> = {
  "Farm": ["Harvested", "Created"],
  "Processing": ["Processing", "Quality Check"],
  "Distribution": ["In Transit", "In Distribution"],
  "Retail": ["Delivered", "Packaged"]
};

export const SupplyChainFlow = () => {
  const { batches, loading } = useBatches();

  const stages = [
    {
      name: "Farm",
      icon: Sprout,
      statusKey: "Farm",
      color: "from-leaf to-nature-primary"
    },
    {
      name: "Processing",
      icon: Factory,
      statusKey: "Processing",
      color: "from-earth to-nature-accent"
    },
    {
      name: "Distribution",
      icon: Truck,
      statusKey: "Distribution",
      color: "from-nature-accent to-leaf"
    },
    {
      name: "Retail",
      icon: Store,
      statusKey: "Retail",
      color: "from-nature-primary to-earth"
    }
  ].map(stage => {
    const stageStatuses = stageStatusMap[stage.statusKey] || [];
    const count = batches.filter(b => stageStatuses.includes(b.status)).length;
    const status = count > 0 ? `${count} active` : "No batches";
    
    return {
      ...stage,
      count,
      status
    };
  });

  const totalActiveBatches = batches.filter(b => 
    !['Delivered', 'Completed', 'Cancelled'].includes(b.status)
  ).length;

  return (
    <Card className="h-full">
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <div className="w-2 h-2 bg-nature-primary rounded-full animate-pulse"></div>
          Supply Chain Flow (Real-time)
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-6">
        <div className="flex flex-col space-y-4">
          {stages.map((stage, index) => (
            <div key={index} className="flex items-center space-x-4">
              <div className={`p-3 rounded-xl bg-gradient-to-br ${stage.color} text-white shadow-lg`}>
                <stage.icon className="w-6 h-6" />
              </div>
              
              <div className="flex-1">
                <div className="flex items-center justify-between">
                  <h3 className="font-semibold">{stage.name}</h3>
                  <span className="text-sm font-medium text-nature-primary">{stage.count} batches</span>
                </div>
                <p className="text-sm text-muted-foreground">{stage.status}</p>
              </div>
              
              {index < stages.length - 1 && (
                <ArrowRight className="w-4 h-4 text-muted-foreground" />
              )}
            </div>
          ))}
        </div>
        
        <div className="pt-4 border-t">
          <div className="flex items-center justify-between text-sm">
            <span className="text-muted-foreground">End-to-end visibility</span>
            <span className="font-semibold text-nature-primary">{totalActiveBatches} active batches</span>
          </div>
        </div>
      </CardContent>
    </Card>
  );
};