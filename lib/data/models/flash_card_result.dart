import 'package:hive/hive.dart';

import 'exercise_metadata.dart';

part 'flash_card_result.g.dart';

@HiveType(typeId: 10)
class FlashCardResult extends HiveObject {
  FlashCardResult({
    required this.id,
    required this.profileId,
    required this.operation,
    required this.table,
    required this.multiplier,
    required this.status,
    required this.timestamp,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String profileId;

  @HiveField(2)
  OperationKind operation;

  @HiveField(3)
  int table;

  /// The multiplier or addend (e.g., for 3×7, this is 7)
  @HiveField(4)
  int multiplier;

  @HiveField(5)
  FlashCardStatus status;

  @HiveField(6)
  DateTime timestamp;
}

@HiveType(typeId: 11)
enum FlashCardStatus {
  @HiveField(0)
  gotIt,
  @HiveField(1)
  reviewAgain,
}

extension FlashCardStatusX on FlashCardStatus {
  String get label => switch (this) {
    FlashCardStatus.gotIt => 'Got it',
    FlashCardStatus.reviewAgain => 'Review Again',
  };
}

