import 'package:flutter/material.dart';
import '../../../design_system.dart';

class HighlightCard extends StatelessWidget {
  const HighlightCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.badges = const [],
    this.trailing,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> badges;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: DesignSystem.backgroundLight,
          borderRadius: BorderRadius.circular(20),
          boxShadow: DesignSystem.cardShadow,
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: DesignSystem.primaryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: DesignSystem.primaryColor, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: DesignSystem.textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: DesignSystem.textTheme.bodySmall?.copyWith(color: DesignSystem.textSecondary),
                  ),
                  if (badges.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: badges
                          .map((b) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: DesignSystem.backgroundLighter,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(b, style: DesignSystem.textTheme.labelSmall),
                              ))
                          .toList(),
                    )
                  ]
                ],
              ),
            ),
            const SizedBox(width: 12),
            trailing ?? const Icon(Icons.chevron_right_rounded, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}


