import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// ListView + standart kenar boşlukları + geniş eşiği (dashboard / geçmiş vb. için ortak iskelet).
class ScrollableScreenShell extends StatelessWidget {
  const ScrollableScreenShell({
    super.key,
    required this.children,
    this.wideBreakpoint = 900,
    this.paddingOverride,
    this.physics,
  });

  final List<Widget> children;
  final double wideBreakpoint;
  final EdgeInsets? paddingOverride;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.canvas,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= wideBreakpoint;
            return ListView(
              physics: physics,
              padding: paddingOverride ?? AppSpacing.screenEdgeInsets(wide: wide),
              children: children,
            );
          },
        ),
      ),
    );
  }
}
