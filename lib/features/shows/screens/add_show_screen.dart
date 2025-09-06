import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddShowScreen extends StatefulWidget {
  final Map<String, dynamic>? spectacle;

  const AddShowScreen({super.key, this.spectacle});

  @override
  State<AddShowScreen> createState() => _AddShowScreenState();
}

class _AddShowScreenState extends State<AddShowScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();

  DateTime? _date;
  File? _selectedImage;
  Uint8List? _webImageBytes;
  String? _existingImageUrl;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    if (widget.spectacle != null) {
      _titleController.text = widget.spectacle!['title'] ?? '';
      _descriptionController.text = widget.spectacle!['description'] ?? '';
      _durationController.text =
          widget.spectacle!['duration_minutes']?.toString() ?? '';
      _date = widget.spectacle!['date_time'] != null
          ? DateTime.parse(widget.spectacle!['date_time'])
          : null;
      _existingImageUrl = widget.spectacle!['image_url'];
    }
  }

  // --- WYBÓR DATY I CZASU ---
  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: _date != null
          ? TimeOfDay(hour: _date!.hour, minute: _date!.minute)
          : TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      _date = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  // --- WYBÓR OBRAZU ---
  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      if (kIsWeb) {
        setState(() {
          _webImageBytes = result.files.single.bytes;
          _selectedImage = null;
        });
      } else if (result.files.single.path != null) {
        setState(() {
          _selectedImage = File(result.files.single.path!);
          _webImageBytes = null;
        });
      }
    }
  }

  // --- UPLOAD OBRAZU DO SUPABASE STORAGE ---
  Future<String?> _uploadImage() async {
    final fileName = 'spectacles/${DateTime.now().millisecondsSinceEpoch}.png';

    try {
      if (kIsWeb && _webImageBytes != null) {
        await supabase.storage.from('images').uploadBinary(fileName, _webImageBytes!);
      } else if (_selectedImage != null) {
        await supabase.storage.from('images').upload(fileName, _selectedImage!);
      } else {
        return null;
      }

      final publicUrl = supabase.storage.from('images').getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      debugPrint('Błąd uploadu: $e');
      return null;
    }
  }

  // --- ZAPIS DO BAZY (ADD/EDIT) ---
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uzupełnij wszystkie pola i wybierz datę')),
      );
      return;
    }

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final duration = int.tryParse(_durationController.text.trim());

    if (duration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Czas trwania musi być liczbą')),
      );
      return;
    }

    String? imageUrl;
    if (_selectedImage != null || _webImageBytes != null) {
      imageUrl = await _uploadImage();
      if (imageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Błąd przesyłania zdjęcia')),
        );
        return;
      }
    } else {
      imageUrl = _existingImageUrl;
    }

    try {
      if (widget.spectacle == null) {
        // --- dodawanie ---
        await supabase.from('spectacles').insert({
          'title': title,
          'description': description,
          'date_time': _date!.toIso8601String(),
          'duration_minutes': duration,
          'image_url': imageUrl,
          'is_active': true,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dodano spektakl')),
        );
      } else {
        // --- edycja ---
        await supabase.from('spectacles').update({
          'title': title,
          'description': description,
          'date_time': _date!.toIso8601String(),
          'duration_minutes': duration,
          'image_url': imageUrl,
        }).eq('id', widget.spectacle!['id']);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Spektakl został zaktualizowany')),
        );
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.spectacle == null ? 'Dodaj Spektakl' : 'Edytuj Spektakl')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Tytuł'),
                validator: (value) =>
                (value == null || value.isEmpty) ? 'Proszę wprowadzić tytuł' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Opis'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(labelText: 'Czas trwania (min)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              Text(_date == null
                  ? 'Nie wybrano daty'
                  : 'Wybrana data: ${_date.toString()}'),
              TextButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: const Text('Wybierz datę i godzinę'),
                onPressed: _pickDateTime,
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                icon: const Icon(Icons.image),
                label: const Text('Dodaj/zmień plakat'),
                onPressed: _pickImage,
              ),
              const SizedBox(height: 12),
              if (_selectedImage != null)
                Image.file(_selectedImage!, height: 150, fit: BoxFit.contain),
              if (_webImageBytes != null)
                Image.memory(_webImageBytes!, height: 150, fit: BoxFit.contain),
              if (_existingImageUrl != null && _selectedImage == null && _webImageBytes == null)
                Image.network(_existingImageUrl!, height: 150, fit: BoxFit.contain),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text(widget.spectacle == null ? 'Zapisz spektakl' : 'Zaktualizuj spektakl'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
