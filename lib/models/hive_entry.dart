import 'package:hive/hive.dart';
import 'hive_check_entry.dart';

part 'hive_entry.g.dart';

@HiveType(typeId: 0)
class HiveEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(16)
  int? serverId;

  @HiveField(1)
  final String? name;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final String type;

  @HiveField(4)
  List<String> notes;

  @HiveField(5)
  List<String> imagePaths;

  @HiveField(6)
  List<String> tags;

  @HiveField(7)
  double? latitude;

  @HiveField(8)
  double? longitude;

  @HiveField(9)
  int? frames;

  @HiveField(10)
  int? total;

  @HiveField(11)
  int? brood;

  @HiveField(12)
  int? honey;

  @HiveField(13)
  final List<HiveCheckEntry> history;

  @HiveField(14)
  final String? breed; // Rasa

  @HiveField(15)
  bool? queenPresent; // Podaci o matici: DA (true) / NE (false)

  HiveEntry({
    required this.id,
    this.serverId,
    this.name,
    this.description,
    required this.type,
    this.tags = const [],
    this.notes = const [],
    this.imagePaths = const [],
    this.latitude,
    this.longitude,
    this.frames,
    this.total,
    this.brood,
    this.honey,
    required this.history,
    this.breed,
    this.queenPresent,
  });
}