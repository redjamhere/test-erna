import 'package:flutter/material.dart';

class BiometricSetupDialog extends StatelessWidget {
  final VoidCallback onEnableBiometric;
  final VoidCallback onSkip;

  const BiometricSetupDialog({
    super.key,
    required this.onEnableBiometric,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.fingerprint, color: colorScheme.primary, size: 28),
          const SizedBox(width: 12),
          const Flexible(child: Text('Включить биометрию?')),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Используйте отпечаток пальца или Face ID для быстрого и безопасного входа в приложение.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.security, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Вы сможете изменить эту настройку позже в настройках приложения',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onSkip,
          child: Text(
            'Пропустить',
            style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
          ),
        ),
        ElevatedButton.icon(
          onPressed: onEnableBiometric,
          icon: const Icon(Icons.fingerprint),
          label: const Text('Включить'),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }
}
