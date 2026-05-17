import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';

class SourceDropZone extends StatefulWidget {
  const SourceDropZone({
    super.key,
    required this.isLoading,
    required this.onChoose,
    required this.onDropped,
  });

  final bool isLoading;
  final Future<void> Function() onChoose;
  final Future<void> Function(String path) onDropped;

  @override
  State<SourceDropZone> createState() => _SourceDropZoneState();
}

class _SourceDropZoneState extends State<SourceDropZone> {
  var _dragging = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DropTarget(
      onDragEntered: (_) => setState(() => _dragging = true),
      onDragExited: (_) => setState(() => _dragging = false),
      onDragDone: (detail) async {
        setState(() => _dragging = false);
        if (detail.files.isNotEmpty) {
          await widget.onDropped(detail.files.first.path);
        }
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _dragging
              ? scheme.primary.withValues(alpha: 0.08)
              : Colors.white,
          border: Border.all(
            color: _dragging ? scheme.primary : scheme.outlineVariant,
            width: _dragging ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 64,
                  color: scheme.primary,
                ),
                const SizedBox(height: 18),
                Text(
                  'Drop an image here',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'JPEG, PNG, WebP, GIF, BMP, TIFF, and ICO are processed locally on this device.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: widget.isLoading ? null : widget.onChoose,
                  icon: widget.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.folder_open_rounded),
                  label: const Text('Choose Image'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
