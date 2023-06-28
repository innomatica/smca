// Database ID rules
//
// Requirements
//
// * Each schedule should have unique id
// * Notification id is 32bit integer
//
// Implementations
//
// * IDs are epoch time with the first fractional number (0.1 second)
// * By this all Activities and Drugs (medication activity) have unique IDs
//
//   Drug.id = getDatabaseId()                        <= 16434668051
//   Activity.id = getDatabaseId()
//   Log.id = getDatabaseId()
//
// * Schedules share the same ID with its parent Activities
//
//   Schedule.id = Drug.id                            <= 16434668051
//   Schedule.id = Activity.id
//
// * Alarm IDs are created by the parent Schedule and used by notification
//
// * Alarm[0].id = Schedule.getAlarmId(0)             <= 434668051
// * Alarm[1].id = Schedule.getAlarmId(1)             <= 434668052

// proxy for DateTimeComponents of flutter_local_notifications
enum DateTimeMatch {
  time,
  dayOfWeekAndTime,
  dayOfMonthAndTime,
  dateAndTime,
}

int getDatabaseId() {
  return DateTime.now().millisecondsSinceEpoch ~/ 100;
}
