/// Global feature flags and configuration.
///
/// Priority: demoMode → PowerSync (always offline-first) → nothing.
///
/// [demoMode] true  → in-memory DemoStore, no DB touched at all.
/// [demoMode] false → PowerSync local SQLite, auto-syncs to Supabase.
class AppConfig {
  static const bool demoMode = false;

  /// Your PowerSync instance endpoint from app.powersync.com.
  /// Example: 'https://abc123.powersync.journeyapps.com'
  static const String powerSyncUrl =
    'https://6a3cc0b435ca576ca0df812b.powersync.journeyapps.com';
}
