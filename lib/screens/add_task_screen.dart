import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../utils/constants.dart';

class AddTaskScreen extends StatefulWidget {
  // Menerima data tugas jika ini adalah mode Edit
  final Task? taskToEdit;

  const AddTaskScreen({super.key, this.taskToEdit});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    // LOGIC: Cek apakah ada data tugas yang dikirim?
    if (widget.taskToEdit != null) {
      // MODE EDIT: Isi form dengan data lama
      _titleController = TextEditingController(text: widget.taskToEdit!.title);
      _descController = TextEditingController(text: widget.taskToEdit!.description);
      _selectedCategory = widget.taskToEdit!.category;
    } else {
      // MODE BARU: Kosongkan form
      _titleController = TextEditingController();
      _descController = TextEditingController();
      _selectedCategory = categoryList[0];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      // Jika Edit, pakai ID lama. Jika Baru, buat ID baru.
      final String id = widget.taskToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
      final DateTime date = widget.taskToEdit?.dateCreated ?? DateTime.now();

      final task = Task(
        id: id,
        title: _titleController.text,
        description: _descController.text,
        category: _selectedCategory,
        dateCreated: date,
      );

      // Kembalikan data ke Home Screen
      Navigator.pop(context, task);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.taskToEdit != null;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Tugas' : 'Tugas Baru', style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDarkMode ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- CARD CONTAINER AGAR RAPI ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    // Input Judul
                    TextFormField(
                      controller: _titleController,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: 'Judul Tugas',
                        labelStyle: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                        hintText: 'Contoh: Makalah Technopreneur',
                        prefixIcon: const Icon(Icons.title_rounded, color: Colors.blueAccent),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: isDarkMode ? Colors.black26 : Colors.grey[50],
                      ),
                      validator: (value) => (value == null || value.isEmpty) ? 'Judul wajib diisi' : null,
                    ),
                    const SizedBox(height: 20),
                    
                    // Input Deskripsi
                    TextFormField(
                      controller: _descController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Deskripsi Detail',
                        alignLabelWithHint: true,
                         labelStyle: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                        hintText: 'Catat detail tugasmu di sini...',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 60), // Icon agak ke atas
                          child: Icon(Icons.notes_rounded, color: Colors.blueAccent),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: isDarkMode ? Colors.black26 : Colors.grey[50],
                      ),
                      validator: (value) => (value == null || value.isEmpty) ? 'Deskripsi wajib diisi' : null,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 25),
              const Text("Pilih Kategori", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              // --- DROPDOWN KATEGORI MODERN ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                   boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(20),
                    items: categoryList.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Row(
                          children: [
                            getIconForCategory(category),
                            const SizedBox(width: 15),
                            Text(category, style: const TextStyle(fontWeight: FontWeight.w500)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) => setState(() => _selectedCategory = newValue!),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // --- TOMBOL SIMPAN GRADASI ---
              Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)], // Senada dengan Home
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4A00E0).withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ]
                ),
                child: ElevatedButton.icon(
                  onPressed: _saveForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  icon: Icon(isEdit ? Icons.update_rounded : Icons.save_rounded, color: Colors.white),
                  label: Text(
                    isEdit ? 'PERBARUI TUGAS' : 'SIMPAN TUGAS',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}