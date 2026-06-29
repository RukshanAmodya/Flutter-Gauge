import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solar PV Gauge',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00A294),
          brightness: Brightness.light,
        ),
        cardTheme: const CardTheme(
          color: Colors.white,
          elevation: 2,
          shadowColor: Color(0x1A000000),
        ),
      ),
      home: const GaugeScreen(),
    );
  }
}

class GaugeScreen extends StatefulWidget {
  const GaugeScreen({super.key});

  @override
  State<GaugeScreen> createState() => _GaugeScreenState();
}

class _GaugeScreenState extends State<GaugeScreen> {
  // Inputs
  double _capacityKWp = 5.00; // Default capacity in kWp
  double _currentPowerW = 0.0; // Default power in W

  final TextEditingController _capacityController =
      TextEditingController(text: '5.00');
  final TextEditingController _powerController =
      TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    _capacityController.addListener(_onCapacityChanged);
    _powerController.addListener(_onPowerChanged);
  }

  @override
  void dispose() {
    _capacityController.dispose();
    _powerController.dispose();
    super.dispose();
  }

  void _onCapacityChanged() {
    final val = double.tryParse(_capacityController.text);
    if (val != null && val > 0) {
      setState(() {
        _capacityKWp = val;
        // Clamp power to new capacity limits if needed
        final maxW = _capacityKWp * 1000.0;
        if (_currentPowerW > maxW) {
          _currentPowerW = maxW;
          _powerController.text = _currentPowerW.toStringAsFixed(0);
        }
      });
    }
  }

  void _onPowerChanged() {
    final val = double.tryParse(_powerController.text);
    if (val != null && val >= 0) {
      setState(() {
        final maxW = _capacityKWp * 1000.0;
        _currentPowerW = val.clamp(0.0, maxW);
      });
    }
  }

  // Determine color based on percentage of capacity
  Color _getThemeColor(double percentage) {
    if (percentage < 10) {
      return const Color(0xFFE53935); // Red (rathu)
    } else if (percentage >= 10 && percentage < 20) {
      return const Color(0xFFFF9800); // Orange (thabili)
    } else if (percentage >= 20 && percentage < 50) {
      return const Color(0xFFFFEB3B); // Yellow (kaha)
    } else if (percentage >= 50 && percentage < 70) {
      return const Color(0xFF4CAF50); // Light Green (kola)
    } else {
      return const Color(0xFF00B6A6); // Teal/Cyan (matching image)
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxPowerW = _capacityKWp * 1000.0;
    final percentage = maxPowerW > 0 ? (_currentPowerW / maxPowerW) * 100 : 0.0;
    final activeColor = _getThemeColor(percentage);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'PV Monitor Dashboard',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // The main Gauge inside a clean Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 36.0, horizontal: 24.0),
                  child: Column(
                    children: [
                      // Custom Gauge Widget
                      CustomPaint(
                        size: const Size(280, 280),
                        painter: SolarGaugePainter(
                          currentValue: _currentPowerW,
                          maxValue: maxPowerW,
                          themeColor: activeColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Subtitle / Capacity text below the Gauge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'PV Capacity:',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF758A99),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            ' ${_capacityKWp.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Color(0xFF1E293B),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            ' kWp',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Control Panel Card for inputs
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Simulation Controls',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const Divider(height: 24),
                      // Capacity Input (kWp)
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'PV Capacity (kWp)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                SizedBox(
                                  height: 45,
                                  child: TextField(
                                    controller: _capacityController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Current Power Input (W)
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Current Power (W)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                SizedBox(
                                  height: 45,
                                  child: TextField(
                                    controller: _powerController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Slider to dynamically control Power
                      Text(
                        'Adjust PV Power: ${_currentPowerW.toStringAsFixed(0)} W',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                      ),
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: activeColor,
                          thumbColor: activeColor,
                          overlayColor: activeColor.withOpacity(0.2),
                        ),
                        child: Slider(
                          value: _currentPowerW,
                          min: 0.0,
                          max: maxPowerW > 0 ? maxPowerW : 1.0,
                          divisions: 100,
                          label: '${_currentPowerW.toStringAsFixed(0)} W',
                          onChanged: (val) {
                            setState(() {
                              _currentPowerW = val;
                              _powerController.text = val.toStringAsFixed(0);
                            });
                          },
                        ),
                      ),
                      // Quick value presets
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: [
                          _buildPresetButton(0.0, '0% (Empty)'),
                          _buildPresetButton(maxPowerW * 0.15, '15% (Orange)'),
                          _buildPresetButton(maxPowerW * 0.40, '40% (Yellow)'),
                          _buildPresetButton(maxPowerW * 0.60, '60% (Green)'),
                          _buildPresetButton(maxPowerW * 0.90, '90% (Teal)'),
                          _buildPresetButton(maxPowerW, '100% (Max)'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetButton(double value, String label) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        setState(() {
          _currentPowerW = value;
          _powerController.text = value.toStringAsFixed(0);
        });
      },
    );
  }
}

class SolarGaugePainter extends CustomPainter {
  final double currentValue;
  final double maxValue;
  final Color themeColor;

  SolarGaugePainter({
    required this.currentValue,
    required this.maxValue,
    required this.themeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    // Angle configuration: Gauge starts at 135 deg and ends at 45 deg clockwise (270 degrees total)
    const double startAngleRad = 135 * pi / 180;
    const double totalSweepRad = 270 * pi / 180;

    final double fillPercentage = maxValue > 0 ? (currentValue / maxValue) : 0.0;
    final double activeSweepRad = totalSweepRad * fillPercentage.clamp(0.0, 1.0);

    // 1. Draw central soft background glow & circular shadow (representing depth in image)
    final shadowPaint = Paint()
      ..color = const Color(0x06000000)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.72, shadowPaint);

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          themeColor.withOpacity(0.08),
          themeColor.withOpacity(0.01),
          Colors.transparent,
        ],
        stops: const [0.6, 0.9, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.85));
    canvas.drawCircle(center, radius * 0.85, glowPaint);

    // 2. Draw static track arc (semi-transparent background arc)
    final trackPaint = Paint()
      ..color = const Color(0xFFE2E8F0).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.68),
      startAngleRad,
      totalSweepRad,
      false,
      trackPaint,
    );

    // 3. Draw active progress fill arc
    if (activeSweepRad > 0) {
      final progressPaint = Paint()
        ..color = themeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14.0
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 0.68),
        startAngleRad,
        activeSweepRad,
        false,
        progressPaint,
      );
    }

    // 4. Draw Radial Ticks
    const int tickCount = 70;
    final double angleStep = totalSweepRad / (tickCount - 1);

    for (int i = 0; i < tickCount; i++) {
      final double angle = startAngleRad + (i * angleStep);

      // Determine if this tick is active (below current progress)
      final double progressAtTick = i / (tickCount - 1);
      final bool isActive = progressAtTick <= fillPercentage;

      // Major ticks are at start, 1/4, 2/4 (top), 3/4, and end
      final bool isMajor = (i == 0 ||
          i == (tickCount - 1) ~/ 4 ||
          i == (tickCount - 1) ~/ 2 ||
          i == ((tickCount - 1) * 3) ~/ 4 ||
          i == tickCount - 1);

      final double tickLength = isMajor ? 12.0 : 6.0;
      final double tickThickness = isMajor ? 2.5 : 1.0;

      final startRadius = radius * 0.82;
      final endRadius = startRadius + tickLength;

      final startOffset = Offset(
        center.dx + startRadius * cos(angle),
        center.dy + startRadius * sin(angle),
      );
      final endOffset = Offset(
        center.dx + endRadius * cos(angle),
        center.dy + endRadius * sin(angle),
      );

      final Color tickColor = isActive
          ? themeColor
          : (isMajor ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0));

      final tickPaint = Paint()
        ..color = tickColor
        ..strokeWidth = tickThickness
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(startOffset, endOffset, tickPaint);
    }

    // 5. Draw the Needle (Starts at center, points to current progress edge)
    final double needleAngle = startAngleRad + activeSweepRad;
    final double needleLength = radius * 0.68;

    final needleStart = Offset(
      center.dx + (radius * 0.12) * cos(needleAngle),
      center.dy + (radius * 0.12) * sin(needleAngle),
    );
    final needleEnd = Offset(
      center.dx + needleLength * cos(needleAngle),
      center.dy + needleLength * sin(needleAngle),
    );

    final needlePaint = Paint()
      ..color = themeColor
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(needleStart, needleEnd, needlePaint);

    // 6. Draw central texts inside the gauge (0, W, PV Power)
    // - Current value text ("0" or actual power)
    final valueSpan = TextSpan(
      text: currentValue.toStringAsFixed(0),
      style: const TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0F172A),
        height: 1.0,
      ),
    );
    final valuePainter = TextPainter(
      text: valueSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(minWidth: 0, maxWidth: size.width);

    valuePainter.paint(
      canvas,
      Offset(center.dx - valuePainter.width / 2, center.dy - 35),
    );

    // - Unit text ("W")
    final unitSpan = TextSpan(
      text: 'W',
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Color(0xFF64748B),
      ),
    );
    final unitPainter = TextPainter(
      text: unitSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(minWidth: 0, maxWidth: size.width);

    unitPainter.paint(
      canvas,
      Offset(center.dx - unitPainter.width / 2, center.dy + 15),
    );

    // - Title text ("PV Power")
    final titleSpan = TextSpan(
      text: 'PV Power',
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF475569),
      ),
    );
    final titlePainter = TextPainter(
      text: titleSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(minWidth: 0, maxWidth: size.width);

    titlePainter.paint(
      canvas,
      Offset(center.dx - titlePainter.width / 2, center.dy + 50),
    );
  }

  @override
  bool shouldRepaint(covariant SolarGaugePainter oldDelegate) {
    return oldDelegate.currentValue != currentValue ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.themeColor != themeColor;
  }
}
