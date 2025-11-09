import 'package:flutter/material.dart';
import 'package:mentraverse_frontend/core/theme/app_colors.dart';

class SocialAuthButton extends StatelessWidget {
  final IconData? icon;
  final Widget? leading;
  final String label;
  final VoidCallback onPressed;
  final double borderRadius;
  final double verticalPadding;
  final double iconSize;

  const SocialAuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.leading,
    this.borderRadius = 12,
    this.verticalPadding = 14,
    this.iconSize = 24,
  }) : assert(icon != null || leading != null,
            'Provide either an icon or a leading widget.');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: 16),
          backgroundColor:
              isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
          foregroundColor:
              isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          side: BorderSide(
            color: isDarkMode
                ? AppColors.darkTextSecondary
                : Colors.grey[300]!,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leading != null)
              SizedBox(
                height: iconSize,
                width: iconSize,
                child: Center(child: leading),
              )
            else
              Icon(icon, size: iconSize),
            const SizedBox(width: 12),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
