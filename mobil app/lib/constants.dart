import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AppColors {
  static const Color clearTurquoise = Color(0xFF008b7f);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color sherpaBlue = Color(0xFF00494e);
  static const Color tucsonTeal = Color(0xFF00848c);
  static const Color saltMountain = Color(0xFFD9FDFF);
  static const Color epicureanOrange = Color(0xFFEC6608);
  static const Color chromeYellow = Color(0xFFFFA800);
  static const Color naturalIndigo = Color(0xFF03393D);
  static const Color red = Color(0xFFE60000);
  static const Color plungePool = Color(0xFF00FFD1);
  static const Color moreThanaWeek = Color(0xFF8c8c8c);
  static const Color silentBreath = Color(0xFFE8F1EE);
  static const Color aareRiverBrienz = Color(0xFF04A1AB);
  static const Color neavyBlue = Color(0xFF0A2D3B);
  static const Color cyan = Color(0xFF00FFFF);
  static const List<Color> sliderColors = [
    Color.fromARGB(255, 255, 0, 0),
    Color.fromARGB(255, 255, 128, 0),
    Color.fromARGB(255, 255, 255, 0),
    Color.fromARGB(255, 128, 255, 0),
    Color.fromARGB(255, 0, 255, 0),
    Color.fromARGB(255, 0, 255, 128),
    Color.fromARGB(255, 255, 255, 255),
    Color.fromARGB(255, 0, 255, 255),
    Color.fromARGB(255, 0, 128, 255),
    Color.fromARGB(255, 0, 0, 255),
    Color.fromARGB(255, 127, 0, 255),
    Color.fromARGB(255, 255, 0, 255),
    Color.fromARGB(255, 255, 0, 127),
    Color.fromARGB(255, 128, 128, 128),
  ];
}

class SliderIndicatorPainter extends CustomPainter {
  final double position;
  SliderIndicatorPainter(this.position);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
        Offset(position, size.height / 2), 12, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(SliderIndicatorPainter old) {
    return true;
  }
}

class GraphQlExtensions {
  static String uri = 'http://cow.visiobit.org/graphql';
  static String token =
      'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MywiaWF0IjoxNjY3MjAxMTUwLCJleHAiOjE2Njk3OTMxNTB9.-nXSpH4J8cScMeSgEzbufKM810afofFv0QhE-t7Vlyo';

  static String updateMilkData = """
      mutation UpdateMilkingData(\$Production:Float,\$Time:DateTime)
      {
        updateMilkingData(
          id: 52
          data : {
            Time: \$Time
            Production: \$Production 
          }
        )
        {
          data{attributes{Time}}
        }   
      }
        """;
}
