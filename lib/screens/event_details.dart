import 'package:flutter/material.dart';

class EventDetailScreen extends StatefulWidget {
  final String title;
  final DateTime dueDate;

  const EventDetailScreen({
    super.key,
    required this.title,
    required this.dueDate,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  Color getBackgroundColor() {
    final now = DateTime.now();
    final difference = widget.dueDate.difference(now).inDays;

    if (difference <= 7) return const Color(0xFFFF4B4B); // Red
    if (difference <= 30) return const Color(0xFFFFB74D); // Orange
    return const Color(0xFF66BB6A); // Green
  }

  // Navigation function to go back to Chat
  void _backToChat() {
    // If you used named routes in main.dart:
    Navigator.pushNamedAndRemoveUntil(context, '/chat', (route) => false);

    // OR if you just want to go back:
    // Navigator.pop(context);
  }

  Future<void> _showEditConfirmation() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Changes'),
          content: const Text(
            'Are you sure you want to save the changes to this appointment?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text(
                'Yes',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Appointment Updated!")),
                );
                // After updating, you might want to return to Chat
                _backToChat();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [getBackgroundColor(), Colors.white.withValues(alpha: 0.1)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.black12,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 18,
                          color: Colors.black,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Text(
                "Duedate : ${widget.dueDate.day}/${widget.dueDate.month}/${widget.dueDate.year}",
              ),
              const SizedBox(height: 40),

              // The White Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "It almost your due date ! ! !",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "A reminder can help you stay on track.",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    _actionButton(
                      "Keep reminding",
                      const Color(0xFF0081FF),
                      Colors.white,
                      _backToChat, // Navigates back to Chat
                    ),
                    _actionButton(
                      "Remind me later",
                      Colors.grey[300]!,
                      Colors.black,
                      _showEditConfirmation,
                    ),
                    _actionButton(
                      "Completed",
                      Colors.grey[300]!,
                      Colors.black,
                      () {
                        // Logic for completion then back to chat
                        _backToChat();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton(
    String label,
    Color bg,
    Color text,
    VoidCallback onPress,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          onPressed: onPress,
          child: Text(
            label,
            style: TextStyle(color: text, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
