import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_models.dart';

class WeatherService {
  static const _base = 'https://api.open-meteo.com/v1/forecast';

  Future<WeatherBundle> fetchAll({
    required double lat,
    required double lon,
  }) async {
    final uri = Uri.parse(_base).replace(queryParameters: {
      'latitude': '$lat',
      'longitude': '$lon',
      'timezone': 'Asia/Bangkok',

      // ตอนนี้: current
      'current':
          'temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,wind_speed_10m',

      // รายชั่วโมง
      'hourly':
          'temperature_2m,relative_humidity_2m,precipitation_probability,weather_code,wind_speed_10m',

      // รายวัน (7 วัน)
      'daily':
          'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,precipitation_sum',
      'forecast_days': '7',
    });

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    final Map<String, dynamic> json = jsonDecode(res.body);

    // current
    final current = CurrentWeather.fromJson(json);

    // hourly
    final h = (json['hourly'] as Map<String, dynamic>);
    final List times = h['time'] as List;
    final List temps = h['temperature_2m'] as List;
    final List wind = h['wind_speed_10m'] as List;
    final List codes = h['weather_code'] as List;
    final List? rh = h['relative_humidity_2m'] as List?;
    final List? pprob = h['precipitation_probability'] as List?;
    final hourly = <HourlyPoint>[
      for (int i = 0; i < times.length; i++)
        HourlyPoint(
          time: DateTime.parse(times[i] as String),
          temperature: (temps[i] as num?)?.toDouble() ?? 0,
          windSpeed: (wind[i] as num?)?.toDouble() ?? 0,
          weatherCode: (codes[i] as num?)?.toInt() ?? 0,
          humidity: rh != null ? (rh[i] as num?)?.toDouble() : null,
          precipitationProb: pprob != null ? (pprob[i] as num?)?.toInt() : null,
        )
    ];

    // daily
    final d = (json['daily'] as Map<String, dynamic>);
    final List dTimes = d['time'] as List;
    final List dTmax = d['temperature_2m_max'] as List;
    final List dTmin = d['temperature_2m_min'] as List;
    final List dCode = d['weather_code'] as List;
    final List? dPprobMax = d['precipitation_probability_max'] as List?;
    final List? dPsum = d['precipitation_sum'] as List?;
    final daily = <DailyPoint>[
      for (int i = 0; i < dTimes.length; i++)
        DailyPoint(
          date: DateTime.parse(dTimes[i] as String),
          tMax: (dTmax[i] as num?)?.toDouble() ?? 0,
          tMin: (dTmin[i] as num?)?.toDouble() ?? 0,
          weatherCode: (dCode[i] as num?)?.toInt() ?? 0,
          precipitationProbMax:
              dPprobMax != null ? (dPprobMax[i] as num?)?.toInt() : null,
          precipitationSum:
              dPsum != null ? (dPsum[i] as num?)?.toDouble() : null,
        )
    ];

    return WeatherBundle(current: current, hourly: hourly, daily: daily);
  }
}
