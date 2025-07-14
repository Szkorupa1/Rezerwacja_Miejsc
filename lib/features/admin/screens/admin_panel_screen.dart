import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Admina'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Dodaj nowy spektakl'),
              onPressed: () {
                context.go('/admin/add-show');
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.event_available),
              label: const Text('Potwierdź rezerwacje'),
              onPressed: () {
                context.go('/admin/Admin_Reservation_List_Screen');
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Wyloguj'),
              onPressed: () {



              },
            ),
          ],
        ),
      ),
    );
  }
}
