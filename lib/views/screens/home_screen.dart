import 'package:flutter/material.dart';
import 'package:namoz_vaqtlari/controller/praying_controller.dart';
import 'package:namoz_vaqtlari/models/praying.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PrayerTimesController _controller = PrayerTimesController();
  PrayerTimes? _prayerTimes;
  String _selectedRegion = 'Toshkent';
  late Timer _timer;
  late DateTime _currentTime;
  String _currentPrayer = '';
  String _nextPrayer = '';
  String _timeUntilNextPrayer = '';

  final List<String> _regions = [
    'Andijon',
    'Buxoro',
    'Farg‘ona',
    'Jizzax',
    'Qoraqalpog‘iston',
    'Qashqadaryo',
    'Xorazm',
    'Namangan',
    'Navoiy',
    'Samarqand',
    'Sirdaryo',
    'Surxondaryo',
    'Toshkent',
  ];

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _fetchPrayerTimes();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
        _updateCurrentPrayer();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _fetchPrayerTimes() async {
    try {
      final prayerTimes = await _controller.fetchPrayerTimes(_selectedRegion);
      setState(() {
        _prayerTimes = prayerTimes;
        _updateCurrentPrayer();
      });
    } catch (e) {
      print(e.toString());
    }
  }

  void _updateCurrentPrayer() {
    if (_prayerTimes == null) return;

    final now = _currentTime;
    final prayers = [
      ('Bomdod', _parseTime(_prayerTimes!.fajr)),
      ('Quyosh', _parseTime(_prayerTimes!.sunrise)),
      ('Peshin', _parseTime(_prayerTimes!.dhuhr)),
      ('Asr', _parseTime(_prayerTimes!.asr)),
      ('Shom', _parseTime(_prayerTimes!.maghrib)),
      ('Xufton', _parseTime(_prayerTimes!.isha)),
    ];

    for (int i = 0; i < prayers.length; i++) {
      if (now.isBefore(prayers[i].$2)) {
        _currentPrayer = i == 0 ? prayers.last.$1 : prayers[i - 1].$1;
        _nextPrayer = prayers[i].$1;
        _timeUntilNextPrayer = _formatDuration(prayers[i].$2.difference(now));
        return;
      }
    }

    _currentPrayer = prayers.last.$1;
    _nextPrayer = prayers.first.$1;
    _timeUntilNextPrayer = _formatDuration(
        prayers.first.$2.add(const Duration(days: 1)).difference(now));
  }

  DateTime _parseTime(String time) {
    final parts = time.split(':');
    final now = DateTime.now();
    return DateTime(
        now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Namoz Vaqtlari',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1F2F98),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1F2F98), Color(0xFF080E4B)],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildCurrentTimeAndPrayer(),
                    const SizedBox(height: 20),
                    _buildRegionDropdown(),
                    const SizedBox(height: 20),
                    _buildHorizontalPrayerCards(), // New prayer card slider
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTimeAndPrayer() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            DateFormat('HH:mm:ss').format(_currentTime),
            style: const TextStyle(
              fontSize: 32,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            DateFormat('d MMMM yyyy').format(_currentTime),
            style: const TextStyle(fontSize: 18, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Text(
            'Hozirgi namoz: $_currentPrayer',
            style: const TextStyle(fontSize: 24, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Keyingi namozgacha: $_timeUntilNextPrayer',
            style: const TextStyle(fontSize: 18, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionDropdown() {
    return DropdownButton<String>(
      value: _selectedRegion,
      dropdownColor: const Color(0xFF1F2F98),
      iconEnabledColor: Colors.white,
      style: const TextStyle(color: Colors.white, fontSize: 18),
      onChanged: (String? newValue) {
        setState(() {
          _selectedRegion = newValue!;
          _fetchPrayerTimes();
        });
      },
      items: _regions.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _buildHorizontalPrayerCards() {
    final List<Map<String, String>> prayerData = [
      {'name': 'Bomdod', 'time': _prayerTimes?.fajr ?? '00:00'},
      {'name': 'Quyosh', 'time': _prayerTimes?.sunrise ?? '00:00'},
      {'name': 'Peshin', 'time': _prayerTimes?.dhuhr ?? '00:00'},
      {'name': 'Asr', 'time': _prayerTimes?.asr ?? '00:00'},
      {'name': 'Shom', 'time': _prayerTimes?.maghrib ?? '00:00'},
      {'name': 'Xufton', 'time': _prayerTimes?.isha ?? '00:00'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: prayerData.map((prayer) {
          return _buildPrayerTimeCard(prayer['name']!, prayer['time']!);
        }).toList(),
      ),
    );
  }

  Widget _buildPrayerTimeCard(String prayerName, String prayerTime) {
    return Container(
      width: 150,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3445AF), Color(0xFF1F2F98)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Card(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                prayerName,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                prayerTime,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
