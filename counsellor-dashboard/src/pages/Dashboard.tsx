import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { 
  Calendar, 
  MessageSquare, 
  BookOpen, 
  Users, 
  TrendingUp, 
  Clock,
  AlertCircle,
  CheckCircle 
} from "lucide-react";

const Dashboard = () => {
  const overviewStats = [
    {
      title: "Pending Appointments",
      value: "8",
      description: "Awaiting approval",
      icon: Calendar,
      color: "text-cta",
      bgColor: "bg-warning-soft",
    },
    {
      title: "New Anonymous Questions", 
      value: "12",
      description: "Require response",
      icon: MessageSquare,
      color: "text-accent",
      bgColor: "bg-info-soft",
    },
    {
      title: "Journals for Review",
      value: "5",
      description: "Flagged entries",
      icon: BookOpen,
      color: "text-primary",
      bgColor: "bg-success-soft",
    },
    {
      title: "Active Students",
      value: "124",
      description: "This month",
      icon: Users,
      color: "text-accent",
      bgColor: "bg-info-soft",
    },
  ];

  const recentActivity = [
    {
      type: "appointment",
      message: "New appointment request from Sarah M.",
      time: "5 minutes ago",
      status: "pending",
    },
    {
      type: "question",
      message: "Anonymous question about exam anxiety",
      time: "15 minutes ago", 
      status: "new",
    },
    {
      type: "journal",
      message: "Journal entry flagged for review",
      time: "1 hour ago",
      status: "review",
    },
  ];

  return (
    <div className="space-y-8">
      {/* Welcome Section */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-accent">Welcome back, Dr. Smith</h1>
          <p className="text-customBlue mt-2">
            Professional mental health support dashboard overview
          </p>
        </div>
        <div className="flex gap-3">
          <Button variant="outline" size="sm">
            <Clock className="w-4 h-4 mr-2" />
            Schedule Break
          </Button>
          <Button variant="cta" size="sm">
            <TrendingUp className="w-4 h-4 mr-2" />
            View Analytics
          </Button>
        </div>
      </div>

      {/* Overview Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {overviewStats.map((stat, index) => (
          <Card key={index} className="shadow-card border-0 hover:shadow-floating transition-smooth">
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium text-customBlue">
                {stat.title}
              </CardTitle>
              <div className={`w-10 h-10 rounded-lg ${stat.bgColor} flex items-center justify-center`}>
                <stat.icon className={`w-5 h-5 ${stat.color}`} />
              </div>
            </CardHeader>
            <CardContent>
              <div className="text-3xl font-bold text-foreground">{stat.value}</div>
              <p className="text-xs text-customBlue mt-1">
                {stat.description}
              </p>
            </CardContent>
          </Card>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Recent Activity */}
        <Card className="lg:col-span-2 shadow-card border-0">
          <CardHeader>
            <CardTitle className="text-accent">Recent Activity</CardTitle>
            <CardDescription>
              Latest updates from your student support dashboard
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {recentActivity.map((activity, index) => (
                <div key={index} className="flex items-center gap-4 p-4 rounded-lg bg-muted/30">
                  <div className={`w-8 h-8 rounded-full flex items-center justify-center ${
                    activity.status === 'pending' ? 'bg-warning-soft' :
                    activity.status === 'new' ? 'bg-info-soft' : 'bg-success-soft'
                  }`}>
                    {activity.status === 'pending' ? <AlertCircle className="w-4 h-4 text-cta" /> :
                     activity.status === 'new' ? <MessageSquare className="w-4 h-4 text-accent" /> :
                     <CheckCircle className="w-4 h-4 text-primary" />}
                  </div>
                  <div className="flex-1">
                    <p className="text-sm font-medium text-foreground">{activity.message}</p>
                    <p className="text-xs text-customBlue">{activity.time}</p>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        {/* Quick Actions */}
        <Card className="shadow-card border-0">
          <CardHeader>
            <CardTitle className="text-accent">Quick Actions</CardTitle>
            <CardDescription>
              Common tasks and shortcuts
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-3">
            <Button variant="outline" className="w-full justify-start h-12">
              <Calendar className="w-4 h-4 mr-3" />
              Review Pending Appointments
            </Button>
            <Button variant="outline" className="w-full justify-start h-12">
              <MessageSquare className="w-4 h-4 mr-3" />
              Answer Q&A Questions
            </Button>
            <Button variant="outline" className="w-full justify-start h-12">
              <BookOpen className="w-4 h-4 mr-3" />
              Review Flagged Journals
            </Button>
            <Button variant="cta" className="w-full h-12 mt-4">
              <Users className="w-4 h-4 mr-2" />
              Student Resources Hub
            </Button>
          </CardContent>
        </Card>
      </div>
    </div>
  );
};

export default Dashboard;