import { useState } from "react";
import { Navigate } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Users, Mail, Lock } from "lucide-react";

const Login = () => {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [isLoggedIn, setIsLoggedIn] = useState(false);

  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault();
    // Simple mock login - in real app, this would be proper authentication
    if (email && password) {
      setIsLoggedIn(true);
    }
  };

  if (isLoggedIn) {
    return <Navigate to="/" replace />;
  }

  return (
    <div className="min-h-screen bg-calm-gradient flex items-center justify-center p-4">
      <Card className="w-full max-w-md shadow-card border-0">
        <CardHeader className="space-y-4 text-center">
      <div className="mx-auto w-16 h-16 rounded-full bg-accent flex items-center justify-center">
        <Users className="w-8 h-8 text-accent-foreground" />
      </div>
      <CardTitle className="text-3xl font-bold text-accent">
        Counsellor Login
      </CardTitle>
      <CardDescription className="text-muted-foreground">
        Access your professional counsellor dashboard
      </CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleLogin} className="space-y-6">
            <div className="space-y-2">
              <Label htmlFor="email" className="text-sm font-medium">Email</Label>
              <div className="relative">
                <Mail className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                <Input
                  id="email"
                  type="email"
                  placeholder="Enter your email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="pl-10 h-12 rounded-lg border-2 focus:border-primary"
                  required
                />
              </div>
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="password" className="text-sm font-medium">Password</Label>
              <div className="relative">
                <Lock className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                <Input
                  id="password"
                  type="password"
                  placeholder="Enter your password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="pl-10 h-12 rounded-lg border-2 focus:border-primary"
                  required
                />
              </div>
            </div>

            <Button
              type="submit"
              className="w-full h-12 text-base font-medium"
              variant="default"
            >
              Sign In
            </Button>

            <div className="text-center">
              <button
                type="button"
                className="text-sm text-muted-foreground hover:text-primary transition-smooth"
              >
                Forgot your password?
              </button>
            </div>
          </form>
        </CardContent>
      </Card>
    </div>
  );
};

export default Login;