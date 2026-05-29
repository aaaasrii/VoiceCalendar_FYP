import 'package:flutter/material.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Schedule"),
        backgroundColor: const Color(0xFF3DA4FF),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Placeholder for the Calendar Widget
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: Column(
              children: [
                const Text(
                  "April 2026",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                // This is a placeholder grid representing a calendar
                GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                  ),
                  itemCount: 30,
                  itemBuilder: (context, index) =>
                      Center(child: Text("${index + 1}")),
                ),
              ],
            ),
          ),
          const Expanded(
            child: Center(child: Text("Select a date to see AI reminders")),
          ),
        ],
      ),
    );
  }
}
