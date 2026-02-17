import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:kosnice_app/models/hive_entry.dart';

import 'api_config.dart';

class HiveApiService {
  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<void> syncHivesToLocal({required String token}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/hives');
    final response = await http.get(uri, headers: _headers(token));

    if (response.statusCode != 200) {
      throw Exception('Failed to load hives: ${response.statusCode}');
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    final box = Hive.box<HiveEntry>('hives');
    await box.clear();

    for (final item in list) {
      final m = item as Map<String, dynamic>;
      final hive = HiveEntry(
        serverId: m['id'] as int?,
        id: (m['hive_code'] ?? '').toString(),
        name: m['name']?.toString(),
        description: m['description']?.toString(),
        type: (m['type'] ?? 'LR').toString(),
        breed: m['breed']?.toString(),
        queenPresent: m['queen_present'] as bool?,
        latitude: (m['latitude'] as num?)?.toDouble(),
        longitude: (m['longitude'] as num?)?.toDouble(),
        frames: m['frames'] as int?,
        total: m['total'] as int?,
        brood: m['brood'] as int?,
        honey: m['honey'] as int?,
        history: const [],
      );
      await box.put(hive.id, hive);
    }
  }

  Future<int> createHive({required String token, required HiveEntry hive}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/hives');
    final response = await http.post(
      uri,
      headers: _headers(token),
      body: jsonEncode({
        'hive_code': hive.id,
        'name': hive.name,
        'description': hive.description,
        'type': hive.type,
        'breed': hive.breed,
        'queen_present': hive.queenPresent,
        'latitude': hive.latitude,
        'longitude': hive.longitude,
        'frames': hive.frames,
        'total': hive.total,
        'brood': hive.brood,
        'honey': hive.honey,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create hive');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['id'] as int;
  }

  Future<void> deleteHive({required String token, required int hiveServerId}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/hives/$hiveServerId');
    final response = await http.delete(uri, headers: _headers(token));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete hive');
    }
  }
}
