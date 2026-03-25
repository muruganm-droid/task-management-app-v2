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

class _ShimmerCard extends StatelessWidget {
  final int index;

  const _ShimmerCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerLoading(width: 4, height: 28, borderRadius: 2),
              const SizedBox(width: 10),
              Expanded(
                child: ShimmerLoading(height: 16, borderRadius: 8),
              ),
              const SizedBox(width: 12),
              ShimmerLoading(width: 60, height: 22, borderRadius: 6),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: ShimmerLoading(height: 12, borderRadius: 6),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: ShimmerLoading(
              width: 180,
              height: 12,
              borderRadius: 6,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Row(
              children: [
                ShimmerLoading(width: 70, height: 18, borderRadius: 6),
                const SizedBox(width: 8),
                ShimmerLoading(width: 50, height: 18, borderRadius: 6),
                const Spacer(),
                ShimmerLoading(width: 22, height: 22, borderRadius: 11),
              ],
            ),
          ),
        ],
      ),
    );
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
