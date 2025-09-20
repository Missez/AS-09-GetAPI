class CurrentWeather {
  final double temperature;
  final double apparentTemperature;
  final int weatherCode;
  final double windSpeed;
  final double humidity;
  final bool isDay;

  CurrentWeather({
    required this.temperature,
    required this.apparentTemperature,
    required this.weatherCode,
    required this.windSpeed,
    required this.humidity,
    required this.isDay,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    final c = json['current'] as Map<String, dynamic>;
    return CurrentWeather(
      temperature: (c['temperature_2m'] as num?)?.toDouble() ?? 0,
      apparentTemperature: (c['apparent_temperature'] as num?)?.toDouble() ?? 0,
      weatherCode: (c['weather_code'] as num?)?.toInt() ?? 0,
      windSpeed: (c['wind_speed_10m'] as num?)?.toDouble() ?? 0,
      humidity: (c['relative_humidity_2m'] as num?)?.toDouble() ?? 0,
      isDay: ((c['is_day'] as num?)?.toInt() ?? 1) == 1,
    );
  }
}

class HourlyPoint {
  final DateTime time;
  final double temperature;
  final double windSpeed;
  final int weatherCode;
  final double? humidity;
  final int? precipitationProb;

  HourlyPoint({
    required this.time,
    required this.temperature,
    required this.windSpeed,
    required this.weatherCode,
    this.humidity,
    this.precipitationProb,
  });
}

class DailyPoint {
  final DateTime date;
  final double tMax;
  final double tMin;
  final int weatherCode;
  final int? precipitationProbMax;
  final double? precipitationSum;

  DailyPoint({
    required this.date,
    required this.tMax,
    required this.tMin,
    required this.weatherCode,
    this.precipitationProbMax,
    this.precipitationSum,
  });
}

/// รวมทุกอย่างที่ดึงมาในครั้งเดียว
class WeatherBundle {
  final CurrentWeather current;
  final List<HourlyPoint> hourly; // แนะนำตัดแสดง 24-48 ชม.ถัดไปที่ UI
  final List<DailyPoint> daily;   // 7 วัน

  WeatherBundle({required this.current, required this.hourly, required this.daily});
}

/// แปลง weather_code -> คำอธิบาย
String weatherCodeToText(int code) {
  if (code == 0) return 'ท้องฟ้าแจ่มใส';
  if ([1, 2, 3].contains(code)) return 'มีเมฆบางส่วน/เมฆมาก';
  if ([45, 48].contains(code)) return 'หมอก/น้ำแข็งเกาะ';
  if ([51, 53, 55].contains(code)) return 'ฝนปรอยๆ';
  if ([61, 63, 65].contains(code)) return 'ฝนตก';
  if ([66, 67].contains(code)) return 'ฝนเย็นจัด';
  if ([71, 73, 75].contains(code)) return 'หิมะตก';
  if (code == 77) return 'หิมะเกล็ดแข็ง';
  if ([80, 81, 82].contains(code)) return 'ฝนตกเป็นช่วงๆ';
  if ([95].contains(code)) return 'พายุฝนฟ้าคะนอง';
  if ([96, 99].contains(code)) return 'พายุฟ้าคะนองลูกเห็บ';
  return 'สภาพอากาศไม่ทราบแน่ชัด';
}

String emojiForCode(int code, bool isDay) {
  if (code == 0) return isDay ? '☀️' : '🌙';
  if ([1, 2, 3].contains(code)) return '⛅';
  if ([45, 48].contains(code)) return '🌫️';
  if ([51, 53, 55].contains(code)) return '🌦️';
  if ([61, 63, 65, 80, 81, 82].contains(code)) return '🌧️';
  if ([95, 96, 99].contains(code)) return '⛈️';
  if ([71, 73, 75, 77].contains(code)) return '❄️';
  return '🌡️';
}
