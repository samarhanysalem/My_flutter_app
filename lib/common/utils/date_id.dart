/// `doctors/{doctorId}/availability` documents and `appointments` documents
/// are both keyed/filtered by calendar date as `yyyy-MM-dd` — shared here
/// since both the `doctor_profile` and `home` features need it.
String dateId(DateTime date) {
  String pad(int n, int width) => n.toString().padLeft(width, '0');
  return '${pad(date.year, 4)}-${pad(date.month, 2)}-${pad(date.day, 2)}';
}
