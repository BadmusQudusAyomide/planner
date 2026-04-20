import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/event_provider.dart';
import '../providers/birthday_provider.dart';
import '../widgets/event_card.dart';
import '../widgets/birthday_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final events = ref.watch(eventListProvider);
    final birthdays = ref.read(birthdayListProvider.notifier).getUpcomingBirthdays(3);

    // Filter events for the next 7 days
    final upcomingEvents = events.where((e) {
      final diff = e.date.difference(DateTime(now.year, now.month, now.day)).inDays;
      return diff >= 0 && diff < 7;
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Dashboard'),
                Text(
                  DateFormat('EEEE, MMMM d').format(now),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context, 'This Week'),
                  const SizedBox(height: 8),
                  if (upcomingEvents.isEmpty)
                    const Text('No upcoming events this week.')
                  else
                    ...upcomingEvents.map((e) => EventCard(event: e)),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'Upcoming Birthdays'),
                  const SizedBox(height: 8),
                  if (birthdays.isEmpty)
                    const Text('No upcoming birthdays.')
                  else
                    ...birthdays.map((b) => BirthdayCard(birthday: b)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }
}
