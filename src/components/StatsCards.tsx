import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { TrendingUp, Package, Users, Shield } from "lucide-react";
import { useBatches, calculateStatsFromBatches } from "@/hooks/useFirebaseData";
import { Skeleton } from "@/components/ui/skeleton";
import { useEffect, useState } from "react";

export const StatsCards = () => {
  const { batches, loading } = useBatches();
  const [calculatedStats, setCalculatedStats] = useState({
    activeBatches: 0,
    supplyPartners: 0,
    qualityScore: 0,
    traceabilityRate: 0
  });

  useEffect(() => {
    if (batches.length > 0) {
      const stats = calculateStatsFromBatches(batches);
      setCalculatedStats(stats);
    } else {
      setCalculatedStats({
        activeBatches: 0,
        supplyPartners: 0,
        qualityScore: 0,
        traceabilityRate: 0
      });
    }
  }, [batches]);

  const statsConfig = [
    {
      title: "Active Batches",
      value: calculatedStats.activeBatches,
      change: "+12.5%",
      icon: Package,
      color: "from-nature-primary to-leaf"
    },
    {
      title: "Supply Partners",
      value: calculatedStats.supplyPartners,
      change: "+8.2%",
      icon: Users,
      color: "from-earth to-nature-accent"
    },
    {
      title: "Quality Score",
      value: `${calculatedStats.qualityScore.toFixed(1)}%`,
      change: "+2.1%",
      icon: Shield,
      color: "from-leaf to-nature-primary"
    },
    {
      title: "Traceability Rate",
      value: `${calculatedStats.traceabilityRate.toFixed(1)}%`,
      change: "+0.5%",
      icon: TrendingUp,
      color: "from-nature-accent to-earth"
    }
  ];

  if (loading) {
    return (
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {[...Array(4)].map((_, index) => (
          <Card key={index}>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <Skeleton className="h-4 w-24" />
              <Skeleton className="h-4 w-4 rounded" />
            </CardHeader>
            <CardContent>
              <Skeleton className="h-8 w-20 mb-2" />
              <Skeleton className="h-3 w-32" />
            </CardContent>
          </Card>
        ))}
      </div>
    );
  }

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
      {statsConfig.map((stat, index) => (
        <Card key={index} className="relative overflow-hidden group hover:shadow-lg transition-all duration-300">
          <div className={`absolute inset-0 bg-gradient-to-br ${stat.color} opacity-5 group-hover:opacity-10 transition-opacity`}></div>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              {stat.title}
            </CardTitle>
            <stat.icon className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stat.value}</div>
            <p className="text-xs text-nature-primary font-medium">
              {stat.change} from last month
            </p>
          </CardContent>
        </Card>
      ))}
    </div>
  );
};