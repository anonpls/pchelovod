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

  int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  bool? _asBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value.toString().trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
    return null;
  }

  String _extractError(String body, {required String fallback}) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded['error']?.toString() ?? fallback;
      }
      return fallback;
    } catch (_) {
      return fallback;
    }
  }

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
        serverId: _asInt(m['id']),
        id: (m['hive_code'] ?? '').toString(),
        name: m['name']?.toString(),
        description: m['description']?.toString(),
        type: (m['type'] ?? 'LR').toString(),
        breed: m['breed']?.toString(),
        queenPresent: _asBool(m['queen_present']),
        latitude: (m['latitude'] as num?)?.toDouble(),
        longitude: (m['longitude'] as num?)?.toDouble(),
        frames: _asInt(m['frames']),
        total: _asInt(m['total']),
        brood: _asInt(m['brood']),
        honey: _asInt(m['honey']),
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
      throw Exception(
        _extractError(response.body, fallback: 'Failed to create hive'),
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final id = _asInt(data['id']);
    if (id == null) {
      throw Exception('Invalid create hive response: missing numeric id');
    }
    return id;
  }

  Future<void> deleteHive({required String token, required int hiveServerId}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/hives/$hiveServerId');
    final response = await http.delete(uri, headers: _headers(token));
    if (response.statusCode != 204) {
      throw Exception(_extractError(response.body, fallback: 'Failed to delete hive'));
    }
  }
}
