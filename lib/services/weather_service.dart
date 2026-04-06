import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherService {
  String get apiKey => dotenv.env['OPENWEATHER_API_KEY'] ?? '';

  double get lat => double.tryParse(dotenv.env['DEFAULT_LAT'] ?? '18.7883') ?? 18.7883;
  double get lon => double.tryParse(dotenv.env['DEFAULT_LON'] ?? '98.9853') ?? 98.9853;

  // ดึงสภาพอากาศ
  Future<Map<String, dynamic>> fetchWeather() async {
    final url = 'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception('Failed to load weather');
  }

  // ดึงค่ามลพิษ (Air Pollution)
  Future<Map<String, dynamic>> fetchPollution() async {
    final url = 'https://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception('Failed to load pollution');
  }
}