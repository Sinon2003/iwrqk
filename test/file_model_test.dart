import 'package:flutter_test/flutter_test.dart';
import 'package:iwrqk/app/data/models/file.dart';

void main() {
  test('preserves file size while accepting existing records without it', () {
    final old = FileModel.fromJson({'id': 'example', 'duration': 30});
    expect(old.size, isNull);
    final current = FileModel.fromJson({
      'id': 'example',
      'duration': 30,
      'size': 6000000,
    });
    expect(FileModel.fromJson(current.toJson()).size, 6000000);
  });
}
