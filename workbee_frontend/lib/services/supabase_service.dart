import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  static const String _url = 'https://ugkjcyycvuogbjufmbms.supabase.co';
  static const String _key = 'sb_publishable_hoIKcJp4dKu_8XiLVCzJTQ_2QTsdkeE';
  static const String _bucket = 'workbee_db';

  late final SupabaseClient _client;

  Future<void> init() async {
    await Supabase.initialize(url: _url, anonKey: _key);
    _client = Supabase.instance.client;
  }

  SupabaseClient get client => _client;
  String get bucket => _bucket;

  /// Checks if file exceeds max size (default 5 MB)
  static bool isFileTooLarge(String filePath, {int maxMb = 5}) {
    final file = File(filePath);
    final bytes = file.lengthSync();
    final mb = bytes / (1024 * 1024);
    return mb > maxMb;
  }

  /// Uploads an image file and returns the public URL
  Future<String?> upload(String filePath, String fileName) async {
    try {
      await _client.storage.from(_bucket).upload(fileName, File(filePath));
      return _client.storage.from(_bucket).getPublicUrl(fileName);
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  /// Removes an image from the bucket
  Future<void> removeImage(String fileName) async {
    try {
      await _client.storage.from(_bucket).remove([fileName]);
    } catch (e) {
      print('Remove error: $e');
    }
  }
}
