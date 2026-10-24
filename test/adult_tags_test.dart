import 'package:flutter_test/flutter_test.dart';
import 'package:readtrack/data/adult_tags.dart';

void main() {
  test('recognizes adult tags in English and Russian', () {
    for (final tag in [
      'Anal Sex',
      'Explicit Sexual Content',
      'Smut',
      'NSFW',
      'Анальный секс',
      'Изнасилование',
      'Underage',
      'BDSM',
    ]) {
      expect(looksAdult(tag), isTrue, reason: tag);
    }
  });

  test('does not flag ordinary tags', () {
    for (final tag in [
      'Analysis',
      'Action',
      'Marriage',
      'Child Care',
      'Kingdom Building',
      'Ангст',
      'Sussex',
      'Hurt/Comfort',
    ]) {
      expect(looksAdult(tag), isFalse, reason: tag);
    }
  });
}
