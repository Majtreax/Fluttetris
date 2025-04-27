import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tetris/game.dart';

void main() => runApp(const TetrisApp());

class TetrisApp extends StatelessWidget {
  const TetrisApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Roboto for all text
        textTheme: GoogleFonts.robotoTextTheme(),
        // Make scaffolds transparent so our gradient shows through
        scaffoldBackgroundColor: Colors.transparent,
      ),
      // Wrap every page in a purple gradient container
      builder: (context, child) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurpleAccent,
              Colors.blueAccent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: child,
      ),
      home: const GamePage(),
    );
  }
}
