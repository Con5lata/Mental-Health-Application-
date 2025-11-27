import React, { useState } from "react";
import { 
  MessageSquare, 
  Search, 
  Reply, 
  Flag, 
  CheckCircle, 
  Clock, 
  AlertTriangle,
  Send,
  X,
  Filter
} from "lucide-react";

const QA = () => {
  // Mock Data
  const [questions, setQuestions] = useState([
    {
      id: 1,
      question: "How can I manage my anxiety before exams?",
      category: "academic-stress",
      dateAsked: "2024-01-14",
      priority: "high",
      status: "pending",
      response: "",
    },
    {
      id: 2,
      question: "I'm feeling isolated and lonely. What can I do?",
      category: "social-emotional",
      dateAsked: "2024-01-13",
      priority: "high",
      status: "pending",
      response: "",
    },
    {
      id: 3,
      question: "Tips for better sleep during stressful periods?",
      category: "wellness",
      dateAsked: "2024-01-12",
      priority: "medium",
      status: "answered",
      response: "Here are some effective sleep strategies...",
    },
  ]);

  const [selectedQuestion, setSelectedQuestion] = useState(null);
  const [responseText, setResponseText] = useState("");
  const [filterCategory, setFilterCategory] = useState("all");
  const [searchTerm, setSearchTerm] = useState("");

  // Styling Helpers
  const getStatusStyles = (status) => {
    switch (status) {
      case 'pending': return 'bg-orange-50 text-orange-700 border-orange-100';
      case 'answered': return 'bg-emerald-50 text-emerald-700 border-emerald-100';
      case 'flagged': return 'bg-red-50 text-red-700 border-red-100';
      default: return 'bg-gray-100 text-gray-600 border-gray-200';
    }
  };

  const getCategoryStyles = (category) => {
    switch (category) {
      case 'academic-stress': return 'bg-blue-50 text-blue-700';
      case 'social-emotional': return 'bg-purple-50 text-purple-700';
      case 'wellness': return 'bg-emerald-50 text-emerald-700';
      default: return 'bg-gray-100 text-gray-700';
    }
  };

  // Logic
  const filteredQuestions = questions.filter(q => {
    const matchesCategory = filterCategory === "all" || q.category === filterCategory;
    const matchesSearch = q.question.toLowerCase().includes(searchTerm.toLowerCase());
    return matchesCategory && matchesSearch;
  });

  const handleRespond = (id) => {
    if (!responseText.trim()) return;
    setQuestions(prev => 
      prev.map(q => 
        q.id === id ? { ...q, status: 'answered', response: responseText } : q
      )
    );
    setResponseText("");
    setSelectedQuestion(null);
  };

  const handleFlag = (id) => {
    setQuestions(prev => 
      prev.map(q => 
        q.id === id ? { ...q, status: 'flagged' } : q
      )
    );
  };

  // Stats
  const pendingCount = questions.filter(q => q.status === 'pending').length;
  const answeredCount = questions.filter(q => q.status === 'answered').length;

  return (
    <div className="space-y-8 animate-fade-in">
      
      {/* 1. Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold text-gray-800">Q&A Moderation</h1>
          <p className="text-gray-500 mt-1">
            Respond to anonymous student inquiries securely.
          </p>
        </div>
        <button className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 font-medium transition-colors text-sm shadow-sm flex items-center gap-2">
          <MessageSquare size={16} />
          View All Archives
        </button>
      </div>

      {/* 2. Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-white p-6 rounded-xl border border-gray-100 shadow-sm flex items-center gap-4">
          <div className="w-12 h-12 rounded-lg bg-orange-50 flex items-center justify-center">
            <Clock className="w-6 h-6 text-orange-600" />
          </div>
          <div>
            <p className="text-2xl font-bold text-gray-800">{pendingCount}</p>
            <p className="text-sm text-gray-500">Pending Responses</p>
          </div>
        </div>
        
        <div className="bg-white p-6 rounded-xl border border-gray-100 shadow-sm flex items-center gap-4">
          <div className="w-12 h-12 rounded-lg bg-emerald-50 flex items-center justify-center">
            <CheckCircle className="w-6 h-6 text-emerald-600" />
          </div>
          <div>
            <p className="text-2xl font-bold text-gray-800">{answeredCount}</p>
            <p className="text-sm text-gray-500">Answered Total</p>
          </div>
        </div>
        
        <div className="bg-white p-6 rounded-xl border border-gray-100 shadow-sm flex items-center gap-4">
          <div className="w-12 h-12 rounded-lg bg-blue-50 flex items-center justify-center">
            <MessageSquare className="w-6 h-6 text-blue-600" />
          </div>
          <div>
            <p className="text-2xl font-bold text-gray-800">{questions.length}</p>
            <p className="text-sm text-gray-500">Total Inquiries</p>
          </div>
        </div>
      </div>

      {/* 3. Filters & List */}
      <div className="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden">
        
        {/* Filter Bar */}
        <div className="p-6 border-b border-gray-100 flex flex-col md:flex-row gap-4">
            <div className="relative flex-1">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-gray-400" />
                <input 
                    type="text" 
                    placeholder="Search questions..." 
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    className="w-full pl-10 pr-4 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
                />
            </div>
            <div className="w-full md:w-64">
                <div className="relative">
                    <Filter className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-gray-400" />
                    <select 
                        value={filterCategory}
                        onChange={(e) => setFilterCategory(e.target.value)}
                        className="w-full pl-10 pr-8 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 appearance-none bg-white text-gray-600"
                    >
                        <option value="all">All Categories</option>
                        <option value="academic-stress">Academic Stress</option>
                        <option value="social-emotional">Social & Emotional</option>
                        <option value="wellness">Wellness & Health</option>
                    </select>
                </div>
            </div>
        </div>

        {/* Questions Feed */}
        <div className="divide-y divide-gray-50">
            {filteredQuestions.map((question) => (
              <div key={question.id} className="p-6 hover:bg-gray-50 transition-colors">
                <div className="flex flex-col gap-4">
                  
                  {/* Top Row: Tags & Status */}
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                        <span className={`px-2.5 py-1 rounded-md text-xs font-medium uppercase tracking-wider ${getCategoryStyles(question.category)}`}>
                            {question.category.replace('-', ' ')}
                        </span>
                        <span className={`px-2 py-1 rounded-full text-xs font-medium border ${getStatusStyles(question.status)}`}>
                            {question.status}
                        </span>
                    </div>
                    <span className="text-xs text-gray-400 flex items-center gap-1">
                        <Clock size={12} /> {question.dateAsked}
                    </span>
                  </div>

                  {/* Question Text */}
                  <div>
                    <h3 className="text-lg font-semibold text-gray-800 leading-snug">
                        "{question.question}"
                    </h3>
                  </div>

                  {/* Expanded Response Area */}
                  {selectedQuestion === question.id ? (
                    <div className="mt-2 bg-blue-50/50 p-4 rounded-xl border border-blue-100 animate-fade-in">
                        <label className="block text-sm font-medium text-blue-900 mb-2">Write your response:</label>
                        <textarea 
                            value={responseText}
                            onChange={(e) => setResponseText(e.target.value)}
                            placeholder="Type a supportive, professional answer here..."
                            rows={4}
                            className="w-full p-3 border border-blue-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 bg-white"
                        ></textarea>
                        <div className="flex gap-3 mt-3 justify-end">
                            <button 
                                onClick={() => setSelectedQuestion(null)}
                                className="px-4 py-2 text-gray-600 hover:text-gray-800 text-sm font-medium"
                            >
                                Cancel
                            </button>
                            <button 
                                onClick={() => handleRespond(question.id)}
                                className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 text-sm font-medium flex items-center gap-2"
                            >
                                <Send size={16} /> Send Reply
                            </button>
                        </div>
                    </div>
                  ) : (
                    /* Existing Response or Actions */
                    <div className="mt-1">
                        {question.response ? (
                            <div className="bg-gray-50 p-4 rounded-lg border border-gray-100 text-sm text-gray-600">
                                <span className="font-semibold text-gray-900 block mb-1">Your Answer:</span>
                                {question.response}
                            </div>
                        ) : (
                            <div className="flex gap-3">
                                <button 
                                    onClick={() => setSelectedQuestion(question.id)}
                                    className="flex items-center gap-2 px-4 py-2 bg-white border border-gray-200 text-gray-700 rounded-lg hover:bg-gray-50 hover:border-gray-300 transition-all text-sm font-medium shadow-sm"
                                >
                                    <Reply size={16} /> Reply
                                </button>
                                <button 
                                    onClick={() => handleFlag(question.id)}
                                    className="flex items-center gap-2 px-4 py-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors text-sm font-medium"
                                >
                                    <Flag size={16} /> Flag
                                </button>
                            </div>
                        )}
                    </div>
                  )}

                </div>
              </div>
            ))}
        </div>
      </div>
    </div>
  );
};

export default QA;