import 'package:flutter/foundation.dart';
import '../data/th_cities.dart';
import '../models/weather_models.dart';
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  final _service = WeatherService();

  THCity _selected = thNorthernProvinces.first;
  THCity get selected => _selected;

  WeatherBundle? _bundle;
  WeatherBundle? get bundle => _bundle;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  Future<void> load() async {
    _error = null;
    _loading = true;
    notifyListeners();
    try {
      _bundle = await _service.fetchAll(
        lat: _selected.lat,
        lon: _selected.lon,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void selectCity(THCity city) {
    _selected = city;
    load();
  }

  Future<void> refresh() => load();
}
