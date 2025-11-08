import { useState, useEffect } from 'react';
import { database } from '@/lib/firebase';
import { ref, onValue, off, set, push, update, remove } from 'firebase/database';

export interface Batch {
  id: string;
  batchNumber: string;
  productName: string;
  quantity: string;
  origin: string;
  harvestDate: string;
  status: string;
  quality: string;
  currentLocation: string;
  lastUpdated: string;
}

export interface Stats {
  activeBatches: number;
  supplyPartners: number;
  qualityScore: number;
  traceabilityRate: number;
}

export interface QualityMetric {
  id: string;
  batchId?: string; // Link to specific batch
  productName?: string; // Product name from batch
  category: string;
  score: number;
  status: string;
  notes?: string; // Additional notes
  lastUpdated: string;
}

export interface Certification {
  id: string;
  name: string;
  active: boolean;
  issuedDate?: string;
  expiryDate?: string;
  issuingBody?: string;
  certificateNumber?: string;
  lastUpdated: string;
}

// Hook to read data from Firebase with real-time sync
export function useFirebaseData<T>(path: string) {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const dataRef = ref(database, path);
    
    const unsubscribe = onValue(
      dataRef,
      (snapshot) => {
        try {
          const value = snapshot.val();
          setData(value);
          setLoading(false);
          setError(null);
        } catch (err) {
          setError(err instanceof Error ? err : new Error('Unknown error'));
          setLoading(false);
        }
      },
      (err) => {
        setError(err);
        setLoading(false);
      }
    );

    return () => {
      off(dataRef, 'value', unsubscribe);
    };
  }, [path]);

  return { data, loading, error };
}

// Hook for batches with real-time sync
export function useBatches() {
  const { data, loading, error } = useFirebaseData<Record<string, Batch>>('batches');
  
  const batches = data 
    ? Object.entries(data).map(([id, batch]) => ({ ...batch, id }))
    : [];

  return { batches, loading, error };
}

// Hook for single batch with real-time sync
export function useBatch(id: string | undefined) {
  const [batch, setBatch] = useState<Batch | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    if (!id) {
      setLoading(false);
      return;
    }

    const batchRef = ref(database, `batches/${id}`);
    
    const unsubscribe = onValue(
      batchRef,
      (snapshot) => {
        try {
          const value = snapshot.val();
          if (value) {
            setBatch({ ...value, id });
          } else {
            setBatch(null);
          }
          setLoading(false);
          setError(null);
        } catch (err) {
          setError(err instanceof Error ? err : new Error('Unknown error'));
          setLoading(false);
        }
      },
      (err) => {
        setError(err);
        setLoading(false);
      }
    );

    return () => {
      off(batchRef, 'value', unsubscribe);
    };
  }, [id]);

  return { batch, loading, error };
}

// Hook for stats with real-time sync
export function useStats() {
  const { data, loading, error } = useFirebaseData<Stats>('stats');
  
  return { stats: data, loading, error };
}

// Functions to write batch data with real-time updates
export async function addBatch(batch: Omit<Batch, 'id'>) {
  const batchesRef = ref(database, 'batches');
  const newBatchRef = push(batchesRef);
  const batchWithTimestamp = {
    ...batch,
    lastUpdated: new Date().toISOString()
  };
  await set(newBatchRef, batchWithTimestamp);
  return newBatchRef.key;
}

export async function updateBatch(id: string, updates: Partial<Batch>) {
  const batchRef = ref(database, `batches/${id}`);
  const updatesWithTimestamp = {
    ...updates,
    lastUpdated: new Date().toISOString()
  };
  await update(batchRef, updatesWithTimestamp);
}

export async function deleteBatch(id: string) {
  const batchRef = ref(database, `batches/${id}`);
  await remove(batchRef);
}

export async function updateStats(stats: Stats) {
  const statsRef = ref(database, 'stats');
  await set(statsRef, stats);
}

// Calculate stats from batches (for real-time stats calculation)
export function calculateStatsFromBatches(batches: Batch[]): Stats {
  const activeBatches = batches.filter(b => 
    b.status && !['Delivered', 'Completed', 'Cancelled'].includes(b.status)
  ).length;

  const qualityScores = batches
    .filter(b => b.quality && b.quality !== 'Unknown')
    .map(b => {
      if (b.quality === 'Premium') return 95;
      if (b.quality === 'Standard') return 85;
      return 75;
    });

  const qualityScore = qualityScores.length > 0
    ? qualityScores.reduce((a, b) => a + b, 0) / qualityScores.length
    : 0;

  // Count unique origins as supply partners (simplified)
  const uniqueOrigins = new Set(batches.filter(b => b.origin).map(b => b.origin));
  const supplyPartners = uniqueOrigins.size;

  // Calculate traceability rate (batches with all required fields)
  const traceableBatches = batches.filter(b => 
    b.batchNumber && b.productName && b.origin && b.harvestDate && b.status && b.currentLocation
  ).length;

  const traceabilityRate = batches.length > 0
    ? (traceableBatches / batches.length) * 100
    : 0;

  return {
    activeBatches,
    supplyPartners,
    qualityScore: Math.round(qualityScore * 10) / 10,
    traceabilityRate: Math.round(traceabilityRate * 10) / 10
  };
}

// Hooks for Quality Metrics
export function useQualityMetrics() {
  const { data, loading, error } = useFirebaseData<Record<string, QualityMetric>>('qualityMetrics');
  
  const qualityMetrics = data 
    ? Object.entries(data).map(([id, metric]) => ({ ...metric, id }))
    : [];

  return { qualityMetrics, loading, error };
}

// Hooks for Certifications
export function useCertifications() {
  const { data, loading, error } = useFirebaseData<Record<string, Certification>>('certifications');
  
  const certifications = data 
    ? Object.entries(data).map(([id, cert]) => ({ ...cert, id }))
    : [];

  return { certifications, loading, error };
}

// Functions to write Quality Metrics
export async function addQualityMetric(metric: Omit<QualityMetric, 'id' | 'lastUpdated'>) {
  const metricsRef = ref(database, 'qualityMetrics');
  const newMetricRef = push(metricsRef);
  const metricWithTimestamp = {
    ...metric,
    lastUpdated: new Date().toISOString()
  };
  await set(newMetricRef, metricWithTimestamp);
  return newMetricRef.key;
}

export async function updateQualityMetric(id: string, updates: Partial<QualityMetric>) {
  const metricRef = ref(database, `qualityMetrics/${id}`);
  const updatesWithTimestamp = {
    ...updates,
    lastUpdated: new Date().toISOString()
  };
  await update(metricRef, updatesWithTimestamp);
}

export async function deleteQualityMetric(id: string) {
  const metricRef = ref(database, `qualityMetrics/${id}`);
  await remove(metricRef);
}

// Functions to write Certifications
export async function addCertification(certification: Omit<Certification, 'id' | 'lastUpdated'>) {
  const certificationsRef = ref(database, 'certifications');
  const newCertRef = push(certificationsRef);
  const certWithTimestamp = {
    ...certification,
    lastUpdated: new Date().toISOString()
  };
  await set(newCertRef, certWithTimestamp);
  return newCertRef.key;
}

export async function updateCertification(id: string, updates: Partial<Certification>) {
  const certRef = ref(database, `certifications/${id}`);
  const updatesWithTimestamp = {
    ...updates,
    lastUpdated: new Date().toISOString()
  };
  await update(certRef, updatesWithTimestamp);
}

export async function deleteCertification(id: string) {
  const certRef = ref(database, `certifications/${id}`);
  await remove(certRef);
}
