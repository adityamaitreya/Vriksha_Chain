import { Toaster } from "@/components/ui/toaster";
import { Toaster as Sonner } from "@/components/ui/sonner";
import { TooltipProvider } from "@/components/ui/tooltip";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import { AuthProvider, useAuth } from "@/contexts/AuthContext";
import ErrorBoundary from "@/components/ErrorBoundary";
import { ConnectionStatus } from "@/hooks/useConnectionState";
import Index from "./pages/Index";
import Dashboard from "./pages/Dashboard";
import SupplyChain from "./pages/SupplyChain";
import Products from "./pages/Products";
import Analytics from "./pages/Analytics";
import NotFound from "./pages/NotFound";
import LoginForm from "./components/LoginForm";
import ProtectedRoute from "./components/ProtectedRoute";
import BatchDetail from "./pages/BatchDetail";
import InitializeData from "./pages/InitializeData";
import PublicBatch from "./pages/PublicBatch";

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 1,
      refetchOnWindowFocus: false,
      staleTime: 5 * 60 * 1000, // 5 minutes
    },
  },
});

const AppRoutes = () => {
  const { user, isLoading } = useAuth();

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-background via-muted/30 to-background flex items-center justify-center">
        <div className="text-center space-y-4">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-nature-primary mx-auto"></div>
          <p className="text-muted-foreground">Loading...</p>
        </div>
      </div>
    );
  }

  return (
    <Routes>
      <Route path="/" element={<Index />} />
      <Route 
        path="/login" 
        element={user ? <Navigate to="/dashboard" replace /> : <LoginForm />} 
      />
      <Route 
        path="/dashboard" 
        element={user ? <Dashboard /> : <Navigate to="/login" replace />} 
      />
      <Route 
        path="/supply-chain" 
        element={user ? <SupplyChain /> : <Navigate to="/login" replace />} 
      />
      <Route 
        path="/products" 
        element={user ? <Products /> : <Navigate to="/login" replace />} 
      />
      <Route 
        path="/analytics" 
        element={user ? <Analytics /> : <Navigate to="/login" replace />} 
      />
      <Route 
        path="/batch/:id" 
        element={user ? <BatchDetail /> : <Navigate to="/login" replace />} 
      />
      <Route 
        path="/initialize-data" 
        element={<InitializeData />} 
      />
      {/* Public batch view - intentionally unauthenticated so QR scans work */}
      <Route
        path="/public/batch/:id"
        element={<PublicBatch />}
      />
      {/* ADD ALL CUSTOM ROUTES ABOVE THE CATCH-ALL "*" ROUTE */}
      <Route path="*" element={<NotFound />} />
    </Routes>
  );
};

const App = () => (
  <ErrorBoundary>
    <QueryClientProvider client={queryClient}>
      <TooltipProvider>
        <Toaster />
        <Sonner />
        <ConnectionStatus />
        <BrowserRouter>
          <AuthProvider>
            <AppRoutes />
          </AuthProvider>
        </BrowserRouter>
      </TooltipProvider>
    </QueryClientProvider>
  </ErrorBoundary>
);

export default App;
