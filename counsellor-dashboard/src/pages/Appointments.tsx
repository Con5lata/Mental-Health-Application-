import { useState } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Calendar, Clock, User, CheckCircle, X, RotateCcw, Eye } from "lucide-react";

const Appointments = () => {
  const [appointments, setAppointments] = useState([
    {
      id: 1,
      studentName: "Sarah M.",
      date: "2024-01-15",
      time: "10:00 AM",
      reason: "Exam anxiety support",
      status: "pending",
      priority: "high",
    },
    {
      id: 2, 
      studentName: "John D.",
      date: "2024-01-16",
      time: "2:00 PM",
      reason: "General counselling",
      status: "approved",
      priority: "medium",
    },
    {
      id: 3,
      studentName: "Emily R.",
      date: "2024-01-17",
      time: "11:30 AM",
      reason: "Academic stress",
      status: "pending",
      priority: "high",
    },
  ]);

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'pending': return 'bg-warning-soft text-cta';
      case 'approved': return 'bg-success-soft text-primary';
      case 'rejected': return 'bg-destructive/10 text-destructive';
      case 'rescheduled': return 'bg-info-soft text-accent';
      default: return 'bg-muted text-muted-foreground';
    }
  };

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case 'high': return 'bg-destructive/10 text-destructive';
      case 'medium': return 'bg-warning-soft text-cta';
      case 'low': return 'bg-success-soft text-primary';
      default: return 'bg-muted text-muted-foreground';
    }
  };

  const handleAction = (id: number, action: string) => {
    setAppointments(prev => 
      prev.map(apt => 
        apt.id === id ? { ...apt, status: action } : apt
      )
    );
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-accent">Appointment Management</h1>
          <p className="text-muted-foreground mt-2">
            Review and manage student appointment requests
          </p>
        </div>
        <Button variant="cta">
          <Calendar className="w-4 h-4 mr-2" />
          View Calendar
        </Button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <Card className="shadow-card border-0">
          <CardContent className="p-6">
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 rounded-lg bg-warning-soft flex items-center justify-center">
                <Clock className="w-6 h-6 text-cta" />
              </div>
              <div>
                <p className="text-2xl font-bold">8</p>
                <p className="text-sm text-muted-foreground">Pending</p>
              </div>
            </div>
          </CardContent>
        </Card>
        
        <Card className="shadow-card border-0">
          <CardContent className="p-6">
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 rounded-lg bg-success-soft flex items-center justify-center">
                <CheckCircle className="w-6 h-6 text-primary" />
              </div>
              <div>
                <p className="text-2xl font-bold">24</p>
                <p className="text-sm text-muted-foreground">This Week</p>
              </div>
            </div>
          </CardContent>
        </Card>
        
        <Card className="shadow-card border-0">
          <CardContent className="p-6">
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 rounded-lg bg-info-soft flex items-center justify-center">
                <User className="w-6 h-6 text-accent" />
              </div>
              <div>
                <p className="text-2xl font-bold">156</p>
                <p className="text-sm text-muted-foreground">Total Students</p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      <Card className="shadow-card border-0">
        <CardHeader>
          <CardTitle className="text-accent">Appointment Requests</CardTitle>
          <CardDescription>
            Review and manage incoming appointment requests from students
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {appointments.map((appointment) => (
              <div key={appointment.id} className="p-6 rounded-lg border border-border hover:shadow-soft transition-smooth">
                <div className="flex items-center justify-between">
                  <div className="space-y-3">
                    <div className="flex items-center gap-3">
                      <h3 className="font-semibold text-foreground">{appointment.studentName}</h3>
                      <Badge className={getPriorityColor(appointment.priority)}>
                        {appointment.priority} priority
                      </Badge>
                      <Badge className={getStatusColor(appointment.status)}>
                        {appointment.status}
                      </Badge>
                    </div>
                    
                    <div className="flex items-center gap-6 text-sm text-muted-foreground">
                      <div className="flex items-center gap-2">
                        <Calendar className="w-4 h-4" />
                        {appointment.date}
                      </div>
                      <div className="flex items-center gap-2">
                        <Clock className="w-4 h-4" />
                        {appointment.time}
                      </div>
                    </div>
                    
                    <p className="text-sm text-foreground">{appointment.reason}</p>
                  </div>

                  {appointment.status === 'pending' && (
                    <div className="flex items-center gap-2">
                      <Button
                        size="sm"
                        variant="outline"
                        onClick={() => handleAction(appointment.id, 'approved')}
                      >
                        <CheckCircle className="w-4 h-4 mr-1" />
                        Approve
                      </Button>
                      <Button
                        size="sm"
                        variant="outline"
                        onClick={() => handleAction(appointment.id, 'rescheduled')}
                      >
                        <RotateCcw className="w-4 h-4 mr-1" />
                        Reschedule
                      </Button>
                      <Button
                        size="sm"
                        variant="destructive"
                        onClick={() => handleAction(appointment.id, 'rejected')}
                      >
                        <X className="w-4 h-4 mr-1" />
                        Reject
                      </Button>
                    </div>
                  )}
                  
                  {appointment.status !== 'pending' && (
                    <Button size="sm" variant="ghost">
                      <Eye className="w-4 h-4 mr-1" />
                      View Details
                    </Button>
                  )}
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    </div>
  );
};

export default Appointments;