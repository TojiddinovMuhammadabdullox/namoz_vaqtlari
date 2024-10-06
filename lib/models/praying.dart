class PrayerTimes {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  PrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    final timings = json['times'];
    return PrayerTimes(
      fajr: timings['tong_saharlik'],
      sunrise: timings['quyosh'],
      dhuhr: timings['peshin'],
      asr: timings['asr'],
      maghrib: timings['shom_iftor'],
      isha: timings['hufton'],
    );
  }
}
