import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
              onPressed: () async {

                final added = await context.push<bool>('/admin/add-show');


                if (added == true) {

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Spektakl został dodany!')),
                  );
                }
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
              icon: const Icon(Icons.list),
              label: const Text('Lista spektakli (Admin)'),
              onPressed: () {
                context.go('/admin/spectacle-list');
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Wyloguj'),
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
    );
  }
}
