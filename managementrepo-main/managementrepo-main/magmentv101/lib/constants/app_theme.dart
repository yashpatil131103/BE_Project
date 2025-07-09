import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryColor = Color(0xFF6C5CE7); // Vibrant Purple
  static const Color accentColor = Color(0xFFFD79A8); // Pink
  static const Color backgroundColor = Color(0xFFF7F1FF); // Light Purple
  static const Color cardColor = Colors.white;
  static const Color iconColor = Color(0xFF00CEFF); // Bright Cyan
  static const Color borderColor = Color(0xFF00B894); // Teal

  // Text Colors
  static const Color headlineColor = Color(0xFF6C5CE7); // Vibrant Purple
  static const Color subtitleColor = Color(0xFF2D3436); // Dark Gray
  static const Color bodyTextColor = Color(0xFF2D3436); // Dark Gray
  static const Color buttonTextColor = Colors.white;
  static const Color linkTextColor = Color(0xFFFD79A8); // Pink

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C5CE7), Color(0xFF00CEFF)],
  );

  // Text Styles
  static TextStyle headlineTextStyle = GoogleFonts.quicksand(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: headlineColor,
  );

  static TextStyle subtitleTextStyle = GoogleFonts.quicksand(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: subtitleColor,
  );

  static TextStyle bodyTextStyle = GoogleFonts.quicksand(
    fontSize: 16,
    color: bodyTextColor,
  );

  static TextStyle buttonTextStyle = GoogleFonts.quicksand(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: buttonTextColor,
  );

  static TextStyle linkTextStyle = GoogleFonts.quicksand(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: linkTextColor,
  );

  static TextStyle inputTextStyle = GoogleFonts.quicksand(
    fontSize: 16,
    color: Colors.black,
  );

  static TextStyle chipTextStyle = GoogleFonts.quicksand(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  // Input Decoration
  static InputDecoration inputDecoration = InputDecoration(
    filled: true,
    fillColor: Colors.white,
    hintStyle: AppTheme.chipTextStyle,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: borderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: primaryColor, width: 2),
    ),
  );

  // Button Styles
  static final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: buttonTextColor,
    minimumSize: Size(double.infinity, 50),
    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      titleTextStyle: headlineTextStyle.copyWith(color: Colors.white),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    textTheme: TextTheme(
      titleLarge: headlineTextStyle,
      titleMedium: subtitleTextStyle,
      bodyMedium: bodyTextStyle,
      labelLarge: buttonTextStyle,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: borderColor),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: elevatedButtonStyle,
    ),
  );
}
