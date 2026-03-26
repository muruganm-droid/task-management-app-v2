import 'package:flutter/material.dart';
import '../animations/animated_list_item.dart';
import '../animations/creative_loaders.dart';

class ShimmerTaskList extends StatelessWidget {
  final int itemCount;

  const ShimmerTaskList({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return const CreativeLoader();
  }
}

class ShimmerStatCards extends StatelessWidget {
  const ShimmerStatCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: ShimmerLoading(height: 80, borderRadius: 16)),
        const SizedBox(width: 10),
        Expanded(child: ShimmerLoading(height: 80, borderRadius: 16)),
        const SizedBox(width: 10),
        Expanded(child: ShimmerLoading(height: 80, borderRadius: 16)),
      ],
    );
  }
}
