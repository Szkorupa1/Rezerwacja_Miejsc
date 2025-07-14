import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel użytkownika')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.theaters),
              label: const Text('Zarezerwuj miejsce'),
              onPressed: () {
                context.go('/user/spectacles');
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.event_seat),
              label: const Text('Moje rezerwacje'),
              onPressed: () {
                context.go('/user/reservation_screen.dart');
              },
            ),
          ],
        ),
      ),
    );
  }
}
