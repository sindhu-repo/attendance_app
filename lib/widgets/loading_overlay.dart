import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black.withAlpha(76),
              child: Center(
                child: SpinKitFadingCircle(
                  color: Theme.of(context).colorScheme.primary,
                  size: 52,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
