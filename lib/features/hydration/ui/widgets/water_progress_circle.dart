import 'package:flutter/material.dart';
import 'wave_progress_widget.dart';

class WaterProgressCircle extends StatelessWidget {
  final double progress;
  final int percentage;

  const WaterProgressCircle({
    super.key,
    required this.progress,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to make it responsive
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate size based on screen width, maxing out at 260
        final double size = (MediaQuery.of(context).size.width * 0.65).clamp(
          200.0,
          280.0,
        );
        final double innerSize = size - 20;

        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background Circle border
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.cyan.withValues(alpha: 0.1),
                    width: 2,
                  ),
                ),
              ),
              // Wave Widget
              Container(
                width: innerSize,
                height: innerSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyan.withValues(alpha: 0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: progress),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return WaveProgressWidget(
                        progress: value,
                        size: innerSize,
                        color: Colors.cyanAccent,
                      );
                    },
                  ),
                ),
              ),
              // Center Content (Percentage & Icon)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.water_drop,
                    size: size * 0.18, // Responsive icon size
                    color: progress > 0.5 ? Colors.white : Colors.cyan,
                    shadows: [
                      if (progress > 0.5)
                        const Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 4.0,
                          color: Colors.black26,
                        ),
                    ],
                  ),
                  TweenAnimationBuilder<int>(
                    tween: IntTween(begin: 0, end: percentage),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutExpo,
                    builder: (context, value, child) {
                      return Text(
                        '$value%',
                        style: TextStyle(
                          fontSize: size * 0.16, // Responsive font size
                          fontWeight: FontWeight.bold,
                          color: progress > 0.5 ? Colors.white : Colors.black87,
                          shadows: [
                            if (progress > 0.5)
                              const Shadow(
                                offset: Offset(0, 2),
                                blurRadius: 4.0,
                                color: Colors.black26,
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
