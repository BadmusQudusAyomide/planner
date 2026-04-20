import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/birthday_provider.dart';
import '../widgets/birthday_card.dart';
import 'add_birthday_screen.dart';

class BirthdaysScreen extends ConsumerWidget {
  const BirthdaysScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final birthdays = ref.watch(birthdayListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Birthdays'),
      ),
      body: birthdays.isEmpty
          ? const Center(child: Text('No birthdays added yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: birthdays.length,
              itemBuilder: (context, index) {
                final birthday = birthdays[index];
                return Dismissible(
                  key: Key(birthday.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    ref.read(birthdayListProvider.notifier).deleteBirthday(birthday.id);
                  },
                  child: BirthdayCard(birthday: birthday),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddBirthdayScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
