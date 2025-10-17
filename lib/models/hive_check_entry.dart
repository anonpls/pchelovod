import 'package:hive/hive.dart';

part 'hive_check_entry.g.dart';

@HiveType(typeId: 1)
class HiveCheckEntry {
  @HiveField(0)
  final DateTime timestamp;

  @HiveField(1)
  final int? frames;

  // Jačina društva (ranije koristili total)
  @HiveField(2)
  final int? total;

  @HiveField(3)
  final int? brood;

  @HiveField(4)
  final int? honey;

  HiveCheckEntry({
    required this.timestamp,
    this.frames,
    this.total,
    this.brood,
    this.honey,
  });

  @override
  String toString() {
    return '${timestamp.toIso8601String()};${frames ?? ''};${total ?? ''};${brood ?? ''};${honey ?? ''}';
  }
}