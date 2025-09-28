import { useState } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";
import { Upload, FileText, Video, Link as LinkIcon, Edit, Trash2, Plus } from "lucide-react";

const Resources = () => {
  const [resources, setResources] = useState([
    {
      id: 1,
      title: "Managing Exam Anxiety",
      description: "Comprehensive guide on coping strategies for exam-related stress",
      category: "articles",
      type: "PDF",
      dateAdded: "2024-01-10",
      downloads: 145,
    },
    {
      id: 2,
      title: "Mindfulness Meditation for Students",
      description: "Video series on mindfulness techniques to reduce academic stress",
      category: "videos",
      type: "Video",
      dateAdded: "2024-01-08",
      downloads: 89,
    },
    {
      id: 3,
      title: "Study-Life Balance Tips",
      description: "Practical advice for maintaining healthy study habits",
      category: "tips",
      type: "Article",
      dateAdded: "2024-01-05",
      downloads: 203,
    },
  ]);

  const [showUploadForm, setShowUploadForm] = useState(false);
  const [newResource, setNewResource] = useState({
    title: "",
    description: "",
    category: "",
    type: "article",
  });

  const getCategoryColor = (category: string) => {
    switch (category) {
      case 'articles': return 'bg-info-soft text-accent';
      case 'videos': return 'bg-warning-soft text-cta';
      case 'tips': return 'bg-success-soft text-primary';
      default: return 'bg-muted text-muted-foreground';
    }
  };

  const handleSubmitResource = (e: React.FormEvent) => {
    e.preventDefault();
    const resource = {
      id: resources.length + 1,
      ...newResource,
      dateAdded: new Date().toISOString().split('T')[0],
      downloads: 0,
    };
    setResources([resource, ...resources]);
    setNewResource({ title: "", description: "", category: "", type: "article" });
    setShowUploadForm(false);
  };

  const handleDelete = (id: number) => {
    setResources(resources.filter(r => r.id !== id));
  };

  const totalResources = resources.length;
  const totalDownloads = resources.reduce((sum, r) => sum + r.downloads, 0);
  const thisWeekUploads = resources.filter(r => {
    const resourceDate = new Date(r.dateAdded);
    const weekAgo = new Date();
    weekAgo.setDate(weekAgo.getDate() - 7);
    return resourceDate >= weekAgo;
  }).length;

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-accent">Resource Management</h1>
          <p className="text-muted-foreground mt-2">
            Professional resource library for student mental health support
          </p>
        </div>
        <Button variant="cta" onClick={() => setShowUploadForm(!showUploadForm)}>
          <Plus className="w-4 h-4 mr-2" />
          Add Resource
        </Button>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <Card className="shadow-card border-0">
          <CardContent className="p-6">
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 rounded-lg bg-info-soft flex items-center justify-center">
                <FileText className="w-6 h-6 text-accent" />
              </div>
              <div>
                <p className="text-2xl font-bold">{totalResources}</p>
                <p className="text-sm text-muted-foreground">Total Resources</p>
              </div>
            </div>
          </CardContent>
        </Card>
        
        <Card className="shadow-card border-0">
          <CardContent className="p-6">
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 rounded-lg bg-success-soft flex items-center justify-center">
                <Upload className="w-6 h-6 text-primary" />
              </div>
              <div>
                <p className="text-2xl font-bold">{totalDownloads}</p>
                <p className="text-sm text-muted-foreground">Total Downloads</p>
              </div>
            </div>
          </CardContent>
        </Card>
        
        <Card className="shadow-card border-0">
          <CardContent className="p-6">
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 rounded-lg bg-warning-soft flex items-center justify-center">
                <Plus className="w-6 h-6 text-cta" />
              </div>
              <div>
                <p className="text-2xl font-bold">{thisWeekUploads}</p>
                <p className="text-sm text-muted-foreground">Added This Week</p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Upload Form */}
      {showUploadForm && (
        <Card className="shadow-card border-0">
          <CardHeader>
            <CardTitle className="text-accent">Add New Resource</CardTitle>
            <CardDescription>
              Upload articles, videos, or links to help support student mental health
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleSubmitResource} className="space-y-4">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="title">Title</Label>
                  <Input
                    id="title"
                    value={newResource.title}
                    onChange={(e) => setNewResource({...newResource, title: e.target.value})}
                    placeholder="Enter resource title"
                    required
                  />
                </div>
                
                <div className="space-y-2">
                  <Label htmlFor="category">Category</Label>
                  <Select value={newResource.category} onValueChange={(value) => setNewResource({...newResource, category: value})}>
                    <SelectTrigger>
                      <SelectValue placeholder="Select category" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="articles">Articles</SelectItem>
                      <SelectItem value="videos">Videos</SelectItem>
                      <SelectItem value="tips">Tips & Guides</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="description">Description</Label>
                <Textarea
                  id="description"
                  value={newResource.description}
                  onChange={(e) => setNewResource({...newResource, description: e.target.value})}
                  placeholder="Describe the resource and how it helps students"
                  rows={3}
                  required
                />
              </div>

              <div className="space-y-2">
                <Label>Upload Type</Label>
                <div className="flex gap-4">
                  <Button type="button" variant="outline" className="flex-1">
                    <Upload className="w-4 h-4 mr-2" />
                    Upload File
                  </Button>
                  <Button type="button" variant="outline" className="flex-1">
                    <LinkIcon className="w-4 h-4 mr-2" />
                    Add Link
                  </Button>
                </div>
              </div>

              <div className="flex gap-3 pt-4">
                <Button type="submit" variant="default">
                  <Plus className="w-4 h-4 mr-2" />
                  Add Resource
                </Button>
                <Button type="button" variant="outline" onClick={() => setShowUploadForm(false)}>
                  Cancel
                </Button>
              </div>
            </form>
          </CardContent>
        </Card>
      )}

      {/* Resources List */}
      <Card className="shadow-card border-0">
        <CardHeader>
          <CardTitle className="text-accent">Published Resources</CardTitle>
          <CardDescription>
            Manage your uploaded resources and track their usage
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {resources.map((resource) => (
              <div key={resource.id} className="p-6 rounded-lg border border-border hover:shadow-soft transition-smooth">
                <div className="flex items-start justify-between">
                  <div className="space-y-3 flex-1">
                    <div className="flex items-center gap-3">
                      <h3 className="font-semibold text-foreground">{resource.title}</h3>
                      <Badge className={getCategoryColor(resource.category)}>
                        {resource.category}
                      </Badge>
                      <Badge variant="outline">
                        {resource.type}
                      </Badge>
                    </div>
                    
                    <p className="text-sm text-foreground">{resource.description}</p>
                    
                    <div className="flex items-center gap-6 text-sm text-muted-foreground">
                      <span>Added: {resource.dateAdded}</span>
                      <span>{resource.downloads} downloads</span>
                    </div>
                  </div>

                  <div className="flex items-center gap-2 ml-4">
                    <Button size="sm" variant="outline">
                      <Edit className="w-4 h-4 mr-1" />
                      Edit
                    </Button>
                    <Button 
                      size="sm" 
                      variant="destructive"
                      onClick={() => handleDelete(resource.id)}
                    >
                      <Trash2 className="w-4 h-4 mr-1" />
                      Delete
                    </Button>
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

export default Resources;