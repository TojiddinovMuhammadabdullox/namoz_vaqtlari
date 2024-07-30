import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:namoz_vaqtlari/models/praying.dart';

class PrayerTimesController {
  Future<PrayerTimes> fetchPrayerTimes(String city) async {
    final response = await http.get(Uri.parse(
        'https://api.aladhan.com/v1/timingsByCity/30-07-2024?city=$city&country=Uzbekistan&method=2'));

    if (response.statusCode == 200) {
      return PrayerTimes.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load prayer times');
    }
  }
}
