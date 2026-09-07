/// `doctors/{doctorId}/availability` documents (and the appointments booked
/// against them) are keyed by calendar date as `yyyy-MM-dd`.
String availabilityDateId(DateTime date) {
  String pad(int n, int width) => n.toString().padLeft(width, '0');
  return '${pad(date.year, 4)}-${pad(date.month, 2)}-${pad(date.day, 2)}';
}
