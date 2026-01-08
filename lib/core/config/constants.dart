import 'environment.dart';

class AppConstants {
  static const String appName = 'MTSM ERP';
  static const String apiVersion = 'v1';
  static const String defaultBaseUrl = Environment.apiUrl;
  
  // Storage Keys
  static const String tokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String tenantSchemaKey = 'tenant_schema';
  static const String tenantUrlKey = 'tenant_url';
}
