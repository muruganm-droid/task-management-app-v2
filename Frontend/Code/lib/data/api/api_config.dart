import 'package:flutter/foundation.dart';

enum Environment { dev, production }

class ApiConfig {
  static Environment _environment = kDebugMode ? Environment.dev : Environment.production;

  static Environment get environment => _environment;

  static void setEnvironment(Environment env) {
    _environment = env;
  }

  static String get baseUrl {
    switch (_environment) {
      case Environment.dev:
        return 'https://task-management-api-brown.vercel.app/api';
      case Environment.production:
        return 'https://task-management-api-brown.vercel.app/api';
    }
  }

  static bool get isProduction => _environment == Environment.production;
}
