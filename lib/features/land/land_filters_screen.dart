import 'package:flutter/material.dart';
import '../../design_system.dart';

class LandFiltersScreen extends StatelessWidget {
  const LandFiltersScreen({super.key});

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Text(title, style: DesignSystem.textTheme.headlineSmall),
      );

  Widget _chip(String label, IconData icon) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: DesignSystem.backgroundLight,
          borderRadius: BorderRadius.circular(999),
          boxShadow: DesignSystem.cardShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: DesignSystem.accentColor),
            const SizedBox(width: 6),
            Text(label, style: DesignSystem.textTheme.labelSmall),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plot Filters')),
      body: ListView(
        children: [
          _sectionTitle('Plot Types'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip('Residential', Icons.home_work_rounded),
                _chip('Commercial', Icons.domain_rounded),
                _chip('Agricultural', Icons.agriculture_rounded),
              ],
            ),
          ),
          _sectionTitle('Filters'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip('Location / Near me', Icons.location_on_rounded),
                _chip('Budget', Icons.currency_rupee_rounded),
                _chip('Ownership type', Icons.badge_rounded),
                _chip('Plot size (sqft/acre)', Icons.grid_on_rounded),
                _chip('Facing direction', Icons.explore_rounded),
                _chip('Loan eligible', Icons.request_quote_rounded),
                _chip('Verified docs', Icons.verified_user_rounded),
                _chip('Freehold/Leasehold', Icons.assignment_rounded),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}


