import 'package:uuid/uuid.dart';

import 'id_generator.dart';

class UuidGenerator implements IdGenerator {
  static const _uuid = Uuid();

  @override
  String generate() => _uuid.v4();
}
