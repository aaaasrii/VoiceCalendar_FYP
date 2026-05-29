import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Spacer(flex: 2),
          // Logo Placeholder
          Center(
            child: Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.mic, size: 80, color: Colors.blue),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "Welcome to Voca-Assist !",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text(
            "YOUR PERSONAL ASSISTANT",
            style: TextStyle(color: Colors.grey, letterSpacing: 1.5),
          ),
          const Spacer(),
          const Text(
            "“Your Day, Just a Voice Away.”",
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3DA4FF),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () async {
                // --- FIREBASE TEST START ---
                try {
                  // ignore: avoid_print
                  print("📡 Attempting to connect to Firebase...");
                  await FirebaseFirestore.instance
                      .collection('connection_test')
                      .add({
                        'status': 'Connection Successful!',
                        'developer': 'M. Isyraq',
                        'timestamp': FieldValue.serverTimestamp(),
                      });
                  // ignore: avoid_print
                  print("✅ SUCCESS: Data sent to Cloud Firestore!");
                } catch (e) {
                  // ignore: avoid_print
                  print("❌ ERROR: Could not send data: $e");
                }
                // --- FIREBASE TEST END ---

                // THE FIX: Check if the context is still valid after the 'await'
                if (!context.mounted) return;

                Navigator.pushNamed(context, '/register');
              },
              child: const Text(
                "Get Started",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}
