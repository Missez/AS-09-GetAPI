# Weather App - Flutter HTTP API Project

แอปพลิเคชันแสดงสภาพอากาศที่พัฒนาด้วย Flutter โดยใช้ Open-Meteo API พร้อม UI แบบ Modern Dark Theme

<img width="433" height="996" alt="image" src="https://github.com/user-attachments/assets/30c82b0e-2e2e-4cf8-9b4c-1955f4206973" />
<img width="433" height="992" alt="image" src="https://github.com/user-attachments/assets/b4df52a7-67b3-409e-b730-df7caa55e333" />
<img width="440" height="924" alt="image" src="https://github.com/user-attachments/assets/bf247a97-1342-47d7-97b3-b7cf51ae4086" />


## 📋 สารบัญ
1. [ภาพรวมโปรเจกต์](#ภาพรวมโปรเจกต์)
2. [การศึกษาการใช้งาน API](#การศึกษาการใช้งาน-api)
3. [การสร้าง Class สำหรับข้อมูล](#การสร้าง-class-สำหรับข้อมูล)
4. [หลักการใช้งาน HTTP และ Provider](#หลักการใช้งาน-http-และ-provider)
5. [การนำ HTTP และ Provider มาใช้งานใน App](#การนำ-http-และ-provider-มาใช้งานใน-app)
6. [การออกแบบหน้า App](#การออกแบบหน้า-app)
7. [อธิบายโค้ดอย่างละเอียด](#อธิบายโค้ดอย่างละเอียด)
8. [การติดตั้งและรันโปรเจกต์](#การติดตั้งและรันโปรเจกต์)

---

## 🎯 ภาพรวมโปรเจกต์

โปรเจกต์นี้เป็นแอปพลิเคชันแสดงสภาพอากาศที่ใช้:
- **Flutter Framework** สำหรับ UI
- **Open-Meteo API** สำหรับข้อมูลสภาพอากาศ
- **Provider Pattern** สำหรับ State Management
- **HTTP Package** สำหรับการเรียก API
- **Custom Paint** สำหรับพื้นหลังแบบ Animation

### โครงสร้างโปรเจกต์
```
lib/
├── main.dart                 # Entry point และ UI หลัก
├── models/
│   └── weather_models.dart   # Data models
├── services/
│   └── weather_service.dart  # API service
├── providers/
│   └── weather_provider.dart # State management
└── data/
    └── th_cities.dart        # ข้อมูลเมืองไทย
```

---

## 🔍 การศึกษาการใช้งาน API

### Open-Meteo API
Open-Meteo เป็น API ฟรีสำหรับข้อมูลสภาพอากาศที่มีความแม่นยำสูง

#### Base URL
```
https://api.open-meteo.com/v1/forecast
```

#### Parameters ที่ใช้
```dart
{
  'latitude': '13.7563',           // ละติจูด
  'longitude': '100.5018',         // ลองจิจูด
  'timezone': 'Asia/Bangkok',      // เขตเวลา
  
  // ข้อมูลปัจจุบัน
  'current': 'temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,wind_speed_10m',
  
  // ข้อมูลรายชั่วโมง
  'hourly': 'temperature_2m,relative_humidity_2m,precipitation_probability,weather_code,wind_speed_10m',
  
  // ข้อมูลรายวัน
  'daily': 'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,precipitation_sum',
  'forecast_days': '7',            // 7 วันข้างหน้า
}
```

#### Response Format
```json
{
  "current": {
    "temperature_2m": 28.5,
    "relative_humidity_2m": 75,
    "apparent_temperature": 32.1,
    "is_day": 1,
    "precipitation": 0,
    "weather_code": 61,
    "wind_speed_10m": 2.3
  },
  "hourly": {
    "time": ["2024-01-01T00:00", "2024-01-01T01:00", ...],
    "temperature_2m": [25.1, 24.8, ...],
    "weather_code": [61, 61, ...],
    "precipitation_probability": [80, 75, ...]
  },
  "daily": {
    "time": ["2024-01-01", "2024-01-02", ...],
    "temperature_2m_max": [30.2, 31.5, ...],
    "temperature_2m_min": [24.1, 25.3, ...],
    "weather_code": [61, 0, ...]
  }
}
# Weather App - ส่วนที่ 2: Data Models และ HTTP

## 🏗️ การสร้าง Class สำหรับข้อมูล

### 1. CurrentWeather Class
```dart
class CurrentWeather {
  final double temperature;           // อุณหภูมิ
  final double apparentTemperature;   // อุณหภูมิที่รู้สึก
  final int weatherCode;              // รหัสสภาพอากาศ
  final double windSpeed;             // ความเร็วลม
  final double humidity;              // ความชื้น
  final bool isDay;                   // กลางวัน/กลางคืน

  CurrentWeather({
    required this.temperature,
    required this.apparentTemperature,
    required this.weatherCode,
    required this.windSpeed,
    required this.humidity,
    required this.isDay,
  });

  // Factory constructor สำหรับแปลงจาก JSON
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
```

### 2. HourlyPoint Class
```dart
class HourlyPoint {
  final DateTime time;                // เวลา
  final double temperature;           // อุณหภูมิ
  final double windSpeed;             // ความเร็วลม
  final int weatherCode;              // รหัสสภาพอากาศ
  final double? humidity;             // ความชื้น (nullable)
  final int? precipitationProb;       // โอกาสฝน (nullable)

  HourlyPoint({
    required this.time,
    required this.temperature,
    required this.windSpeed,
    required this.weatherCode,
    this.humidity,
    this.precipitationProb,
  });
}
```

### 3. DailyPoint Class
```dart
class DailyPoint {
  final DateTime date;                // วันที่
  final double tMax;                  // อุณหภูมิสูงสุด
  final double tMin;                  // อุณหภูมิต่ำสุด
  final int weatherCode;              // รหัสสภาพอากาศ
  final int? precipitationProbMax;    // โอกาสฝนสูงสุด (nullable)
  final double? precipitationSum;     // ปริมาณฝนรวม (nullable)

  DailyPoint({
    required this.date,
    required this.tMax,
    required this.tMin,
    required this.weatherCode,
    this.precipitationProbMax,
    this.precipitationSum,
  });
}
```

### 4. WeatherBundle Class
```dart
class WeatherBundle {
  final CurrentWeather current;       // ข้อมูลปัจจุบัน
  final List<HourlyPoint> hourly;     // ข้อมูลรายชั่วโมง
  final List<DailyPoint> daily;       // ข้อมูลรายวัน

  WeatherBundle({
    required this.current,
    required this.hourly,
    required this.daily,
  });
}
```

### 5. Helper Functions
```dart
// แปลงรหัสสภาพอากาศเป็นคำอธิบาย
String weatherCodeToText(int code) {
  if (code == 0) return 'ท้องฟ้าแจ่มใส';
  if ([1, 2, 3].contains(code)) return 'มีเมฆบางส่วน/เมฆมาก';
  if ([45, 48].contains(code)) return 'หมอก/น้ำแข็งเกาะ';
  if ([51, 53, 55].contains(code)) return 'ฝนปรอยๆ';
  if ([61, 63, 65].contains(code)) return 'ฝนตก';
  if ([95, 96, 99].contains(code)) return 'พายุฝนฟ้าคะนอง';
  return 'สภาพอากาศไม่ทราบแน่ชัด';
}

// แปลงรหัสสภาพอากาศเป็น emoji
String emojiForCode(int code, bool isDay) {
  if (code == 0) return isDay ? '☀️' : '🌙';
  if ([1, 2, 3].contains(code)) return '⛅';
  if ([45, 48].contains(code)) return '🌫️';
  if ([51, 53, 55].contains(code)) return '🌦️';
  if ([61, 63, 65].contains(code)) return '🌧️';
  if ([95, 96, 99].contains(code)) return '⛈️';
  if ([71, 73, 75].contains(code)) return '❄️';
  return '🌡️';
}
```

---

## 🔧 หลักการใช้งาน HTTP และ Provider

### HTTP Package
HTTP package ใช้สำหรับการเรียก API และรับข้อมูล JSON

#### การติดตั้ง
```yaml
dependencies:
  http: ^1.1.0
```

#### การใช้งานพื้นฐาน
```dart
import 'package:http/http.dart' as http;

// GET request
final response = await http.get(Uri.parse('https://api.example.com/data'));

// ตรวจสอบ status code
if (response.statusCode == 200) {
  // แปลง JSON string เป็น Map
  final Map<String, dynamic> json = jsonDecode(response.body);
  // ประมวลผลข้อมูล
} else {
  throw Exception('HTTP ${response.statusCode}: ${response.body}');
}
```

### Provider Pattern
Provider เป็น State Management pattern ที่ใช้จัดการ state ของแอปพลิเคชัน

#### การติดตั้ง
```yaml
dependencies:
  provider: ^6.1.1
```

#### การใช้งานพื้นฐาน
```dart
import 'package:provider/provider.dart';

// 1. สร้าง Provider class
class WeatherProvider extends ChangeNotifier {
  WeatherData? _data;
  bool _loading = false;
  String? _error;

  WeatherData? get data => _data;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchData() async {
    _loading = true;
    notifyListeners(); // แจ้ง UI ให้อัปเดต

    try {
      _data = await apiService.getData();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}

// 2. ตั้งค่า Provider ใน main
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => WeatherProvider(),
      child: MyApp(),
    ),
  );
}

// 3. ใช้งานใน Widget
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();
    
    if (provider.loading) {
      return CircularProgressIndicator();
    }
    
    if (provider.error != null) {
      return Text('Error: ${provider.error}');
    }
    
    return Text('Data: ${provider.data}');
  }
}
```

---

## 🚀 การนำ HTTP และ Provider มาใช้งานใน App

### 1. WeatherService Class
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_models.dart';

class WeatherService {
  static const _base = 'https://api.open-meteo.com/v1/forecast';

  Future<WeatherBundle> fetchAll({
    required double lat,
    required double lon,
  }) async {
    // สร้าง URL พร้อม parameters
    final uri = Uri.parse(_base).replace(queryParameters: {
      'latitude': '$lat',
      'longitude': '$lon',
      'timezone': 'Asia/Bangkok',
      'current': 'temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,wind_speed_10m',
      'hourly': 'temperature_2m,relative_humidity_2m,precipitation_probability,weather_code,wind_speed_10m',
      'daily': 'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,precipitation_sum',
      'forecast_days': '7',
    });

    // ส่ง HTTP GET request
    final res = await http.get(uri);
    
    // ตรวจสอบ status code
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    
    // แปลง JSON string เป็น Map
    final Map<String, dynamic> json = jsonDecode(res.body);

    // สร้าง CurrentWeather object
    final current = CurrentWeather.fromJson(json);

    // ประมวลผลข้อมูล hourly
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

    // ประมวลผลข้อมูล daily
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
          precipitationProbMax: dPprobMax != null ? (dPprobMax[i] as num?)?.toInt() : null,
          precipitationSum: dPsum != null ? (dPsum[i] as num?)?.toDouble() : null,
        )
    ];

    return WeatherBundle(current: current, hourly: hourly, daily: daily);
  }
}
```

### 2. WeatherProvider Class
```dart
import 'package:flutter/foundation.dart';
import '../data/th_cities.dart';
import '../models/weather_models.dart';
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  final _service = WeatherService();

  THCity _selected = thNorthernProvinces.first;
  WeatherBundle? _bundle;
  bool _loading = false;
  String? _error;

  // Getters
  THCity get selected => _selected;
  WeatherBundle? get bundle => _bundle;
  bool get loading => _loading;
  String? get error => _error;

  // โหลดข้อมูลสภาพอากาศ
  Future<void> load() async {
    _error = null;
    _loading = true;
    notifyListeners(); // แจ้ง UI ให้แสดง loading

    try {
      _bundle = await _service.fetchAll(
        lat: _selected.lat,
        lon: _selected.lon,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners(); // แจ้ง UI ให้ซ่อน loading
    }
  }

  // เปลี่ยนเมือง
  void selectCity(THCity city) {
    _selected = city;
    load(); // โหลดข้อมูลใหม่
  }

  // รีเฟรชข้อมูล
  Future<void> refresh() => load();
}
```

### 3. การตั้งค่าใน main.dart
```dart
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => WeatherProvider()..load(), // สร้าง provider และโหลดข้อมูลทันที
      child: const WeatherApp(),
    ),
  );
}

class WeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          onPrimary: Colors.black,
          secondary: Colors.blue,
          surface: Color(0xFF1A1A1A),
          onSurface: Colors.white,
        ),
      ),
      home: const WeatherHomePage(),
    );
  }
}
```
# Weather App - ส่วนที่ 2: Data Models และ HTTP

## 🏗️ การสร้าง Class สำหรับข้อมูล

### 1. CurrentWeather Class
```dart
class CurrentWeather {
  final double temperature;           // อุณหภูมิ
  final double apparentTemperature;   // อุณหภูมิที่รู้สึก
  final int weatherCode;              // รหัสสภาพอากาศ
  final double windSpeed;             // ความเร็วลม
  final double humidity;              // ความชื้น
  final bool isDay;                   // กลางวัน/กลางคืน

  CurrentWeather({
    required this.temperature,
    required this.apparentTemperature,
    required this.weatherCode,
    required this.windSpeed,
    required this.humidity,
    required this.isDay,
  });

  // Factory constructor สำหรับแปลงจาก JSON
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
```

### 2. HourlyPoint Class
```dart
class HourlyPoint {
  final DateTime time;                // เวลา
  final double temperature;           // อุณหภูมิ
  final double windSpeed;             // ความเร็วลม
  final int weatherCode;              // รหัสสภาพอากาศ
  final double? humidity;             // ความชื้น (nullable)
  final int? precipitationProb;       // โอกาสฝน (nullable)

  HourlyPoint({
    required this.time,
    required this.temperature,
    required this.windSpeed,
    required this.weatherCode,
    this.humidity,
    this.precipitationProb,
  });
}
```

### 3. DailyPoint Class
```dart
class DailyPoint {
  final DateTime date;                // วันที่
  final double tMax;                  // อุณหภูมิสูงสุด
  final double tMin;                  // อุณหภูมิต่ำสุด
  final int weatherCode;              // รหัสสภาพอากาศ
  final int? precipitationProbMax;    // โอกาสฝนสูงสุด (nullable)
  final double? precipitationSum;     // ปริมาณฝนรวม (nullable)

  DailyPoint({
    required this.date,
    required this.tMax,
    required this.tMin,
    required this.weatherCode,
    this.precipitationProbMax,
    this.precipitationSum,
  });
}
```

### 4. WeatherBundle Class
```dart
class WeatherBundle {
  final CurrentWeather current;       // ข้อมูลปัจจุบัน
  final List<HourlyPoint> hourly;     // ข้อมูลรายชั่วโมง
  final List<DailyPoint> daily;       // ข้อมูลรายวัน

  WeatherBundle({
    required this.current,
    required this.hourly,
    required this.daily,
  });
}
```

### 5. Helper Functions
```dart
// แปลงรหัสสภาพอากาศเป็นคำอธิบาย
String weatherCodeToText(int code) {
  if (code == 0) return 'ท้องฟ้าแจ่มใส';
  if ([1, 2, 3].contains(code)) return 'มีเมฆบางส่วน/เมฆมาก';
  if ([45, 48].contains(code)) return 'หมอก/น้ำแข็งเกาะ';
  if ([51, 53, 55].contains(code)) return 'ฝนปรอยๆ';
  if ([61, 63, 65].contains(code)) return 'ฝนตก';
  if ([95, 96, 99].contains(code)) return 'พายุฝนฟ้าคะนอง';
  return 'สภาพอากาศไม่ทราบแน่ชัด';
}

// แปลงรหัสสภาพอากาศเป็น emoji
String emojiForCode(int code, bool isDay) {
  if (code == 0) return isDay ? '☀️' : '🌙';
  if ([1, 2, 3].contains(code)) return '⛅';
  if ([45, 48].contains(code)) return '🌫️';
  if ([51, 53, 55].contains(code)) return '🌦️';
  if ([61, 63, 65].contains(code)) return '🌧️';
  if ([95, 96, 99].contains(code)) return '⛈️';
  if ([71, 73, 75].contains(code)) return '❄️';
  return '🌡️';
}
```

---

## 🔧 หลักการใช้งาน HTTP และ Provider

### HTTP Package
HTTP package ใช้สำหรับการเรียก API และรับข้อมูล JSON

#### การติดตั้ง
```yaml
dependencies:
  http: ^1.1.0
```

#### การใช้งานพื้นฐาน
```dart
import 'package:http/http.dart' as http;

// GET request
final response = await http.get(Uri.parse('https://api.example.com/data'));

// ตรวจสอบ status code
if (response.statusCode == 200) {
  // แปลง JSON string เป็น Map
  final Map<String, dynamic> json = jsonDecode(response.body);
  // ประมวลผลข้อมูล
} else {
  throw Exception('HTTP ${response.statusCode}: ${response.body}');
}
```

### Provider Pattern
Provider เป็น State Management pattern ที่ใช้จัดการ state ของแอปพลิเคชัน

#### การติดตั้ง
```yaml
dependencies:
  provider: ^6.1.1
```

#### การใช้งานพื้นฐาน
```dart
import 'package:provider/provider.dart';

// 1. สร้าง Provider class
class WeatherProvider extends ChangeNotifier {
  WeatherData? _data;
  bool _loading = false;
  String? _error;

  WeatherData? get data => _data;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchData() async {
    _loading = true;
    notifyListeners(); // แจ้ง UI ให้อัปเดต

    try {
      _data = await apiService.getData();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}

// 2. ตั้งค่า Provider ใน main
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => WeatherProvider(),
      child: MyApp(),
    ),
  );
}

// 3. ใช้งานใน Widget
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();
    
    if (provider.loading) {
      return CircularProgressIndicator();
    }
    
    if (provider.error != null) {
      return Text('Error: ${provider.error}');
    }
    
    return Text('Data: ${provider.data}');
  }
}
```

---

## 🚀 การนำ HTTP และ Provider มาใช้งานใน App

### 1. WeatherService Class
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_models.dart';

class WeatherService {
  static const _base = 'https://api.open-meteo.com/v1/forecast';

  Future<WeatherBundle> fetchAll({
    required double lat,
    required double lon,
  }) async {
    // สร้าง URL พร้อม parameters
    final uri = Uri.parse(_base).replace(queryParameters: {
      'latitude': '$lat',
      'longitude': '$lon',
      'timezone': 'Asia/Bangkok',
      'current': 'temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,wind_speed_10m',
      'hourly': 'temperature_2m,relative_humidity_2m,precipitation_probability,weather_code,wind_speed_10m',
      'daily': 'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,precipitation_sum',
      'forecast_days': '7',
    });

    // ส่ง HTTP GET request
    final res = await http.get(uri);
    
    // ตรวจสอบ status code
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    
    // แปลง JSON string เป็น Map
    final Map<String, dynamic> json = jsonDecode(res.body);

    // สร้าง CurrentWeather object
    final current = CurrentWeather.fromJson(json);

    // ประมวลผลข้อมูล hourly
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

    // ประมวลผลข้อมูล daily
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
          precipitationProbMax: dPprobMax != null ? (dPprobMax[i] as num?)?.toInt() : null,
          precipitationSum: dPsum != null ? (dPsum[i] as num?)?.toDouble() : null,
        )
    ];

    return WeatherBundle(current: current, hourly: hourly, daily: daily);
  }
}
```

### 2. WeatherProvider Class
```dart
import 'package:flutter/foundation.dart';
import '../data/th_cities.dart';
import '../models/weather_models.dart';
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  final _service = WeatherService();

  THCity _selected = thNorthernProvinces.first;
  WeatherBundle? _bundle;
  bool _loading = false;
  String? _error;

  // Getters
  THCity get selected => _selected;
  WeatherBundle? get bundle => _bundle;
  bool get loading => _loading;
  String? get error => _error;

  // โหลดข้อมูลสภาพอากาศ
  Future<void> load() async {
    _error = null;
    _loading = true;
    notifyListeners(); // แจ้ง UI ให้แสดง loading

    try {
      _bundle = await _service.fetchAll(
        lat: _selected.lat,
        lon: _selected.lon,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners(); // แจ้ง UI ให้ซ่อน loading
    }
  }

  // เปลี่ยนเมือง
  void selectCity(THCity city) {
    _selected = city;
    load(); // โหลดข้อมูลใหม่
  }

  // รีเฟรชข้อมูล
  Future<void> refresh() => load();
}
```

### 3. การตั้งค่าใน main.dart
```dart
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => WeatherProvider()..load(), // สร้าง provider และโหลดข้อมูลทันที
      child: const WeatherApp(),
    ),
  );
}

class WeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          onPrimary: Colors.black,
          secondary: Colors.blue,
          surface: Color(0xFF1A1A1A),
          onSurface: Colors.white,
        ),
      ),
      home: const WeatherHomePage(),
    );
  }
}
```
