import 'package:cloud_firestore/cloud_firestore.dart';

/// Run this function ONCE to populate your database with dummy resources.
Future<void> seedDatabase() async {
  final firestore = FirebaseFirestore.instance;
  final batch = firestore.batch();

  final List<Map<String, dynamic>> resources = [
    {
      'category': 'Anxiety',
      'title': 'The 5-4-3-2-1 Grounding Technique',
      'body': '''When you feel anxious or panic setting in, use this grounding technique to bring you back to the present moment:

1. Acknowledge 5 things you see around you.
2. Acknowledge 4 things you can touch.
3. Acknowledge 3 things you hear.
4. Acknowledge 2 things you can smell.
5. Acknowledge 1 thing you can taste.

This exercise shifts your focus from internal worries to your external environment, helping to calm your nervous system.'''
    },
    {
      'category': 'Exams',
      'title': 'Smart Study Strategies for Finals',
      'body': '''Cramming causes stress. Try these proven techniques instead:

1. The Pomodoro Technique: Study for 25 minutes, then take a 5-minute break. After 4 cycles, take a longer break.
2. Active Recall: Don't just re-read notes. Close your book and try to recite what you learned.
3. Teach It: Try to explain the concept to an imaginary classroom. If you can't explain it simply, you don't understand it well enough yet.'''
    },
    {
      'category': 'Burnout',
      'title': 'Recognizing the 3 Signs of Burnout',
      'body': '''Burnout isn't just "being tired." It is a state of emotional, physical, and mental exhaustion. Watch for these three signs:

1. Exhaustion: You feel drained all the time, even after sleeping.
2. Detachment: You feel cynical about your schoolwork or disconnected from friends.
3. Inefficacy: You feel like nothing you do makes a difference or that you can't cope.

If you spot these, it is time to stop pushing and start resting.'''
    },
    {
      'category': 'Stress',
      'title': 'Progressive Muscle Relaxation (PMR)',
      'body': '''Physical tension is a common side effect of mental stress. PMR helps release that tension.

How to do it:
Lie down in a quiet place. Start with your toes. Tense the muscles in your toes as hard as you can for 5 seconds, then release suddenly. Feel the tension leave.

Move up to your calves, thighs, stomach, hands, shoulders, and finally your face. Tense and release each group. This signals to your brain that it is safe to relax.'''
    },
    {
      'category': 'Wellness',
      'title': 'Why Sleep Hygiene Matters',
      'body': '''Sleep is when your brain processes emotions and memories. Poor sleep equals poor mental health.

Tips for better sleep hygiene:
- No screens 1 hour before bed (blue light tricks your brain into thinking it's daytime).
- Keep your room cool and dark.
- Stick to a routine: Go to bed and wake up at the same time, even on weekends.
- Avoid caffeine after 2 PM.'''
    },
  ];

  for (var doc in resources) {
    final newDoc = firestore.collection('resources').doc();
    batch.set(newDoc, {
      ...doc,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  await batch.commit();
  print("✅ 5 Resources successfully uploaded to Firestore!");
}