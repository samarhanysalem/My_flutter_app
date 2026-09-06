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
        color: Colors.white,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.favorite, color: Colors.white, size: size * 0.48),
      ),
    );
  }
}
