import 'package:flutter/material.dart';

import '../../../domain/image_format.dart';
import '../converter_controller.dart';

class ConversionControls extends StatelessWidget {
  const ConversionControls({
    super.key,
    required this.controller,
    this.scrollable = true,
  });

  final ConverterController controller;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final warning = controller.selectedFormatWarning;
    final children = [
      Row(
        children: [
          Expanded(
            child: Text(
              '${controller.options.targetFormat.label} Settings',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Icon(
            controller.writableFormats.contains(controller.options.targetFormat)
                ? Icons.check_circle_outline_rounded
                : Icons.construction_rounded,
            color:
                controller.writableFormats.contains(
                  controller.options.targetFormat,
                )
                ? const Color(0xff28724f)
                : const Color(0xffa45b13),
          ),
        ],
      ),
      const SizedBox(height: 12),
      if (warning != null) ...[
        _WarningBox(message: warning),
        const SizedBox(height: 12),
      ],
      _ResizeControls(controller: controller),
      const Divider(height: 28),
      _FormatSpecificControls(controller: controller),
      const Divider(height: 28),
      SwitchListTile(
        value: controller.options.stripMetadata,
        onChanged: controller.setStripMetadata,
        title: const Text('Strip metadata'),
        subtitle: const Text(
          'Keeps output smaller where the codec supports it.',
        ),
        contentPadding: EdgeInsets.zero,
      ),
      const SizedBox(height: 12),
      FilledButton.icon(
        onPressed: controller.canConvert ? controller.convertSelected : null,
        icon: controller.isConverting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save_alt_rounded),
        label: Text(
          controller.isConverting ? 'Converting' : 'Save Converted Image',
        ),
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: scrollable
            ? ListView(
                primary: false,
                physics: const ClampingScrollPhysics(),
                children: children,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
      ),
    );
  }
}

class _ResizeControls extends StatelessWidget {
  const _ResizeControls({required this.controller});

  final ConverterController controller;

  @override
  Widget build(BuildContext context) {
    final metadata = controller.source!.metadata;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Size', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                key: ValueKey('width-${metadata.path}'),
                initialValue: controller.options.resizeWidth?.toString() ?? '',
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Width',
                  hintText: '${metadata.width}',
                  suffixText: 'px',
                ),
                onChanged: controller.setResizeWidth,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                key: ValueKey('height-${metadata.path}'),
                initialValue: controller.options.resizeHeight?.toString() ?? '',
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Height',
                  hintText: '${metadata.height}',
                  suffixText: 'px',
                ),
                onChanged: controller.setResizeHeight,
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              tooltip: 'Use original size',
              onPressed: controller.clearResize,
              icon: const Icon(Icons.restart_alt_rounded),
            ),
          ],
        ),
        SwitchListTile(
          value: controller.options.maintainAspectRatio,
          onChanged: controller.setMaintainAspectRatio,
          title: const Text('Maintain aspect ratio'),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}

class _FormatSpecificControls extends StatelessWidget {
  const _FormatSpecificControls({required this.controller});

  final ConverterController controller;

  @override
  Widget build(BuildContext context) {
    return switch (controller.options.targetFormat) {
      ImageFormat.jpeg => _LossyControls(
        controller: controller,
        title: 'JPEG quality',
      ),
      ImageFormat.webp => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            value: controller.options.webpLossless,
            onChanged: controller.setWebpLossless,
            title: const Text('Lossless WebP'),
            contentPadding: EdgeInsets.zero,
          ),
          if (!controller.options.webpLossless)
            _LossyControls(controller: controller, title: 'WebP quality'),
          _EffortControls(controller: controller),
        ],
      ),
      ImageFormat.avif => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            value: controller.options.avifLossless,
            onChanged: controller.setAvifLossless,
            title: const Text('Lossless AVIF'),
            contentPadding: EdgeInsets.zero,
          ),
          if (!controller.options.avifLossless)
            _LossyControls(controller: controller, title: 'AVIF quality'),
          _EffortControls(controller: controller),
        ],
      ),
      ImageFormat.png => _SliderControl(
        label: 'PNG compression',
        value: controller.options.pngCompression.toDouble(),
        min: 0,
        max: 9,
        divisions: 9,
        displayValue: '${controller.options.pngCompression}',
        onChanged: controller.setPngCompression,
      ),
      ImageFormat.gif => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SliderControl(
            label: 'Palette size',
            value: controller.options.gifPaletteSize.toDouble(),
            min: 2,
            max: 256,
            divisions: 254,
            displayValue: '${controller.options.gifPaletteSize}',
            onChanged: controller.setGifPalette,
          ),
          SwitchListTile(
            value: controller.options.gifDither,
            onChanged: controller.setGifDither,
            title: const Text('Dithering'),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
      ImageFormat.bmp => const _StaticFormatNote(
        'BMP has no compression controls in this build.',
      ),
      ImageFormat.tiff => _SliderControl(
        label: 'Compression intent',
        value: controller.options.pngCompression.toDouble(),
        min: 0,
        max: 9,
        divisions: 9,
        displayValue: '${controller.options.pngCompression}',
        onChanged: controller.setPngCompression,
      ),
      ImageFormat.ico => const _StaticFormatNote(
        'ICO output uses a square icon image. Multi-size ICO is planned.',
      ),
    };
  }
}

class _LossyControls extends StatelessWidget {
  const _LossyControls({required this.controller, required this.title});

  final ConverterController controller;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SliderControl(
          label: title,
          value: controller.options.quality.toDouble(),
          min: 1,
          max: 100,
          divisions: 99,
          displayValue: '${controller.options.quality}',
          onChanged: controller.setQuality,
        ),
        if (controller.source!.metadata.hasAlpha &&
            !controller.options.targetFormat.supportsAlpha) ...[
          const SizedBox(height: 10),
          Text('Matte color', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: const [
              _ColorSwatch(value: 0xffffffff),
              _ColorSwatch(value: 0xfff4efe7),
              _ColorSwatch(value: 0xff202124),
              _ColorSwatch(value: 0xff2f7d73),
            ],
          ),
        ],
      ],
    );
  }
}

class _EffortControls extends StatelessWidget {
  const _EffortControls({required this.controller});

  final ConverterController controller;

  @override
  Widget build(BuildContext context) {
    return _SliderControl(
      label: 'Effort',
      value: controller.options.effort.toDouble(),
      min: 0,
      max: 10,
      divisions: 10,
      displayValue: '${controller.options.effort}',
      onChanged: controller.setEffort,
    );
  }
}

class _SliderControl extends StatelessWidget {
  const _SliderControl({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.displayValue,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String displayValue;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.labelLarge),
            ),
            Text(displayValue, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          label: displayValue,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    final controls = context
        .findAncestorWidgetOfExactType<ConversionControls>()!;
    final selected = controls.controller.options.matteColor == value;
    return Tooltip(
      message: 'Use matte color',
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => controls.controller.setMatteColor(value),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Color(value),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outlineVariant,
              width: selected ? 3 : 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _WarningBox extends StatelessWidget {
  const _WarningBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xfffff7e8),
        border: Border.all(color: const Color(0xfff2c46d)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: Color(0xff946313),
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

class _StaticFormatNote extends StatelessWidget {
  const _StaticFormatNote(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
