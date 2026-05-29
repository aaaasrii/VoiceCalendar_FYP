import 'package:flutter/material.dart';

class UpcomingEventsScreen extends StatelessWidget {
  // Add this list to accept dynamic data
  final List<Map<String, dynamic>>? events;

  const UpcomingEventsScreen({super.key, this.events});

  @override
  Widget build(BuildContext context) {
    // If no events are passed, we use your original hardcoded ones as a fallback
    final displayEvents =
        events ??
        [
          {
            "title": "FYP Proposal Submission",
            "desc": "Due in 2 days",
            "color": Colors.red,
          },
          {
            "title": "Project Presentation",
            "desc": "In 15 days",
            "color": Colors.orange,
          },
        ];

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: const Text(
          "Upcoming Events",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF3DA4FF),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: displayEvents.length,
        itemBuilder: (context, index) {
          final event = displayEvents[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: _eventCard(event['title'], event['desc'], event['color']),
          );
        },
      ),
    );
  }

  Widget _eventCard(String title, String desc, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc, style: TextStyle(color: color)),
        trailing: const Icon(
          Icons.calendar_today,
          size: 20,
          color: Color(0xFF3DA4FF),
        ),
      ),
    );
  }
}
