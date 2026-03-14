import 'package:flutter/material.dart';

import '../utils/portfolio_theme.dart';
import 'glass_card.dart';

class SkillBadge extends StatelessWidget {
  final String label;
  final IconData icon;

  const SkillBadge({
    super.key,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      margin: const EdgeInsets.only(right: 12, bottom: 12),
      borderRadius: 4,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: PortfolioTheme.accentPrimary,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: PortfolioTheme.textPrimary,
                ),
          ),
        ],
      ),
    );
  }
}
