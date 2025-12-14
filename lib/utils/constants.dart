import 'package:flutter/material.dart';

// Daftar Kategori
const List<String> categoryList = [
  'Kuliah',
  'Organisasi',
  'Pribadi',
  'Lain-lain'
];

// Mapping Kategori ke Ikon dan Warna agar terlihat keren
final Map<String, Icon> categoryIcons = {
  'Kuliah': const Icon(Icons.menu_book_rounded, color: Colors.blueAccent),
  'Organisasi': const Icon(Icons.groups_rounded, color: Colors.orangeAccent),
  'Pribadi': const Icon(Icons.home_rounded, color: Colors.greenAccent),
  'Lain-lain': const Icon(Icons.auto_awesome_rounded, color: Colors.purpleAccent),
};

// Helper untuk mendapatkan ikon default jika kategori tidak dikenali
Icon getIconForCategory(String category) {
  return categoryIcons[category] ?? const Icon(Icons.note_alt_outlined, color: Colors.grey);
}