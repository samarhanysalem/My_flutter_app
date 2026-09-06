import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../theme/app_theme.dart';

/// The branded app mark shown on auth screens and (later) splash/about
/// screens. Renders [AppConfig.logoAssetPath] when the customer has dropped
/// one into `assets/branding/`, falling back to a neutral glyph so the app
/// still looks reasonable before that asset exists.
class AppLogoMark extends StatelessWidget {
  const AppLogoMark({super.key, this.size = 46});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Image.asset(
        AppConfig.logoAssetPath,
        width: size * 0.48,
        height: size * 0.48,
        // No color/colorBlendMode tint here: the customer's real logo is a
        // full-color image and Image's default srcIn blend would flatten
        // it to a solid silhouette. Only the monochrome fallback glyph
        // below needs to be recolored to sit on the primary background.
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.favorite,
          color: AppTheme.onPrimary,
          size: size * 0.48,
        ),
      ),
    );
  }
}
