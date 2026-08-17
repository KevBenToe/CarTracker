/// Returns a German label for known maintenance status values.
/// Falls back to the original value when no mapping exists.
String maintenanceStatusLabel(String status) {
  switch (status) {
    case 'Completed':
      return 'Abgeschlossen';
    case 'Scheduled':
      return 'Geplant';
    case 'Overdue':
      return 'Überfällig';
    default:
      return status;
  }
}
