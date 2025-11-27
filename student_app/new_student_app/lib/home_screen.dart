import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'appointments_screen.dart';
import 'bottom_nav_bar.dart';
import 'journals_screen.dart';
import 'resources_screen.dart';
import 'support_screen.dart';
import 'settings_screen.dart';
import 'login_page.dart'; // For redirecting guests

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? _userName;
  Map<String, dynamic>? _nextAppointment;
  int _streakDays = 0; 
  int _selectedMoodIndex = -1;
  bool _isSubmittingMood = false;

  final List<String> _moodEmojis = ['😞', '😐', '🙂', '😊', '😁'];

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // 🛑 GUEST CHECK: If guest, don't fetch user data from Firestore (it doesn't exist)
    if (user.isAnonymous) {
      setState(() {
        _userName = "Guest";
        _streakDays = 0;
      });
      return;
    }

    try {
      // 1. Fetch User Name
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final userDoc = await userRef.get();
      String? nameFromFirestore = userDoc.data()?['name'];
      String? nameFromAuth = user.displayName;
      String? resolvedName = nameFromFirestore;
      if (resolvedName == null || resolvedName.trim().isEmpty) {
        resolvedName = nameFromAuth;
      }
      if (resolvedName == null || resolvedName.trim().isEmpty) {
        // If email fallback, strip domain
        if (user.email != null && user.email!.contains('@')) {
          resolvedName = user.email!.split('@')[0];
        } else {
          resolvedName = "User";
        }
      }
      if (mounted) {
        setState(() {
          _userName = resolvedName;
        });
      }

      // 2. Calculate Streak
      await _calculateMoodStreak(user.uid);

      // 3. Fetch Next Appointment
      final appointmentQuery = await FirebaseFirestore.instance
          .collection('appointments')
          .where('user_id', isEqualTo: user.uid)
          .orderBy('slot')
          .where('slot', isGreaterThan: Timestamp.now())
          .limit(1)
          .get();

      if (mounted && appointmentQuery.docs.isNotEmpty) {
        setState(() {
          _nextAppointment = appointmentQuery.docs.first.data();
        });
      }
    } catch (e) {
      debugPrint("Error initializing home: $e");
    }
  }

  Future<void> _calculateMoodStreak(String userId) async {
    // ... (Keep your existing streak logic here) ...
    // Logic is preserved from previous file
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('moods')
          .where('user_id', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      if (querySnapshot.docs.isEmpty) {
        if (mounted) setState(() => _streakDays = 0);
        return;
      }

      final Set<DateTime> uniqueDates = {};
      for (var doc in querySnapshot.docs) {
        final timestamp = doc['date'] as Timestamp?;
        if (timestamp != null) {
          final date = timestamp.toDate();
          uniqueDates.add(DateTime(date.year, date.month, date.day));
        }
      }

      if (uniqueDates.isEmpty) {
        if (mounted) setState(() => _streakDays = 0);
        return;
      }

      final sortedDates = uniqueDates.toList()..sort((a, b) => b.compareTo(a)); 
      final today = DateTime.now();
      final normalizedToday = DateTime(today.year, today.month, today.day);
      final normalizedYesterday = normalizedToday.subtract(const Duration(days: 1));

      if (!sortedDates.first.isAtSameMomentAs(normalizedToday) && 
          !sortedDates.first.isAtSameMomentAs(normalizedYesterday)) {
        if (mounted) setState(() => _streakDays = 0);
        return;
      }

      int currentStreak = 1;
      DateTime previousDate = sortedDates.first;

      for (int i = 1; i < sortedDates.length; i++) {
        final currentDate = sortedDates[i];
        if (previousDate.difference(currentDate).inDays == 1) {
          currentStreak++;
          previousDate = currentDate;
        } else {
          break; 
        }
      }

      if (mounted) {
        setState(() => _streakDays = currentStreak);
      }
    } catch (e) {
      debugPrint("Error calculating mood streak: $e");
    }
  }

  Future<void> _submitMood(int index) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _selectedMoodIndex = index;
      _isSubmittingMood = true;
    });

    try {
      // Guests CAN submit moods (saved to anonymous ID), but it won't persist if they logout.
      final moodScore = index + 1;
      final moodEmoji = _moodEmojis[index];

      await FirebaseFirestore.instance.collection('moods').add({
        'user_id': user.uid,
        'note': moodEmoji,
        'score': moodScore,
        'date': FieldValue.serverTimestamp(),
      });

      // Only recalc streak if real user
      if (!user.isAnonymous) {
        await _calculateMoodStreak(user.uid);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(user.isAnonymous 
              ? 'Mood logged! (Guest data is temporary)' 
              : 'Mood logged: $moodEmoji'),
            backgroundColor: Colors.indigo,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save mood: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmittingMood = false);
    }
  }

  // 🛑 GUEST BLOCKER: Shows a dialog for locked features
  void _showGuestLock(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Account Required"),
        content: Text("Please sign up to access $feature and save your progress."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            child: const Text("Login / Sign Up"),
          )
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    final user = FirebaseAuth.instance.currentUser;
    final isGuest = user?.isAnonymous ?? false;

    setState(() => _selectedIndex = index);
    
    switch (index) {
      case 1: // Journals
        if (isGuest) {
          _showGuestLock(context, "Journals");
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const JournalsScreen()));
        }
        break;
      case 2: // Appointments
        if (isGuest) {
          _showGuestLock(context, "Appointments");
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AppointmentsScreen()));
        }
        break;
      case 3: // Resources (OPEN FOR GUESTS)
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ResourcesScreen()));
        break;
      case 4: // Support (OPEN FOR GUESTS)
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SupportScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isGuest = user?.isAnonymous ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF8F9FC),
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.indigo.shade200, width: 2),
              ),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.indigo.shade50,
                // Show generic icon for guests
                backgroundImage: (!isGuest && user?.photoURL != null) ? NetworkImage(user!.photoURL!) : null,
                child: (isGuest || user?.photoURL == null) 
                    ? const Icon(Icons.person, color: Colors.indigo) 
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                Text(
                  (user != null && !isGuest)
                      ? (_userName ?? user.displayName ?? (user.email != null && user.email!.contains('@') ? user.email!.split('@')[0] : 'User'))
                      : 'Guest',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.blueGrey.shade900),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black87),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              const Text("How are you feeling today?", 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 15),
              
              _buildMoodSelector(),
              
              const SizedBox(height: 25),

              // STREAK CARD (Modified for Guests)
              isGuest 
                ? _buildGuestStreakCard()
                : StreakCard(streakDays: _streakDays, onTap: _showStreakDetails),
                
              const SizedBox(height: 25),

              if (_nextAppointment != null) ...[
                const Text("Upcoming", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _buildAppointmentCard(context),
                const SizedBox(height: 25),
              ],

              const Text("Essentials", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.1,
                children: [
                  // Journals (Locked for Guest)
                  _buildGradientNavCard(
                    context, "Journals", Icons.book, 
                    isGuest ? [Colors.grey, Colors.blueGrey] : [const Color(0xFF6A11CB), const Color(0xFF2575FC)], 
                    () {
                      if(isGuest) {
                        _showGuestLock(context, "Journals");
                      } else {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const JournalsScreen()));
                      }
                    },
                    isLocked: isGuest,
                  ),
                  // Appointments (Locked for Guest)
                  _buildGradientNavCard(
                    context, "Appointments", Icons.calendar_today, 
                    isGuest ? [Colors.grey, Colors.blueGrey] : [const Color(0xFF11998E), const Color(0xFF38EF7D)], 
                    () {
                      if(isGuest) {
                        _showGuestLock(context, "Appointments");
                      } else {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AppointmentsScreen()));
                      }
                    },
                    isLocked: isGuest,
                  ),
                  // Resources (Open)
                  _buildGradientNavCard(
                    context, "Resources", Icons.lightbulb, 
                    const [Color(0xFFFF9966), Color(0xFFFF5E62)], 
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResourcesScreen())),
                  ),
                  // Support (Open)
                  _buildGradientNavCard(
                    context, "Support", Icons.favorite, 
                    const [Color(0xFFEB3349), Color(0xFFF45C43)], 
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen())),
                  ),
                ],
              ),

              const SizedBox(height: 25),
              _buildQuoteCard(),
              const SizedBox(height: 25),
              const ContactSupportBanner(),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex, 
        onTap: _onItemTapped
      ),
    );
  }

  Widget _buildGuestStreakCard() {
    return GestureDetector(
      onTap: () => _showGuestLock(context, "Progress Tracking"),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
              child: const Icon(Icons.lock, color: Colors.grey),
            ),
            const SizedBox(width: 15),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Track your Journey", 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("Sign in to unlock streaks & history.", 
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSelector() {
    final moodLabels = ['Terrible', 'Bad', 'Okay', 'Good', 'Great'];
    if (_isSubmittingMood) {
      return const Center(child: CircularProgressIndicator());
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_moodEmojis.length, (index) {
        final isSelected = _selectedMoodIndex == index;
        return GestureDetector(
          onTap: () => _submitMood(index),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.indigo : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Text(
                  _moodEmojis[index],
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                moodLabels[index],
                style: TextStyle(
                  fontSize: 12, 
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.indigo : Colors.grey
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildAppointmentCard(BuildContext context) {
    // Same as before
    final date = _parseAppointmentSlot(_nextAppointment!['slot']);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
        border: Border.all(color: Colors.indigo.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.calendar_month, color: Colors.indigo, size: 28),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_nextAppointment!['counsellor_id'] != null ? "Counsellor Assigned" : "Therapist",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text("${_formatDate(date!)} • ${_formatTime(date)}",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.indigo, borderRadius: BorderRadius.circular(20)),
            child: const Text("Join", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildGradientNavCard(BuildContext context, String title, IconData icon, List<Color> colors, VoidCallback onTap, {bool isLocked = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors.last.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                  if (isLocked) const Icon(Icons.lock, color: Colors.white54, size: 20),
                ],
              ),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // ... (Keep _buildQuoteCard, _showStreakDetails, _getGreeting, _parseAppointmentSlot, date helpers) ...
  // These helper functions remain identical to your existing file. 
  // Just paste them here or ensure they are present.
  
  Widget _buildQuoteCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: const Column(
        children: [
          Icon(Icons.format_quote, color: Colors.orange, size: 30),
          SizedBox(height: 10),
          Text(
            "\"Healing takes time, and asking for help is a courageous step.\"",
            textAlign: TextAlign.center,
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black87, fontSize: 14),
          ),
          SizedBox(height: 10),
          Text("- MindCare Daily", style: TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showStreakDetails() {
    // ... (Existing implementation) ...
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("🔥 Streak Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text("You have checked in for $_streakDays days in a row!", 
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text("Keep it up!", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  DateTime? _parseAppointmentSlot(dynamic value) {
    if (value is Timestamp) return value.toDate();
    return null;
  }
  
  String _formatDate(DateTime d) => "${_monthShort(d.month)} ${d.day}";
  String _formatTime(DateTime d) => "${d.hour % 12 == 0 ? 12 : d.hour % 12}:${d.minute.toString().padLeft(2, '0')} ${d.hour >= 12 ? 'PM' : 'AM'}";
  String _monthShort(int m) => ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][m - 1];
}

class StreakCard extends StatelessWidget {
  final int streakDays;
  final VoidCallback onTap;

  const StreakCard({super.key, required this.streakDays, required this.onTap});

  @override
  Widget build(BuildContext context) {
    double progress = (streakDays % 7) / 7; 
    if(progress == 0 && streakDays > 0) progress = 1.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)], 
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: const Color(0xFF4CA1AF).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 60, height: 60,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 6,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                  ),
                ),
                const Text("🔥", style: TextStyle(fontSize: 24)),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Daily Streak", 
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text("$streakDays Days", 
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
                  const SizedBox(height: 4),
                  const Text("Keep logging in to boost your mental hygiene!", 
                      style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}

class ContactSupportBanner extends StatelessWidget {
  const ContactSupportBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1), 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.support_agent, color: Colors.teal),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Need immediate help?", 
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                SizedBox(height: 2),
                Text("Call Hotline: +254 724 255 169", 
                    style: TextStyle(fontSize: 13, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}