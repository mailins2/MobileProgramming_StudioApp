import 'package:supabase_flutter/supabase_flutter.dart';

class AccountService {
  static Future<bool> isStudioAccount(int userId) async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('StudioAccount')
        .select()
        .eq('studioOwnerID', userId)
        .maybeSingle();

    return response != null;
  }
}
