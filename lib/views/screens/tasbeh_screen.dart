// import 'package:flutter/material.dart';
// import 'dart:math' as math;

// class TasbehScreen extends StatefulWidget {
//   @override
//   _TasbehScreenState createState() => _TasbehScreenState();
// }

// class _TasbehScreenState extends State<TasbehScreen> {
//   int _counter = 0;
//   int _set = 1;
//   int _range = 33;

//   void _incrementCounter() {
//     setState(() {
//       if (_counter < _range) {
//         _counter++;
//       } else {
//         _counter = 0;
//         _set++;
//       }
//     });
//   }

//   void _resetCounter() {
//     setState(() {
//       _counter = 0;
//       _set = 1;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Color(0xFF1F2F98),
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh, color: Colors.white),
//             onPressed: _resetCounter,
//           ),
//         ],
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Color(0xFF1F2F98), Color(0xFF1F2F98)],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               _buildArabicText(),
//               Expanded(child: _buildCircularCounter()),
//               _buildSetAndRange(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildArabicText() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Text(
//         'يا حي يا قيوم برحمتك أستغيث',
//         style: TextStyle(color: Colors.white, fontSize: 24),
//         textAlign: TextAlign.center,
//       ),
//     );
//   }

//   Widget _buildCircularCounter() {
//     return GestureDetector(
//       onTap: _incrementCounter,
//       child: Container(
//         width: 250,
//         height: 250,
//         child: CustomPaint(
//           painter: CircleProgressPainter(_counter / _range),
//           child: Center(
//             child: Text(
//               '$_counter',
//               style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 72,
//                   fontWeight: FontWeight.bold),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSetAndRange() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text('SET: $_set', style: TextStyle(color: Colors.white)),
//           Text('RANGE: $_range', style: TextStyle(color: Colors.white)),
//         ],
//       ),
//     );
//   }
// }

// class CircleProgressPainter extends CustomPainter {
//   final double progress;

//   CircleProgressPainter(this.progress);

//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);
//     final radius = math.min(size.width, size.height) / 2;
//     final paint = Paint()
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 10.0
//       ..color = Colors.white.withOpacity(0.3);

//     canvas.drawCircle(center, radius, paint);

//     final progressPaint = Paint()
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 10.0
//       ..color = Colors.white
//       ..strokeCap = StrokeCap.round;

//     canvas.drawArc(
//       Rect.fromCircle(center: center, radius: radius),
//       -math.pi / 2,
//       2 * math.pi * progress,
//       false,
//       progressPaint,
//     );
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => true;
// }
