import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminReservationListScreen extends StatefulWidget {
  const AdminReservationListScreen({super.key});

  @override
  State<AdminReservationListScreen> createState() => _AdminReservationListScreenState();
}

class _AdminReservationListScreenState extends State<AdminReservationListScreen> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> pendingReservations = [];

  @override
  void initState() {
    super.initState();
    loadPendingReservations();
  }

  Future<void> loadPendingReservations() async {
    final data = await supabase
        .from('reservations')
        .select('id, user_id, seats, created_at, spectacle_id, reservations_spectacle_id_fkey(title, date_time)')
        .eq('status', 'pending')
        .order('created_at');

    setState(() {
      pendingReservations = List<Map<String, dynamic>>.from(data);
    });
  }

  Future<void> updateStatus(String id, String status) async {
    final Map<String, dynamic> update = {
      'status': status,
      'confirmed_at': status == 'confirmed' ? DateTime.now().toIso8601String() : null,
    };

    await supabase.from('reservations').update(update).eq('id', id);
    await loadPendingReservations();
  }
  String formatDateTime(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final day = twoDigits(dateTime.day);
    final month = twoDigits(dateTime.month);
    final year = dateTime.year;
    final hour = twoDigits(dateTime.hour);
    final minute = twoDigits(dateTime.minute);
    final second = twoDigits(dateTime.second);
    return '$day.$month.$year $hour:$minute:$second';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Oczekujące rezerwacje')),
      body: ListView.builder(
        itemCount: pendingReservations.length,
        itemBuilder: (context, index) {
          final r = pendingReservations[index];
          final seats = (r['seats'] as List<dynamic>).join(', ');

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text('Użytkownik: ${r['user_id']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Spektakl: ${r['reservations_spectacle_id_fkey'] != null ? r['reservations_spectacle_id_fkey']['title'] : 'Brak tytułu'}'),
                  Text('Data: ${r['reservations_spectacle_id_fkey'] != null ? formatDateTime(r['reservations_spectacle_id_fkey']['date_time']) : 'Brak daty'}'),
                  Text('Miejsca: $seats'),
                  Text('Złożono: ${formatDateTime(r['created_at'])}'),

                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () => updateStatus(r['id'], 'confirmed'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => updateStatus(r['id'], 'rejected'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
