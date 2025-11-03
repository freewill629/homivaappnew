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
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 160),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [theme.colorScheme.primary.withOpacity(0.12), theme.colorScheme.secondary.withOpacity(0.12)],
                    ),
                  ),
                  child: Icon(Icons.auto_awesome, color: theme.colorScheme.primary),
                ),
                const Spacer(),
                Tooltip(
                  message: 'Coming soon',
                  child: Icon(Icons.lock_clock, color: theme.colorScheme.primary.withOpacity(0.5)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF64748B), height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
