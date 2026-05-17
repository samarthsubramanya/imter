import 'package:flutter/material.dart';

import '../../../domain/formatting.dart';
import '../../../domain/image_format.dart';
import '../converter_controller.dart';

class FormatComparison extends StatelessWidget {
  const FormatComparison({
    super.key,
    required this.controller,
    this.scrollable = true,
  });

  final ConverterController controller;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final source = controller.source!.metadata;
    final tiles = [
      for (final format in ImageFormat.values)
        _FormatTile(
          format: format,
          selected: controller.options.targetFormat == format,
          supported: controller.writableFormats.contains(format),
          sizeLabel: controller.estimates[format] == null
              ? '...'
              : formatBytes(controller.estimates[format]!.bytes),
          deltaLabel: controller.estimates[format] == null
              ? ''
              : formatDelta(
                  controller.estimates[format]!.bytes,
                  source.fileSizeBytes,
                ),
          onTap: () => controller.selectTarget(format),
        ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Output Comparison',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  'Approx.',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (scrollable)
              Expanded(
                child: ListView.separated(
                  primary: false,
                  physics: const ClampingScrollPhysics(),
                  itemCount: tiles.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) => tiles[index],
                ),
              )
            else
              Column(
                children: [
                  for (var index = 0; index < tiles.length; index++) ...[
                    if (index > 0) const SizedBox(height: 8),
                    tiles[index],
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _FormatTile extends StatelessWidget {
  const _FormatTile({
    required this.format,
    required this.selected,
    required this.supported,
    required this.sizeLabel,
    required this.deltaLabel,
    required this.onTap,
  });

  final ImageFormat format;
  final bool selected;
  final bool supported;
  final String sizeLabel;
  final String deltaLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected
              ? scheme.primaryContainer.withValues(alpha: 0.55)
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? scheme.primary : scheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: supported
                      ? const Color(0xff102d2a)
                      : const Color(0xff6f7470),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  format.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            format.bestFor,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (!supported) ...[
                          const SizedBox(width: 8),
                          const _StatusPill(label: 'Planned'),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${format.lossy ? 'Lossy' : 'Lossless'} · ${format.supportsAlpha ? 'Alpha' : 'No alpha'} · ${format.supportsAnimation ? 'Animation' : 'Static'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    sizeLabel,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    deltaLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: deltaLabel.startsWith('+')
                          ? const Color(0xffa4412b)
                          : const Color(0xff28724f),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xfffff2dd),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: const Color(0xff8b4a12),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
