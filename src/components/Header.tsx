import { Bell, Search, User, LogOut, ChevronDown } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { 
  DropdownMenu, 
  DropdownMenuContent, 
  DropdownMenuItem, 
  DropdownMenuLabel, 
  DropdownMenuSeparator, 
  DropdownMenuTrigger 
} from "@/components/ui/dropdown-menu";
import { Badge } from "@/components/ui/badge";
import { useAuth } from "@/contexts/AuthContext";
import { Link, useLocation } from "react-router-dom";
import vrikshaLogo from "@/assets/vriksha-chain-logo.png";

export const Header = () => {
  const { user, logout } = useAuth();
  const location = useLocation();

  const getRoleBadgeColor = (role: string) => {
    switch (role) {
      case 'admin': return 'bg-red-100 text-red-800';
      case 'supplier': return 'bg-green-100 text-green-800';
      case 'manufacturer': return 'bg-blue-100 text-blue-800';
      case 'distributor': return 'bg-yellow-100 text-yellow-800';
      case 'retailer': return 'bg-purple-100 text-purple-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const isActive = (path: string) => {
    return location.pathname === path;
  };

  return (
    <header className="border-b bg-card/50 backdrop-blur-sm sticky top-0 z-50">
      <div className="container mx-auto px-4 py-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-8">
            <div className="flex items-center space-x-3">
              <img 
                src={vrikshaLogo} 
                alt="VrikshaChain Logo" 
                className="w-10 h-10 object-contain"
              />
              <span className="font-semibold text-lg text-nature-primary">VrikshaChain</span>
            </div>
            
            <nav className="hidden md:flex space-x-6">
              <Link 
                to="/" 
                className={`text-sm font-medium transition-colors ${
                  isActive('/') 
                    ? 'text-nature-primary' 
                    : 'hover:text-nature-primary'
                }`}
              >
                Home
              </Link>
              {user && (
                <Link 
                  to="/dashboard" 
                  className={`text-sm font-medium transition-colors ${
                    isActive('/dashboard') 
                      ? 'text-nature-primary' 
                      : 'hover:text-nature-primary'
                  }`}
                >
                  Dashboard
                </Link>
              )}
              <Link 
                to="/supply-chain" 
                className={`text-sm font-medium transition-colors ${
                  isActive('/supply-chain') 
                    ? 'text-nature-primary' 
                    : 'hover:text-nature-primary'
                }`}
              >
                Batches
              </Link>
              <Link 
                to="/analytics" 
                className={`text-sm font-medium transition-colors ${
                  isActive('/analytics') 
                    ? 'text-nature-primary' 
                    : 'hover:text-nature-primary'
                }`}
              >
                Analytics
              </Link>
            </nav>
          </div>

          <div className="flex items-center space-x-4">
            <div className="relative hidden md:block">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground w-4 h-4" />
              <Input 
                placeholder="Search batches..." 
                className="pl-10 w-64"
              />
            </div>
            
            <Button variant="ghost" size="icon">
              <Bell className="w-5 h-5" />
            </Button>
            
            {user ? (
              <DropdownMenu>
                <DropdownMenuTrigger asChild>
                  <Button variant="ghost" className="flex items-center space-x-2">
                    <div className="w-8 h-8 bg-nature-primary/10 rounded-full flex items-center justify-center">
                      <User className="w-4 h-4 text-nature-primary" />
                    </div>
                    <div className="hidden md:block text-left">
                      <div className="text-sm font-medium">{user?.name}</div>
                      <div className="text-xs text-muted-foreground">{user?.email}</div>
                    </div>
                    <ChevronDown className="w-4 h-4" />
                  </Button>
                </DropdownMenuTrigger>
                <DropdownMenuContent align="end" className="w-56">
                  <DropdownMenuLabel>
                    <div className="flex flex-col space-y-1">
                      <p className="text-sm font-medium">{user?.name}</p>
                      <p className="text-xs text-muted-foreground">{user?.email}</p>
                      <Badge className={`w-fit text-xs ${getRoleBadgeColor(user?.role || '')}`}>
                        {user?.role?.toUpperCase()}
                      </Badge>
                    </div>
                  </DropdownMenuLabel>
                  <DropdownMenuSeparator />
                  <DropdownMenuItem>
                    <User className="mr-2 h-4 w-4" />
                    <span>Profile</span>
                  </DropdownMenuItem>
                  <DropdownMenuItem>
                    <Bell className="mr-2 h-4 w-4" />
                    <span>Notifications</span>
                  </DropdownMenuItem>
                  <DropdownMenuSeparator />
                  <DropdownMenuItem onClick={logout} className="text-red-600">
                    <LogOut className="mr-2 h-4 w-4" />
                    <span>Log out</span>
                  </DropdownMenuItem>
                </DropdownMenuContent>
              </DropdownMenu>
            ) : (
              <Link to="/login">
                <Button>Login</Button>
              </Link>
            )}
          </div>
        </div>
      </div>
    </header>
  );
};