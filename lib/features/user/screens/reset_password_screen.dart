import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final newPasswordController = TextEditingController();
  final supabase = Supabase.instance.client;
  bool isLoading = false;

  Future<void> updatePassword() async {
    final newPassword = newPasswordController.text.trim();

    if (newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wpisz nowe hasło')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hasło zostało zmienione')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ustaw nowe hasło')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(labelText: 'Nowe hasło'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : updatePassword,
              child: const Text('Zmień hasło'),
            ),
          ],
        ),
      ),
    );
  }
}
