import React, { useState } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Loader2, Eye, EyeOff } from 'lucide-react';
import vrikshaLogo from '@/assets/vriksha-chain-logo.png';
import heroImage from '@/assets/herbal-supply-chain-hero.jpg';

const LoginForm: React.FC = () => {
  const { login, loginWithGoogle, isLoading } = useAuth();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    
    const success = await login(email, password);
    if (!success) {
      setError('Invalid email or password. Please try again.');
    }
  };

  const handleGoogle = async () => {
    setError('');
    const success = await loginWithGoogle();
    if (!success) {
      setError('Google sign-in failed. Please try again.');
    }
  };

  // Removed demo accounts; users should sign in with their own credentials

  return (
    <div 
      className="min-h-screen bg-gradient-to-br from-background via-muted/30 to-background flex items-center justify-center p-4 bg-cover bg-center bg-no-repeat"
      style={{ backgroundImage: `url(${heroImage})` }}
    >
      <div className="w-full max-w-4xl grid lg:grid-cols-2 gap-8">
        {/* Left side - Login Form */}
        <Card className="w-full">
          <CardHeader className="space-y-2">
            <div className="flex items-center space-x-3 mb-4">
              <img 
                src={vrikshaLogo} 
                alt="VrikshaChain Logo" 
                className="w-12 h-12 object-contain"
              />
              <div>
                <CardTitle className="text-2xl text-nature-primary">VrikshaChain</CardTitle>
                <CardDescription>Herbal Supply Chain Platform</CardDescription>
              </div>
            </div>
            <CardTitle>Welcome Back</CardTitle>
            <CardDescription>
              Sign in to access your supply chain dashboard
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="email">Email</Label>
                <Input
                  id="email"
                  type="email"
                  placeholder="Enter your email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  required
                />
              </div>
              
              <div className="space-y-2">
                <Label htmlFor="password">Password</Label>
                <div className="relative">
                  <Input
                    id="password"
                    type={showPassword ? 'text' : 'password'}
                    placeholder="Enter your password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    required
                  />
                  <Button
                    type="button"
                    variant="ghost"
                    size="icon"
                    className="absolute right-0 top-0 h-full px-3 py-2 hover:bg-transparent"
                    onClick={() => setShowPassword(!showPassword)}
                  >
                    {showPassword ? (
                      <EyeOff className="h-4 w-4" />
                    ) : (
                      <Eye className="h-4 w-4" />
                    )}
                  </Button>
                </div>
              </div>

              {error && (
                <Alert variant="destructive">
                  <AlertDescription>{error}</AlertDescription>
                </Alert>
              )}

              <Button type="submit" className="w-full" disabled={isLoading}>
                {isLoading ? (
                  <>
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                    Signing in...
                  </>
                ) : (
                  'Sign In'
                )}
              </Button>

              <div className="relative my-4">
                <div className="absolute inset-0 flex items-center">
                  <span className="w-full border-t" />
                </div>
                <div className="relative flex justify-center text-xs uppercase">
                  <span className="bg-card px-2 text-muted-foreground">Or continue with</span>
                </div>
              </div>

              <Button type="button" variant="outline" className="w-full" onClick={handleGoogle} disabled={isLoading}>
                <svg className="mr-2 h-4 w-4" viewBox="0 0 24 24" aria-hidden="true">
                  <path fill="#EA4335" d="M12 10.2v3.9h5.4c-.2 1.2-1.6 3.5-5.4 3.5-3.2 0-5.9-2.7-5.9-6s2.7-6 5.9-6c1.8 0 3 .8 3.7 1.5l2.5-2.4C16.9 3.7 14.7 2.7 12 2.7 6.9 2.7 2.7 6.9 2.7 12s4.2 9.3 9.3 9.3c5.4 0 9-3.8 9-9.1 0-.6-.1-1-.1-1.4H12z"/>
                  <path fill="#34A853" d="M3.9 7.1l3.2 2.3C8 7.7 9.9 6.6 12 6.6c1.8 0 3 .8 3.7 1.5l2.5-2.4C16.9 3.7 14.7 2.7 12 2.7 8.7 2.7 5.9 4.6 3.9 7.1z" opacity=".1"/>
                  <path fill="#FBBC05" d="M12 21.3c2.7 0 5-1 6.6-2.7l-3-2.5c-.8.5-1.9.8-3.6.8-2.8 0-5.2-1.9-6-4.4l-3.1 2.4C4.9 18.6 8.2 21.3 12 21.3z"/>
                  <path fill="#4285F4" d="M21 12c0-.6-.1-1-.1-1.4H12v3.9h5.4c-.3 1.6-1.3 2.9-2.7 3.7l3 2.5c2.1-1.9 3.3-4.8 3.3-8.7z"/>
                </svg>
                Continue with Google
              </Button>
            </form>

            {/* Demo credentials notice removed */}
          </CardContent>
        </Card>

        {/* Right side - Account Types */}
        <div className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle className="text-lg">Account Types</CardTitle>
              <CardDescription>Use credentials provided for your role</CardDescription>
            </CardHeader>
            <CardContent>
              <ul className="space-y-2 text-sm text-muted-foreground">
                <li className="flex items-center space-x-2">
                  <div className="w-2 h-2 bg-nature-primary rounded-full"></div>
                  <span>Admin</span>
                </li>
                <li className="flex items-center space-x-2">
                  <div className="w-2 h-2 bg-leaf rounded-full"></div>
                  <span>Supplier</span>
                </li>
                <li className="flex items-center space-x-2">
                  <div className="w-2 h-2 bg-earth rounded-full"></div>
                  <span>Manufacturer</span>
                </li>
                <li className="flex items-center space-x-2">
                  <div className="w-2 h-2 bg-yellow-600 rounded-full"></div>
                  <span>Distributor</span>
                </li>
                <li className="flex items-center space-x-2">
                  <div className="w-2 h-2 bg-purple-600 rounded-full"></div>
                  <span>Retailer</span>
                </li>
              </ul>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle className="text-lg">Features</CardTitle>
            </CardHeader>
            <CardContent>
              <ul className="space-y-2 text-sm text-muted-foreground">
                <li className="flex items-center space-x-2">
                  <div className="w-2 h-2 bg-nature-primary rounded-full"></div>
                  <span>Blockchain-verified supply chain tracking</span>
                </li>
                <li className="flex items-center space-x-2">
                  <div className="w-2 h-2 bg-leaf rounded-full"></div>
                  <span>Real-time quality metrics monitoring</span>
                </li>
                <li className="flex items-center space-x-2">
                  <div className="w-2 h-2 bg-earth rounded-full"></div>
                  <span>Smart contract integration</span>
                </li>
                <li className="flex items-center space-x-2">
                  <div className="w-2 h-2 bg-nature-accent rounded-full"></div>
                  <span>Role-based access control</span>
                </li>
              </ul>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
};

export default LoginForm;
