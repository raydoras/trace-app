import 'package:flutter/material.dart';

import 'tela_inicial.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const fundo = Color(0xFF0D1F17);
    const card = Color(0xFF162A20);
    const destaque = Color(0xFF6F9B76);
    const textoPrincipal = Color(0xFFF1F5F2);
    const textoSecundario = Color(0xFFA8B2AA);

    return MaterialApp(
      title: 'TRACE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: fundo,
        colorScheme: const ColorScheme.dark(
          primary: destaque,
          onPrimary: fundo,
          secondary: destaque,
          onSecondary: fundo,
          surface: card,
          onSurface: textoPrincipal,
          onSurfaceVariant: textoSecundario,
        ),
        textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: textoPrincipal,
          displayColor: textoPrincipal,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: fundo,
          foregroundColor: textoPrincipal,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          color: card,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: card,
          labelStyle: const TextStyle(color: textoSecundario),
          hintStyle: const TextStyle(color: textoSecundario),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: destaque),
          ),
        ),
      ),
      home: const TelaInicial(),
    );
  }
}
