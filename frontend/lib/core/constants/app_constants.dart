class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://localhost:8000/api';
  static const String socketUrl = 'http://localhost:8000';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  
  // App Information
  static const String appName = 'Gig Marketplace';
  static const String appVersion = '1.0.0';
  static const String appUrl = 'https://gig.com.bd';
  
  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String onboardingKey = 'onboarding_completed';
  static const String fcmTokenKey = 'fcm_token';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx', 'txt'];
  
  // Animation Durations
  static const Duration quickAnimation = Duration(milliseconds: 200);
  static const Duration standardAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  
  // Social Login
  static const String googleClientId = 'your-google-client-id';
  static const String facebookAppId = 'your-facebook-app-id';
  static const String linkedinClientId = 'your-linkedin-client-id';
  
  // Firebase
  static const String firebaseProjectId = 'gig-marketplace-bd';
  static const String firebaseStorageBucket = 'gig-marketplace-bd.appspot.com';
  
  // Agora (Video Calls)
  static const String agoraAppId = 'your-agora-app-id';
  
  // Currency & Pricing
  static const String defaultCurrency = 'BDT';
  static const List<String> supportedCurrencies = ['BDT', 'USD', 'EUR', 'GBP'];
  static const Map<String, String> currencySymbols = {
    'BDT': '৳',
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
  };
  
  // Job Categories
  static const List<String> skillCategories = [
    'Web Development',
    'Mobile Development',
    'UI/UX Design',
    'Graphic Design',
    'Digital Marketing',
    'Content Writing',
    'Data Science',
    'Translation',
    'Video Editing',
    'Photography',
    'Business Consulting',
    'Virtual Assistant',
  ];
  
  // Bangladesh Specific
  static const List<String> bdDivisions = [
    'Dhaka',
    'Chittagong',
    'Sylhet',
    'Barisal',
    'Khulna',
    'Rajshahi',
    'Rangpur',
    'Mymensingh',
  ];
  
  // Experience Levels
  static const Map<String, String> experienceLevels = {
    'entry': 'Entry Level',
    'intermediate': 'Intermediate',
    'expert': 'Expert',
  };
  
  // Project Status
  static const Map<String, String> projectStatuses = {
    'active': 'Active',
    'completed': 'Completed',
    'cancelled': 'Cancelled',
    'disputed': 'Disputed',
  };
  
  // Job Types
  static const Map<String, String> jobTypes = {
    'fixed': 'Fixed Price',
    'hourly': 'Hourly Rate',
  };
  
  // Location Types
  static const Map<String, String> locationTypes = {
    'remote': 'Remote',
    'onsite': 'On-site',
    'hybrid': 'Hybrid',
  };
  
  // Regular Expressions
  static const String emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phoneRegex = r'^(\+88)?01[3-9]\d{8}$'; // Bangladesh phone format
  static const String passwordRegex = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$';
  
  // Error Messages
  static const String networkError = 'Network connection error. Please check your internet connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unknownError = 'An unexpected error occurred. Please try again.';
  static const String authError = 'Authentication failed. Please login again.';
  
  // Success Messages
  static const String loginSuccess = 'Login successful!';
  static const String registerSuccess = 'Registration successful!';
  static const String profileUpdated = 'Profile updated successfully!';
  static const String jobPosted = 'Job posted successfully!';
  static const String proposalSubmitted = 'Proposal submitted successfully!';
  
  // Feature Flags
  static const bool enableAIMatching = true;
  static const bool enableVideoCallling = true;
  static const bool enableChat = true;
  static const bool enableNotifications = true;
  static const bool enableAnalytics = true;
}