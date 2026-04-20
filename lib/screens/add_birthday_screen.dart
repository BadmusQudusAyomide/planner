import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/birthday.dart';
import '../providers/birthday_provider.dart';

const _bg = Color(0xFF0D0703);
const _cardBg = Color(0xFF140A03);
const _surfaceBg = Color(0xFF1A0E06);
const _borderDim = Color(0xFF3D2410);
const _gold = Color(0xFFD4A017);
const _textWarm = Color(0xFFC9A47E);
const _textMuted = Color(0xFF6B4A2A);
const _textDim = Color(0xFF6B3A2A);

class AddBirthdayScreen extends ConsumerStatefulWidget {
  final Birthday? birthday;
  const AddBirthdayScreen({super.key, this.birthday});

  @override
  ConsumerState<AddBirthdayScreen> createState() => _AddBirthdayScreenState();
}

class _AddBirthdayScreenState extends ConsumerState<AddBirthdayScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late DateTime _date;
  late String _relationship;
  late bool _includeYear;

  bool get _isEditing => widget.birthday != null;

  static const _relationships = ['Friend', 'Family', 'Partner', 'Other'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.birthday?.name ?? '');
    _date = widget.birthday?.date ?? DateTime.now();
    _relationship = widget.birthday?.relationship ?? 'Friend';
    _includeYear = widget.birthday?.includeYear ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
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
                    _buildNameField(),
                    const SizedBox(height: 16),
                    _buildDateTile(context),
                    const SizedBox(height: 12),
                    _buildYearToggle(),
                    const SizedBox(height: 24),
                    _buildRelationshipSection(),
                    const SizedBox(height: 40),
                    _buildPreviewCard(),
                    const SizedBox(height: 24),
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
                  _isEditing ? 'Edit Birthday' : 'Add Birthday',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 28,
                    color: _gold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Text(
                  _isEditing ? 'Update details' : 'Someone special',
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
                ref.read(birthdayListProvider.notifier).deleteBirthday(widget.birthday!.id);
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

  // ── Name Field ────────────────────────────────────────────────────────────

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Name'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          style: GoogleFonts.dmSans(fontSize: 14, color: _textWarm),
          cursorColor: _gold,
          textCapitalization: TextCapitalization.words,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'e.g. Aunty Bimpe',
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
          value == null || value.trim().isEmpty ? 'Name is required' : null,
        ),
      ],
    );
  }

  // ── Date Tile ─────────────────────────────────────────────────────────────

  Widget _buildDateTile(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Birth date'),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: _date,
              firstDate: DateTime(1900),
              // If year is included, don't allow future. 
              // If year is hidden, allow picking any month/day in the current year.
              lastDate: _includeYear ? now : DateTime(now.year, 12, 31),
              initialDatePickerMode:
                  _includeYear ? DatePickerMode.year : DatePickerMode.day,
              builder: (context, child) => _pickerTheme(child),
            );
            if (picked != null) setState(() => _date = picked);
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
                const Icon(Icons.cake_outlined,
                    color: _textMuted, size: 16),
                const SizedBox(width: 12),
                Text(
                  _includeYear 
                      ? DateFormat('MMMM d, yyyy').format(_date)
                      : DateFormat('MMMM d').format(_date),
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

  Widget _buildYearToggle() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Include birth year',
              style: GoogleFonts.dmSans(fontSize: 13, color: _textWarm),
            ),
            Text(
              _includeYear ? 'Picker will show years' : 'Only month & day',
              style: GoogleFonts.dmSans(fontSize: 10, color: _textMuted),
            ),
          ],
        ),
        const Spacer(),
        Switch(
          value: _includeYear,
          onChanged: (val) {
            setState(() {
              _includeYear = val;
              // If they turn it on, we might want to default to a sensible "birth year" 
              // but only if the current date is "now"
              if (_includeYear && _date.year == DateTime.now().year) {
                _date = DateTime(1995, _date.month, _date.day);
              } else if (!_includeYear) {
                // If they turn it off, we reset the internal year to current year 
                // so the picker starts at "today" next time
                _date = DateTime(DateTime.now().year, _date.month, _date.day);
              }
            });
          },
          activeColor: _gold,
          activeTrackColor: const Color(0xFF2A1208),
          inactiveThumbColor: _textDim,
          inactiveTrackColor: _surfaceBg,
        ),
      ],
    );
  }

  // ── Relationship Section ──────────────────────────────────────────────────

  Widget _buildRelationshipSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Relationship'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _relationships.map((r) {
            final selected = _relationship == r;
            return GestureDetector(
              onTap: () => setState(() => _relationship = r),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFF2A1208) : _cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? _gold : _borderDim,
                    width: selected ? 1 : 0.5,
                  ),
                ),
                child: Text(
                  r.toUpperCase(),
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
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

  // ── Live Preview Card ─────────────────────────────────────────────────────

  Widget _buildPreviewCard() {
    final name = _nameController.text.trim();
    final hasName = name.isNotEmpty;
    final days = _daysUntilBirthday(_date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Preview'),
        const SizedBox(height: 10),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: hasName ? _borderDim : const Color(0xFF1A0E06),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: hasName ? _gold : _borderDim,
                    width: 0.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    hasName ? name[0].toUpperCase() : '?',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 18,
                      color: hasName ? _gold : _textDim,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasName ? name : 'Name will appear here',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: hasName ? _textWarm : _textDim,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$_relationship  ·  ${_includeYear ? DateFormat('MMMM d, yyyy').format(_date) : DateFormat('MMMM d').format(_date)}',
                      style: GoogleFonts.dmSans(
                          fontSize: 11, color: _textMuted),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: days <= 30
                      ? const Color(0xFF2A1208)
                      : _surfaceBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: days <= 30 ? _gold : _borderDim,
                    width: 0.5,
                  ),
                ),
                child: Text(
                  days == 0
                      ? 'Today!'
                      : '$days days',
                  style: GoogleFonts.dmSans(
                    fontSize: 9,
                    letterSpacing: 0.8,
                    color: days <= 30 ? _gold : _textMuted,
                  ),
                ),
              ),
            ],
          ),
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
            final updatedBirthday = Birthday(
              id: widget.birthday!.id,
              name: _nameController.text.trim(),
              date: _date,
              relationship: _relationship,
              includeYear: _includeYear,
            );
            await ref
                .read(birthdayListProvider.notifier)
                .updateBirthday(updatedBirthday);
          } else {
            final birthday = Birthday.create(
              name: _nameController.text.trim(),
              date: _date,
              relationship: _relationship,
              includeYear: _includeYear,
            );
            await ref.read(birthdayListProvider.notifier).addBirthday(birthday);
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
            _isEditing ? 'UPDATE BIRTHDAY' : 'SAVE BIRTHDAY',
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

  Widget _pickerTheme(Widget? child) {
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
