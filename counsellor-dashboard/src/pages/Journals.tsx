import { useState } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import { BookOpen, AlertTriangle, Search, Eye, Flag, CheckCircle } from "lucide-react";

const Journals = () => {
  const [journals, setJournals] = useState([
    {
      id: 1,
      studentId: "STU001",
      title: "Feeling overwhelmed with coursework",
      excerpt: "I've been struggling to keep up with my classes and feeling really anxious about falling behind...",
      date: "2024-01-14",
      flagged: true,
      priority: "high",
      status: "pending",
    },
    {
      id: 2,
      studentId: "STU002", 
      title: "Positive progress this week",
      excerpt: "Had a much better week, managed to complete all assignments and even had time for self-care...",
      date: "2024-01-13",
      flagged: false,
      priority: "low",
      status: "reviewed",
    },
    {
      id: 3,
      studentId: "STU003",
      title: "Relationship difficulties affecting studies",
      excerpt: "Having some personal issues that are making it hard to focus on my academic work...",
      date: "2024-01-12",
      flagged: true,
      priority: "medium",
      status: "pending",
    },
  ]);

  const [searchTerm, setSearchTerm] = useState("");

  const filteredJournals = journals.filter(journal => 
    journal.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
    journal.excerpt.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'pending': return 'bg-warning-soft text-cta';
      case 'reviewed': return 'bg-success-soft text-primary';
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

  const handleReview = (id: number) => {
    setJournals(prev => 
      prev.map(journal => 
        journal.id === id ? { ...journal, status: 'reviewed', flagged: false } : journal
      )
    );
  };

  const flaggedJournals = journals.filter(j => j.flagged).length;
  const totalJournals = journals.length;
  const reviewedThisWeek = journals.filter(j => j.status === 'reviewed').length;

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-accent">Journal Review</h1>
          <p className="text-customBlue mt-2">
            Professional review of flagged student journal entries
          </p>
        </div>
        <Button variant="export">
          <BookOpen className="w-4 h-4 mr-2" />
          Export Reports
        </Button>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <Card className="shadow-card border-0">
          <CardContent className="p-6">
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 rounded-lg bg-warning-soft flex items-center justify-center">
                <AlertTriangle className="w-6 h-6 text-cta" />
              </div>
              <div>
                <p className="text-2xl font-bold">{flaggedJournals}</p>
                <p className="text-sm text-customBlue">Flagged for Review</p>
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
                <p className="text-2xl font-bold">{reviewedThisWeek}</p>
                <p className="text-sm text-customBlue">Reviewed This Week</p>
              </div>
            </div>
          </CardContent>
        </Card>
        
        <Card className="shadow-card border-0">
          <CardContent className="p-6">
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 rounded-lg bg-info-soft flex items-center justify-center">
                <BookOpen className="w-6 h-6 text-accent" />
              </div>
              <div>
                <p className="text-2xl font-bold">{totalJournals}</p>
                <p className="text-sm text-customBlue">Total Entries</p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Search and Filters */}
      <Card className="shadow-card border-0">
        <CardHeader>
          <CardTitle className="text-accent">Search Journal Entries</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-muted-foreground" />
            <Input
              placeholder="Search by title or content..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="pl-10"
            />
          </div>
        </CardContent>
      </Card>

      {/* Journal Entries */}
      <Card className="shadow-card border-0">
        <CardHeader>
          <CardTitle className="text-accent">Journal Entries</CardTitle>
          <CardDescription>
            Review student journal entries and provide appropriate support
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {filteredJournals.map((journal) => (
              <div key={journal.id} className="p-6 rounded-lg border border-border hover:shadow-soft transition-smooth">
                <div className="flex items-start justify-between">
                  <div className="space-y-3 flex-1">
                    <div className="flex items-center gap-3">
                      <h3 className="font-semibold text-foreground">{journal.title}</h3>
                      {journal.flagged && (
                        <div className="flex items-center gap-1 text-destructive">
                          <Flag className="w-4 h-4" />
                          <span className="text-xs">Flagged</span>
                        </div>
                      )}
                      <Badge className={getPriorityColor(journal.priority)}>
                        {journal.priority}
                      </Badge>
                      <Badge className={getStatusColor(journal.status)}>
                        {journal.status}
                      </Badge>
                    </div>
                    
                    <div className="text-sm text-customBlue">
                      Student ID: {journal.studentId} • {journal.date}
                    </div>
                    
                    <p className="text-sm text-foreground">{journal.excerpt}</p>
                  </div>

                  <div className="flex items-center gap-2 ml-4">
                    <Button size="sm" variant="outline">
                      <Eye className="w-4 h-4 mr-1" />
                      Read Full
                    </Button>
                    {journal.status === 'pending' && (
                      <Button
                        size="sm"
                        variant="default"
                        onClick={() => handleReview(journal.id)}
                      >
                        <CheckCircle className="w-4 h-4 mr-1" />
                        Mark Reviewed
                      </Button>
                    )}
                  </div>
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    </div>
  );
};

export default Journals;