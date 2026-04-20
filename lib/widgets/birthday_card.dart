import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/birthday.dart';

const _bg = Color(0xFF0D0703);
const _cardBg = Color(0xFF140A03);
const _surfaceBg = Color(0xFF1A0E06);
const _borderDim = Color(0xFF3D2410);
const _gold = Color(0xFFD4A017);
const _goldMid = Color(0xFFC8960C);
const _textWarm = Color(0xFFC9A47E);
const _textMuted = Color(0xFF6B4A2A);
const _textDim = Color(0xFF6B3A2A);

class BirthdayCard extends StatelessWidget {
  final Birthday birthday;

  const BirthdayCard({super.key, required this.birthday});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    var next = DateTime(today.year, birthday.date.month, birthday.date.day);
    if (next.isBefore(today)) {
      next = DateTime(today.year + 1, birthday.date.month, birthday.date.day);
    }

    final daysUntil = next.difference(today).inDays;
    final isToday = daysUntil == 0;
    final isSoon = daysUntil <= 7;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
          _buildInitial(),
          const SizedBox(width: 14),
          Expanded(child: _buildInfo()),
          const SizedBox(width: 8),
          _buildBadge(daysUntil, isToday, isSoon),
        ],
      ),
    );
  }

  Widget _buildInitial() {
    return Container(
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
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          birthday.name,
          style: GoogleFonts.dmSans(fontSize: 14, color: _textWarm),
        ),
        const SizedBox(height: 2),
        Text(
          '${birthday.relationship}  ·  ${DateFormat('MMMM d').format(birthday.date)}',
          style: GoogleFonts.dmSans(fontSize: 11, color: _textMuted),
        ),
      ],
    );
  }

  Widget _buildBadge(int days, bool isToday, bool isSoon) {
    final color = isToday ? _gold : isSoon ? _goldMid : _textDim;
    final bg = isToday || isSoon ? const Color(0xFF2A1208) : _surfaceBg;
    final border = isToday || isSoon ? color : _borderDim;

    final label = isToday
        ? 'Today!'
        : days == 1
        ? 'Tomorrow'
        : '$days days';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 0.5),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.dmSans(
          fontSize: 9,
          letterSpacing: 0.8,
          color: color,
        ),
      ),
    );
  }
}