import { useState, useEffect } from 'react';
import { ref, onValue, serverTimestamp, set } from 'firebase/database';
import { database } from '@/lib/firebase';

/**
 * Hook to monitor Firebase connection state
 */
export function useConnectionState() {
  const [isConnected, setIsConnected] = useState(true);
  const [isOnline, setIsOnline] = useState(navigator.onLine);

  useEffect(() => {
    // Monitor browser online/offline state
    const handleOnline = () => setIsOnline(true);
    const handleOffline = () => setIsOnline(false);

    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);

    // Monitor Firebase connection state
    const connectedRef = ref(database, '.info/connected');
    const unsubscribe = onValue(connectedRef, (snapshot) => {
      setIsConnected(snapshot.val() === true);
    });

    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
      unsubscribe();
    };
  }, []);

  return { isConnected, isOnline, isFullyConnected: isConnected && isOnline };
}

/**
 * Component to display connection status
 */
export function ConnectionStatus() {
  const { isFullyConnected, isOnline, isConnected } = useConnectionState();

  if (isFullyConnected) return null;

  return (
    <div className="fixed bottom-4 right-4 z-50 animate-in slide-in-from-bottom-5">
      <div className="bg-yellow-500 text-white px-4 py-2 rounded-lg shadow-lg flex items-center gap-2">
        <div className="animate-pulse">
          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
            />
          </svg>
        </div>
        <div>
          <p className="font-semibold text-sm">
            {!isOnline ? 'No Internet Connection' : 'Connecting to database...'}
          </p>
          <p className="text-xs opacity-90">
            Data will sync when connection is restored
          </p>
        </div>
      </div>
    </div>
  );
}
