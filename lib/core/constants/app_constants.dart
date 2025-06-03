class AppConstants {
  // Firebase Configuration
  static const String FIREBASE_PROJECT_ID = "kumafire-7864b";
  static const String FIREBASE_MESSAGING_SENDER_ID = "116620596804";
  
  // Collections Firestore
  static const String COLLECTION_STORIES = "stories";
  static const String COLLECTION_USERS = "users";
  static const String COLLECTION_PROGRESS = "progress";
  
  // Quiz Configuration
  static const int QUIZ_QUESTIONS_COUNT = 3;
  static const int QUIZ_PASSING_SCORE = 2;
  static const int QUIZ_OPTIONS_COUNT = 4;
  
  // Progression
  static const int MAX_CHILDREN = 5;
  static const int MAX_FREE_CHILDREN = 1;
  static const int MAX_PREMIUM_CHILDREN = 5;
  
  // Cache Keys
  static const String CACHE_USER_SETTINGS = "user_settings";
  static const String CACHE_PROGRESS = "progress";
  static const String CACHE_STORIES = "stories";
  
  // Routes
  static const String ROUTE_SPLASH = "/";
  static const String ROUTE_ONBOARDING = "/onboarding";
  static const String ROUTE_HOME = "/home";
  static const String ROUTE_STORY_DETAIL = "/story";
  static const String ROUTE_READING = "/reading";
  static const String ROUTE_LISTENING = "/listening";
  static const String ROUTE_QUIZ = "/quiz";
  static const String ROUTE_QUIZ_RESULT = "/quiz-result";
  
  // Story Types
  static const String STORY_TYPE_TEXT = "text";
  static const String STORY_TYPE_AUDIO = "audio";
  
  // User Types
  static const String USER_TYPE_PARENT = "parent";
  static const String USER_TYPE_TEACHER = "teacher";
  static const String USER_TYPE_CHILD = "child";
  
  // Reading Goals
  static const List<String> READING_GOALS = [
    "Apprendre sur la culture africaine",
    "Améliorer la lecture",
    "Découvrir de nouvelles histoires",
    "Passer du temps en famille"
  ];
  
  // Reading Times
  static const List<String> READING_TIMES = [
    "Matin (7h-10h)",
    "Après-midi (14h-17h)",
    "Soir (18h-21h)",
    "Avant le coucher (21h-23h)"
  ];
  
  // Animal Avatar Options
  static const List<Map<String, dynamic>> ANIMAL_AVATARS = [
    {"name": "Lion", "emoji": "🦁", "id": "lion"},
    {"name": "Éléphant", "emoji": "🐘", "id": "elephant"},
    {"name": "Girafe", "emoji": "🦒", "id": "giraffe"},
    {"name": "Zèbre", "emoji": "🦓", "id": "zebra"},
    {"name": "Rhinocéros", "emoji": "🦏", "id": "rhino"},
    {"name": "Hippopotame", "emoji": "🦛", "id": "hippo"},
    {"name": "Guépard", "emoji": "🐆", "id": "cheetah"},
    {"name": "Gorille", "emoji": "🦍", "id": "gorilla"},
    {"name": "Flamant", "emoji": "🦩", "id": "flamingo"},
    {"name": "Perroquet", "emoji": "🦜", "id": "parrot"},
    {"name": "Singe", "emoji": "🐒", "id": "monkey"},
    {"name": "Crocodile", "emoji": "🐊", "id": "crocodile"},
  ];
}