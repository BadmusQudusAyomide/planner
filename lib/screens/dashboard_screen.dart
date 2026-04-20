import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/event_provider.dart';
import '../providers/birthday_provider.dart';
import '../models/event.dart';
import '../models/birthday.dart';

// ── Colors ──────────────────────────────────────────────────────────────────
const _bg = Color(0xFF0D0703);
const _cardBg = Color(0xFF140A03);
const _surfaceBg = Color(0xFF1A0E06);
const _borderDim = Color(0xFF3D2410);
const _borderDeep = Color(0xFF2A1208);
const _gold = Color(0xFFD4A017);
const _goldMid = Color(0xFFC8960C);
const _textWarm = Color(0xFFC9A47E);
const _textMuted = Color(0xFF6B4A2A);
const _textDim = Color(0xFF6B3A2A);
const _textFaint = Color(0xFF4A2E14);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final events = ref.watch(eventListProvider);
    final birthdays = ref.watch(birthdayListProvider);

    final upcomingEvents = events.where((e) {
      final today = DateTime(now.year, now.month, now.day);
      final diff = DateTime(e.date.year, e.date.month, e.date.day)
          .difference(today)
          .inDays;
      return diff >= 0 && diff < 7;
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final upcomingBirthdays = _getUpcomingBirthdays(birthdays, 3);
    final soonBirthdays = upcomingBirthdays.where((b) {
      return _daysUntilBirthday(b.date) <= 30;
    }).length;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, now),
              const SizedBox(height: 24),
              _buildTodayCard(context, now),
              const SizedBox(height: 16),
              _buildNotificationDebugCard(context, ref),
              const SizedBox(height: 16),
              _buildStatsRow(upcomingEvents.length, soonBirthdays),
              const SizedBox(height: 24),
              _buildSectionLabel('This week'),
              const SizedBox(height: 10),
      _buildEventsSection(context, upcomingEvents, now),
              const SizedBox(height: 24),
              _buildDivider(),
              const SizedBox(height: 20),
              _buildSectionLabel('Upcoming birthdays'),
              const SizedBox(height: 10),
              _buildBirthdaysSection(context, upcomingBirthdays, now),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, DateTime now) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 32,
                    color: _gold,
                    height: 1.1,
                  ),
                  children: const [
                    TextSpan(text: 'Hello, '),
                    TextSpan(
                      text: 'Ria',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    TextSpan(text: '  ✦'),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('EEEE, MMMM d, yyyy').format(now).toUpperCase(),
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  letterSpacing: 1.4,
                  color: _textMuted,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _gold, width: 1.5),
          ),
          child: Center(
            child: Text(
              'R',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 20,
                color: _gold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Today Card ─────────────────────────────────────────────────────────────

  Widget _buildTodayCard(BuildContext context, DateTime now) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: _surfaceBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderDim, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            now.day.toString(),
            style: GoogleFonts.cormorantGaramond(
              fontSize: 56,
              color: _gold,
              height: 1,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(
                  DateFormat('MMMM yyyy').format(now).toUpperCase(),
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    letterSpacing: 1.2,
                    color: _textMuted,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${DateFormat('EEEE').format(now)} — have a lovely day',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    color: _textDim,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _gold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationDebugCard(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _surfaceBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderDim, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NOTIFICATION CHECK',
            style: GoogleFonts.dmSans(
              fontSize: 10,
              letterSpacing: 1.4,
              color: _textMuted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Use this to test whether notifications display at all and whether scheduled reminders fire.',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: _textWarm,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildDebugButton(
                label: 'Show Now',
                onTap: () async {
                  try {
                    await ref
                        .read(notificationServiceProvider)
                        .showTestNotification();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Test notification sent immediately.'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Immediate test failed: $e'),
                        ),
                      );
                    }
                  }
                },
              ),
              _buildDebugButton(
                label: 'Schedule 5s',
                onTap: () async {
                  try {
                    await ref
                        .read(notificationServiceProvider)
                        .scheduleTestNotification();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Scheduled test notification for 5 seconds from now.',
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Scheduled test failed: $e'),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDebugButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _borderDim, width: 0.5),
        ),
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.dmSans(
            fontSize: 11,
            letterSpacing: 0.9,
            color: _gold,
          ),
        ),
      ),
    );
  }

  // ── Stats Row ──────────────────────────────────────────────────────────────

  Widget _buildStatsRow(int eventCount, int bdayCount) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(eventCount.toString(), 'events this week')),
        const SizedBox(width: 10),
        Expanded(child: _buildStatCard(bdayCount.toString(), 'birthdays soon')),
      ],
    );
  }

  Widget _buildStatCard(String number, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _surfaceBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderDim, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 30,
              color: _gold,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.dmSans(
              fontSize: 10,
              letterSpacing: 1.1,
              color: _textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Label ──────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.dmSans(
        fontSize: 10,
        letterSpacing: 1.6,
        color: _textMuted,
      ),
    );
  }

  // ── Events ─────────────────────────────────────────────────────────────────

  Widget _buildEventsSection(
      BuildContext context, List<Event> events, DateTime now) {
    if (events.isEmpty) {
      return Text(
        'No events this week.',
        style: GoogleFonts.cormorantGaramond(
          fontSize: 14,
          fontStyle: FontStyle.italic,
          color: _textFaint,
        ),
      );
    }
    return Column(
      children: events
          .map((e) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _buildEventCard(context, e, now),
      ))
          .toList(),
    );
  }

  Widget _buildEventCard(BuildContext context, Event event, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(event.date.year, event.date.month, event.date.day);
    final diff = eventDay.difference(today).inDays;

    final String dayLabel;
    final Color dotColor;

    if (diff == 0) {
      dayLabel = 'Today';
      dotColor = _goldMid;
    } else if (diff == 1) {
      dayLabel = 'Tmr';
      dotColor = _gold;
    } else {
      dayLabel = DateFormat('EEE').format(event.date);
      dotColor = _textDim;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderDim, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: GoogleFonts.dmSans(fontSize: 14, color: _textWarm),
                ),
                if (event.time != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    Event.formatStoredTime(context, event.time) ?? event.time!,
                    style: GoogleFonts.dmSans(fontSize: 11, color: _textMuted),
                  ),
                ],
              ],
            ),
          ),
          Text(
            dayLabel.toUpperCase(),
            style: GoogleFonts.dmSans(
              fontSize: 11,
              letterSpacing: 0.8,
              color: _textDim,
            ),
          ),
        ],
      ),
    );
  }

  // ── Birthdays ──────────────────────────────────────────────────────────────

  Widget _buildBirthdaysSection(
      BuildContext context, List<Birthday> birthdays, DateTime now) {
    if (birthdays.isEmpty) {
      return Text(
        'No upcoming birthdays.',
        style: GoogleFonts.cormorantGaramond(
          fontSize: 14,
          fontStyle: FontStyle.italic,
          color: _textFaint,
        ),
      );
    }
    return Column(
      children: birthdays
          .map((b) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _buildBirthdayCard(b),
      ))
          .toList(),
    );
  }

  Widget _buildBirthdayCard(Birthday birthday) {
    final days = _daysUntilBirthday(birthday.date);
    final isSoon = days <= 14;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderDim, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _gold, width: 0.5),
            ),
            child: Center(
              child: Text(
                birthday.name[0].toUpperCase(),
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 16,
                  color: _gold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  birthday.name,
                  style: GoogleFonts.dmSans(fontSize: 14, color: _textWarm),
                ),
                const SizedBox(height: 1),
                Text(
                  '${birthday.relationship} · ${DateFormat('MMM d').format(birthday.date)}',
                  style: GoogleFonts.dmSans(fontSize: 11, color: _textMuted),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isSoon ? const Color(0xFF2A1208) : _surfaceBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSoon ? _gold : _borderDim,
                width: 0.5,
              ),
            ),
            child: Text(
              days == 0 ? 'Today!' : '$days days',
              style: GoogleFonts.dmSans(
                fontSize: 10,
                letterSpacing: 0.8,
                color: isSoon ? _gold : _textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Divider ────────────────────────────────────────────────────────────────

  Widget _buildDivider() {
    return Container(height: 0.5, color: _borderDeep);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  int _daysUntilBirthday(DateTime birthDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var next = DateTime(now.year, birthDate.month, birthDate.day);
    if (next.isBefore(today)) {
      next = DateTime(now.year + 1, birthDate.month, birthDate.day);
    }
    return next.difference(today).inDays;
  }

  List<Birthday> _getUpcomingBirthdays(List<Birthday> birthdays, int limit) {
    final sorted = [...birthdays]
      ..sort((a, b) =>
          _daysUntilBirthday(a.date)
              .compareTo(_daysUntilBirthday(b.date)));
    return sorted.take(limit).toList();
  }
}
