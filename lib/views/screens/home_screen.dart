import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:namoz_vaqtlari/controller/praying_controller.dart';
import 'package:namoz_vaqtlari/models/praying.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import 'package:namoz_vaqtlari/views/screens/tasbeh_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PrayerTimesController _controller = PrayerTimesController();
  PrayerTimes? _prayerTimes;
  String _selectedRegion = 'Tashkent';
  late Timer _timer;
  late DateTime _currentTime;
  String _currentPrayer = '';
  String _nextPrayer = '';
  String _timeUntilNextPrayer = '';

  final List<String> _regions = [
    'Andijan',
    'Bukhara',
    'Fergana',
    'Jizzakh',
    'Karakalpakstan',
    'Kashkadarya',
    'Khorezm',
    'Namangan',
    'Navoiy',
    'Samarkand',
    'Sirdaryo',
    'Surkhandarya',
    'Tashkent',
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
    final prayerTimes = await _controller.fetchPrayerTimes(_selectedRegion);
    setState(() {
      _prayerTimes = prayerTimes;
      _updateCurrentPrayer();
    });
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF1F2F98),
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Color(0xFF1F2F98)),
              title: const Text('Home',
                  style: TextStyle(color: Color(0xFF1F2F98))),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.panorama_fish_eye, color: Color(0xFF1F2F98)),
              title: const Text('Tasbeh',
                  style: TextStyle(color: Color(0xFF1F2F98))),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => TasbehScreen()),
                );
              },
            ),
          ],
        ),
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
                  ],
                ),
              ),
              if (_prayerTimes == null)
                const SliverFillRemaining(
                  child: Center(
                      child: CircularProgressIndicator(color: Colors.white)),
                )
              else
                _buildPrayerTimesList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTimeAndPrayer() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                DateFormat('HH:mm:ss').format(_currentTime),
                style: TextStyle(
                  fontSize: constraints.maxWidth > 600 ? 48 : 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(5.0, 5.0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                DateFormat('d MMMM yyyy').format(_currentTime),
                style: const TextStyle(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hozirgi namoz',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                      Text(
                        _currentPrayer,
                        style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Keyingi namoz',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                      Text(
                        _nextPrayer,
                        style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Qolgan vaqt: $_timeUntilNextPrayer',
                style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRegionDropdown() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRegion,
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedRegion = newValue;
                _prayerTimes = null;
              });
              _fetchPrayerTimes();
            }
          },
          items: _regions.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          dropdownColor: const Color(0xFF1F2F98),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          isExpanded: true,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildPrayerTimesList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final prayerNames = [
            'Bomdod',
            'Quyosh',
            'Peshin',
            'Asr',
            'Shom',
            'Xufton'
          ];
          final prayerTimes = [
            _prayerTimes!.fajr,
            _prayerTimes!.sunrise,
            _prayerTimes!.dhuhr,
            _prayerTimes!.asr,
            _prayerTimes!.maghrib,
            _prayerTimes!.isha,
          ];
          final icons = [
            Icons.nightlight_round,
            Icons.wb_sunny,
            Icons.wb_sunny_outlined,
            Icons.wb_twighlight,
            Icons.nights_stay,
            Icons.bedtime,
          ];
          return _buildPrayerTimeItem(
              prayerNames[index], prayerTimes[index], icons[index]);
        },
        childCount: 6,
      ),
    );
  }

  Widget _buildPrayerTimeItem(String name, String time, IconData icon) {
    final isCurrentPrayer = name == _currentPrayer;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isCurrentPrayer
            ? const Color(0xFF3D4EC6)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          name,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        trailing: Text(
          time,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
