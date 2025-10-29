import { createContext, useContext, useState, useEffect, ReactNode } from "react";
import { useNavigate } from "react-router-dom";

interface AuthContextType {
  isAuthenticated: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider = ({ children }: { children: ReactNode }) => {
  const [isAuthenticated, setIsAuthenticated] = useState<boolean>(false);
  const navigate = useNavigate();

  useEffect(() => {
    // Check for existing session on mount
    const session = localStorage.getItem("counsellor_session");
    setIsAuthenticated(!!session);
  }, []);

  const login = async (email: string, password: string) => {
    // TODO: Replace with Firebase Authentication
    // For now, mock authentication
    localStorage.setItem("counsellor_session", "true");
    setIsAuthenticated(true);
  };

  const logout = () => {
    localStorage.removeItem("counsellor_session");
    setIsAuthenticated(false);
    navigate("/login");
  };

  return (
    <AuthContext.Provider value={{ isAuthenticated, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return context;
};
