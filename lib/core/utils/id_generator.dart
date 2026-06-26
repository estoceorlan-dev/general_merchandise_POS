import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final idGeneratorProvider = Provider<IdGenerator>((ref) {
  return const UuidIdGenerator();
});

abstract interface class IdGenerator {
  String newId();
}

final class UuidIdGenerator implements IdGenerator {
  const UuidIdGenerator();

  static const _uuid = Uuid();

  @override
  String newId() => _uuid.v4();
}

final class FixedIdGenerator implements IdGenerator {
  const FixedIdGenerator(this.value);

  final String value;

  @override
  String newId() => value;
}
