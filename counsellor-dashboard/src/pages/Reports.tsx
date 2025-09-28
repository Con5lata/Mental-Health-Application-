import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { BarChart3, Download, Calendar, TrendingUp, Users, MessageSquare, BookOpen } from "lucide-react";
import { useState } from "react";

const Reports = () => {
  const [selectedPeriod, setSelectedPeriod] = useState("month");

  const appointmentData = [
    { month: "Nov", appointments: 45 },
    { month: "Dec", appointments: 52 },
    { month: "Jan", appointments: 38 },
  ];

  const moodTrends = [
    { mood: "Positive", count: 156, percentage: 62 },
    { mood: "Neutral", count: 72, percentage: 29 },
    { mood: "Negative", count: 22, percentage: 9 },
  ];

  const categoryBreakdown = [
    { category: "Academic Stress", count: 89, color: "bg-warning-soft text-cta" },
    { category: "Social Issues", count: 45, color: "bg-info-soft text-accent" },
    { category: "Mental Health", count: 67, color: "bg-success-soft text-primary" },
    { category: "Career Guidance", count: 23, color: "bg-muted text-muted-foreground" },
  ];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-accent">Reports & Analytics</h1>
          <p className="text-muted-foreground mt-2">
            Professional insights and analytics for student mental health support
          </p>
        </div>
        <div className="flex gap-3">
          <Select value={selectedPeriod} onValueChange={setSelectedPeriod}>
            <SelectTrigger className="w-40">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="week">This Week</SelectItem>
              <SelectItem value="month">This Month</SelectItem>
              <SelectItem value="quarter">This Quarter</SelectItem>
              <SelectItem value="year">This Year</SelectItem>
            </SelectContent>
          </Select>
          <Button variant="export">
            <Download className="w-4 h-4 mr-2" />
            Download Report
          </Button>
        </div>
      </div>

      {/* Key Metrics */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <Card className="shadow-card border-0">
          <CardContent className="p-6">
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 rounded-lg bg-success-soft flex items-center justify-center">
                <Calendar className="w-6 h-6 text-primary" />
              </div>
              <div>
                <p className="text-2xl font-bold">135</p>
                <p className="text-sm text-muted-foreground">Appointments</p>
              </div>
            </div>
          </CardContent>
        </Card>
        
        <Card className="shadow-card border-0">
          <CardContent className="p-6">
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 rounded-lg bg-info-soft flex items-center justify-center">
                <Users className="w-6 h-6 text-accent" />
              </div>
              <div>
                <p className="text-2xl font-bold">89</p>
                <p className="text-sm text-muted-foreground">Active Students</p>
              </div>
            </div>
          </CardContent>
        </Card>
        
        <Card className="shadow-card border-0">
          <CardContent className="p-6">
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 rounded-lg bg-warning-soft flex items-center justify-center">
                <MessageSquare className="w-6 h-6 text-cta" />
              </div>
              <div>
                <p className="text-2xl font-bold">247</p>
                <p className="text-sm text-muted-foreground">Q&A Responses</p>
              </div>
            </div>
          </CardContent>
        </Card>
        
        <Card className="shadow-card border-0">
          <CardContent className="p-6">
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 rounded-lg bg-success-soft flex items-center justify-center">
                <BookOpen className="w-6 h-6 text-primary" />
              </div>
              <div>
                <p className="text-2xl font-bold">56</p>
                <p className="text-sm text-muted-foreground">Journal Reviews</p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Appointment Trends */}
        <Card className="shadow-card border-0">
          <CardHeader>
            <CardTitle className="text-accent">Appointment Trends</CardTitle>
            <CardDescription>
              Monthly appointment statistics
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {appointmentData.map((data, index) => (
                <div key={index} className="flex items-center justify-between p-4 rounded-lg bg-muted/30">
                  <div className="flex items-center gap-3">
                    <div className="w-8 h-8 rounded-lg bg-primary/10 flex items-center justify-center">
                      <BarChart3 className="w-4 h-4 text-primary" />
                    </div>
                    <span className="font-medium">{data.month}</span>
                  </div>
                  <div className="text-right">
                    <p className="text-2xl font-bold">{data.appointments}</p>
                    <p className="text-xs text-muted-foreground">appointments</p>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        {/* Mood Overview */}
        <Card className="shadow-card border-0">
          <CardHeader>
            <CardTitle className="text-accent">Student Mood Trends</CardTitle>
            <CardDescription>
              Aggregated mood data from student interactions
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {moodTrends.map((mood, index) => (
                <div key={index} className="space-y-2">
                  <div className="flex items-center justify-between">
                    <span className="font-medium">{mood.mood}</span>
                    <span className="text-sm text-muted-foreground">{mood.count} students</span>
                  </div>
                  <div className="w-full bg-muted rounded-full h-2">
                    <div 
                      className={`h-2 rounded-full ${
                        mood.mood === 'Positive' ? 'bg-primary' :
                        mood.mood === 'Neutral' ? 'bg-accent' : 'bg-cta'
                      }`}
                      style={{ width: `${mood.percentage}%` }}
                    />
                  </div>
                  <div className="text-right text-xs text-muted-foreground">
                    {mood.percentage}%
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Support Categories */}
      <Card className="shadow-card border-0">
        <CardHeader>
          <CardTitle className="text-accent">Support Categories</CardTitle>
          <CardDescription>
            Breakdown of student support requests by category
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            {categoryBreakdown.map((category, index) => (
              <div key={index} className="p-6 rounded-lg border border-border">
                <div className="space-y-3">
                  <div className={`inline-flex px-3 py-1 rounded-full text-sm font-medium ${category.color}`}>
                    {category.category}
                  </div>
                  <div>
                    <p className="text-3xl font-bold">{category.count}</p>
                    <p className="text-sm text-muted-foreground">requests</p>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* Export Options */}
      <Card className="shadow-card border-0">
        <CardHeader>
          <CardTitle className="text-accent">Export Reports</CardTitle>
          <CardDescription>
            Download detailed reports for further analysis
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <Button variant="outline" className="h-16 flex-col">
              <Download className="w-5 h-5 mb-2" />
              <span>Appointment Report</span>
            </Button>
            <Button variant="outline" className="h-16 flex-col">
              <Download className="w-5 h-5 mb-2" />
              <span>Student Analytics</span>
            </Button>
            <Button variant="export" className="h-16 flex-col">
              <Download className="w-5 h-5 mb-2" />
              <span>Complete Report</span>
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
};

export default Reports;