import { useState } from 'react';
import { QRCodeSVG } from 'qrcode.react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Download, RefreshCw, CheckCircle, Copy } from "lucide-react";
import { addBatch } from '@/hooks/useFirebaseData';

interface BatchRegistrationQRProps {
  baseUrl: string;
}

export const BatchRegistrationQR = ({ baseUrl }: BatchRegistrationQRProps) => {
  const [batchName, setBatchName] = useState('');
  const [generatedBatchId, setGeneratedBatchId] = useState('');

  const generateNewBatch = () => {
    if (!batchName.trim()) return;
    // Generate a unique batch ID using timestamp and batch name
    const timestamp = new Date().getTime();
    const cleanBatchName = batchName.replace(/[^a-zA-Z0-9]/g, '').toUpperCase();
    const newBatchId = `${cleanBatchName}-${timestamp}`;
    setGeneratedBatchId(newBatchId);
  };

  const [saving, setSaving] = useState(false);
  const [savedKey, setSavedKey] = useState<string | null>(null);
  const [saveError, setSaveError] = useState<string | null>(null);

  const saveBatchToDatabase = async () => {
    if (!generatedBatchId) return;
    setSaving(true);
    setSaveError(null);
    try {
      const batchPayload = {
        batchNumber: generatedBatchId,
        productName: batchName || generatedBatchId,
        quantity: '0kg',
        origin: '',
        harvestDate: new Date().toISOString(),
        status: 'Created',
        quality: 'Unknown',
        currentLocation: '',
        lastUpdated: new Date().toISOString(),
      };

      const key = await addBatch(batchPayload as any);
      setSavedKey(key || null);
    } catch (err: any) {
      setSaveError(err?.message || 'Failed to save batch');
    } finally {
      setSaving(false);
    }
  };

  const downloadQRCode = () => {
    const svg = document.getElementById('registration-qr-code');
    if (svg) {
      const svgData = new XMLSerializer().serializeToString(svg);
      const canvas = document.createElement('canvas');
      const ctx = canvas.getContext('2d');
      const img = new Image();
      
      img.onload = () => {
        canvas.width = img.width;
        canvas.height = img.height;
        ctx?.drawImage(img, 0, 0);
        const pngFile = canvas.toDataURL('image/png');
        
        const downloadLink = document.createElement('a');
        downloadLink.download = `batch-registration-${generatedBatchId}.png`;
        downloadLink.href = pngFile;
        downloadLink.click();
      };
      
      img.src = 'data:image/svg+xml;base64,' + btoa(svgData);
    }
  };

  // Use public route so registration QR is scannable without auth
  const registrationUrl = `${baseUrl}/public/batch/${generatedBatchId}`;

  return (
    <Card className="w-full">
      <CardHeader>
        <CardTitle>Generate New Batch QR Code</CardTitle>
        <CardDescription>Create a QR code for new batch registration</CardDescription>
      </CardHeader>
      <CardContent className="space-y-6">
        <div className="flex gap-4">
          <Input
            placeholder="Enter batch name"
            value={batchName}
            onChange={(e) => setBatchName(e.target.value)}
            className="flex-1"
          />
          <Button
            onClick={generateNewBatch}
            variant="outline"
            className="flex items-center gap-2"
          >
            <RefreshCw className="w-4 h-4" />
            Generate
          </Button>
        </div>

        {generatedBatchId && (
          <div className="space-y-4">
            <div className="p-4 bg-muted rounded-lg">
              <p className="text-sm font-medium">Generated Batch ID:</p>
              <p className="text-sm font-mono">{generatedBatchId}</p>
            </div>
            
            <div className="flex flex-col items-center space-y-4">
              <div className="bg-white p-4 rounded-lg">
                <QRCodeSVG
                  id={`registration-qr-code-${generatedBatchId}`}
                  value={registrationUrl}
                  size={200}
                  level="H"
                  includeMargin={true}
                />
              </div>
                <div className="w-full space-y-2">
                  <Button
                    onClick={downloadQRCode}
                    variant="outline"
                    className="w-full flex items-center justify-center gap-2"
                  >
                    <Download className="w-4 h-4" />
                    Download QR Code
                  </Button>

                  <Button
                    onClick={saveBatchToDatabase}
                    variant="default"
                    className="w-full flex items-center justify-center gap-2"
                    disabled={saving || !!savedKey}
                  >
                    {saving ? 'Saving...' : savedKey ? (
                      <><CheckCircle className="w-4 h-4 text-green-600"/> Saved</>
                    ) : 'Save Batch to Database'}
                  </Button>

                  {savedKey && (
                    <div className="flex items-center justify-between bg-muted p-2 rounded">
                      <div className="text-sm font-mono truncate">{registrationUrl}</div>
                      <Button
                        variant="ghost"
                        size="icon"
                        onClick={() => navigator.clipboard?.writeText(registrationUrl)}
                        title="Copy registration URL"
                      >
                        <Copy className="w-4 h-4" />
                      </Button>
                    </div>
                  )}

                  {saveError && (
                    <div className="text-sm text-red-600">{saveError}</div>
                  )}
                </div>
            </div>
          </div>
        )}
      </CardContent>
    </Card>
  );
};