import 'package:flutter_test/flutter_test.dart';

import 'package:prayer_guide/data/qibla.dart';

void main() {
  group('the direction of the Kaaba', () {
    /// Bearings checked against published qibla directions for each city.
    /// The tolerance allows for slightly different city centre coordinates.
    void expectBearing(QiblaCity city, double expected, {double within = 2}) {
      final actual = Qibla.bearingFrom(city.latitude, city.longitude);
      expect(actual, closeTo(expected, within),
          reason: '${city.label} should point at about $expected degrees');
    }

    test('points north east from North America', () {
      // The great circle from North America runs well north of due east,
      // which is the result a flat map gets wrong.
      expectBearing(Qibla.defaultCity, 53.3);
      expectBearing(
          Qibla.cities.firstWhere((c) => c.name == 'Toronto'), 54.6);
      expectBearing(
          Qibla.cities.firstWhere((c) => c.name == 'New York'), 58.5);
    });

    test('points south east from Britain', () {
      final london = Qibla.cities.firstWhere(
        (c) => c.name == 'London' && c.country == 'United Kingdom',
      );
      expectBearing(london, 119.0);
    });

    test('points north from southern Africa', () {
      // Cape Town lies south of Mecca, so the qibla is northward.
      expectBearing(
          Qibla.cities.firstWhere((c) => c.name == 'Cape Town'), 23.4);
    });

    test('points west from the far east', () {
      expectBearing(
          Qibla.cities.firstWhere((c) => c.name == 'Jakarta'), 295.2);
      expectBearing(Qibla.cities.firstWhere((c) => c.name == 'Tokyo'), 293.0);
      expectBearing(Qibla.cities.firstWhere((c) => c.name == 'Sydney'), 277.5);
    });

    test('is always a compass bearing', () {
      for (final city in Qibla.cities) {
        final bearing = Qibla.bearingFrom(city.latitude, city.longitude);
        expect(bearing, greaterThanOrEqualTo(0),
            reason: '${city.label} produced $bearing');
        expect(bearing, lessThan(360));
        expect(bearing.isNaN, isFalse);
      }
    });
  });

  group('distance', () {
    test('is nothing at the Kaaba itself', () {
      final d = Qibla.distanceKmFrom(Qibla.kaabaLatitude, Qibla.kaabaLongitude);
      expect(d, closeTo(0, 1));
    });

    test('matches known distances', () {
      final toronto = Qibla.cities.firstWhere((c) => c.name == 'Toronto');
      expect(Qibla.distanceKmFrom(toronto.latitude, toronto.longitude),
          closeTo(10496, 50));

      final medina = Qibla.cities.firstWhere((c) => c.name == 'Medina');
      expect(Qibla.distanceKmFrom(medina.latitude, medina.longitude),
          closeTo(339, 20));
    });

    test('never exceeds half the way around the earth', () {
      for (final city in Qibla.cities) {
        final d = Qibla.distanceKmFrom(city.latitude, city.longitude);
        expect(d, lessThan(20100), reason: '${city.label} is $d km away');
        expect(d, greaterThanOrEqualTo(0));
      }
    });
  });

  group('compass points', () {
    test('name the right sector', () {
      expect(Qibla.compassPoint(0), 'N');
      expect(Qibla.compassPoint(45), 'NE');
      expect(Qibla.compassPoint(90), 'E');
      expect(Qibla.compassPoint(180), 'S');
      expect(Qibla.compassPoint(270), 'W');
      expect(Qibla.compassPoint(359), 'N', reason: 'wraps back to north');
    });

    test('round to the nearest of the sixteen', () {
      expect(Qibla.compassPoint(53.3), 'NE');
      expect(Qibla.compassPoint(119.0), 'ESE');
      expect(Qibla.compassPoint(295.2), 'WNW');
    });
  });

  group('the city list', () {
    test('opens on London Ontario', () {
      expect(Qibla.defaultCity.name, 'London');
      expect(Qibla.defaultCity.country, contains('Ontario'));
    });

    test('includes the default so the dropdown can show it', () {
      // A DropdownButton throws when its value is not among the items.
      final matches = Qibla.cities.where(
        (c) => c.name == Qibla.defaultCity.name &&
            c.country == Qibla.defaultCity.country,
      );
      expect(matches, hasLength(1),
          reason: 'exactly one entry must match the default');
    });

    test('has no duplicates', () {
      final labels = Qibla.cities.map((c) => c.label).toList();
      expect(labels.toSet(), hasLength(labels.length));
    });

    test('holds plausible coordinates', () {
      for (final city in Qibla.cities) {
        expect(city.latitude, inInclusiveRange(-90, 90));
        expect(city.longitude, inInclusiveRange(-180, 180));
      }
    });

    test('spans the world', () {
      expect(Qibla.cities.length, greaterThan(40));

      final countries = Qibla.cities.map((c) => c.country).toSet();
      expect(countries.length, greaterThan(25));

      // Both hemispheres, north and south, east and west.
      expect(Qibla.cities.any((c) => c.latitude < 0), isTrue);
      expect(Qibla.cities.any((c) => c.latitude > 0), isTrue);
      expect(Qibla.cities.any((c) => c.longitude < 0), isTrue);
      expect(Qibla.cities.any((c) => c.longitude > 0), isTrue);
    });

    test('distinguishes the two Londons', () {
      final londons = Qibla.cities.where((c) => c.name == 'London').toList();
      expect(londons, hasLength(2));

      final bearings = londons
          .map((c) => Qibla.bearingFrom(c.latitude, c.longitude))
          .toList();
      // One points north east, the other south east.
      expect((bearings[0] - bearings[1]).abs(), greaterThan(50));
    });
  });
}
