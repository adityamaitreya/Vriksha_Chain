import { QRCodeSVG } from 'qrcode.react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Download } from "lucide-react";

interface BatchQRCodeProps {
  batchId: string;
  baseUrl: string;
}

export const BatchQRCode = ({ batchId, baseUrl }: BatchQRCodeProps) => {
  // Use a public, unauthenticated route so scanning the QR from a mobile device
  // can directly open batch details and fetch data from the Realtime Database.
  const batchUrl = `${baseUrl}/public/batch/${batchId}`;

  const downloadQRCode = () => {
    const svg = document.getElementById('batch-qr-code');
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
        downloadLink.download = `batch-${batchId}-qr.png`;
        downloadLink.href = pngFile;
        downloadLink.click();
      };
      
      img.src = 'data:image/svg+xml;base64,' + btoa(svgData);
    }
  };

  return (
    <Card>
      <CardHeader>
        <CardTitle>Batch QR Code</CardTitle>
        <CardDescription>Scan to track this batch</CardDescription>
      </CardHeader>
      <CardContent className="flex flex-col items-center space-y-4">
        <div className="bg-white p-4 rounded-lg">
          <QRCodeSVG
            id={`batch-qr-code-${batchId}`}
            value={batchUrl}
            size={200}
            level="H"
            includeMargin={true}
          />
        </div>
        <Button
          onClick={downloadQRCode}
          variant="outline"
          className="w-full flex items-center justify-center gap-2"
        >
          <Download className="w-4 h-4" />
          Download QR Code
        </Button>
      </CardContent>
    </Card>
  );
};