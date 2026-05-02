import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// Küçük ikonlu kategori kartı (Dashboard’daki finansal kategori şeridi için).
class FinancialCategoryTile extends StatelessWidget {
  const FinancialCategoryTile({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  /// Şerit için daha dar hücre (hızlı kategori butonları).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final w = compact ? 72.0 : 84.0;
    final iconSize = compact ? 22.0 : 26.0;
    final verticalPad = compact ? 10.0 : 12.0;

    return Material(
      color: selected ? AppColors.heroDark : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadii.tile),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.tile),
        child: Container(
          width: w,
          padding: EdgeInsets.symmetric(vertical: verticalPad, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.tile),
            border: Border.all(color: selected ? AppColors.heroDark : AppColors.borderSubtle),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: selected ? Colors.white : AppColors.textPrimary, size: iconSize),
              SizedBox(height: compact ? 4 : 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: compact ? 10 : 11,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.textPrimary,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
