import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../providers/event_provider.dart';

const _bg = Color(0xFF0D0703);
const _cardBg = Color(0xFF140A03);
const _surfaceBg = Color(0xFF1A0E06);
const _borderDim = Color(0xFF3D2410);
const _gold = Color(0xFFD4A017);
const _textWarm = Color(0xFFC9A47E);
const _textMuted = Color(0xFF6B4A2A);
const _textDim = Color(0xFF6B3A2A);

class AddEventScreen extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  final Event? event;
  const AddEventScreen({super.key, required this.selectedDate, this.event});

  @override
  ConsumerState<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends ConsumerState<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late DateTime _date;
  TimeOfDay? _time;
  String _tag = 'Personal';

  bool get _isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _date = widget.event?.date ?? widget.selectedDate;
    _tag = widget.event?.tag ?? 'Personal';
    _time = Event.parseStoredTime(widget.event?.time);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                  children: [
                    _buildTitleField(),
                    const SizedBox(height: 16),
                    _buildDateTile(context),
                    const SizedBox(height: 8),
                    _buildTimeTile(context),
                    const SizedBox(height: 24),
                    _buildTagSection(),
                    const SizedBox(height: 40),
                    _buildSaveButton(context),
                  ],
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
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _surfaceBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _borderDim, width: 0.5),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: _textMuted, size: 14),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? 'Edit Event' : 'New Event',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 28,
                    color: _gold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Text(
                  DateFormat('MMMM d, yyyy').format(_date).toUpperCase(),
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    letterSpacing: 1.4,
                    color: _textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (_isEditing)
            GestureDetector(
              onTap: () {
                ref.read(eventListProvider.notifier).deleteEvent(widget.event!.id);
                Navigator.pop(context);
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A0808),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF4D1414), width: 0.5),
                ),
                child: const Icon(Icons.delete_outline,
                    color: Color(0xFFE24B4A), size: 18),
              ),
            ),
        ],
      ),
    );
  }

  // ── Title Field ───────────────────────────────────────────────────────────

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Event title'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          style: GoogleFonts.dmSans(fontSize: 14, color: _textWarm),
          cursorColor: _gold,
          decoration: InputDecoration(
            hintText: 'e.g. Doctor\'s appointment',
            hintStyle: GoogleFonts.dmSans(fontSize: 14, color: _textDim),
            filled: true,
            fillColor: _cardBg,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _borderDim, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _gold, width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
              const BorderSide(color: Color(0xFFE24B4A), width: 0.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
              const BorderSide(color: Color(0xFFE24B4A), width: 1),
            ),
            errorStyle: GoogleFonts.dmSans(
                fontSize: 11, color: const Color(0xFFE24B4A)),
          ),
          validator: (value) =>
          value == null || value.trim().isEmpty ? 'Title is required' : null,
        ),
      ],
    );
  }

  // ── Date Tile ─────────────────────────────────────────────────────────────

  Widget _buildDateTile(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Date'),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _date,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              builder: (context, child) => _datePickerTheme(child),
            );
            if (picked != null) {
              setState(() {
                _date = picked;
              });
            }
          },
          child: Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _borderDim, width: 0.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    color: _textMuted, size: 16),
                const SizedBox(width: 12),
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(_date),
                  style:
                  GoogleFonts.dmSans(fontSize: 14, color: _textWarm),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right,
                    color: _textDim, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Time Tile ─────────────────────────────────────────────────────────────

  Widget _buildTimeTile(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Time  (optional)'),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: _time ?? TimeOfDay.now(),
              builder: (context, child) => _datePickerTheme(child),
            );
            if (picked != null) setState(() => _time = picked);
          },
          child: Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _borderDim, width: 0.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time_outlined,
                    color: _textMuted, size: 16),
                const SizedBox(width: 12),
                Text(
                  _time?.format(context) ?? 'No time set',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: _time != null ? _textWarm : _textDim,
                  ),
                ),
                const Spacer(),
                if (_time != null)
                  GestureDetector(
                    onTap: () => setState(() => _time = null),
                    child: const Icon(Icons.close,
                        color: _textDim, size: 16),
                  )
                else
                  const Icon(Icons.chevron_right,
                      color: _textDim, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Tag Section ───────────────────────────────────────────────────────────

  Widget _buildTagSection() {
    const tags = ['Personal', 'Work', 'Other'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Tag'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags.map((tag) {
            final selected = _tag == tag;
            return GestureDetector(
              onTap: () => setState(() => _tag = tag),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFF2A1208) : _cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? _gold : _borderDim,
                    width: selected ? 1 : 0.5,
                  ),
                ),
                child: Text(
                  tag.toUpperCase(),
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    letterSpacing: 0.8,
                    color: selected ? _gold : _textMuted,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Save Button ───────────────────────────────────────────────────────────

  Widget _buildSaveButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (_formKey.currentState!.validate()) {
          if (_isEditing) {
            final updatedEvent = Event(
              id: widget.event!.id,
              title: _titleController.text.trim(),
              date: _date,
              time: Event.serializeTimeOfDay(_time),
              tag: _tag,
            );
            await ref.read(eventListProvider.notifier).updateEvent(updatedEvent);
          } else {
            final event = Event.create(
              title: _titleController.text.trim(),
              date: _date,
              time: Event.serializeTimeOfDay(_time),
              tag: _tag,
            );
            await ref.read(eventListProvider.notifier).addEvent(event);
          }
          if (mounted) {
            Navigator.pop(context);
          }
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _gold,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            _isEditing ? 'UPDATE EVENT' : 'SAVE EVENT',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w500,
              color: _bg,
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _buildFieldLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.dmSans(
        fontSize: 10,
        letterSpacing: 1.4,
        color: _textMuted,
      ),
    );
  }

  Widget _datePickerTheme(Widget? child) {
    return Theme(
      data: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: _gold,
          onPrimary: _bg,
          surface: _surfaceBg,
          onSurface: _textWarm,
        ),
        dialogBackgroundColor: _bg,
      ),
      child: child!,
    );
  }
}
