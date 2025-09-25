import 'package:flutter/material.dart';
import '../../../design_system.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key, required this.title, required this.content});

  final String title;
  final List<String> content;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DesignSystem.backgroundLight,
              borderRadius: BorderRadius.circular(16),
              boxShadow: DesignSystem.cardShadow,
            ),
            child: Text(
              content[index],
              style: DesignSystem.textTheme.bodyMedium,
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: content.length,
      ),
    );
  }
}


