import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Import halaman utama
import 'screens/home_screen.dart';

void main() {
  // Memastikan binding diinisialisasi sebelum akses SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system; // Default ke system

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  // Bonus: Load tema dari SharedPreferences
  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Jika belum ada data, gunakan light mode sebagai default
      final isDark = prefs.getBool('isDarkMode') ?? false;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  // Bonus: Fungsi Toggle Dark Mode yang akan dilempar ke HomeScreen
  void _toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      prefs.setBool('isDarkMode', isDark);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Definisi Warna Utama agar konsisten keren
    const seedColor = Colors.indigo;

    return MaterialApp(
      title: 'Catatan Tugas Mahasiswa',
      debugShowCheckedModeBanner: false,
      // Tema Terang yang Keren
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white, // Mencegah warna tercampur di M3
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      // Tema Gelap yang Keren
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          surfaceTintColor: Colors.grey[900],
        ),
        scaffoldBackgroundColor: Colors.grey[900],
      ),
      themeMode: _themeMode,
      // Mengirimkan fungsi dan status tema ke HomeScreen
      home: HomeScreen(onThemeChanged: _toggleTheme, currentMode: _themeMode),
    );
  }
}