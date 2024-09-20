import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shopping_list_app/widgets/grocery_list.dart';

final theme = ThemeData(
  cardTheme: const CardTheme().copyWith(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 147, 229, 250),
      brightness: Brightness.dark),
  textTheme: GoogleFonts.latoTextTheme(
    const TextTheme(
      bodySmall: TextStyle(color: Colors.white, fontSize: 15),
    ),
  ),
);
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(context) {
    return MaterialApp(
      theme: theme,
      home: const GroceryList(),
    );
  }
}
