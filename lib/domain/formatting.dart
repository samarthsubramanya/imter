String formatBytes(int bytes) {
  const units = ['B', 'KB', 'MB', 'GB'];
  var value = bytes.toDouble();
  var unitIndex = 0;
  while (value >= 1024 && unitIndex < units.length - 1) {
    value /= 1024;
    unitIndex++;
  }
  if (unitIndex == 0) {
    return '${value.round()} ${units[unitIndex]}';
  }
  return '${value.toStringAsFixed(value >= 10 ? 1 : 2)} ${units[unitIndex]}';
}

String formatDelta(int estimatedBytes, int sourceBytes) {
  if (sourceBytes <= 0) {
    return '0%';
  }
  final ratio = (estimatedBytes - sourceBytes) / sourceBytes * 100;
  final sign = ratio > 0 ? '+' : '';
  return '$sign${ratio.toStringAsFixed(0)}%';
}
