import { Outlet } from "react-router-dom";
import { SidebarTrigger } from "@/components/ui/sidebar";
import { AppSidebar } from "@/components/layout/AppSidebar";

export function DashboardLayout() {
  return (
    <div className="min-h-screen flex w-full bg-background">
      <AppSidebar />
      <div className="flex-1 flex flex-col">
        {/* Header */}
        <header className="h-16 border-b border-sidebar-border bg-card/50 backdrop-blur-sm">
          <div className="h-full px-6 flex items-center justify-between">
            <div className="flex items-center gap-3">
              <SidebarTrigger className="lg:hidden" />
              <h1 className="text-2xl font-semibold text-accent">Counsellor Portal</h1>
            </div>
            <div className="flex items-center gap-4">
              <div className="text-sm text-customBlue">Welcome back, Dr. Smith</div>
            </div>
          </div>
        </header>
        
        {/* Main Content */}
        <main className="flex-1 p-6 overflow-auto">
          <Outlet />
        </main>
      </div>
    </div>
  );
}