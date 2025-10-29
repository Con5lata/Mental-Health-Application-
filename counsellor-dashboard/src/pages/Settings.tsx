import { useState } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import { Separator } from "@/components/ui/separator";
import { User, Bell, Shield, Eye, Save, Key } from "lucide-react";

const Settings = () => {
  const [profile, setProfile] = useState({
    name: "Dr. Sarah Smith",
    email: "sarah.smith@university.edu",
    phone: "+1 (555) 123-4567",
    department: "Student Counseling Services",
    title: "Senior Mental Health Counselor",
  });

  const [notifications, setNotifications] = useState({
    newAppointments: true,
    urgentQuestions: true,
    flaggedJournals: true,
    systemUpdates: false,
    emailSummary: true,
  });

  const [privacy, setPrivacy] = useState({
    profileVisibility: true,
    activityStatus: false,
    dataCollection: true,
  });

  const handleProfileUpdate = (e: React.FormEvent) => {
    e.preventDefault();
    // Handle profile update logic
    console.log("Profile updated:", profile);
  };

  const handleNotificationChange = (key: string, value: boolean) => {
    setNotifications(prev => ({ ...prev, [key]: value }));
  };

  const handlePrivacyChange = (key: string, value: boolean) => {
    setPrivacy(prev => ({ ...prev, [key]: value }));
  };

  return (
    <div className="space-y-6">
        <div>
          <h1 className="text-3xl font-bold text-accent">Professional Settings</h1>
          <p className="text-customBlue mt-2">
            Manage your counsellor profile and system preferences
          </p>
        </div>

      {/* Profile Settings */}
      <Card className="shadow-card border-0">
        <CardHeader>
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-lg bg-accent/10 flex items-center justify-center">
              <User className="w-5 h-5 text-accent" />
            </div>
            <div>
              <CardTitle className="text-accent">Profile Information</CardTitle>
              <CardDescription>
                Update your personal and professional information
              </CardDescription>
            </div>
          </div>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleProfileUpdate} className="space-y-6">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="space-y-2">
                <Label htmlFor="name">Full Name</Label>
                <Input
                  id="name"
                  value={profile.name}
                  onChange={(e) => setProfile({...profile, name: e.target.value})}
                />
              </div>
              
              <div className="space-y-2">
                <Label htmlFor="title">Professional Title</Label>
                <Input
                  id="title"
                  value={profile.title}
                  onChange={(e) => setProfile({...profile, title: e.target.value})}
                />
              </div>
              
              <div className="space-y-2">
                <Label htmlFor="email">Email Address</Label>
                <Input
                  id="email"
                  type="email"
                  value={profile.email}
                  onChange={(e) => setProfile({...profile, email: e.target.value})}
                />
              </div>
              
              <div className="space-y-2">
                <Label htmlFor="phone">Phone Number</Label>
                <Input
                  id="phone"
                  value={profile.phone}
                  onChange={(e) => setProfile({...profile, phone: e.target.value})}
                />
              </div>
            </div>

            <div className="space-y-2">
              <Label htmlFor="department">Department</Label>
              <Input
                id="department"
                value={profile.department}
                onChange={(e) => setProfile({...profile, department: e.target.value})}
              />
            </div>

            <Button type="submit" variant="default">
              <Save className="w-4 h-4 mr-2" />
              Save Profile Changes
            </Button>
          </form>
        </CardContent>
      </Card>

      {/* Security Settings */}
      <Card className="shadow-card border-0">
        <CardHeader>
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-lg bg-warning-soft flex items-center justify-center">
              <Shield className="w-5 h-5 text-cta" />
            </div>
            <div>
              <CardTitle className="text-accent">Security</CardTitle>
              <CardDescription>
                Manage your account security and password
              </CardDescription>
            </div>
          </div>
        </CardHeader>
        <CardContent className="space-y-6">
          <div className="flex items-center justify-between p-4 rounded-lg border border-border">
            <div>
              <h4 className="font-medium">Password</h4>
              <p className="text-sm text-customBlue">Last changed 30 days ago</p>
            </div>
            <Button variant="outline">
              <Key className="w-4 h-4 mr-2" />
              Change Password
            </Button>
          </div>
          
          <div className="flex items-center justify-between p-4 rounded-lg border border-border">
            <div>
              <h4 className="font-medium">Two-Factor Authentication</h4>
              <p className="text-sm text-customBlue">Add an extra layer of security</p>
            </div>
            <Button variant="outline">
              Enable 2FA
            </Button>
          </div>
        </CardContent>
      </Card>

      {/* Notification Settings */}
      <Card className="shadow-card border-0">
        <CardHeader>
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-lg bg-info-soft flex items-center justify-center">
              <Bell className="w-5 h-5 text-accent" />
            </div>
            <div>
              <CardTitle className="text-accent">Notifications</CardTitle>
              <CardDescription>
                Configure how you receive alerts and updates
              </CardDescription>
            </div>
          </div>
        </CardHeader>
        <CardContent className="space-y-6">
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <div>
                <h4 className="font-medium">New Appointment Requests</h4>
                <p className="text-sm text-customBlue">Get notified when students request appointments</p>
              </div>
              <Switch
                checked={notifications.newAppointments}
                onCheckedChange={(value) => handleNotificationChange('newAppointments', value)}
              />
            </div>
            
            <Separator />
            
            <div className="flex items-center justify-between">
              <div>
                <h4 className="font-medium">Urgent Q&A Questions</h4>
                <p className="text-sm text-customBlue">High-priority questions requiring immediate attention</p>
              </div>
              <Switch
                checked={notifications.urgentQuestions}
                onCheckedChange={(value) => handleNotificationChange('urgentQuestions', value)}
              />
            </div>
            
            <Separator />
            
            <div className="flex items-center justify-between">
              <div>
                <h4 className="font-medium">Flagged Journal Entries</h4>
                <p className="text-sm text-customBlue">Journal entries that need review</p>
              </div>
              <Switch
                checked={notifications.flaggedJournals}
                onCheckedChange={(value) => handleNotificationChange('flaggedJournals', value)}
              />
            </div>
            
            <Separator />
            
            <div className="flex items-center justify-between">
              <div>
                <h4 className="font-medium">Daily Email Summary</h4>
                <p className="text-sm text-customBlue">Daily digest of platform activity</p>
              </div>
              <Switch
                checked={notifications.emailSummary}
                onCheckedChange={(value) => handleNotificationChange('emailSummary', value)}
              />
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Privacy Settings */}
      <Card className="shadow-card border-0">
        <CardHeader>
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-lg bg-success-soft flex items-center justify-center">
              <Eye className="w-5 h-5 text-primary" />
            </div>
            <div>
              <CardTitle className="text-accent">Privacy & Data</CardTitle>
              <CardDescription>
                Control your privacy settings and data usage
              </CardDescription>
            </div>
          </div>
        </CardHeader>
        <CardContent className="space-y-6">
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <div>
                <h4 className="font-medium">Profile Visibility</h4>
                <p className="text-sm text-customBlue">Allow students to see your profile information</p>
              </div>
              <Switch
                checked={privacy.profileVisibility}
                onCheckedChange={(value) => handlePrivacyChange('profileVisibility', value)}
              />
            </div>
            
            <Separator />
            
            <div className="flex items-center justify-between">
              <div>
                <h4 className="font-medium">Activity Status</h4>
                <p className="text-sm text-customBlue">Show when you're online and available</p>
              </div>
              <Switch
                checked={privacy.activityStatus}
                onCheckedChange={(value) => handlePrivacyChange('activityStatus', value)}
              />
            </div>
            
            <Separator />
            
            <div className="flex items-center justify-between">
              <div>
                <h4 className="font-medium">Analytics Data Collection</h4>
                <p className="text-sm text-customBlue">Help improve the platform with usage analytics</p>
              </div>
              <Switch
                checked={privacy.dataCollection}
                onCheckedChange={(value) => handlePrivacyChange('dataCollection', value)}
              />
            </div>
          </div>
          
          <div className="pt-4">
            <Button variant="outline" className="w-full">
              <Eye className="w-4 h-4 mr-2" />
              View Privacy Policy
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
};

export default Settings;