import { useState } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";
import { MessageSquare, Search, Reply, Flag, CheckCircle, Clock, AlertTriangle } from "lucide-react";

const QAModeration = () => {
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

  const [selectedQuestion, setSelectedQuestion] = useState<number | null>(null);
  const [responseText, setResponseText] = useState("");
  const [filterCategory, setFilterCategory] = useState("all");
  const [searchTerm, setSearchTerm] = useState("");

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'pending': return 'bg-warning-soft text-cta';
      case 'answered': return 'bg-success-soft text-primary';
      case 'flagged': return 'bg-destructive/10 text-destructive';
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

  const getCategoryColor = (category: string) => {
    switch (category) {
      case 'academic-stress': return 'bg-warning-soft text-cta';
      case 'social-emotional': return 'bg-info-soft text-accent';
      case 'wellness': return 'bg-success-soft text-primary';
      default: return 'bg-muted text-muted-foreground';
    }
  };

  const filteredQuestions = questions.filter(q => {
    const matchesCategory = filterCategory === "all" || q.category === filterCategory;
    const matchesSearch = q.question.toLowerCase().includes(searchTerm.toLowerCase());
    return matchesCategory && matchesSearch;
  });

  const handleRespond = (id: number) => {
    if (!responseText.trim()) return;
    
    setQuestions(prev => 
      prev.map(q => 
        q.id === id ? { ...q, status: 'answered', response: responseText } : q
      )
    );
    setResponseText("");
    setSelectedQuestion(null);
  };

  const handleFlag = (id: number) => {
    setQuestions(prev => 
      prev.map(q => 
        q.id === id ? { ...q, status: 'flagged' } : q
      )
    );
  };

  const pendingQuestions = questions.filter(q => q.status === 'pending').length;
  const answeredToday = questions.filter(q => q.status === 'answered' && q.dateAsked === '2024-01-14').length;
  const totalQuestions = questions.length;

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-accent">Anonymous Q&A Moderation</h1>
          <p className="text-customBlue mt-2">
            Professional response to anonymous student questions
          </p>
        </div>
        <Button variant="cta">
          <MessageSquare className="w-4 h-4 mr-2" />
          View All Categories
        </Button>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <Card className="shadow-card border-0">
          <CardContent className="p-6">
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 rounded-lg bg-warning-soft flex items-center justify-center">
                <Clock className="w-6 h-6 text-cta" />
              </div>
              <div>
                <p className="text-2xl font-bold">{pendingQuestions}</p>
                <p className="text-sm text-customBlue">Pending Responses</p>
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
                <p className="text-2xl font-bold">{answeredToday}</p>
                <p className="text-sm text-customBlue">Answered Today</p>
              </div>
            </div>
          </CardContent>
        </Card>
        
        <Card className="shadow-card border-0">
          <CardContent className="p-6">
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 rounded-lg bg-info-soft flex items-center justify-center">
                <MessageSquare className="w-6 h-6 text-accent" />
              </div>
              <div>
                <p className="text-2xl font-bold">{totalQuestions}</p>
                <p className="text-sm text-customBlue">Total Questions</p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Filters */}
      <Card className="shadow-card border-0">
        <CardHeader>
          <CardTitle className="text-accent">Filter Questions</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label>Search Questions</Label>
              <div className="relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                <Input
                  placeholder="Search questions..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="pl-10"
                />
              </div>
            </div>
            
            <div className="space-y-2">
              <Label>Filter by Category</Label>
              <Select value={filterCategory} onValueChange={setFilterCategory}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Categories</SelectItem>
                  <SelectItem value="academic-stress">Academic Stress</SelectItem>
                  <SelectItem value="social-emotional">Social & Emotional</SelectItem>
                  <SelectItem value="wellness">Wellness & Health</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Questions List */}
      <Card className="shadow-card border-0">
        <CardHeader>
          <CardTitle className="text-accent">Student Questions</CardTitle>
          <CardDescription>
            Review and respond to anonymous questions from students
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {filteredQuestions.map((question) => (
              <div key={question.id} className="p-6 rounded-lg border border-border hover:shadow-soft transition-smooth">
                <div className="space-y-4">
                  <div className="flex items-start justify-between">
                    <div className="space-y-3 flex-1">
                      <div className="flex items-center gap-3">
                        <Badge className={getCategoryColor(question.category)}>
                          {question.category.replace('-', ' ')}
                        </Badge>
                        <Badge className={getPriorityColor(question.priority)}>
                          {question.priority} priority
                        </Badge>
                        <Badge className={getStatusColor(question.status)}>
                          {question.status}
                        </Badge>
                      </div>
                      
                      <p className="text-foreground font-medium">{question.question}</p>
                      
                      <div className="text-sm text-customBlue">
                        Asked on {question.dateAsked}
                      </div>
                      
                      {question.response && (
                        <div className="mt-4 p-4 bg-muted/30 rounded-lg">
                          <p className="text-sm text-foreground"><strong>Response:</strong> {question.response}</p>
                        </div>
                      )}
                    </div>

                    <div className="flex items-center gap-2 ml-4">
                      {question.status === 'pending' && (
                        <>
                          <Button
                            size="sm"
                            variant="outline"
                            onClick={() => setSelectedQuestion(question.id)}
                          >
                            <Reply className="w-4 h-4 mr-1" />
                            Respond
                          </Button>
                          <Button
                            size="sm"
                            variant="destructive"
                            onClick={() => handleFlag(question.id)}
                          >
                            <Flag className="w-4 h-4 mr-1" />
                            Flag
                          </Button>
                        </>
                      )}
                    </div>
                  </div>

                  {selectedQuestion === question.id && (
                    <div className="mt-4 p-4 border border-border rounded-lg bg-muted/10">
                      <div className="space-y-3">
                        <Label htmlFor="response">Your Response</Label>
                        <Textarea
                          id="response"
                          value={responseText}
                          onChange={(e) => setResponseText(e.target.value)}
                          placeholder="Provide a helpful, supportive response..."
                          rows={4}
                        />
                        <div className="flex gap-2">
                          <Button
                            onClick={() => handleRespond(question.id)}
                            disabled={!responseText.trim()}
                          >
                            <CheckCircle className="w-4 h-4 mr-1" />
                            Send Response
                          </Button>
                          <Button
                            variant="outline"
                            onClick={() => setSelectedQuestion(null)}
                          >
                            Cancel
                          </Button>
                        </div>
                      </div>
                    </div>
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
export default QAModeration;