import 'package:flutter/material.dart';
import '../../design_system.dart';

class PropertyFiltersScreen extends StatelessWidget {
  const PropertyFiltersScreen({super.key});

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
      appBar: AppBar(title: const Text('Property Filters')),
      body: ListView(
        children: [
          _sectionTitle('Basic'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip('Location / Near me', Icons.location_on_rounded),
                _chip('Budget', Icons.currency_rupee_rounded),
                _chip('Owner', Icons.person_rounded),
                _chip('Broker', Icons.badge_rounded),
                _chip('Builder', Icons.engineering_rounded),
                _chip('Property type', Icons.category_rounded),
                _chip('BHK/Room type', Icons.hotel_rounded),
                _chip('Ready / Under construction', Icons.construction_rounded),
              ],
            ),
          ),
          _sectionTitle('Size & Space'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip('Carpet / Built-up area', Icons.straighten_rounded),
                _chip('Plot size (sqft/acre)', Icons.grid_on_rounded),
                _chip('Floor number', Icons.stairs_rounded),
                _chip('Total floors', Icons.apartment_rounded),
                _chip('Furnishing', Icons.chair_rounded),
              ],
            ),
          ),
          _sectionTitle('Amenities'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip('Parking (2W/4W/EV)', Icons.local_parking_rounded),
                _chip('Lift', Icons.elevator_rounded),
                _chip('Security & CCTV', Icons.security_rounded),
                _chip('Gated community', Icons.domain_rounded),
                _chip('Club/Pool/Gym', Icons.pool_rounded),
                _chip('Power backup', Icons.bolt_rounded),
                _chip('Water supply type', Icons.water_drop_rounded),
                _chip('Internet/Wi‑Fi', Icons.wifi_rounded),
              ],
            ),
          ),
          _sectionTitle('Legal & Finance'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip('Loan/EMI eligible', Icons.request_quote_rounded),
                _chip('RERA registered', Icons.approval_rounded),
                _chip('Verified documents', Icons.verified_user_rounded),
                _chip('Price per sq ft', Icons.calculate_rounded),
                _chip('Leasehold / Freehold', Icons.assignment_rounded),
              ],
            ),
          ),
          _sectionTitle('Lifestyle'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip('Pet-friendly', Icons.pets_rounded),
                _chip('Nearby (schools/hospitals/metro)', Icons.place_rounded),
                _chip('Facing direction', Icons.explore_rounded),
                _chip('Vastu compliant', Icons.compass_calibration_rounded),
                _chip('Age of property', Icons.calendar_month_rounded),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}


