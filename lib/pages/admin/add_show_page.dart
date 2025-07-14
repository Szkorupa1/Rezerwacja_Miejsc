import 'package:flutter/material.dart';
import '../../services/show_service.dart';

class AddShowPage extends StatefulWidget {
  const AddShowPage({Key? key}) : super(key: key);

  @override
  _AddShowPageState createState() => _AddShowPageState();
}

class _AddShowPageState extends State<AddShowPage> {
  final _formKey = GlobalKey<FormState>();
  final _showService = ShowService();

  String _title = '';
  String _description = '';
  DateTime? _date;

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && _date != null) {
      _formKey.currentState!.save();
      try {
        await _showService.addShow(
          title: _title,
          description: _description,
          date: _date!,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Spektakl dodany')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uzupełnij wszystkie pola')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dodaj spektakl')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Tytuł'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Podaj tytuł' : null,
                onSaved: (value) => _title = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Opis'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Podaj opis' : null,
                onSaved: (value) => _description = value!,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(_date == null
                      ? 'Wybierz datę'
                      : 'Data: ${_date!.toLocal().toString().split(' ')[0]}'),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                      );
                      if (picked != null) {
                        setState(() {
                          _date = picked;
                        });
                      }
                    },
                    child: const Text('Wybierz datę'),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Dodaj spektakl'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
