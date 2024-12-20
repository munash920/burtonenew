import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UpcomingEventsCard extends StatelessWidget {
  const UpcomingEventsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upcoming Events',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to calendar view
                  },
                  child: const Text('View Calendar'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildEventList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEventList() {
    // This would typically come from a provider or database
    final events = [
      _Event(
        title: 'Tax Return Deadline',
        date: DateTime.now().add(const Duration(days: 5)),
        type: EventType.deadline,
        clientCount: 15,
      ),
      _Event(
        title: 'Company Registration Workshop',
        date: DateTime.now().add(const Duration(days: 7)),
        type: EventType.workshop,
      ),
      _Event(
        title: 'Client Meeting - ABC Corp',
        date: DateTime.now().add(const Duration(days: 2)),
        type: EventType.meeting,
      ),
      _Event(
        title: 'Monthly Reports Due',
        date: DateTime.now().add(const Duration(days: 10)),
        type: EventType.deadline,
        clientCount: 8,
      ),
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return _EventTile(event: event);
      },
    );
  }
}

class _EventTile extends StatelessWidget {
  final _Event event;

  const _EventTile({required this.event});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: event.type.color.withOpacity(0.2),
        child: Icon(
          event.type.icon,
          color: event.type.color,
        ),
      ),
      title: Text(event.title),
      subtitle: Text(
        DateFormat('MMM dd, yyyy').format(event.date),
        style: TextStyle(color: Colors.grey[600]),
      ),
      trailing: event.clientCount != null
          ? Chip(
              label: Text('${event.clientCount} clients'),
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            )
          : null,
    );
  }
}

class _Event {
  final String title;
  final DateTime date;
  final EventType type;
  final int? clientCount;

  _Event({
    required this.title,
    required this.date,
    required this.type,
    this.clientCount,
  });
}

enum EventType {
  deadline(Icons.warning_rounded, Colors.red),
  meeting(Icons.people, Colors.blue),
  workshop(Icons.school, Colors.orange);

  final IconData icon;
  final Color color;

  const EventType(this.icon, this.color);
} 