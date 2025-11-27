import { Navigate } from "react-router-dom";
import { useAuth } from "../../pages/AuthContext";

export const ProtectedRoute = ({ children }: { children: React.ReactNode }) => {
  const { isLoggedIn } = useAuth();

  if (isLoggedIn === false) {
    return <Navigate to="/login" replace />;
  }
  if (isLoggedIn === null) {
    // Optionally show a loading spinner
    return <div className="flex h-screen items-center justify-center">Loading...</div>;
  }
  return <>{children}</>;
};
