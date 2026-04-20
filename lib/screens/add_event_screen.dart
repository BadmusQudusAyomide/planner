import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../providers/event_provider.dart';

class AddEventScreen extends ConsumerStatefulWidget {
  final DateTime selectedDate;

  const AddEventScreen({super.key, required this.selectedDate});

  @override
  ConsumerState<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends ConsumerState<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late DateTime _date;
  TimeOfDay? _time;
  String _tag = 'Personal';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _date = widget.selectedDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Event')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Date'),
              subtitle: Text(DateFormat('EEEE, MMMM d, yyyy').format(_date)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
            ListTile(
              title: const Text('Time (Optional)'),
              subtitle: Text(_time?.format(context) ?? 'No time set'),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _time ?? TimeOfDay.now(),
                );
                if (picked != null) setState(() => _time = picked);
              },
            ),
            const SizedBox(height: 16),
            const Text('Tag', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: ['Personal', 'Work', 'Other'].map((tag) {
                return ChoiceChip(
                  label: Text(tag),
                  selected: _tag == tag,
                  onSelected: (selected) {
                    if (selected) setState(() => _tag = tag);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final event = Event.create(
                    title: _titleController.text,
                    date: _date,
                    time: _time?.format(context),
                    tag: _tag,
                  );
                  ref.read(eventListProvider.notifier).addEvent(event);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save Event'),
            ),
          ],
        ),
      ),
    );
  }
}
