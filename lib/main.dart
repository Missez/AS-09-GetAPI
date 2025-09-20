import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'data/th_cities.dart';
import 'models/weather_models.dart';
import 'providers/weather_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => WeatherProvider()..load(),
      child: const WeatherApp(),
    ),
  );
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: ThemeData(
        useMaterial3: false,
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

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage>
    with TickerProviderStateMixin {
  late AnimationController _rainController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _rainController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _rainController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<WeatherProvider>();
    final items = thNorthernProvinces;
    final safeValue = items.contains(p.selected) ? p.selected : items.first;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // Animated background
          _AnimatedBackground(controller: _rainController, bundle: p.bundle),
          
          // Main content
          FadeTransition(
            opacity: _fadeController,
            child: RefreshIndicator(
              onRefresh: () => context.read<WeatherProvider>().refresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Top section with current weather
                    if (!p.loading && p.error == null && p.bundle != null)
                      _CurrentWeatherSection(
                        bundle: p.bundle!,
                        cityName: p.selected.name,
                      ),
                    
                    // Loading indicator
                    if (p.loading)
                      const Padding(
                        padding: EdgeInsets.only(top: 100),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    
                    // Error message
                    if (p.error != null)
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'เกิดข้อผิดพลาด: ${p.error}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    
                    // Hourly forecast
                    if (!p.loading && p.error == null && p.bundle != null)
                      _HourlyForecastSection(bundle: p.bundle!),
                    
                    // Weekly forecast
                    if (!p.loading && p.error == null && p.bundle != null)
                      _WeeklyForecastSection(bundle: p.bundle!),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          
          // City selector (top right)
          Positioned(
            top: 50,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: DropdownButton<THCity>(
                value: safeValue,
                dropdownColor: const Color(0xFF1A1A1A),
                underline: const SizedBox(),
                icon: const Icon(Icons.location_on, color: Colors.white),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                items: items
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Text(c.name),
                          ),
                        ))
                    .toList(),
                onChanged: (c) {
                  if (c != null) context.read<WeatherProvider>().selectCity(c);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Dynamic animated background based on weather conditions
class _AnimatedBackground extends StatelessWidget {
  final AnimationController controller;
  final WeatherBundle? bundle;

  const _AnimatedBackground({required this.controller, this.bundle});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          painter: WeatherBackgroundPainter(
            controller.value,
            bundle?.current.weatherCode ?? 0,
            bundle?.current.isDay ?? true,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class WeatherBackgroundPainter extends CustomPainter {
  final double animationValue;
  final int weatherCode;
  final bool isDay;

  WeatherBackgroundPainter(this.animationValue, this.weatherCode, this.isDay);

  @override
  void paint(Canvas canvas, Size size) {
    // Base gradient background
    _drawGradientBackground(canvas, size);
    
    // Add weather-specific effects
    if ([61, 63, 65, 80, 81, 82].contains(weatherCode)) {
      _drawRain(canvas, size);
    } else if ([95, 96, 99].contains(weatherCode)) {
      _drawThunderstorm(canvas, size);
    } else if ([45, 48].contains(weatherCode)) {
      _drawFog(canvas, size);
    } else if (weatherCode == 0 && isDay) {
      _drawSun(canvas, size);
    } else if (weatherCode == 0 && !isDay) {
      _drawStars(canvas, size);
    } else if ([1, 2, 3].contains(weatherCode)) {
      _drawClouds(canvas, size);
    }
  }

  void _drawGradientBackground(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    // Choose gradient based on weather and time
    Gradient gradient;
    if (weatherCode == 0 && isDay) {
      // Clear sky - day
      gradient = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF87CEEB), Color(0xFF98D8E8), Color(0xFFB0E0E6)],
      );
    } else if (weatherCode == 0 && !isDay) {
      // Clear sky - night
      gradient = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF191970), Color(0xFF000080), Color(0xFF000033)],
      );
    } else if ([61, 63, 65, 80, 81, 82].contains(weatherCode)) {
      // Rain
      gradient = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF4A4A4A), Color(0xFF2C2C2C), Color(0xFF1A1A1A)],
      );
    } else if ([95, 96, 99].contains(weatherCode)) {
      // Thunderstorm
      gradient = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF2F2F2F), Color(0xFF1A1A1A), Color(0xFF0F0F0F)],
      );
    } else if ([45, 48].contains(weatherCode)) {
      // Fog
      gradient = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFC0C0C0), Color(0xFFA0A0A0), Color(0xFF808080)],
      );
    } else {
      // Cloudy
      gradient = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF708090), Color(0xFF5A5A5A), Color(0xFF2F2F2F)],
      );
    }
    
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
  }

  void _drawRain(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.4)
      ..strokeWidth = 1.5;

    final random = math.Random(42);
    for (int i = 0; i < 60; i++) {
      final x = random.nextDouble() * size.width;
      final y = (random.nextDouble() * size.height + animationValue * 300) % (size.height + 100);
      
      canvas.drawLine(
        Offset(x, y),
        Offset(x, y + 25),
        paint,
      );
    }
  }

  void _drawThunderstorm(Canvas canvas, Size size) {
    // Rain
    _drawRain(canvas, size);
    
    // Lightning flashes
    if (animationValue > 0.8) {
      final paint = Paint()
        ..color = Colors.white.withOpacity(0.8)
        ..strokeWidth = 3.0;
      
      final random = math.Random(123);
      for (int i = 0; i < 3; i++) {
        final x = random.nextDouble() * size.width;
        canvas.drawLine(
          Offset(x, 0),
          Offset(x + 20, size.height * 0.3),
          paint,
        );
      }
    }
  }

  void _drawFog(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final random = math.Random(456);
    for (int i = 0; i < 8; i++) {
      final x = random.nextDouble() * size.width;
      final y = size.height * 0.3 + random.nextDouble() * size.height * 0.4;
      final radius = 50 + random.nextDouble() * 100;
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  void _drawSun(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final centerX = size.width * 0.8;
    final centerY = size.height * 0.2;
    final radius = 40.0;

    // Sun rays
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30.0) * math.pi / 180;
      final startX = centerX + math.cos(angle) * radius;
      final startY = centerY + math.sin(angle) * radius;
      final endX = centerX + math.cos(angle) * (radius + 20);
      final endY = centerY + math.sin(angle) * (radius + 20);
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        Paint()
          ..color = Colors.yellow.withOpacity(0.4)
          ..strokeWidth = 2.0,
      );
    }

    // Sun circle
    canvas.drawCircle(Offset(centerX, centerY), radius, paint);
  }

  void _drawStars(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final random = math.Random(789);
    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height * 0.6;
      final twinkle = (math.sin(animationValue * 4 + i) + 1) / 2;
      
      canvas.drawCircle(
        Offset(x, y),
        1 + twinkle * 2,
        paint..color = Colors.white.withOpacity(0.6 + twinkle * 0.4),
      );
    }

    // Moon
    final moonPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.15),
      25,
      moonPaint,
    );
  }

  void _drawClouds(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final random = math.Random(321);
    for (int i = 0; i < 5; i++) {
      final x = random.nextDouble() * size.width;
      final y = size.height * 0.1 + random.nextDouble() * size.height * 0.3;
      final width = 80 + random.nextDouble() * 60;
      final height = 30 + random.nextDouble() * 20;
      
      _drawCloud(canvas, Offset(x, y), width, height, paint);
    }
  }

  void _drawCloud(Canvas canvas, Offset center, double width, double height, Paint paint) {
    final path = Path();
    final radius = height / 2;
    
    path.addOval(Rect.fromCircle(center: Offset(center.dx - width/4, center.dy), radius: radius));
    path.addOval(Rect.fromCircle(center: Offset(center.dx, center.dy), radius: radius * 1.2));
    path.addOval(Rect.fromCircle(center: Offset(center.dx + width/4, center.dy), radius: radius));
    path.addOval(Rect.fromCircle(center: Offset(center.dx - width/8, center.dy - height/3), radius: radius * 0.8));
    path.addOval(Rect.fromCircle(center: Offset(center.dx + width/8, center.dy - height/3), radius: radius * 0.8));
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Current weather section matching the design
class _CurrentWeatherSection extends StatelessWidget {
  final WeatherBundle bundle;
  final String cityName;

  const _CurrentWeatherSection({
    required this.bundle,
    required this.cityName,
  });

  @override
  Widget build(BuildContext context) {
    final c = bundle.current;
    final desc = weatherCodeToText(c.weatherCode);
    final today = bundle.daily.isNotEmpty ? bundle.daily.first : null;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 40),
      child: Column(
        children: [
          // Location
          Text(
            cityName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 8),
          
          // Weather condition
          Text(
            desc,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 20),
          
          // Large temperature
          Text(
            '${c.temperature.round()}°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 80,
              fontWeight: FontWeight.w100,
              height: 0.9,
            ),
          ),
          const SizedBox(height: 40),
          
          // Today's high/low
          if (today != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${today.tMax.round()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${today.tMin.round()}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// Hourly forecast section with horizontal scroll
class _HourlyForecastSection extends StatelessWidget {
  final WeatherBundle bundle;

  const _HourlyForecastSection({required this.bundle});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final nextHours = bundle.hourly
        .where((h) => h.time.isAfter(now.subtract(const Duration(hours: 1))))
        .take(8)
        .toList();

    if (nextHours.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with day and high/low
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getDayName(now),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (bundle.daily.isNotEmpty)
                Text(
                  '${bundle.daily.first.tMax.round()} ${bundle.daily.first.tMin.round()}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Horizontal scrollable hourly forecast
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: nextHours.length,
              itemBuilder: (context, index) {
                final h = nextHours[index];
                final isNow = index == 0;
                final timeText = isNow ? 'Now' : _formatHour(h.time);
                
                return Container(
                  width: 60,
                  margin: const EdgeInsets.only(right: 16),
                  child: Column(
                    children: [
                      // Time
                      Text(
                        timeText,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Precipitation probability
                      if (h.precipitationProb != null && h.precipitationProb! > 0)
                        Text(
                          '${h.precipitationProb}%',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      const SizedBox(height: 4),
                      
                      // Weather icon
                      Text(
                        _getWeatherIcon(h.weatherCode, h.time.hour),
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 8),
                      
                      // Temperature
                      Text(
                        '${h.temperature.round()}°',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getDayName(DateTime date) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[date.weekday - 1];
  }

  String _formatHour(DateTime time) {
    final hour = time.hour;
    if (hour == 0) return '12AM';
    if (hour < 12) return '${hour}AM';
    if (hour == 12) return '12PM';
    return '${hour - 12}PM';
  }

  String _getWeatherIcon(int code, int hour) {
    final isDay = hour >= 6 && hour < 18;
    if (code == 0) return isDay ? '☀️' : '🌙';
    if ([1, 2, 3].contains(code)) return '⛅';
    if ([45, 48].contains(code)) return '🌫️';
    if ([51, 53, 55].contains(code)) return '🌦️';
    if ([61, 63, 65, 80, 81, 82].contains(code)) return '🌧️';
    if ([95, 96, 99].contains(code)) return '⛈️';
    if ([71, 73, 75, 77].contains(code)) return '❄️';
    return '🌡️';
  }
}

// Weekly forecast section
class _WeeklyForecastSection extends StatelessWidget {
  final WeatherBundle bundle;

  const _WeeklyForecastSection({required this.bundle});

  @override
  Widget build(BuildContext context) {
    final days = bundle.daily;
    if (days.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: days.map((day) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Day name
                Text(
                  _getDayName(day.date),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                
                // Weather icon
                Text(
                  _getWeatherIcon(day.weatherCode),
                  style: const TextStyle(fontSize: 20),
                ),
                
                // Temperature range
                Text(
                  '${day.tMax.round()} ${day.tMin.round()}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getDayName(DateTime date) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[date.weekday - 1];
  }

  String _getWeatherIcon(int code) {
    if (code == 0) return '☀️';
    if ([1, 2, 3].contains(code)) return '⛅';
    if ([45, 48].contains(code)) return '🌫️';
    if ([51, 53, 55].contains(code)) return '🌦️';
    if ([61, 63, 65, 80, 81, 82].contains(code)) return '🌧️';
    if ([95, 96, 99].contains(code)) return '⛈️';
    if ([71, 73, 75, 77].contains(code)) return '❄️';
    return '🌡️';
  }
}

