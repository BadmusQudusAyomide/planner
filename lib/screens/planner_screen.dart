import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/event_provider.dart';
import '../models/event.dart';
import 'add_event_screen.dart';

const _bg = Color(0xFF0D0703);
const _cardBg = Color(0xFF140A03);
const _surfaceBg = Color(0xFF1A0E06);
const _borderDim = Color(0xFF3D2410);
const _gold = Color(0xFFD4A017);
const _goldMid = Color(0xFFC8960C);
const _textWarm = Color(0xFFC9A47E);
const _textMuted = Color(0xFF6B4A2A);
const _textDim = Color(0xFF6B3A2A);

class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime(
      _focusedDay.year,
      _focusedDay.month,
      _focusedDay.day,
    );
  }

  @override
  Widget build(BuildContext context) {
    // watch the list so UI rebuilds when events change
    ref.watch(eventListProvider);
    final eventNotifier = ref.read(eventListProvider.notifier);
    final selectedEvents =
    eventNotifier.getEventsForDay(_selectedDay ?? _focusedDay);

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  _buildCalendar(eventNotifier),
                  _buildDayLabel(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            selectedEvents.isEmpty
                ? SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmpty(),
            )
                : SliverPadding(
              padding: const EdgeInsets.only(bottom: 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final event = selectedEvents[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 4),
                      child: Dismissible(
                        key: Key(event.id),
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
                          ref
                              .read(eventListProvider.notifier)
                              .deleteEvent(event.id);
                        },
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddEventScreen(
                                  selectedDate: event.date,
                                  event: event,
                                ),
                              ),
                            );
                          },
                          child: _buildEventTile(event),
                        ),
                      ),
                    );
                  },
                  childCount: selectedEvents.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
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
                  'Planner',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 32,
                    color: _gold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('MMMM yyyy').format(_focusedDay).toUpperCase(),
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
          MaterialPageRoute(
            builder: (_) => AddEventScreen(
              selectedDate: _selectedDay ?? _focusedDay,
            ),
          ),
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

  // ── Calendar ─────────────────────────────────────────────────────────────

  Widget _buildCalendar(eventNotifier) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
      child: Container(
        decoration: BoxDecoration(
          color: _surfaceBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _borderDim, width: 0.5),
        ),
        child: TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = DateTime(
                selectedDay.year,
                selectedDay.month,
                selectedDay.day,
              );
              _focusedDay = focusedDay;
            });
          },
          onFormatChanged: (format) {
            setState(() => _calendarFormat = format);
          },
          onPageChanged: (focusedDay) {
            setState(() => _focusedDay = focusedDay);
          },
          eventLoader: (day) => eventNotifier.getEventsForDay(day),
          headerStyle: HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
            formatButtonDecoration: BoxDecoration(
              border: Border.all(color: _borderDim, width: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            formatButtonTextStyle: GoogleFonts.dmSans(
              fontSize: 11,
              color: _textMuted,
            ),
            titleTextStyle: GoogleFonts.dmSans(
              fontSize: 13,
              letterSpacing: 1.0,
              color: _textWarm,
            ),
            leftChevronIcon:
            const Icon(Icons.chevron_left, color: _textMuted, size: 20),
            rightChevronIcon:
            const Icon(Icons.chevron_right, color: _textMuted, size: 20),
            headerPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: GoogleFonts.dmSans(
              fontSize: 11,
              color: _textMuted,
              letterSpacing: 0.5,
            ),
            weekendStyle: GoogleFonts.dmSans(
              fontSize: 11,
              color: _textDim,
              letterSpacing: 0.5,
            ),
          ),
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            defaultTextStyle:
            GoogleFonts.dmSans(fontSize: 13, color: _textWarm),
            weekendTextStyle:
            GoogleFonts.dmSans(fontSize: 13, color: _textWarm),
            todayDecoration: BoxDecoration(
              border: Border.all(color: _gold, width: 1),
              shape: BoxShape.circle,
            ),
            todayTextStyle:
            GoogleFonts.dmSans(fontSize: 13, color: _gold),
            selectedDecoration: const BoxDecoration(
              color: _gold,
              shape: BoxShape.circle,
            ),
            selectedTextStyle: GoogleFonts.dmSans(
              fontSize: 13,
              color: Color(0xFF0D0703),
              fontWeight: FontWeight.w500,
            ),
            markerDecoration: const BoxDecoration(
              color: _goldMid,
              shape: BoxShape.circle,
            ),
            markerSize: 4,
            markersMaxCount: 3,
            cellMargin: const EdgeInsets.all(4),
          ),
        ),
      ),
    );
  }

  // ── Day Label ─────────────────────────────────────────────────────────────

  Widget _buildDayLabel() {
    final day = _selectedDay ?? _focusedDay;
    final isToday = isSameDay(day, DateTime.now());
    final label = isToday
        ? 'Today'
        : DateFormat('EEEE, MMMM d').format(day);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
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
      ),
    );
  }

  // ── Event List ────────────────────────────────────────────────────────────

  Widget _buildEventList(List<Event> events) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 100),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Dismissible(
            key: Key(event.id),
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
              ref.read(eventListProvider.notifier).deleteEvent(event.id);
            },
            child: _buildEventTile(event),
          ),
        );
      },
    );
  }

  Widget _buildEventTile(Event event) {
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
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _gold,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style:
                  GoogleFonts.dmSans(fontSize: 14, color: _textWarm),
                ),
                if (event.time != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    event.time!,
                    style: GoogleFonts.dmSans(
                        fontSize: 11, color: _textMuted),
                  ),
                ],
              ],
            ),
          ),
          if (event.tag != null)
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _surfaceBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _borderDim, width: 0.5),
              ),
              child: Text(
                event.tag!.toUpperCase(),
                style: GoogleFonts.dmSans(
                  fontSize: 9,
                  letterSpacing: 0.8,
                  color: _textMuted,
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
            'Nothing planned for this day.',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: _textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap + to add an event.',
            style: GoogleFonts.dmSans(fontSize: 12, color: _textDim),
          ),
        ],
      ),
    );
  }

}