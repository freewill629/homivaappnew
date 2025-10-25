import 'package:flutter/material.dart';

class CardPlaceholder extends StatelessWidget {
  const CardPlaceholder({required this.title, required this.description, super.key});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.6,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const Tooltip(
                      message: 'Coming soon',
                      child: Icon(Icons.lock_clock, color: Color(0xFF6E6E6E)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
