import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:namoz_vaqtlari/models/praying.dart';

class PrayerTimesController {
  Future<PrayerTimes> fetchPrayerTimes(String region) async {
    final response = await http.get(
      Uri.parse('https://islomapi.uz/api/present/day?region=$region'),
    );

    if (response.statusCode == 200) {
      return PrayerTimes.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load prayer times');
    }
  }
}
