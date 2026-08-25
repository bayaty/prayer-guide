import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_guide/services/update_service.dart';

void main() {
  group('UpdateService.isNewer', () {
    test('detects a newer patch release', () {
      expect(UpdateService.isNewer('v1.0.1', '1.0.0'), isTrue);
    });

    test('same version is not newer', () {
      expect(UpdateService.isNewer('1.0.0', '1.0.0'), isFalse);
    });

    test('older remote is not newer', () {
      expect(UpdateService.isNewer('v1.0.0', '1.0.1'), isFalse);
    });

    test('major bump wins over minor/patch', () {
      expect(UpdateService.isNewer('v2.0.0', '1.9.9'), isTrue);
    });

    test('compares numerically, not lexically (1.10 > 1.9)', () {
      expect(UpdateService.isNewer('v1.10.0', '1.9.0'), isTrue);
    });

    test('ignores the +build suffix', () {
      expect(UpdateService.isNewer('v1.0.0', '1.0.0+1'), isFalse);
    });

    test('handles differing segment counts', () {
      expect(UpdateService.isNewer('v1.2', '1.1.9'), isTrue);
      expect(UpdateService.isNewer('v1.0.0', '1.0'), isFalse);
    });

    test('tolerates a missing v prefix on either side', () {
      expect(UpdateService.isNewer('1.0.1', 'v1.0.0'), isTrue);
    });
  });
}
