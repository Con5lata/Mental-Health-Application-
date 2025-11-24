import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _hasChanges = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _role = "User";
  
  // Store original values to check for changes
  String _initialName = "";
  String _initialPhone = "";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    
    // Listen for changes to show/hide the save button
    _nameController.addListener(_checkForChanges);
    _phoneController.addListener(_checkForChanges);
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _checkForChanges() {
    final nameChanged = _nameController.text.trim() != _initialName;
    final phoneChanged = _phoneController.text.trim() != _initialPhone;
    
    if (mounted) {
      setState(() {
        _hasChanges = nameChanged || phoneChanged;
      });
    }
  }

  Future<void> _fetchUserData() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // 1. Pre-fill from Auth (fastest)
      _nameController.text = user.displayName ?? '';
      _emailController.text = user.email ?? '';
      _initialName = user.displayName ?? '';

      // 2. Fetch details from Firestore
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      
      if (doc.exists && mounted) {
        final data = doc.data()!;
        final name = data['name'] ?? user.displayName ?? '';
        final phone = data['phone'] ?? '';
        
        _nameController.text = name;
        _phoneController.text = phone;
        _role = data['role'] ?? 'User';
        
        _initialName = name;
        _initialPhone = phone;
        
        // Force UI refresh
        setState(() {}); 
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load profile: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateUserData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final newName = _nameController.text.trim();
      final newPhone = _phoneController.text.trim();

      // 1. Update Firebase Auth Profile (So it reflects globally instantly)
      if (newName != user.displayName) {
        await user.updateDisplayName(newName);
      }

      // 2. Update Firestore Document
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'name': newName,
        'phone': newPhone,
        'updated_at': FieldValue.serverTimestamp(),
      });

      // 3. Reset state
      _initialName = newName;
      _initialPhone = newPhone;
      _checkForChanges(); // Should hide the button

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Optional: Go back after save
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          "Edit Profile", 
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF1A1C1E))
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFFF8F9FA),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          // Save button only appears when changes are made
          if (_hasChanges && !_isLoading)
            TextButton(
              onPressed: _updateUserData,
              child: Text(
                "Save", 
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.indigo)
              ),
            ),
        ],
      ),
      body: _isLoading && _nameController.text.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // --- AVATAR SECTION ---
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.indigo.shade50,
                            child: Icon(Icons.person, size: 50, color: Colors.indigo.shade200),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.indigo,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                          ),
                        )
                      ],
                    ),
                    
                    const SizedBox(height: 30),

                    // --- FORM SECTION ---
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildLabel("Full Name"),
                          TextFormField(
                            controller: _nameController,
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                            decoration: _inputDecoration(Icons.person_outline, "Your Name"),
                            validator: (value) => value?.isEmpty ?? true ? 'Name cannot be empty' : null,
                          ),
                          
                          const SizedBox(height: 20),
                          
                          _buildLabel("Phone Number"),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                            decoration: _inputDecoration(Icons.phone_outlined, "07XX XXX XXX"),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --- READ ONLY SECTION ---
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Account Information",
                            style: GoogleFonts.poppins(
                              fontSize: 12, fontWeight: FontWeight.w600, 
                              color: Colors.grey.shade400, letterSpacing: 1.2
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildReadOnlyField("Email Address", _emailController.text, Icons.email_outlined),
                          const Divider(height: 30),
                          _buildReadOnlyField("Role", _role.toUpperCase(), Icons.security_outlined),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else if (_hasChanges)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _updateUserData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 4,
                            shadowColor: Colors.indigo.withOpacity(0.3),
                          ),
                          child: Text(
                            "Save Changes",
                            style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label, 
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey.shade600)
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(IconData icon, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: Colors.grey.shade300),
      prefixIcon: Icon(icon, color: Colors.indigo.shade300, size: 20),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade100),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.indigo, width: 1.5),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: Colors.grey.shade500),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500)),
              Text(value, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey.shade700)),
            ],
          ),
        ),
        const Icon(Icons.lock, size: 16, color: Colors.grey),
      ],
    );
  }
}