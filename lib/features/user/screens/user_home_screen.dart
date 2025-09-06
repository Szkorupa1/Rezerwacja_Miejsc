import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel użytkownika'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                icon: const Icon(Icons.theaters, size: 28),
                label: const Text(
                  'Zarezerwuj miejsce',
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  context.go('/user/spectacles');
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                icon: const Icon(Icons.event_seat, size: 28),
                label: const Text(
                  'Moje rezerwacje',
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  context.go('/user/reservation_screen.dart');
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  backgroundColor: Colors.redAccent,
                ),
                icon: const Icon(Icons.logout, size: 28),
                label: const Text(
                  'Wyloguj',
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: () async {
                  try {
                    await Supabase.instance.client.auth.signOut();
                    if (context.mounted) {
                      context.go('/auth');
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Błąd wylogowania: $e')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
