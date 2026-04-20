import 'package:flutter/material.dart';

class UpcomingSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const UpcomingSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 8),
        if (children.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('Nothing scheduled here.'),
          )
        else
          ...children,
      ],
    );
  }
}
