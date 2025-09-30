import 'package:flutter/material.dart';
import '../../../features/shared/data/devices_data.dart';
import '../../../features/shared/services/language_service.dart';

class ProjectEditWarningDialog extends StatelessWidget {
  final String type; // 'device' or 'language'
  final String itemId; // deviceId or languageCode
  final int screenshotCount;
  final int? textElementCount; // Only for language removal
  final Map<String, int>? breakdown; // Optional breakdown by language or device

  const ProjectEditWarningDialog({
    super.key,
    required this.type,
    required this.itemId,
    required this.screenshotCount,
    this.textElementCount,
    this.breakdown,
  });

  @override
  Widget build(BuildContext context) {
    final isDevice = type == 'device';
    final itemName = isDevice
        ? DevicesData.getDeviceById(itemId)?.name ?? itemId
        : LanguageService.getLanguageByCode(itemId)?.nativeName ?? itemId;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Theme.of(context).colorScheme.error,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text('Remove ${isDevice ? 'Device' : 'Language'}?'),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are about to remove "$itemName" from this project.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This action will permanently delete:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  if (screenshotCount > 0) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.image,
                          size: 20,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$screenshotCount screenshot${screenshotCount != 1 ? 's' : ''}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                  if (!isDevice && textElementCount != null && textElementCount! > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.text_fields,
                          size: 20,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$textElementCount text translation${textElementCount != 1 ? 's' : ''}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                  if (breakdown != null && breakdown!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      'Breakdown:',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ...breakdown!.entries.map((entry) {
                      final name = isDevice
                          ? LanguageService.getLanguageByCode(entry.key)
                                  ?.nativeName ??
                              entry.key
                          : DevicesData.getDeviceById(entry.key)?.name ??
                              entry.key;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            const Text('•'),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                name,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            Text(
                              '${entry.value} screenshot${entry.value != 1 ? 's' : ''}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'This action cannot be undone.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          child: const Text('Remove'),
        ),
      ],
    );
  }
}
