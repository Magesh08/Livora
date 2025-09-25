import 'package:flutter/material.dart';
import '../../../../design_system.dart';

class SpotCard extends StatelessWidget {
  const SpotCard({
    super.key,
    required this.title,
    required this.pricePerHour,
    required this.distanceKm,
    required this.rating,
    this.imageUrl,
    this.available = true,
  });

  final String title;
  final double pricePerHour;
  final double distanceKm;
  final double rating;
  final String? imageUrl;
  final bool available;

  @override
  Widget build(BuildContext context) {
    return Container
    (
      margin: const EdgeInsets.symmetric(
        horizontal: 0,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        gradient: DesignSystem.deviceCardGradient,
        borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
        boxShadow: DesignSystem.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          _buildImage(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: DesignSystem.textTheme.headlineSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _AvailabilityChip(available: available),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: DesignSystem.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${distanceKm.toStringAsFixed(1)} km',
                        style: DesignSystem.textTheme.bodySmall?.copyWith(color: DesignSystem.textSecondary),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.star, size: 14, color: DesignSystem.accentColor),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: DesignSystem.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '\$${pricePerHour.toStringAsFixed(0)}/hr',
                        style: DesignSystem.textTheme.titleLarge?.copyWith(color: DesignSystem.accentColor),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('View'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          backgroundColor: DesignSystem.primaryColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 36),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      width: 84,
      height: 72,
      decoration: BoxDecoration(
        color: DesignSystem.backgroundLighter,
        image: imageUrl != null
            ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
            : null,
      ),
      child: imageUrl == null
          ? const Icon(Icons.local_parking, size: 40, color: Colors.white)
          : null,
    );
  }
}

class _AvailabilityChip extends StatelessWidget {
  const _AvailabilityChip({required this.available});
  final bool available;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: available ? DesignSystem.success.withOpacity(0.15) : DesignSystem.errorColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: available ? DesignSystem.success : DesignSystem.errorColor, width: 1),
      ),
      child: Text(
        available ? 'Available' : 'Unavailable',
        style: DesignSystem.textTheme.labelSmall?.copyWith(
          color: available ? DesignSystem.success : DesignSystem.errorColor,
        ),
      ),
    );
  }
}


