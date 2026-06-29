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
        fontFamily: 'Roboto', // Modern, clean default typography
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00C7BE),
          brightness: Brightness.light,
          background: const Color(0xFFF8FAFC),
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

  // Interpolated color based on percentage to make it transition smoothly
  Color _getThemeColor(double percentage) {
    final pct = percentage.clamp(0.0, 100.0);
    
    // Modern Luminous Color Palette Stops:
    // 0%   -> Luminous Red: Color(0xFFFF3B30)
    // 15%  -> Luminous Orange: Color(0xFFFF9500)
    // 35%  -> Luminous Yellow: Color(0xFFFED200)
    // 65%  -> Luminous Light Green: Color(0xFF4CD964)
    // 100% -> Luminous Emerald Green (Top): Color(0xFF00E676)
    
    if (pct < 15.0) {
      final t = pct / 15.0;
      return Color.lerp(const Color(0xFFFF3B30), const Color(0xFFFF9500), t)!;
    } else if (pct < 35.0) {
      final t = (pct - 15.0) / 20.0;
      return Color.lerp(const Color(0xFFFF9500), const Color(0xFFFED200), t)!;
    } else if (pct < 65.0) {
      final t = (pct - 35.0) / 30.0;
      return Color.lerp(const Color(0xFFFED200), const Color(0xFF4CD964), t)!;
    } else {
      final t = (pct - 65.0) / 35.0;
      return Color.lerp(const Color(0xFF4CD964), const Color(0xFF00E676), t)!;
    }
  }

  // Get dynamic status message based on percentage
  String _getEfficiencyStatus(double percentage) {
    if (percentage < 10) return 'Very Low';
    if (percentage < 20) return 'Low';
    if (percentage < 50) return 'Moderate';
    if (percentage < 70) return 'Good';
    return 'Excellent';
  }

  @override
  Widget build(BuildContext context) {
    final maxPowerW = _capacityKWp * 1000.0;
    final percentage = maxPowerW > 0 ? (_currentPowerW / maxPowerW) * 100 : 0.0;
    final activeColor = _getThemeColor(percentage);
    final statusText = _getEfficiencyStatus(percentage);

    // Simulated derived metrics for dashboard realism
    final double voltage = 230.0; // Simulated typical inverter AC voltage
    final double currentAmps = _currentPowerW / voltage;
    final double co2SavedKg = _currentPowerW * 0.000475; // Approx CO2 offset factor

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Subtle premium grey-blue
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wb_sunny_rounded, color: activeColor, size: 28),
            const SizedBox(width: 10),
            const Text(
              'Solar Jade Energy',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE2E8F0),
            height: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Main Interactive Gauge Card
              Card(
                color: Colors.white,
                elevation: 4.0,
                shadowColor: const Color(0x0A000000),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 36.0, horizontal: 24.0),
                  child: Column(
                    children: [
                      // Smoothly Animated Custom Gauge
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: _currentPowerW),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.decelerate,
                        builder: (context, animatedValue, child) {
                          final animatedPercentage = maxPowerW > 0 ? (animatedValue / maxPowerW) * 100 : 0.0;
                          final animatedColor = _getThemeColor(animatedPercentage);
                          return CustomPaint(
                            size: const Size(280, 280),
                            painter: SolarGaugePainter(
                              currentValue: animatedValue,
                              maxValue: maxPowerW,
                              themeColor: animatedColor,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      // PV Capacity display text with a clean pill badge design
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: activeColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'PV Capacity: ',
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _capacityKWp.toStringAsFixed(2),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF0F172A),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Text(
                              ' kWp',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF94A3B8),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Inverter Smart Stats Row
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('Status', statusText, activeColor),
                            Container(
                                width: 1,
                                height: 40,
                                color: const Color(0xFFE2E8F0)),
                            _buildStatItem('Current AC',
                                '${currentAmps.toStringAsFixed(1)} A', null),
                            Container(
                                width: 1,
                                height: 40,
                                color: const Color(0xFFE2E8F0)),
                            _buildStatItem('CO₂ Saved',
                                '${co2SavedKg.toStringAsFixed(2)} kg', null),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Simulator Input & Control Panel Card
              Card(
                color: Colors.white,
                elevation: 4.0,
                shadowColor: const Color(0x0A000000),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Inputs row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'PV Capacity (kWp)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _capacityController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.flash_on,
                                        color: Color(0xFF94A3B8)),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Color(0xFFCBD5E1)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Color(0xFFE2E8F0)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Current Power (W)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _powerController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.bolt,
                                        color: Color(0xFF94A3B8)),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Color(0xFFCBD5E1)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Color(0xFFE2E8F0)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Slider controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Adjust Generation Power',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF475569),
                            ),
                          ),
                          Text(
                            '${_currentPowerW.toStringAsFixed(0)} W',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: activeColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: activeColor,
                          inactiveTrackColor: const Color(0xFFF1F5F9),
                          thumbColor: Colors.white,
                          overlayColor: activeColor.withOpacity(0.15),
                          trackHeight: 6,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 10,
                            elevation: 3,
                          ),
                        ),
                        child: Slider(
                          value: _currentPowerW,
                          min: 0.0,
                          max: maxPowerW > 0 ? maxPowerW : 1.0,
                          onChanged: (val) {
                            setState(() {
                              _currentPowerW = val;
                              _powerController.text = val.toStringAsFixed(0);
                            });
                          },
                        ),
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

  Widget _buildStatItem(String label, String value, Color? color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color ?? const Color(0xFF1E293B),
          ),
        ),
      ],
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
      ..color = const Color(0x05000000)
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

    // 4. Draw Radial Ticks - All uniform same size, same spacing (matching reference image)
    const int tickCount = 120; // More ticks = denser, more refined look
    final double angleStep = totalSweepRad / (tickCount - 1);

    for (int i = 0; i < tickCount; i++) {
      final double angle = startAngleRad + (i * angleStep);
      final double progressAtTick = i / (tickCount - 1);
      final bool isActive = progressAtTick <= fillPercentage;

      // All ticks are uniform - same length and thickness
      const double tickLength = 8.8;
      const double tickThickness = 1.2;
      const double startRadiusFactor = 0.76;

      final double startR = radius * startRadiusFactor;
      final double endR = startR + tickLength;

      final startOffset = Offset(
        center.dx + startR * cos(angle),
        center.dy + startR * sin(angle),
      );
      final endOffset = Offset(
        center.dx + endR * cos(angle),
        center.dy + endR * sin(angle),
      );

      // Fading opacity: full brightness at top, fading towards bottom ends
      final double distance = (angle - 270 * pi / 180).abs();
      final double maxDistance = 135 * pi / 180;
      final double distanceNormalized = (distance / maxDistance).clamp(0.0, 1.0);

      final double opacityFactor = isActive
          ? 1.0 - (distanceNormalized * 0.30) // Active: stays bright, slight fade
          : (1.0 - (distanceNormalized * 0.95)) * 0.30; // Inactive: soft/faint

      final Color baseColor = isActive ? themeColor : const Color(0xFFCBD5E1);
      final Color tickColor = baseColor.withOpacity(opacityFactor.clamp(0.0, 1.0));

      final tickPaint = Paint()
        ..color = tickColor
        ..strokeWidth = tickThickness
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(startOffset, endOffset, tickPaint);
    }

    // 5. Draw the inner circular ring/ridge (Neumorphic 3D raised ridge)
    final double innerRidgeRadius = radius * 0.62;

    // Draw the soft outer shadow of the ring
    final shadowCirclePaint = Paint()
      ..color = Colors.black.withOpacity(0.06)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, innerRidgeRadius, shadowCirclePaint);

    // Draw the white ridge/ring body
    final ridgePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, innerRidgeRadius, ridgePaint);

    // Draw a subtle soft inner outline/border for the ring
    final ridgeBorderPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, innerRidgeRadius, ridgeBorderPaint);
    
    // Subtle glow color inside the ring
    final centerGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          themeColor.withOpacity(0.04),
          themeColor.withOpacity(0.005),
          Colors.transparent,
        ],
        stops: const [0.5, 0.8, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: innerRidgeRadius));
    canvas.drawCircle(center, innerRidgeRadius - 1, centerGlowPaint);

    // 6. Draw the Needle (Starts from the inner ridge boundary to the progress track)
    final double needleAngle = startAngleRad + activeSweepRad;
    final double needleStartRadius = innerRidgeRadius - 4; // Starts slightly inside the ridge
    final double needleEndRadius = radius * 0.68; // Ends at the progress track

    final needleStart = Offset(
      center.dx + needleStartRadius * cos(needleAngle),
      center.dy + needleStartRadius * sin(needleAngle),
    );
    final needleEnd = Offset(
      center.dx + needleEndRadius * cos(needleAngle),
      center.dy + needleEndRadius * sin(needleAngle),
    );

    final needlePaint = Paint()
      ..color = themeColor
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(needleStart, needleEnd, needlePaint);

    // Draw a small glowing circle at the tip of the needle
    final needleTipPaint = Paint()
      ..color = themeColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(needleEnd, 3.5, needleTipPaint);

    // 7. Draw central texts inside the gauge (Dynamic W / kW formatting)
    final bool isKw = currentValue >= 1000.0;
    final String displayValue = isKw 
        ? (currentValue / 1000.0).toStringAsFixed(2) 
        : currentValue.toStringAsFixed(0);
    final String displayUnit = isKw ? 'kW' : 'W';

    // - Current value text
    final valueSpan = TextSpan(
      text: displayValue,
      style: const TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w900,
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

    // - Unit text
    final unitSpan = TextSpan(
      text: displayUnit,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
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
        fontWeight: FontWeight.w700,
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
