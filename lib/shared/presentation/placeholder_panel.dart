import 'package:flutter/material.dart';

class PlaceholderPanel extends StatelessWidget {
  const PlaceholderPanel({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.items,
    super.key,
  });

  final String eyebrow;
  final String title;
  final String description;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(title, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 12),
          Text(description, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 24),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('当前占位内容', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 16),
                    for (final item in items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                item,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
