import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Progress } from "@/components/ui/progress";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import { CheckCircle, AlertTriangle, Award } from "lucide-react";
import { useQualityMetrics, useCertifications } from "@/hooks/useFirebaseData";

const getMetricIcon = (category: string) => {
  if (category.toLowerCase().includes('organic') || category.toLowerCase().includes('certification')) {
    return Award;
  }
  if (category.toLowerCase().includes('metal') || category.toLowerCase().includes('contaminant')) {
    return AlertTriangle;
  }
  return CheckCircle;
};

const getMetricColor = (score: number, status: string) => {
  if (score >= 90) return "text-nature-primary";
  if (score >= 80) return "text-leaf";
  return "text-nature-accent";
};

export const QualityMetrics = () => {
  const { qualityMetrics, loading: metricsLoading, error: metricsError } = useQualityMetrics();
  const { certifications, loading: certsLoading, error: certsError } = useCertifications();

  const activeCertifications = certifications.filter(cert => cert.active);

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <div className="w-2 h-2 bg-nature-primary rounded-full"></div>
          Quality Metrics & Certifications (Real-time)
        </CardTitle>
        <CardDescription>
          Quality metrics and certifications synced from Firebase database
        </CardDescription>
      </CardHeader>
      <CardContent>
        <div className="grid md:grid-cols-2 gap-8">
          {/* Quality Scores */}
          <div className="space-y-6">
            <h3 className="font-semibold text-lg">Quality Scores</h3>
            {metricsLoading && (
              <div className="space-y-4">
                {[...Array(3)].map((_, i) => (
                  <div key={i} className="space-y-2">
                    <Skeleton className="h-4 w-full" />
                    <Skeleton className="h-2 w-full" />
                  </div>
                ))}
              </div>
            )}
            {metricsError && (
              <div className="text-sm text-red-600">Error loading quality metrics: {metricsError.message}</div>
            )}
            {!metricsLoading && !metricsError && (
              <>
                {qualityMetrics.length === 0 ? (
                  <div className="text-center py-8 text-muted-foreground">
                    No quality metrics yet. Add them in the Analytics page.
                  </div>
                ) : (
                  qualityMetrics.map((metric) => {
                    const IconComponent = getMetricIcon(metric.category);
                    const color = getMetricColor(metric.score, metric.status);
                    return (
                      <div key={metric.id} className="space-y-2">
                        <div className="flex items-center justify-between">
                          <div className="flex items-center gap-2">
                            <IconComponent className={`w-4 h-4 ${color}`} />
                            <span className="font-medium">{metric.category}</span>
                          </div>
                          <div className="flex items-center gap-2">
                            <span className="text-sm font-semibold">{metric.score}%</span>
                            <Badge variant={metric.score >= 90 ? "default" : "secondary"} className="text-xs">
                              {metric.status}
                            </Badge>
                          </div>
                        </div>
                        <Progress value={metric.score} className="h-2" />
                      </div>
                    );
                  })
                )}
              </>
            )}
          </div>
          
          {/* Certifications */}
          <div className="space-y-6">
            <h3 className="font-semibold text-lg">
              Active Certifications ({activeCertifications.length})
            </h3>
            {certsLoading && (
              <div className="grid grid-cols-2 gap-4">
                {[...Array(4)].map((_, i) => (
                  <Skeleton key={i} className="h-24 w-full" />
                ))}
              </div>
            )}
            {certsError && (
              <div className="text-sm text-red-600">Error loading certifications: {certsError.message}</div>
            )}
            {!certsLoading && !certsError && (
              <>
                {certifications.length === 0 ? (
                  <div className="text-center py-8 text-muted-foreground">
                    No certifications yet. Add them in the Analytics page.
                  </div>
                ) : (
                  <div className="grid grid-cols-2 gap-4">
                    {certifications.map((cert) => (
                      <div 
                        key={cert.id}
                        className={`p-4 border rounded-lg text-center transition-all ${
                          cert.active 
                            ? 'border-nature-primary/20 bg-nature-primary/5' 
                            : 'border-muted bg-muted/30'
                        }`}
                      >
                        <div className={`w-8 h-8 mx-auto mb-2 rounded-full flex items-center justify-center ${
                          cert.active ? 'bg-nature-primary' : 'bg-muted-foreground'
                        }`}>
                          {cert.active ? (
                            <CheckCircle className="w-4 h-4 text-white" />
                          ) : (
                            <div className="w-2 h-2 bg-white rounded-full"></div>
                          )}
                        </div>
                        <p className="text-sm font-medium">{cert.name}</p>
                        <p className={`text-xs ${cert.active ? 'text-nature-primary' : 'text-muted-foreground'}`}>
                          {cert.active ? 'Active' : 'Inactive'}
                        </p>
                        {cert.expiryDate && cert.active && (
                          <p className="text-xs text-muted-foreground mt-1">
                            Expires: {new Date(cert.expiryDate).toLocaleDateString()}
                          </p>
                        )}
                      </div>
                    ))}
                  </div>
                )}
              </>
            )}
          </div>
        </div>
      </CardContent>
    </Card>
  );
};