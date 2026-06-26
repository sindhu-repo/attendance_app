import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/app_config.dart';

/// Connects PowerSync to Supabase.
///
/// - [fetchCredentials]: returns the Supabase JWT so PowerSync can authenticate
///   with the PowerSync cloud service.
/// - [uploadData]: applies local CRUD changes back to Supabase.
class SupabaseConnector extends PowerSyncBackendConnector {
  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    var session = Supabase.instance.client.auth.currentSession;
    if (session == null) return null;

    if (session.isExpired) {
      await Supabase.instance.client.auth.refreshSession();
      session = Supabase.instance.client.auth.currentSession;
      if (session == null) return null;
    }

    return PowerSyncCredentials(
      endpoint: AppConfig.powerSyncUrl,
      token: session.accessToken,
      userId: session.user.id,
    );
  }

  @override
  Future<void> uploadData(PowerSyncDatabase database) async {
    final batch = await database.getCrudBatch(limit: 100);
    if (batch == null) return;

    final supabase = Supabase.instance.client;

    for (final entry in batch.crud) {
      // employees table is read-only on the client — skip uploads for it
      if (entry.table == 'employees') continue;

      switch (entry.op) {
        case UpdateType.put:
          await supabase
              .from(entry.table)
              .upsert({'id': entry.id, ...?entry.opData});
        case UpdateType.patch:
          await supabase
              .from(entry.table)
              .update(entry.opData ?? {})
              .eq('id', entry.id);
        case UpdateType.delete:
          await supabase.from(entry.table).delete().eq('id', entry.id);
      }
    }

    await batch.complete();
  }
}
