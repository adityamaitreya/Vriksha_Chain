import { useState, useEffect } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Plus, Save, X, Edit } from "lucide-react";
import { useBatches, addBatch, updateBatch, Batch } from '@/hooks/useFirebaseData';
import { useToast } from '@/hooks/use-toast';

interface BatchManagementProps {
  batchId?: string;
  onClose?: () => void;
}

export const BatchManagement = ({ batchId, onClose }: BatchManagementProps) => {
  const { batches } = useBatches();
  const { toast } = useToast();
  const [open, setOpen] = useState(false);
  const [loading, setLoading] = useState(false);

  const existingBatch = batchId ? batches.find(b => b.id === batchId) : null;

  const [formData, setFormData] = useState<Omit<Batch, 'id' | 'lastUpdated'>>({
    batchNumber: '',
    productName: '',
    quantity: '',
    origin: '',
    harvestDate: new Date().toISOString().split('T')[0],
    status: 'Created',
    quality: 'Standard',
    currentLocation: '',
  });

  // Update form data when batch is found or changes
  useEffect(() => {
    if (batchId && existingBatch) {
      setFormData({
        batchNumber: existingBatch.batchNumber || '',
        productName: existingBatch.productName || '',
        quantity: existingBatch.quantity || '',
        origin: existingBatch.origin || '',
        harvestDate: existingBatch.harvestDate || new Date().toISOString().split('T')[0],
        status: existingBatch.status || 'Created',
        quality: existingBatch.quality || 'Standard',
        currentLocation: existingBatch.currentLocation || '',
      });
    } else if (!batchId) {
      // Reset form for new batch
      setFormData({
        batchNumber: '',
        productName: '',
        quantity: '',
        origin: '',
        harvestDate: new Date().toISOString().split('T')[0],
        status: 'Created',
        quality: 'Standard',
        currentLocation: '',
      });
    }
  }, [batchId, existingBatch]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      if (batchId && existingBatch) {
        await updateBatch(batchId, formData);
        toast({
          title: "Batch updated",
          description: "Batch has been updated successfully.",
        });
      } else {
        // Generate batch number if not provided
        if (!formData.batchNumber) {
          const timestamp = new Date().getTime();
          const cleanProductName = formData.productName.replace(/[^a-zA-Z0-9]/g, '').toUpperCase().slice(0, 8) || 'BATCH';
          formData.batchNumber = `${cleanProductName}-${timestamp}`;
        }
        
        await addBatch(formData);
        toast({
          title: "Batch created",
          description: "New batch has been created successfully.",
        });
      }
      
      setOpen(false);
      if (onClose) onClose();
      // Reset form if creating new batch
      if (!batchId) {
        setFormData({
          batchNumber: '',
          productName: '',
          quantity: '',
          origin: '',
          harvestDate: new Date().toISOString().split('T')[0],
          status: 'Created',
          quality: 'Standard',
          currentLocation: '',
        });
      }
    } catch (error: any) {
      toast({
        title: "Error",
        description: error.message || "Failed to save batch",
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        {batchId ? (
          <Button variant="ghost" size="icon">
            <Edit className="w-4 h-4" />
          </Button>
        ) : (
          <Button className="flex items-center gap-2">
            <Plus className="w-4 h-4" />
            Create New Batch
          </Button>
        )}
      </DialogTrigger>
      <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>{batchId ? 'Edit Batch' : 'Create New Batch'}</DialogTitle>
          <DialogDescription>
            {batchId ? 'Update batch information. Changes will sync in real-time.' : 'Fill in the details to create a new batch. It will sync with the database in real-time.'}
          </DialogDescription>
        </DialogHeader>
        
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="batchNumber">Batch Number</Label>
              <Input
                id="batchNumber"
                placeholder="Auto-generated if empty"
                value={formData.batchNumber}
                onChange={(e) => setFormData({ ...formData, batchNumber: e.target.value })}
              />
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="productName">Product Name *</Label>
              <Input
                id="productName"
                required
                placeholder="e.g., Ashwagandha Root Powder"
                value={formData.productName}
                onChange={(e) => setFormData({ ...formData, productName: e.target.value })}
              />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="quantity">Quantity *</Label>
              <Input
                id="quantity"
                required
                placeholder="e.g., 500kg"
                value={formData.quantity}
                onChange={(e) => setFormData({ ...formData, quantity: e.target.value })}
              />
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="harvestDate">Harvest Date *</Label>
              <Input
                id="harvestDate"
                type="date"
                required
                value={formData.harvestDate}
                onChange={(e) => setFormData({ ...formData, harvestDate: e.target.value })}
              />
            </div>
          </div>

          <div className="space-y-2">
            <Label htmlFor="origin">Origin *</Label>
            <Input
              id="origin"
              required
              placeholder="e.g., Rajasthan, India"
              value={formData.origin}
              onChange={(e) => setFormData({ ...formData, origin: e.target.value })}
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="status">Status *</Label>
              <Select
                value={formData.status}
                onValueChange={(value) => setFormData({ ...formData, status: value })}
              >
                <SelectTrigger id="status">
                  <SelectValue placeholder="Select status" />
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
            
            <div className="space-y-2">
              <Label htmlFor="quality">Quality *</Label>
              <Select
                value={formData.quality}
                onValueChange={(value) => setFormData({ ...formData, quality: value })}
              >
                <SelectTrigger id="quality">
                  <SelectValue placeholder="Select quality" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="Premium">Premium</SelectItem>
                  <SelectItem value="Standard">Standard</SelectItem>
                  <SelectItem value="Unknown">Unknown</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>

          <div className="space-y-2">
            <Label htmlFor="currentLocation">Current Location</Label>
            <Input
              id="currentLocation"
              placeholder="e.g., Distribution Center, Mumbai"
              value={formData.currentLocation}
              onChange={(e) => setFormData({ ...formData, currentLocation: e.target.value })}
            />
          </div>

          <DialogFooter>
            <Button type="button" variant="outline" onClick={() => setOpen(false)}>
              <X className="w-4 h-4 mr-2" />
              Cancel
            </Button>
            <Button type="submit" disabled={loading}>
              <Save className="w-4 h-4 mr-2" />
              {loading ? 'Saving...' : batchId ? 'Update Batch' : 'Create Batch'}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
};
