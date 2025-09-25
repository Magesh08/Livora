import 'package:flutter/material.dart';
import '../../design_system.dart';

class StaysFiltersScreen extends StatelessWidget {
  const StaysFiltersScreen({super.key});

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
      appBar: AppBar(title: const Text('Stays Filters')),
      body: ListView(
        children: [
          _sectionTitle('Categories'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip('PG / Hostel', Icons.bed_rounded),
                _chip('Shared rooms', Icons.people_rounded),
                _chip('Private rooms', Icons.meeting_room_rounded),
                _chip('Entire apartment', Icons.apartment_rounded),
                _chip('Hotel', Icons.hotel_rounded),
                _chip('Guest house', Icons.house_rounded),
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
                _chip('Budget per night', Icons.currency_rupee_rounded),
                _chip('Sharing type', Icons.group_rounded),
                _chip('Furnished', Icons.chair_alt_rounded),
                _chip('Wi‑Fi', Icons.wifi_rounded),
                _chip('Food included', Icons.restaurant_rounded),
                _chip('Girls/Boys/Mixed', Icons.transgender_rounded),
                _chip('Ratings 4.0+', Icons.star_rounded),
                _chip('AC / Non-AC', Icons.ac_unit_rounded),
                _chip('Parking', Icons.local_parking_rounded),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}


