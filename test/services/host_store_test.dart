import 'package:flutter_test/flutter_test.dart';
import 'package:witdget/services/host_store.dart';

void main() {
  test('memory host store loads, saves, and clears host', () async {
    final store = MemoryHostStore();
    expect(await store.load(), isNull);
    await store.save('192.168.1.10');
    expect(await store.load(), '192.168.1.10');
    await store.clear();
    expect(await store.load(), isNull);
  });
}
