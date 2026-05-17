import 'package:flutter/material.dart';

import '../../../domain/formatting.dart';
import '../../../domain/image_metadata.dart';

class SourceInspector extends StatelessWidget {
  const SourceInspector({super.key, required this.source});

  final SourceImage source;

  @override
  Widget build(BuildContext context) {
    final metadata = source.metadata;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xffeef1ef),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    source.previewPngBytes,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              metadata.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _Metric(label: 'Format', value: metadata.format.label),
            _Metric(
              label: 'Dimensions',
              value: '${metadata.width} x ${metadata.height}',
            ),
            _Metric(
              label: 'Current size',
              value: formatBytes(metadata.fileSizeBytes),
            ),
            _Metric(
              label: 'Transparency',
              value: metadata.hasAlpha ? 'Yes' : 'No',
            ),
            _Metric(
              label: 'Frames',
              value: metadata.hasAnimation
                  ? '${metadata.frameCount} animated'
                  : 'Static',
            ),
            _Metric(
              label: 'Depth',
              value: '${metadata.bitsPerChannel}-bit channel',
            ),
            const SizedBox(height: 16),
            DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xffe8f3ef),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.lock_outline_rounded, size: 16),
                    SizedBox(width: 8),
                    Expanded(child: Text('Processed locally')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 104,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
