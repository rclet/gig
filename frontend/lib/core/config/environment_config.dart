enum Environment {
  development,
  staging,
  production,
}

class EnvironmentConfig {
  // Updated to production for Rclet Gig v1.0 release
  static const Environment _currentEnvironment = Environment.production;
  
  static Environment get currentEnvironment => _currentEnvironment;
  
  static String get baseUrl {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'http://localhost:8000/api';
      case Environment.staging:
        return 'https://staging.gig.com.bd/api';
      case Environment.production:
        return 'https://gig.com.bd/gig-main/backend/api';
    }
  }
  
  static String get socketUrl {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'http://localhost:8000';
      case Environment.staging:
        return 'https://staging.gig.com.bd';
      case Environment.production:
        return 'https://gig.com.bd/gig-main/backend';
    }
  }
  
  static String get appUrl {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'http://localhost:3000';
      case Environment.staging:
        return 'https://staging.gig.com.bd';
      case Environment.production:
        return 'https://gig.com.bd';
    }
  }
  
  static bool get isProduction => _currentEnvironment == Environment.production;
  static bool get isDevelopment => _currentEnvironment == Environment.development;
  static bool get isStaging => _currentEnvironment == Environment.staging;
  
  static String get environmentName {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'Development';
      case Environment.staging:
        return 'Staging';
      case Environment.production:
        return 'Production';
    }
  }
  
  // Production URLs for easy switching
  static const String productionBaseUrl = 'https://gig.com.bd/gig-main/backend/api';
  static const String productionSocketUrl = 'https://gig.com.bd/gig-main/backend';
  static const String productionAppUrl = 'https://gig.com.bd';
  
  // Fallback configuration when production is not accessible
  static String getProductionBaseUrl() => productionBaseUrl;
  static String getProductionSocketUrl() => productionSocketUrl;
  static String getProductionAppUrl() => productionAppUrl;
}