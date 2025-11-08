import { useEffect, useState } from 'react';
import { useParams, Link } from 'react-router-dom';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { ArrowLeft } from 'lucide-react';
import { database } from '@/lib/firebase';
import { ref, onValue, off } from 'firebase/database';

type PublicBatchData = {
  batchNumber?: string;
  productName?: string;
  quantity?: string;
  origin?: string;
  harvestDate?: string;
  status?: string;
  quality?: string;
  currentLocation?: string;
  lastUpdated?: string;
};

const PublicBatch = () => {
  const { id = '' } = useParams();
  const [batch, setBatch] = useState<PublicBatchData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!id) return;
    const batchRef = ref(database, `batches/${id}`);
    const unsubscribe = onValue(batchRef, (snapshot) => {
      setBatch(snapshot.val());
      setLoading(false);
    }, (err) => {
      setError(err.message || 'Failed to load batch');
      setLoading(false);
    });

    return () => off(batchRef);
  }, [id]);

  return (
    <div className="min-h-screen bg-gradient-to-br from-background via-muted/30 to-background">
      <main className="container mx-auto px-4 py-8">
        <div className="flex items-center justify-between mb-6">
          <h1 className="text-2xl font-bold">Batch Public View</h1>
          <Link to="/">
            <Button variant="ghost">
              <ArrowLeft className="w-4 h-4 mr-2" /> Home
            </Button>
          </Link>
        </div>

        <Card>
          <CardHeader>
            <CardTitle>Batch {id}</CardTitle>
            <CardDescription>Public tracking information (real-time)</CardDescription>
          </CardHeader>
          <CardContent>
            {loading && <p>Loading...</p>}
            {error && <p className="text-red-600">{error}</p>}
            {!loading && !error && !batch && (
              <p className="text-muted-foreground">Batch not found.</p>
            )}

            {!loading && batch && (
              <div className="space-y-3">
                <div>
                  <div className="text-sm text-muted-foreground">Product</div>
                  <div className="font-medium">{batch.productName || '—'}</div>
                </div>

                <div>
                  <div className="text-sm text-muted-foreground">Batch Number</div>
                  <div className="font-medium">{batch.batchNumber || id}</div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <div className="text-sm text-muted-foreground">Quantity</div>
                    <div className="font-medium">{batch.quantity || '—'}</div>
                  </div>
                  <div>
                    <div className="text-sm text-muted-foreground">Origin</div>
                    <div className="font-medium">{batch.origin || '—'}</div>
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <div className="text-sm text-muted-foreground">Status</div>
                    <div className="font-medium">{batch.status || '—'}</div>
                  </div>
                  <div>
                    <div className="text-sm text-muted-foreground">Quality</div>
                    <div className="font-medium">{batch.quality || '—'}</div>
                  </div>
                </div>

                <div>
                  <div className="text-sm text-muted-foreground">Current Location</div>
                  <div className="font-medium">{batch.currentLocation || '—'}</div>
                </div>

                <div>
                  <div className="text-sm text-muted-foreground">Last Updated</div>
                  <div className="font-medium">{batch.lastUpdated || '—'}</div>
                </div>
              </div>
            )}
          </CardContent>
        </Card>
      </main>
    </div>
  );
};

export default PublicBatch;
