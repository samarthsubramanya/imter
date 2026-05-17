import 'package:flutter/material.dart';

import '../../app/app_info.dart';
import 'converter_controller.dart';
import 'widgets/conversion_controls.dart';
import 'widgets/conversion_result.dart';
import 'widgets/format_comparison.dart';
import 'widgets/source_drop_zone.dart';
import 'widgets/source_inspector.dart';

class ConverterScreen extends StatelessWidget {
  const ConverterScreen({super.key, required this.controller});

  final ConverterController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 1080;
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(controller: controller),
                  const SizedBox(height: 20),
                  if (controller.errorMessage != null) ...[
                    _InlineMessage(
                      icon: Icons.error_outline_rounded,
                      message: controller.errorMessage!,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (controller.statusMessage != null) ...[
                    _InlineMessage(
                      icon: Icons.sync_rounded,
                      message: controller.statusMessage!,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                  ],
                  Expanded(
                    child: controller.hasSource
                        ? compact
                              ? _CompactLoadedLayout(controller: controller)
                              : _WideLoadedLayout(controller: controller)
                        : SourceDropZone(
                            isLoading: controller.isLoading,
                            onChoose: controller.chooseSource,
                            onDropped: controller.loadSource,
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.controller});

  final ConverterController controller;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppInfo.name,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Local raster image conversion with approximate size guidance.',
                style: textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (controller.hasSource)
          OutlinedButton.icon(
            onPressed: controller.isLoading || controller.isConverting
                ? null
                : controller.chooseSource,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: const Text('Choose Image'),
          ),
      ],
    );
  }
}

class _WideLoadedLayout extends StatelessWidget {
  const _WideLoadedLayout({required this.controller});

  final ConverterController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 330,
          child: SourceInspector(source: controller.source!),
        ),
        const SizedBox(width: 16),
        Expanded(flex: 5, child: FormatComparison(controller: controller)),
        const SizedBox(width: 16),
        Expanded(
          flex: 4,
          child: Column(
            children: [
              Expanded(child: ConversionControls(controller: controller)),
              const SizedBox(height: 16),
              ConversionResult(controller: controller),
            ],
          ),
        ),
      ],
    );
  }
}

class _CompactLoadedLayout extends StatelessWidget {
  const _CompactLoadedLayout({required this.controller});

  final ConverterController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        SourceInspector(source: controller.source!),
        const SizedBox(height: 16),
        FormatComparison(controller: controller, scrollable: false),
        const SizedBox(height: 16),
        ConversionControls(controller: controller, scrollable: false),
        const SizedBox(height: 16),
        ConversionResult(controller: controller),
      ],
    );
  }
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({
    required this.icon,
    required this.message,
    required this.color,
  });

  final IconData icon;
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.28)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
