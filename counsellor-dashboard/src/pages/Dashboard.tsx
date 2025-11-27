import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { 
  Calendar, 
  MessageSquare, 
  FolderOpen, 
  Users, 
  Clock,
  ArrowRight,
  MoreVertical,
  Video,
  MapPin
} from "lucide-react";

const Dashboard = () => {
  const navigate = useNavigate();
  const [greeting, setGreeting] = useState('Good Morning');
  
  // Real-world logic: Determine greeting based on time
  useEffect(() => {
    const hour = new Date().getHours();
    if (hour >= 12 && hour < 17) setGreeting('Good Afternoon');
    else if (hour >= 17) setGreeting('Good Evening');
  }, []);

  // Simulating Database Counts (Replace these with real Firestore counts later)
  const stats = [
    {
      title: "Pending Appointments",
      value: "3",
      trend: "+2 today",
      icon: Calendar,
      color: "text-blue-600",
      bg: "bg-blue-50",
      link: "/appointments"
    },
    {
      title: "Unanswered Questions",
      value: "12",
      trend: "Urgent",
      icon: MessageSquare,
      color: "text-orange-500",
      bg: "bg-orange-50",
      link: "/qa"
    },
    {
      title: "Total Clients",
      value: "48",
      trend: "Active cases",
      icon: Users,
      color: "text-emerald-600",
      bg: "bg-emerald-50",
      link: "/"
    },
    {
      title: "Resources Uploaded",
      value: "156",
      trend: "Library total",
      icon: FolderOpen,
      color: "text-purple-600",
      bg: "bg-purple-50",
      link: "/resources"
    }
  ];

  // Simulating the "Appointments" Collection
  const nextAppointment = {
    clientName: "Sarah Jenkins",
    time: "14:00 PM",
    duration: "45 min",
    type: "Video Call",
    tags: ["Anxiety", "Follow-up"]
  };

  // Simulating a merged feed from 'Q_and_A', 'Appointments', and 'Resources'
  const recentActivity = [
    {
      id: 1,
      type: "appointment",
      title: "New Booking Request",
      desc: "Michael B. requested a session for Tomorrow, 10 AM",
      time: "10 min ago",
      color: "bg-blue-100 text-blue-700"
    },
    {
      id: 2,
      type: "question",
      title: "New Question Received",
      desc: "Anonymous: 'How do I deal with panic attacks at work?'",
      time: "45 min ago",
      color: "bg-orange-100 text-orange-700"
    },
    {
      id: 3,
      type: "system",
      title: "System Update",
      desc: "Your resource 'Sleep Hygiene Guide.pdf' was downloaded 5 times.",
      time: "2 hours ago",
      color: "bg-gray-100 text-gray-700"
    }
  ];

  return (
    <div className="space-y-8 animate-fade-in">
      
      {/* 1. Header Section */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold text-gray-800">{greeting}, Dr. Smith</h1>
          <p className="text-gray-500 mt-1">Here's what's happening in your portal today.</p>
        </div>
        <div className="flex gap-3">
            <button 
                onClick={() => navigate('/resources')}
                className="px-4 py-2 bg-white border border-gray-200 text-gray-700 rounded-lg hover:bg-gray-50 font-medium transition-colors text-sm shadow-sm">
                Upload Resource
            </button>
            <button 
              onClick={() => navigate('/appointments')}
              className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 font-medium transition-colors text-sm shadow-sm flex items-center gap-2">
              <Calendar size={16} />
              View Calendar
            </button>
        </div>
      </div>

      {/* 2. Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {stats.map((stat, index) => (
          <div key={index} onClick={() => navigate(stat.link)} className="bg-white p-6 rounded-xl border border-gray-100 shadow-sm hover:shadow-md transition-shadow cursor-pointer">
            <div className="flex items-center justify-between">
              <div className={`w-12 h-12 rounded-lg ${stat.bg} flex items-center justify-center`}>
                <stat.icon className={`w-6 h-6 ${stat.color}`} />
              </div>
              <span className={`text-xs font-medium px-2.5 py-1 rounded-full ${stat.color === 'text-orange-500' ? 'bg-orange-50 text-orange-600' : 'bg-gray-100 text-gray-600'}`}>
                {stat.trend}
              </span>
            </div>
            <div className="mt-4">
              <h3 className="text-3xl font-bold text-gray-800">{stat.value}</h3>
              <p className="text-sm text-gray-500 mt-1">{stat.title}</p>
            </div>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        
        {/* 3. Main Activity Feed */}
        <div className="lg:col-span-2 space-y-6">
          <div className="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden">
            <div className="p-6 border-b border-gray-100 flex justify-between items-center">
              <h2 className="text-lg font-bold text-gray-800">Recent Activity</h2>
              <button className="text-blue-600 text-sm hover:underline">View All</button>
            </div>
            <div className="divide-y divide-gray-50">
              {recentActivity.map((item) => (
                <div key={item.id} className="p-5 hover:bg-gray-50 transition-colors flex gap-4">
                  <div className={`mt-1 w-10 h-10 rounded-full flex-shrink-0 flex items-center justify-center ${item.color}`}>
                    {item.type === 'appointment' && <Calendar size={18} />}
                    {item.type === 'question' && <MessageSquare size={18} />}
                    {item.type === 'system' && <FolderOpen size={18} />}
                  </div>
                  <div className="flex-1">
                    <div className="flex justify-between items-start">
                      <h4 className="font-semibold text-gray-800 text-sm">{item.title}</h4>
                      <span className="text-xs text-gray-400 whitespace-nowrap">{item.time}</span>
                    </div>
                    <p className="text-sm text-gray-600 mt-1">{item.desc}</p>
                    {item.type === 'question' && (
                       <button onClick={() => navigate('/qa')} className="mt-3 text-xs font-medium text-blue-600 hover:text-blue-800 flex items-center gap-1">
                         Reply Now <ArrowRight size={12} />
                       </button>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* 4. Sidebar: Next Appointment & Quick Actions */}
        <div className="space-y-6">
          
          {/* Next Appointment Card */}
          <div className="bg-white rounded-xl border border-gray-100 shadow-sm p-6 relative overflow-hidden">
            <div className="absolute top-0 right-0 w-24 h-24 bg-blue-50 rounded-bl-full -mr-4 -mt-4 z-0"></div>
            <div className="relative z-10">
              <h3 className="text-sm font-bold text-gray-400 uppercase tracking-wider mb-4">Up Next</h3>
              <div className="flex items-start justify-between">
                <div>
                  <h2 className="text-xl font-bold text-gray-800">{nextAppointment.clientName}</h2>
                  <div className="flex items-center gap-2 text-gray-500 text-sm mt-1">
                     <Video size={14} />
                     {nextAppointment.type}
                  </div>
                </div>
                <div className="text-right">
                  <p className="text-2xl font-bold text-blue-600">{nextAppointment.time}</p>
                  <p className="text-xs text-gray-400">{nextAppointment.duration}</p>
                </div>
              </div>
              
              <div className="mt-6 flex flex-wrap gap-2">
                {nextAppointment.tags.map((tag) => (
                    <span key={tag} className="px-2 py-1 bg-gray-100 text-gray-600 text-xs rounded-md">
                        {tag}
                    </span>
                ))}
              </div>

              <button className="w-full mt-6 bg-gray-900 text-white py-2 rounded-lg text-sm font-medium hover:bg-gray-800 transition-colors">
                Join Session
              </button>
            </div>
          </div>

          {/* Quick Actions List */}
          <div className="bg-white rounded-xl border border-gray-100 shadow-sm p-6">
            <h3 className="font-bold text-gray-800 mb-4">Quick Shortcuts</h3>
            <div className="space-y-2">
              <button onClick={() => navigate('/appointments')} className="w-full text-left px-4 py-3 rounded-lg hover:bg-gray-50 text-sm text-gray-600 font-medium flex items-center gap-3 transition-colors border border-transparent hover:border-gray-200">
                <Clock className="text-purple-500" size={18} /> Review Schedule
              </button>
              <button onClick={() => navigate('/qa')} className="w-full text-left px-4 py-3 rounded-lg hover:bg-gray-50 text-sm text-gray-600 font-medium flex items-center gap-3 transition-colors border border-transparent hover:border-gray-200">
                <MessageSquare className="text-orange-500" size={18} /> Pending Inquiries
              </button>
              <button className="w-full text-left px-4 py-3 rounded-lg hover:bg-gray-50 text-sm text-gray-600 font-medium flex items-center gap-3 transition-colors border border-transparent hover:border-gray-200">
                <Users className="text-emerald-500" size={18} /> Client Directory
              </button>
            </div>
          </div>

        </div>
      </div>
    </div>
  );
};

export default Dashboard;