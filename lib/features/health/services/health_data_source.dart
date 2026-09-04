abstract class HealthDataSource {
  Future<List<dynamic>> getSleepRecords(DateTime from, DateTime to);
  Future<List<dynamic>> getExerciseRecords(DateTime from, DateTime to);
}
