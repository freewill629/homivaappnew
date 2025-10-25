import 'package:flutter/material.dart';

import 'glass_container.dart';

class CardPlaceholder extends StatelessWidget {
  const CardPlaceholder({required this.title, required this.description, super.key});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassContainer(
      borderRadius: 24,
      padding: const EdgeInsets.all(24),
      opacity: 0.1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 160),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
                const Tooltip(
                  message: 'Coming soon',
                  child: Icon(Icons.lock_clock, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
