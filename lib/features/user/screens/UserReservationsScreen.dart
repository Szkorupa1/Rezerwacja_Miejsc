import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserReservationsScreen extends StatefulWidget {
  const UserReservationsScreen({super.key});

  @override
  State<UserReservationsScreen> createState() => _UserReservationsScreenState();
}

class _UserReservationsScreenState extends State<UserReservationsScreen> {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> _loadReservations() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await supabase
        .from('reservations')
        .select('id, status, seats, confirmed_at, spectacles(title, date_time)')
        .eq('user_id', userId)
        .eq('status', 'confirmed')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> _cancelReservation(String reservationId) async {
    await supabase
        .from('reservations')
        .update({'status': 'cancelled'})
        .eq('id', reservationId);



    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Moje rezerwacje')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadReservations(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final reservations = snapshot.data!;
          if (reservations.isEmpty) {
            return const Center(child: Text('Brak rezerwacji.'));
          }

          return ListView.builder(
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final res = reservations[index];
              final spectacle = res['spectacles'];
              final status = res['status'];
              final isCancelled = status == 'cancelled';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(spectacle['title']),
                  subtitle: Text(
                    'Data: ${DateTime.parse(spectacle['date_time']).toLocal()}\n'
                        'Miejsca: ${res['seats']}\n'
                        'Status: $status',
                  ),
                  trailing: isCancelled
                      ? null
                      : IconButton(
                    icon: const Icon(Icons.cancel),
                    color: Colors.red,
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Potwierdź'),
                          content: const Text('Czy na pewno chcesz anulować rezerwację?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Nie')),
                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Tak')),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await _cancelReservation(res['id']);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
