library modal_stack_router;

import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

export 'package:stack_router/stack_router.dart';

Future<T?> showModalStackRouter<T>({
  /// The [BuildContext] provided to the modal bottom sheet.
  required BuildContext context,

  /// The child widget that typically is an instance of or builds a [StackRouter].
  required Widget child,

  /// The alignment of the modal.
  Alignment alignment = Alignment.topCenter,

  /// The background color of the are beneath the modal being shown.
  Color barrierColor = Colors.black54,

  /// The margin of the modal.
  EdgeInsets margin = const EdgeInsets.only(top: 200),

  /// The border radius of the modal.
  BorderRadiusGeometry? borderRadius,

  // Control of modal dismiss behavior
  bool isDismissible = true,

  /// A builder used to wrap the modal stack router widget.
  Widget Function(BuildContext context)? builder,
}) {
  return showCustomModalBottomSheet<T>(
    barrierColor: barrierColor,
    context: context,
    builder: (context) => builder?.call(context) ?? child,
    duration: Duration.zero,
    enableDrag: false,
    isDismissible: isDismissible,
    // Since Navigator will only revert the route changes made by the stack router
    // on pop() if the modal was announced with a route name other than the current name,
    // we take the current route name and append whitespace to trigger the resetting.
    settings: RouteSettings(name: '${Uri.base.path} '),
    containerWidget: (_, animation, child) {
      return Container(
        alignment: alignment,
        margin: margin,
        child: Material(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
          child: child,
        ),
      );
    },
  );
}
