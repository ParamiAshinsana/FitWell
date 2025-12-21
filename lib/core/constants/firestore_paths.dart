class FirestorePaths {
  // Users
  static String user(String userId) => 'users/$userId';

  // Meals
  static String meals(String userId) => 'users/$userId/meals';
  static String meal(String userId, String mealId) =>
      'users/$userId/meals/$mealId';

  // Water
  static String water(String userId) => 'users/$userId/water';
  static String waterEntry(String userId, String waterId) =>
      'users/$userId/water/$waterId';

  // Medicine
  static String medicines(String userId) => 'users/$userId/medicines';
  static String medicine(String userId, String medicineId) =>
      'users/$userId/medicines/$medicineId';

  // Workouts
  static String workouts(String userId) => 'users/$userId/workouts';
  static String workout(String userId, String workoutId) =>
      'users/$userId/workouts/$workoutId';

  // Progress
  static String progress(String userId) => 'users/$userId/progress';
  static String progressEntry(String userId, String progressId) =>
      'users/$userId/progress/$progressId';
}

