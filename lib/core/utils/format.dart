String _two(int n) => n.toString().padLeft(2, '0');

String formatDate(DateTime d) {
  final l = d.toLocal();
  return '${_two(l.day)}/${_two(l.month)}/${l.year}';
}

String formatDateTime(DateTime d) {
  final l = d.toLocal();
  return '${formatDate(l)} ${_two(l.hour)}:${_two(l.minute)}';
}
