import 'dart:math' as math;

/// A place the qibla can be worked out from.
class QiblaCity {
  final String name;
  final String country;
  final double latitude;
  final double longitude;

  const QiblaCity(this.name, this.country, this.latitude, this.longitude);

  String get label => '$name, $country';
}

/// Direction of the Kaaba, and the great circle maths behind it.
///
/// The bearing is the initial heading of the shortest path over the surface
/// of the earth, which is what the qibla is taken to be. It is not the same
/// as pointing along a flat map: from North America the path runs well north
/// of due east.
class Qibla {
  Qibla._();

  /// The Kaaba, Masjid al-Haram, Mecca.
  static const double kaabaLatitude = 21.4224779;
  static const double kaabaLongitude = 39.8251832;

  static double _toRadians(double degrees) => degrees * math.pi / 180;

  static double _toDegrees(double radians) => radians * 180 / math.pi;

  /// The compass bearing to the Kaaba, in degrees clockwise from true north.
  static double bearingFrom(double latitude, double longitude) {
    final lat1 = _toRadians(latitude);
    final lat2 = _toRadians(kaabaLatitude);
    final deltaLon = _toRadians(kaabaLongitude - longitude);

    final y = math.sin(deltaLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(deltaLon);

    final bearing = _toDegrees(math.atan2(y, x));
    return (bearing + 360) % 360;
  }

  /// Distance to the Kaaba in kilometres, along the same great circle.
  static double distanceKmFrom(double latitude, double longitude) {
    const earthRadiusKm = 6371.0088;

    final lat1 = _toRadians(latitude);
    final lat2 = _toRadians(kaabaLatitude);
    final deltaLat = _toRadians(kaabaLatitude - latitude);
    final deltaLon = _toRadians(kaabaLongitude - longitude);

    final a = math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(lat1) * math.cos(lat2) *
            math.sin(deltaLon / 2) * math.sin(deltaLon / 2);

    return earthRadiusKm * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  /// Turns a bearing into the nearest compass point, for reading aloud.
  static String compassPoint(double bearing) {
    const points = [
      'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
      'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW',
    ];
    final index = (((bearing % 360) + 11.25) / 22.5).floor() % 16;
    return points[index];
  }

  /// The default place, where the timetable in this app comes from.
  static const QiblaCity defaultCity =
      QiblaCity('London', 'Ontario, Canada', 42.9849, -81.2453);

  /// Major cities, sorted by name within each region.
  static const List<QiblaCity> cities = [
    // Canada
    QiblaCity('Calgary', 'Canada', 51.0447, -114.0719),
    QiblaCity('London', 'Ontario, Canada', 42.9849, -81.2453),
    QiblaCity('Montreal', 'Canada', 45.5019, -73.5674),
    QiblaCity('Ottawa', 'Canada', 45.4215, -75.6972),
    QiblaCity('Toronto', 'Canada', 43.6532, -79.3832),
    QiblaCity('Vancouver', 'Canada', 49.2827, -123.1207),

    // United States
    QiblaCity('Chicago', 'United States', 41.8781, -87.6298),
    QiblaCity('Detroit', 'United States', 42.3314, -83.0458),
    QiblaCity('Houston', 'United States', 29.7604, -95.3698),
    QiblaCity('Los Angeles', 'United States', 34.0522, -118.2437),
    QiblaCity('New York', 'United States', 40.7128, -74.0060),
    QiblaCity('Washington', 'United States', 38.9072, -77.0369),

    // South America
    QiblaCity('Buenos Aires', 'Argentina', -34.6037, -58.3816),
    QiblaCity('Sao Paulo', 'Brazil', -23.5558, -46.6396),

    // Europe
    QiblaCity('Amsterdam', 'Netherlands', 52.3676, 4.9041),
    QiblaCity('Berlin', 'Germany', 52.5200, 13.4050),
    QiblaCity('Brussels', 'Belgium', 50.8476, 4.3572),
    QiblaCity('London', 'United Kingdom', 51.5072, -0.1276),
    QiblaCity('Madrid', 'Spain', 40.4168, -3.7038),
    QiblaCity('Moscow', 'Russia', 55.7558, 37.6173),
    QiblaCity('Paris', 'France', 48.8566, 2.3522),
    QiblaCity('Rome', 'Italy', 41.9028, 12.4964),
    QiblaCity('Stockholm', 'Sweden', 59.3293, 18.0686),

    // Africa
    QiblaCity('Cairo', 'Egypt', 30.0444, 31.2357),
    QiblaCity('Cape Town', 'South Africa', -33.9249, 18.4241),
    QiblaCity('Casablanca', 'Morocco', 33.5731, -7.5898),
    QiblaCity('Lagos', 'Nigeria', 6.5244, 3.3792),
    QiblaCity('Nairobi', 'Kenya', -1.2921, 36.8219),

    // Middle East
    QiblaCity('Baghdad', 'Iraq', 33.3152, 44.3661),
    QiblaCity('Dubai', 'United Arab Emirates', 25.2048, 55.2708),
    QiblaCity('Istanbul', 'Turkey', 41.0082, 28.9784),
    QiblaCity('Jerusalem', 'Palestine', 31.7683, 35.2137),
    QiblaCity('Mecca', 'Saudi Arabia', 21.4225, 39.8262),
    QiblaCity('Medina', 'Saudi Arabia', 24.4686, 39.6142),
    QiblaCity('Tehran', 'Iran', 35.6892, 51.3890),

    // Asia
    QiblaCity('Dhaka', 'Bangladesh', 23.8103, 90.4125),
    QiblaCity('Jakarta', 'Indonesia', -6.2088, 106.8456),
    QiblaCity('Karachi', 'Pakistan', 24.8607, 67.0011),
    QiblaCity('Kuala Lumpur', 'Malaysia', 3.1390, 101.6869),
    QiblaCity('Lahore', 'Pakistan', 31.5204, 74.3587),
    QiblaCity('Mumbai', 'India', 19.0760, 72.8777),
    QiblaCity('New Delhi', 'India', 28.6139, 77.2090),
    QiblaCity('Seoul', 'South Korea', 37.5665, 126.9780),
    QiblaCity('Shanghai', 'China', 31.2304, 121.4737),
    QiblaCity('Singapore', 'Singapore', 1.3521, 103.8198),
    QiblaCity('Tokyo', 'Japan', 35.6762, 139.6503),

    // Oceania
    QiblaCity('Auckland', 'New Zealand', -36.8485, 174.7633),
    QiblaCity('Melbourne', 'Australia', -37.8136, 144.9631),
    QiblaCity('Sydney', 'Australia', -33.8688, 151.2093),
  ];
}
