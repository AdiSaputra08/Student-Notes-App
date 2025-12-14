import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../models/task_model.dart';
import '../utils/constants.dart';
import 'add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final ThemeMode currentMode;

  const HomeScreen(
      {super.key, required this.onThemeChanged, required this.currentMode});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> _tasks = [];
  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      final List<dynamic> decodedList = jsonDecode(tasksJson);
      setState(() {
        _tasks = decodedList.map((item) => Task.fromMap(item)).toList();
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList =
        jsonEncode(_tasks.map((task) => task.toMap()).toList());
    await prefs.setString('tasks', encodedList);
  }

  void _addTask(Task task) {
    setState(() => _tasks.insert(0, task));
    _saveTasks();
    _showSnackBar('Tugas berhasil ditambahkan!', Colors.green);
  }

  void _updateTask(Task updatedTask) {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      setState(() => _tasks[index] = updatedTask);
      _saveTasks();
      _showSnackBar('Tugas berhasil diperbarui!', Colors.blueAccent);
    }
  }

  void _deleteTask(String id) {
    final deletedTask = _tasks.firstWhere((t) => t.id == id);
    final deletedIndex = _tasks.indexOf(deletedTask);

    setState(() => _tasks.removeWhere((t) => t.id == id));
    _saveTasks();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Tugas dihapus'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'BATAL',
          textColor: Colors.yellowAccent,
          onPressed: () {
            setState(() => _tasks.insert(deletedIndex, deletedTask));
            _saveTasks();
          },
        ),
      ),
    );
  }

  // --- FITUR BARU: DIALOG KONFIRMASI HAPUS ---
  void _showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Tugas?"),
        content: const Text("Tugas ini akan dihapus permanen dari daftar."),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () {
              _deleteTask(id); // Jalankan fungsi hapus
              Navigator.pop(ctx); // Tutup dialog
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  void _navigateToForm({Task? task}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTaskScreen(taskToEdit: task)),
    );
    if (result != null && result is Task) {
      task == null ? _addTask(result) : _updateTask(result);
    }
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi,';
    if (hour < 15) return 'Selamat Siang,';
    if (hour < 18) return 'Selamat Sore,';
    return 'Selamat Malam,';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    final filteredTasks = _selectedFilter == 'Semua'
        ? _tasks
        : _tasks.where((t) => t.category == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF0F4F8),
      body: Column(
        children: [
          // --- HEADER ---
          Container(
            padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 25),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode 
                    ? [Colors.grey[900]!, Colors.grey[800]!] 
                    : [const Color(0xFF4A00E0), const Color(0xFF8E2DE2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))
              ]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_getGreeting(), style: const TextStyle(color: Colors.white70, fontSize: 16)),
                        const SizedBox(height: 4),
                        const Text("Mahasiswa Sistem Informasi", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(15)),
                      child: IconButton(
                        icon: Icon(widget.currentMode == ThemeMode.dark ? Icons.sunny : Icons.nightlight_round),
                        color: Colors.white,
                        onPressed: () => widget.onThemeChanged(widget.currentMode != ThemeMode.dark),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 25),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedFilter,
                      dropdownColor: isDarkMode ? Colors.grey[800] : const Color(0xFF5E17EB),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                      icon: const Icon(Icons.filter_list, color: Colors.white70),
                      isExpanded: true,
                      items: ['Semua', ...categoryList].map((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value));
                      }).toList(),
                      onChanged: (newValue) => setState(() => _selectedFilter = newValue!),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- LIST TUGAS ---
          Expanded(
            child: filteredTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.rocket_launch_rounded, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 20),
                        Text("Hore! Tidak ada tugas.", style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      final categoryIcon = getIconForCategory(task.category);
                      
                      return Dismissible(
                        key: Key(task.id),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                           // Fitur: Geser juga memunculkan dialog konfirmasi
                           _showDeleteDialog(task.id);
                           return false; // Mencegah hapus langsung, tunggu tombol dialog
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 25),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(20)),
                          child: const Icon(Icons.delete_forever, color: Colors.white, size: 28),
                        ),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: Colors.grey.withOpacity(isDarkMode ? 0.05 : 0.08), spreadRadius: 2, blurRadius: 15, offset: const Offset(0, 8)),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => _navigateToForm(task: task),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 55, width: 55,
                                      decoration: BoxDecoration(color: categoryIcon.color!.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
                                      child: categoryIcon,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                                          const SizedBox(height: 5),
                                          Text(task.description, style: TextStyle(color: Colors.grey[600], fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(Icons.access_time, size: 12, color: Colors.grey[400]),
                                              const SizedBox(width: 4),
                                              Text(DateFormat('dd MMM • HH:mm').format(task.dateCreated), style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    
                                    // --- TOMBOL DELETE NYATA ---
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                                      onPressed: () {
                                        // Panggil Dialog Konfirmasi saat tombol ditekan
                                        _showDeleteDialog(task.id);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)]),
          boxShadow: [BoxShadow(color: const Color(0xFF4A00E0).withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))]
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _navigateToForm(),
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          label: const Text("Tambah Tugas Baru", style: TextStyle(fontWeight: FontWeight.bold)),
          icon: const Icon(Icons.add_circle_outline),
        ),
      ),
    );
  }
}