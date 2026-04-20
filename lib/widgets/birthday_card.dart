import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/birthday.dart';

class BirthdayCard extends StatelessWidget {
  final Birthday birthday;

  const BirthdayCard({super.key, required this.birthday});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Calculate days until next occurrence
    DateTime nextOccurrence = DateTime(today.year, birthday.date.month, birthday.date.day);
    if (nextOccurrence.isBefore(today)) {
      nextOccurrence = DateTime(today.year + 1, birthday.date.month, birthday.date.day);
    }
    
    final daysUntil = nextOccurrence.difference(today).inDays;
    final isUpcoming = daysUntil <= 7;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isUpcoming ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5) : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRelationshipColor(birthday.relationship),
          child: const Icon(Icons.cake, color: Colors.white, size: 20),
        ),
        title: Text(
          birthday.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${DateFormat('MMMM d').format(birthday.date)} • ${birthday.relationship}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              daysUntil == 0 ? 'Today!' : '$daysUntil days',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: daysUntil == 0 ? Colors.red : null,
              ),
            ),
            const Text('left', style: TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Color _getRelationshipColor(String relationship) {
    switch (relationship.toLowerCase()) {
      case 'family':
        return Colors.redAccent;
      case 'friend':
        return Colors.blueAccent;
      case 'partner':
        return Colors.pinkAccent;
      default:
        return Colors.grey;
    }
  }
}
