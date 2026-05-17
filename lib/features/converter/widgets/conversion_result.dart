import 'package:flutter/material.dart';

import '../../../domain/formatting.dart';
import '../converter_controller.dart';

class ConversionResult extends StatelessWidget {
  const ConversionResult({super.key, required this.controller});

  final ConverterController controller;

  @override
  Widget build(BuildContext context) {
    final resultPath = controller.resultPath;
    final actualBytes = controller.actualOutputBytes;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: resultPath == null || actualBytes == null
            ? Row(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'After conversion, the selected estimate is replaced with the actual output size.',
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        color: Color(0xff28724f),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Saved ${formatBytes(actualBytes)}',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    resultPath,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
