import 'package:flutter/foundation.dart'; // NEW: Required for Windows/Android platform checking!
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voca_assist/globals.dart' as globals;

// --- FIREBASE IMPORTS ---
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'firebase_options.dart';

// ------------------------

// Screen imports
import 'package:voca_assist/screens/welcome_screen.dart';
import 'package:voca_assist/screens/registration_screen.dart';
import 'package:voca_assist/screens/chat_screen.dart';
import 'package:voca_assist/screens/calendar_screen.dart';
import 'package:voca_assist/screens/events_screen.dart';
import 'package:voca_assist/screens/event_details.dart';
import 'package:voca_assist/screens/profile_screen.dart';
import 'package:voca_assist/screens/speech_to_text.dart';

final model = FirebaseAI.googleAI().generativeModel(
  model:
      'gemini-1.5-flash', // Note: I changed this to 1.5-flash as it's the stable model.
);

// --- THE FIX IS HERE ---
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ADDED: Platform safe check. Windows won't crash now!
  if (!kIsWeb) {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await FirebaseAppCheck.instance.activate(
        providerAndroid: AndroidDebugProvider(),
      );
      debugPrint("App Check activated for Android (Debug)");
    } else {
      // For Windows, Web, or iOS
      await FirebaseAppCheck.instance.activate();
      debugPrint("App Check skipped or default used for non-Android platform");
    }
  }

  runApp(const VocaAssist());
}

class VocaAssist extends StatefulWidget {
  const VocaAssist({super.key});

  @override
  State<VocaAssist> createState() => _VocaAssistState();
}

class _VocaAssistState extends State<VocaAssist> {
  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  Future<void> loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      globals.loggedInUsername = prefs.getString('saved_username') ?? "User";
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Voca-Assist',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        primaryColor: const Color(0xFF3DA4FF),
        useMaterial3: true,
      ),
      // We start directly on the speech test screen
      initialRoute: '/chat',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/speech': (context) => SpeechToTextScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/chat': (context) =>
            const ChatScreen(), // Kept commented out for now so you can test!
        '/calendar': (context) => const CalendarScreen(),
        '/events': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as List<Map<String, dynamic>>?;
          return UpcomingEventsScreen(events: args);
        },
        '/profile': (context) => const ProfileSpeechScreen(),
        '/event-details': (context) => EventDetailScreen(
          title: "Sample Event",
          dueDate: DateTime(2026, 4, 22),
        ),
      },
    );
  }
}
