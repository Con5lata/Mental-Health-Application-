import React, { useState } from "react";
import { 
  Calendar, 
  Clock, 
  User, 
  CheckCircle, 
  X, 
  RotateCcw, 
  Eye, 
  MoreHorizontal,
  Filter
} from 'lucide-react';

const Appointments = () => {
  // Mock Data
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
    // Add more mock appointments as needed
  ]);

  const [showCalendar, setShowCalendar] = useState(false);

  // Helper: Status Styles (Matches Dashboard Colors)
  const getStatusStyles = (status) => {
    switch (status) {
      case 'pending': return 'bg-orange-50 text-orange-700 border-orange-100';
      case 'approved': return 'bg-emerald-50 text-emerald-700 border-emerald-100';
      case 'rejected': return 'bg-red-50 text-red-700 border-red-100';
      case 'rescheduled': return 'bg-blue-50 text-blue-700 border-blue-100';
      default: return 'bg-gray-100 text-gray-600 border-gray-200';
    }
  };

  // Helper: Priority Styles
  const getPriorityStyles = (priority) => {
    switch (priority) {
      case 'high': return 'text-red-600 bg-red-50';
      case 'medium': return 'text-orange-600 bg-orange-50';
      case 'low': return 'text-emerald-600 bg-emerald-50';
      default: return 'text-gray-600 bg-gray-50';
    }
  };

  // Logic: Handle Status Change
  const handleAction = (id, action) => {
    setAppointments(prev => 
      prev.map(apt => 
        apt.id === id ? { ...apt, status: action } : apt
      )
    );
  };

  return (
    <div className="space-y-8 animate-fade-in">
      
      {/* 1. Page Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold text-gray-800">Appointment Management</h1>
          <p className="text-gray-500 mt-1">
            Review and manage student session requests.
          </p>
        </div>
        <div className="flex gap-3">
          <button className="px-4 py-2 bg-white border border-gray-200 text-gray-700 rounded-lg hover:bg-gray-50 font-medium transition-colors text-sm shadow-sm flex items-center gap-2">
            <Filter size={16} />
            Filter
          </button>
          <button className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 font-medium transition-colors text-sm shadow-sm flex items-center gap-2">
            <Calendar size={16} />
            View Calendar
          </button>
        </div>
      </div>

      {/* 2. Quick Stats Row */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {/* Card 1 */}
        <div className="bg-white p-6 rounded-xl border border-gray-100 shadow-sm flex items-center gap-4">
          <div className="w-12 h-12 rounded-lg bg-orange-50 flex items-center justify-center">
            <Clock className="w-6 h-6 text-orange-600" />
          </div>
          <div>
            <p className="text-2xl font-bold text-gray-800">8</p>
            <p className="text-sm text-gray-500">Pending Requests</p>
          </div>
        </div>
        
        {/* Card 2 */}
        <div className="bg-white p-6 rounded-xl border border-gray-100 shadow-sm flex items-center gap-4">
          <div className="w-12 h-12 rounded-lg bg-emerald-50 flex items-center justify-center">
            <CheckCircle className="w-6 h-6 text-emerald-600" />
          </div>
          <div>
            <p className="text-2xl font-bold text-gray-800">24</p>
            <p className="text-sm text-gray-500">Approved This Week</p>
          </div>
        </div>
        
        {/* Card 3 */}
        <div className="bg-white p-6 rounded-xl border border-gray-100 shadow-sm flex items-center gap-4">
          <div className="w-12 h-12 rounded-lg bg-blue-50 flex items-center justify-center">
            <User className="w-6 h-6 text-blue-600" />
          </div>
          <div>
            <p className="text-2xl font-bold text-gray-800">156</p>
            <p className="text-sm text-gray-500">Total Students</p>
          </div>
        </div>
      </div>

      {/* 3. Main Appointments List */}
      <div className="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden">
        <div className="p-6 border-b border-gray-100">
            <h2 className="text-lg font-bold text-gray-800">Appointment Requests</h2>
            <p className="text-sm text-gray-500">Latest incoming requests requiring your attention.</p>
        </div>

        <div className="divide-y divide-gray-50">
            {appointments.map((appointment) => (
              <div key={appointment.id} className="p-6 hover:bg-gray-50 transition-colors">
                <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                  
                  {/* Left Side: Info */}
                  <div className="space-y-3 flex-1">
                    <div className="flex items-center gap-3">
                      <h3 className="font-semibold text-gray-800 text-lg">{appointment.studentName}</h3>
                      
                      {/* Status Badge */}
                      <span className={`px-2.5 py-0.5 rounded-full text-xs font-medium border ${getStatusStyles(appointment.status)} uppercase tracking-wide`}>
                        {appointment.status}
                      </span>
                      
                      {/* Priority Badge */}
                      <span className={`px-2 py-0.5 rounded-md text-xs font-medium ${getPriorityStyles(appointment.priority)}`}>
                        {appointment.priority} priority
                      </span>
                    </div>
                    
                    <div className="flex items-center gap-6 text-sm text-gray-500">
                      <div className="flex items-center gap-2">
                        <Calendar className="w-4 h-4" />
                        {appointment.date}
                      </div>
                      <div className="flex items-center gap-2">
                        <Clock className="w-4 h-4" />
                        {appointment.time}
                      </div>
                    </div>
                    
                    <p className="text-sm text-gray-700 bg-gray-50 p-2 rounded-lg inline-block border border-gray-100">
                        Reason: {appointment.reason}
                    </p>
                  </div>

                  {/* Right Side: Actions */}
                  <div className="flex items-center gap-2">
                    {appointment.status === 'pending' ? (
                      <>
                        <button 
                            onClick={() => handleAction(appointment.id, 'approved')}
                            className="flex items-center gap-1 px-3 py-2 bg-emerald-50 text-emerald-700 rounded-lg hover:bg-emerald-100 text-sm font-medium transition-colors"
                        >
                          <CheckCircle className="w-4 h-4" /> Approve
                        </button>
                        
                        <button 
                            onClick={() => handleAction(appointment.id, 'rescheduled')}
                            className="flex items-center gap-1 px-3 py-2 bg-blue-50 text-blue-700 rounded-lg hover:bg-blue-100 text-sm font-medium transition-colors"
                        >
                          <RotateCcw className="w-4 h-4" /> Reschedule
                        </button>
                        
                        <button 
                            onClick={() => handleAction(appointment.id, 'rejected')}
                            className="flex items-center gap-1 px-3 py-2 bg-red-50 text-red-700 rounded-lg hover:bg-red-100 text-sm font-medium transition-colors"
                        >
                          <X className="w-4 h-4" /> Reject
                        </button>
                      </>
                    ) : (
                      <button className="flex items-center gap-1 px-4 py-2 text-gray-500 hover:bg-gray-100 rounded-lg text-sm transition-colors">
                         <Eye className="w-4 h-4" /> View Details
                      </button>
                    )}
                  </div>
                </div>
              </div>
            ))}
        </div>
      </div>

      {/* Calendar Modal */}
      {/* {showCalendar && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-40">
          <div className="bg-white rounded-xl shadow-2xl p-6 w-full max-w-md relative animate-fade-in">
            <button
              className="absolute top-3 right-3 text-gray-400 hover:text-gray-700"
              onClick={() => setShowCalendar(false)}
              aria-label="Close calendar"
            >
              <X className="w-6 h-6" />
            </button>
            <h2 className="text-xl font-bold text-blue-700 mb-4">Calendar</h2>
            <ReactCalendar
              onChange={setCalendarDate}
              value={calendarDate}
              className="rounded-lg border-blue-100 w-full"
              tileClassName={({ date }) =>
                appointments.some(a => a.date === date.toISOString().slice(0, 10))
                  ? 'bg-blue-100 text-blue-700 font-bold' : ''
              }
            />
          </div>
        </div>
      )} */}
    </div>
  );
};

export default Appointments;