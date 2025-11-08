import { useState, useEffect } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Switch } from "@/components/ui/switch";
import { Badge } from "@/components/ui/badge";
import { Textarea } from "@/components/ui/textarea";
import { Plus, Save, X, Edit, Trash2, Award, Package } from "lucide-react";
import { useQualityMetrics, useCertifications, useBatches, addQualityMetric, updateQualityMetric, deleteQualityMetric, addCertification, updateCertification, deleteCertification, QualityMetric, Certification } from '@/hooks/useFirebaseData';
import { useToast } from '@/hooks/use-toast';

export const QualityMetricsManagement = () => {
  const { qualityMetrics, loading: metricsLoading } = useQualityMetrics();
  const { certifications, loading: certsLoading } = useCertifications();
  const { batches, loading: batchesLoading } = useBatches();
  const { toast } = useToast();
  const [loading, setLoading] = useState(false);
  const [openMetricDialog, setOpenMetricDialog] = useState(false);
  const [openCertDialog, setOpenCertDialog] = useState(false);
  const [editingMetric, setEditingMetric] = useState<QualityMetric | null>(null);
  const [editingCert, setEditingCert] = useState<Certification | null>(null);
  const [batchFilter, setBatchFilter] = useState<string>('all');

  const [metricFormData, setMetricFormData] = useState({
    batchId: '',
    productName: '',
    category: '',
    score: 0,
    status: 'Passed',
    notes: ''
  });

  const [certFormData, setCertFormData] = useState({
    name: '',
    active: true,
    issuedDate: '',
    expiryDate: '',
    issuingBody: '',
    certificateNumber: ''
  });

  // Update product name when batch is selected
  useEffect(() => {
    if (metricFormData.batchId && metricFormData.batchId !== '') {
      const selectedBatch = batches.find(b => b.id === metricFormData.batchId);
      if (selectedBatch) {
        setMetricFormData(prev => ({
          ...prev,
          productName: selectedBatch.productName || ''
        }));
      }
    } else if (!metricFormData.batchId || metricFormData.batchId === '') {
      setMetricFormData(prev => ({
        ...prev,
        productName: ''
      }));
    }
  }, [metricFormData.batchId, batches]);

  const resetMetricForm = () => {
    setMetricFormData({
      batchId: '',
      productName: '',
      category: '',
      score: 0,
      status: 'Passed',
      notes: ''
    });
    setEditingMetric(null);
  };

  // Filter quality metrics by batch
  const filteredMetrics = batchFilter === 'all' 
    ? qualityMetrics 
    : qualityMetrics.filter(m => m.batchId === batchFilter);

  const resetCertForm = () => {
    setCertFormData({
      name: '',
      active: true,
      issuedDate: '',
      expiryDate: '',
      issuingBody: '',
      certificateNumber: ''
    });
    setEditingCert(null);
  };

  const handleMetricSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      if (editingMetric) {
        await updateQualityMetric(editingMetric.id, metricFormData);
        toast({
          title: "Quality metric updated",
          description: "Quality metric has been updated successfully.",
        });
      } else {
        await addQualityMetric(metricFormData);
        toast({
          title: "Quality metric added",
          description: "New quality metric has been added successfully.",
        });
      }
      setOpenMetricDialog(false);
      resetMetricForm();
    } catch (error: any) {
      toast({
        title: "Error",
        description: error.message || "Failed to save quality metric",
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  const handleCertSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      if (editingCert) {
        await updateCertification(editingCert.id, certFormData);
        toast({
          title: "Certification updated",
          description: "Certification has been updated successfully.",
        });
      } else {
        await addCertification(certFormData);
        toast({
          title: "Certification added",
          description: "New certification has been added successfully.",
        });
      }
      setOpenCertDialog(false);
      resetCertForm();
    } catch (error: any) {
      toast({
        title: "Error",
        description: error.message || "Failed to save certification",
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  const handleEditMetric = (metric: QualityMetric) => {
    setEditingMetric(metric);
    setMetricFormData({
      batchId: metric.batchId || '',
      productName: metric.productName || '',
      category: metric.category,
      score: metric.score,
      status: metric.status,
      notes: metric.notes || ''
    });
    setOpenMetricDialog(true);
  };

  const handleEditCert = (cert: Certification) => {
    setEditingCert(cert);
    setCertFormData({
      name: cert.name,
      active: cert.active,
      issuedDate: cert.issuedDate || '',
      expiryDate: cert.expiryDate || '',
      issuingBody: cert.issuingBody || '',
      certificateNumber: cert.certificateNumber || ''
    });
    setOpenCertDialog(true);
  };

  const handleDeleteMetric = async (id: string) => {
    if (window.confirm('Are you sure you want to delete this quality metric?')) {
      try {
        await deleteQualityMetric(id);
        toast({
          title: "Quality metric deleted",
          description: "Quality metric has been deleted successfully.",
        });
      } catch (error: any) {
        toast({
          title: "Error",
          description: error.message || "Failed to delete quality metric",
          variant: "destructive",
        });
      }
    }
  };

  const handleDeleteCert = async (id: string) => {
    if (window.confirm('Are you sure you want to delete this certification?')) {
      try {
        await deleteCertification(id);
        toast({
          title: "Certification deleted",
          description: "Certification has been deleted successfully.",
        });
      } catch (error: any) {
        toast({
          title: "Error",
          description: error.message || "Failed to delete certification",
          variant: "destructive",
        });
      }
    }
  };

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center justify-between">
          <span className="flex items-center gap-2">
            <Award className="w-5 h-5" />
            Quality Metrics & Certifications Management
          </span>
        </CardTitle>
        <CardDescription>
          Manage quality metrics and certifications with real-time Firebase sync
        </CardDescription>
      </CardHeader>
      <CardContent>
        <Tabs defaultValue="metrics" className="space-y-6">
          <TabsList className="grid w-full grid-cols-2">
            <TabsTrigger value="metrics">
              Quality Metrics ({qualityMetrics.length})
            </TabsTrigger>
            <TabsTrigger value="certifications">
              Certifications ({certifications.length})
            </TabsTrigger>
          </TabsList>

          <TabsContent value="metrics" className="space-y-4">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-4">
                <Label htmlFor="batchFilter">Filter by Batch:</Label>
                <Select value={batchFilter} onValueChange={setBatchFilter}>
                  <SelectTrigger className="w-[250px]">
                    <SelectValue placeholder="Select batch" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="all">All Batches</SelectItem>
                    {batches.filter(b => b.id).map((batch) => (
                      <SelectItem key={batch.id} value={batch.id}>
                        {batch.productName || batch.batchNumber} ({batch.batchNumber})
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <Dialog open={openMetricDialog} onOpenChange={(open) => {
                setOpenMetricDialog(open);
                if (!open) resetMetricForm();
              }}>
                <DialogTrigger asChild>
                  <Button>
                    <Plus className="w-4 h-4 mr-2" />
                    Add Quality Metric
                  </Button>
                </DialogTrigger>
                <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
                  <DialogHeader>
                    <DialogTitle>{editingMetric ? 'Edit Quality Metric' : 'Add Quality Metric'}</DialogTitle>
                    <DialogDescription>
                      Add or update a quality metric. Optionally link it to a specific batch/product from the database.
                    </DialogDescription>
                  </DialogHeader>
                  <form onSubmit={handleMetricSubmit} className="space-y-4">
                    <div className="space-y-2">
                      <Label htmlFor="batchId">Link to Batch (Optional)</Label>
                      <Select
                        value={metricFormData.batchId || "none"}
                        onValueChange={(value) => setMetricFormData({ ...metricFormData, batchId: value === "none" ? '' : value })}
                      >
                        <SelectTrigger id="batchId">
                          <SelectValue placeholder="Select a batch from database (optional)" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="none">None (Global Metric)</SelectItem>
                          {batches.filter(b => b.id).map((batch) => (
                            <SelectItem key={batch.id} value={batch.id}>
                              {batch.batchNumber} - {batch.productName || 'Unnamed Product'}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                      {batches.length === 0 && (
                        <p className="text-xs text-muted-foreground">
                          No batches available. Create batches first to link metrics to them.
                        </p>
                      )}
                    </div>

                    {metricFormData.batchId && (
                      <div className="space-y-2 p-3 bg-muted rounded-lg">
                        <Label>Selected Batch:</Label>
                        <div className="flex items-center gap-2">
                          <Package className="w-4 h-4 text-muted-foreground" />
                          <span className="font-medium">
                            {batches.find(b => b.id === metricFormData.batchId)?.productName || 'Unknown'}
                          </span>
                          <Badge variant="outline">
                            {batches.find(b => b.id === metricFormData.batchId)?.batchNumber}
                          </Badge>
                        </div>
                      </div>
                    )}

                    <div className="space-y-2">
                      <Label htmlFor="category">Category *</Label>
                      <Input
                        id="category"
                        required
                        placeholder="e.g., Organic Certification, Purity Analysis, Heavy Metals"
                        value={metricFormData.category}
                        onChange={(e) => setMetricFormData({ ...metricFormData, category: e.target.value })}
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="score">Score (0-100) *</Label>
                      <Input
                        id="score"
                        type="number"
                        required
                        min="0"
                        max="100"
                        value={metricFormData.score}
                        onChange={(e) => setMetricFormData({ ...metricFormData, score: parseInt(e.target.value) || 0 })}
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="status">Status *</Label>
                      <Select
                        value={metricFormData.status}
                        onValueChange={(value) => setMetricFormData({ ...metricFormData, status: value })}
                      >
                        <SelectTrigger>
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="Certified">Certified</SelectItem>
                          <SelectItem value="Passed">Passed</SelectItem>
                          <SelectItem value="Clear">Clear</SelectItem>
                          <SelectItem value="Monitoring">Monitoring</SelectItem>
                          <SelectItem value="Failed">Failed</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="notes">Notes (Optional)</Label>
                      <Textarea
                        id="notes"
                        placeholder="Additional notes about this quality metric..."
                        value={metricFormData.notes}
                        onChange={(e) => setMetricFormData({ ...metricFormData, notes: e.target.value })}
                        rows={3}
                      />
                    </div>
                    <DialogFooter>
                      <Button type="button" variant="outline" onClick={() => setOpenMetricDialog(false)}>
                        Cancel
                      </Button>
                      <Button type="submit" disabled={loading}>
                        {loading ? 'Saving...' : editingMetric ? 'Update' : 'Add'}
                      </Button>
                    </DialogFooter>
                  </form>
                </DialogContent>
              </Dialog>
            </div>

            <div className="space-y-2">
              {metricsLoading || batchesLoading ? (
                <div className="text-center py-8 text-muted-foreground">Loading metrics...</div>
              ) : filteredMetrics.length === 0 ? (
                <div className="text-center py-8 text-muted-foreground">
                  {batchFilter === 'all' 
                    ? 'No quality metrics yet. Add one to get started.'
                    : 'No quality metrics for this batch.'}
                </div>
              ) : (
                filteredMetrics.map((metric) => {
                  const linkedBatch = metric.batchId ? batches.find(b => b.id === metric.batchId) : null;
                  return (
                    <div key={metric.id} className="flex items-center justify-between p-4 border rounded-lg hover:bg-muted/50 transition-colors">
                      <div className="flex-1">
                        <div className="flex items-center gap-2">
                          <div className="font-medium">{metric.category}</div>
                          {linkedBatch && (
                            <Badge variant="outline" className="text-xs">
                              <Package className="w-3 h-3 mr-1" />
                              {linkedBatch.batchNumber}
                            </Badge>
                          )}
                        </div>
                        <div className="text-sm text-muted-foreground mt-1">
                          Score: {metric.score}% • Status: {metric.status}
                          {linkedBatch && (
                            <span className="ml-2">• Product: {linkedBatch.productName}</span>
                          )}
                        </div>
                        {metric.notes && (
                          <div className="text-xs text-muted-foreground mt-1 italic">
                            {metric.notes}
                          </div>
                        )}
                      </div>
                      <div className="flex items-center gap-2">
                        <Button variant="ghost" size="icon" onClick={() => handleEditMetric(metric)}>
                          <Edit className="w-4 h-4" />
                        </Button>
                        <Button variant="ghost" size="icon" onClick={() => handleDeleteMetric(metric.id)}>
                          <Trash2 className="w-4 h-4 text-red-600" />
                        </Button>
                      </div>
                    </div>
                  );
                })
              )}
            </div>
          </TabsContent>

          <TabsContent value="certifications" className="space-y-4">
            <div className="flex justify-end">
              <Dialog open={openCertDialog} onOpenChange={(open) => {
                setOpenCertDialog(open);
                if (!open) resetCertForm();
              }}>
                <DialogTrigger asChild>
                  <Button>
                    <Plus className="w-4 h-4 mr-2" />
                    Add Certification
                  </Button>
                </DialogTrigger>
                <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
                  <DialogHeader>
                    <DialogTitle>{editingCert ? 'Edit Certification' : 'Add Certification'}</DialogTitle>
                    <DialogDescription>
                      Add or update a certification
                    </DialogDescription>
                  </DialogHeader>
                  <form onSubmit={handleCertSubmit} className="space-y-4">
                    <div className="space-y-2">
                      <Label htmlFor="certName">Certification Name *</Label>
                      <Input
                        id="certName"
                        required
                        placeholder="e.g., USDA Organic, Fair Trade, ISO 22000"
                        value={certFormData.name}
                        onChange={(e) => setCertFormData({ ...certFormData, name: e.target.value })}
                      />
                    </div>
                    <div className="flex items-center space-x-2">
                      <Switch
                        id="active"
                        checked={certFormData.active}
                        onCheckedChange={(checked) => setCertFormData({ ...certFormData, active: checked })}
                      />
                      <Label htmlFor="active">Active</Label>
                    </div>
                    <div className="grid grid-cols-2 gap-4">
                      <div className="space-y-2">
                        <Label htmlFor="issuedDate">Issued Date</Label>
                        <Input
                          id="issuedDate"
                          type="date"
                          value={certFormData.issuedDate}
                          onChange={(e) => setCertFormData({ ...certFormData, issuedDate: e.target.value })}
                        />
                      </div>
                      <div className="space-y-2">
                        <Label htmlFor="expiryDate">Expiry Date</Label>
                        <Input
                          id="expiryDate"
                          type="date"
                          value={certFormData.expiryDate}
                          onChange={(e) => setCertFormData({ ...certFormData, expiryDate: e.target.value })}
                        />
                      </div>
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="issuingBody">Issuing Body</Label>
                      <Input
                        id="issuingBody"
                        placeholder="e.g., USDA, Fair Trade USA"
                        value={certFormData.issuingBody}
                        onChange={(e) => setCertFormData({ ...certFormData, issuingBody: e.target.value })}
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="certificateNumber">Certificate Number</Label>
                      <Input
                        id="certificateNumber"
                        placeholder="Certificate reference number"
                        value={certFormData.certificateNumber}
                        onChange={(e) => setCertFormData({ ...certFormData, certificateNumber: e.target.value })}
                      />
                    </div>
                    <DialogFooter>
                      <Button type="button" variant="outline" onClick={() => setOpenCertDialog(false)}>
                        Cancel
                      </Button>
                      <Button type="submit" disabled={loading}>
                        {loading ? 'Saving...' : editingCert ? 'Update' : 'Add'}
                      </Button>
                    </DialogFooter>
                  </form>
                </DialogContent>
              </Dialog>
            </div>

            <div className="space-y-2">
              {certsLoading ? (
                <div className="text-center py-8 text-muted-foreground">Loading certifications...</div>
              ) : certifications.length === 0 ? (
                <div className="text-center py-8 text-muted-foreground">No certifications yet. Add one to get started.</div>
              ) : (
                certifications.map((cert) => (
                  <div key={cert.id} className="flex items-center justify-between p-4 border rounded-lg">
                    <div className="flex-1">
                      <div className="flex items-center gap-2">
                        <div className={`w-3 h-3 rounded-full ${cert.active ? 'bg-green-500' : 'bg-gray-400'}`} />
                        <div className="font-medium">{cert.name}</div>
                      </div>
                      <div className="text-sm text-muted-foreground mt-1">
                        {cert.issuingBody && `Issued by: ${cert.issuingBody}`}
                        {cert.certificateNumber && ` • Certificate #: ${cert.certificateNumber}`}
                        {cert.expiryDate && ` • Expires: ${new Date(cert.expiryDate).toLocaleDateString()}`}
                      </div>
                    </div>
                    <div className="flex items-center gap-2">
                      <Button variant="ghost" size="icon" onClick={() => handleEditCert(cert)}>
                        <Edit className="w-4 h-4" />
                      </Button>
                      <Button variant="ghost" size="icon" onClick={() => handleDeleteCert(cert.id)}>
                        <Trash2 className="w-4 h-4 text-red-600" />
                      </Button>
                    </div>
                  </div>
                ))
              )}
            </div>
          </TabsContent>
        </Tabs>
      </CardContent>
    </Card>
  );
};
