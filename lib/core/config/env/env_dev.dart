class Environment {
  static const String name = 'development';
  static const String baseUrl = 'http://public.localhost:8000'; // No /api/v1/ suffix for local?
  // Wait, mtsm_app had http://public.localhost:8000 as base. 
  // school_erp_app constants had https://mtsm.codefyn.com/api/v1/
  // I should probably align them.
  // If constants.dart has /api/v1/, I should probably keep it or check usage.
  // Assuming Backend is the same MultiTenant one.
  // I will use http://public.localhost:8000/api/v1/ to match production structure if prod has it.
  // But wait, mtsm_app Env was http://public.localhost:8000.
  // Let's stick to what's safer.
  // If I use http://public.localhost:8000, I rely on endpoints adding /api/v1/.
  // Constants defaultBaseUrl has /api/v1/.
  // So I will include /api/v1/ in dev as well to match.
  // http://public.localhost:8000/api/v1/
  
  static const String apiUrl = 'http://public.localhost:8000/api/v1/';
  static const bool enableLogging = true;
}
