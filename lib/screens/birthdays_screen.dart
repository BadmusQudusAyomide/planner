import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/birthday_provider.dart';
import '../models/birthday.dart';
import 'add_birthday_screen.dart';

const _bg = Color(0xFF0D0703);
const _cardBg = Color(0xFF140A03);
const _surfaceBg = Color(0xFF1A0E06);
const _borderDim = Color(0xFF3D2410);
const _gold = Color(0xFFD4A017);
const _textWarm = Color(0xFFC9A47E);
const _textMuted = Color(0xFF6B4A2A);
const _textDim = Color(0xFF6B3A2A);
const _textFaint = Color(0xFF4A2E14);

class BirthdaysScreen extends ConsumerWidget {
  const BirthdaysScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final birthdays = ref.watch(birthdayListProvider);

    // sort by days until next birthday
    final sorted = [...birthdays]
      ..sort((a, b) =>
          _daysUntilBirthday(a.date)
              .compareTo(_daysUntilBirthday(b.date)));

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(sorted.length, context),
            const SizedBox(height: 8),
            Expanded(
              child: sorted.isEmpty
                  ? _buildEmpty()
                  : _buildList(sorted, context, ref),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader(int count, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Birthdays',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 32,
                    color: _gold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count ${count == 1 ? 'person' : 'people'} saved'.toUpperCase(),
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    letterSpacing: 1.4,
                    color: _textMuted,
                  ),
                ),
              ],
            ),
          ),
          _buildAddButton(context),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddBirthdayScreen()),
        );
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: _surfaceBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderDim, width: 0.5),
        ),
        child: const Icon(Icons.add, color: _gold, size: 20),
      ),
    );
  }

  // ── List ─────────────────────────────────────────────────────────────────

  Widget _buildList(List<Birthday> birthdays, BuildContext context, WidgetRef ref) {
    // group into "soon" (<=30 days) and "later"
    final soon = birthdays.where((b) => _daysUntilBirthday(b.date) <= 30).toList();
    final later = birthdays.where((b) => _daysUntilBirthday(b.date) > 30).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
      children: [
        if (soon.isNotEmpty) ...[
          _buildGroupLabel('Coming up'),
          const SizedBox(height: 10),
          ...soon.map((b) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildDismissible(b, context, ref),
          )),
          const SizedBox(height: 20),
        ],
        if (later.isNotEmpty) ...[
          _buildGroupLabel('Later this year'),
          const SizedBox(height: 10),
          ...later.map((b) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildDismissible(b, context, ref),
          )),
        ],
      ],
    );
  }

  Widget _buildGroupLabel(String label) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.dmSans(
            fontSize: 10,
            letterSpacing: 1.6,
            color: _textMuted,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(height: 0.5, color: _borderDim),
        ),
      ],
    );
  }

  // ── Dismissible wrapper ───────────────────────────────────────────────────

  Widget _buildDismissible(Birthday birthday, BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(birthday.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF3D0A0A),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.delete_outline,
            color: Color(0xFFE24B4A), size: 20),
      ),
      onDismissed: (_) {
        ref.read(birthdayListProvider.notifier).deleteBirthday(birthday.id);
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddBirthdayScreen(birthday: birthday),
            ),
          );
        },
        child: _buildBirthdayTile(birthday),
      ),
    );
  }

  // ── Birthday Tile ─────────────────────────────────────────────────────────

  Widget _buildBirthdayTile(Birthday birthday) {
    final days = _daysUntilBirthday(birthday.date);
    final isToday = days == 0;
    final isSoon = days <= 7;

    final badgeColor = isToday
        ? _gold
        : isSoon
        ? const Color(0xFFC8960C)
        : _textDim;

    final badgeBg = isToday
        ? const Color(0xFF2A1208)
        : isSoon
        ? const Color(0xFF1F0E04)
        : _surfaceBg;

    final badgeBorder = isToday || isSoon ? badgeColor : _borderDim;

    final badgeText = isToday
        ? '🎂 today'
        : days == 1
        ? 'tomorrow'
        : '$days days';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isToday ? _gold : _borderDim,
          width: isToday ? 1 : 0.5,
        ),
      ),
      child: Row(
        children: [
          // initial circle
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _gold, width: 0.5),
            ),
            child: Center(
              child: Text(
                birthday.name[0].toUpperCase(),
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 18,
                  color: _gold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // name + meta
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  birthday.name,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: _textWarm,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${birthday.relationship}  ·  ${DateFormat('MMMM d').format(birthday.date)}',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: _textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: badgeBorder, width: 0.5),
            ),
            child: Text(
              badgeText.toUpperCase(),
              style: GoogleFonts.dmSans(
                fontSize: 9,
                letterSpacing: 0.8,
                color: badgeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────────────────────

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '✦',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 28,
              color: _borderDim,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No birthdays added yet.',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: _textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap + to add someone special.',
            style: GoogleFonts.dmSans(fontSize: 12, color: _textDim),
          ),
        ],
      ),
    );
  }


  // ── Helper ────────────────────────────────────────────────────────────────

  int _daysUntilBirthday(DateTime birthDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var next = DateTime(now.year, birthDate.month, birthDate.day);
    if (next.isBefore(today)) {
      next = DateTime(now.year + 1, birthDate.month, birthDate.day);
    }
    return next.difference(today).inDays;
  }
}
