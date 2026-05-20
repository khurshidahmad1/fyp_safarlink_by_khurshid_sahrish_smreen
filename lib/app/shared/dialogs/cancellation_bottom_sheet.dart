import 'package:flutter/material.dart';

class CancellationBottomSheet extends StatelessWidget {
  const CancellationBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return const BottomSheet(
      onClosing: _onClosing,
      builder: _builder,
    );
  }

  static void _onClosing() {}
  static Widget _builder(BuildContext context) => const SizedBox();
}
