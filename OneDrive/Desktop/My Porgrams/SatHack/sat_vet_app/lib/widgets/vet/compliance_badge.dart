import 'package:flutter/material.dart';

class ComplianceBadge extends StatelessWidget {
  final int compliance;
  final bool isLarge;

  const ComplianceBadge({
    Key? key,
    required this.compliance,
    this.isLarge = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color color = compliance > 90
        ? Colors.green.shade600
        : Colors.orange.shade800;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'Compliance',
          style:
              (isLarge
                      ? theme.textTheme.bodySmall
                      : theme.textTheme.bodySmall?.copyWith(fontSize: 10))
                  ?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
        ),
        Text(
          '$compliance%',
          style:
              (isLarge ? theme.textTheme.titleLarge : theme.textTheme.bodyLarge)
                  ?.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
