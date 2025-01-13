library modal_stack_router;

import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

export 'package:stack_router/stack_router.dart';

class ResponsiveMarginConfig {
  final double mobileScreenBreakpoint;
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;
  final double mobileMarginPercent;
  final double desktopMarginPercent;
  final double verticalMargin;
  final double? height;

  const ResponsiveMarginConfig({
    this.mobileScreenBreakpoint = 800,
    this.mobileMarginPercent = 0.05,
    this.desktopMarginPercent = 0.15,
    this.verticalMargin = 50,
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.height,
  });

  // EdgeInsets getMargins(double screenWidth) {
  //   final horizontalMargin = screenWidth < mobileScreenBreakpoint
  //       ? screenWidth * mobileMarginPercent
  //       : screenWidth * desktopMarginPercent;

  //   if (left != null || top != null || right != null || bottom != null) {
  //     return EdgeInsets.only(
  //       left: left ?? horizontalMargin,
  //       top: top ?? verticalMargin,
  //       right: right ?? horizontalMargin,
  //       bottom: bottom ?? verticalMargin,
  //     );
  //   }

  //   return EdgeInsets.symmetric(
  //     vertical: verticalMargin,
  //     horizontal: horizontalMargin,
  //   );
  // }

  // BoxConstraints getConstraints() {
  //   if (height != null) {
  //     return BoxConstraints.tightFor(height: height);
  //   }
  //   // When no height is specified, use loose constraints to allow content sizing
  //   return const BoxConstraints(minHeight: 0.0);
  // }
}

Future<T?> showModalStackRouter<T>({
  required BuildContext context,
  required Widget child,
  Alignment alignment = Alignment.topCenter,
  Color barrierColor = Colors.black54,
  BorderRadiusGeometry? borderRadius,
  bool isDismissible = true,
  Widget Function(BuildContext context)? builder,
  ResponsiveMarginConfig? marginConfig,
}) {
  final config = marginConfig ?? const ResponsiveMarginConfig();

  return showCustomModalBottomSheet<T>(
    barrierColor: barrierColor,
    context: context,
    builder: (context) => builder?.call(context) ?? child,
    duration: Duration.zero,
    enableDrag: false,
    isDismissible: isDismissible,
    settings: RouteSettings(name: '${Uri.base.path} '),
    containerWidget: (_, animation, child) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final currentWidth = MediaQuery.of(context).size.width;
          final isMobile = currentWidth < config.mobileScreenBreakpoint;
          final availableHeight = constraints.maxHeight;

          // Calculate responsive margins based on current width
          final horizontalMargin = isMobile
              ? currentWidth * config.mobileMarginPercent
              : currentWidth * config.desktopMarginPercent;

          // Create margins based on explicit values or responsive settings
          EdgeInsets margins;

          // If we have explicit margins, use them
          if (config.left != null ||
              config.right != null ||
              config.top != null ||
              config.bottom != null) {
            margins = EdgeInsets.only(
              left: config.left ?? 0,
              right: config.right ?? 0,
              top: config.top ?? 0,
              bottom: config.bottom ?? 0,
            );
          } else {
            // Otherwise use responsive margins
            margins = EdgeInsets.symmetric(
              horizontal: horizontalMargin,
              vertical: config.verticalMargin,
            );
          }

          // Determine if space is too tight
          bool isTight = false;
          if (config.height != null) {
            final remainingSpace = availableHeight - config.height!;
            if (remainingSpace < margins.vertical) {
              isTight = true;
              // Not enough space for margins, reduce them proportionally
              final ratio =
                  remainingSpace > 0 ? remainingSpace / margins.vertical : 0;
              margins = EdgeInsets.only(
                left: margins.left,
                right: margins.right,
                top: 0, // Force top margin to 0 when tight
                bottom: margins.bottom * ratio,
              );
            }
          }

          Widget content = Material(
            clipBehavior: Clip.hardEdge,
            borderRadius: borderRadius ?? BorderRadius.circular(8),
            child: config.height != null
                ? SizedBox(
                    height: config.height,
                    child: child,
                  )
                : child,
          );

          if (config.height != null) {
            content = UnconstrainedBox(
              constrainedAxis: Axis.horizontal,
              child: content,
            );
          }

          // Only check for space if height is provided
          final hasEnoughSpace = config.height != null
              ? availableHeight >= config.height! + margins.vertical
              : true;

          // If we're really tight on space, force top alignment
          final forceTop =
              config.height != null && availableHeight <= config.height!;

          return Container(
            width: double.infinity,
            height: availableHeight,
            alignment: forceTop
                ? Alignment.topCenter
                : (hasEnoughSpace
                    ? Alignment.bottomCenter
                    : Alignment.topCenter),
            child: Container(
              margin: margins,
              child: content,
            ),
          );
        },
      );
    },
  );
}
