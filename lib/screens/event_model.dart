import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:voca_assist/globals.dart' as globals;
import 'package:intl/intl.dart'; // Helps format the date nicely

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Upcoming Events",
          style: TextStyle(
            color: Color(0xFF5E5E8C),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF5E5E8C)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // 1. Point directly to your 'events' collection
        stream: FirebaseFirestore.instance
            .collection('events')
            .where(
              'user',
              isEqualTo: globals.loggedInUsername,
            ) // Only show this user's events
            .orderBy('date') // Sort by date
            .snapshots(),
        builder: (context, snapshot) {
          // If loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // If no data or empty
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No events scheduled yet.\nTry asking Voca-Assist to set one!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          // Build the list of events
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              // Safely get the title and date
              final title = data['title'] ?? 'No Title';
              final date = (data['date'] as Timestamp).toDate();

              // Format the date to look nice (e.g., "Jun 15, 2024")
              final formattedDate = DateFormat('MMM dd, yyyy').format(date);

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFD1FFDA),
                    child: Icon(Icons.event, color: Color(0xFF3DA4FF)),
                  ),
                  title: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    formattedDate,
                    style: const TextStyle(color: Colors.blueAccent),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    onPressed: () {
                      // Bonus feature for your FYP: Delete an event!
                      FirebaseFirestore.instance
                          .collection('events')
                          .doc(docs[index].id)
                          .delete();
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
