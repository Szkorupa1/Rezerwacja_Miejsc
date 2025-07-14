import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddShowScreen extends StatefulWidget {
  const AddShowScreen({super.key});

  @override
  State<AddShowScreen> createState() => _AddShowScreenState();
}

class _AddShowScreenState extends State<AddShowScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();

  DateTime? _date;

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      _date = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

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

    try {
      await Supabase.instance.client.from('spectacles').insert({
        'title': title,
        'description': description,
        'date_time': _date!.toIso8601String(),
        'duration_minutes': duration,
      }).select(); // <- ważne!

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dodano spektakl')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd dodawania: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dodaj Spektakl')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Tytuł'),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Proszę wprowadzić tytuł'
                    : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Opis'),
                maxLines: 3,
              ),
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Zapisz spektakl'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
