import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rezerwacja_miejsc/features/user/screens/reservation_screen.dart';

class SpectacleListScreen extends StatefulWidget {
  const SpectacleListScreen({super.key});

  @override
  State<SpectacleListScreen> createState() => _SpectacleListScreenState();
}

class _SpectacleListScreenState extends State<SpectacleListScreen> {
  final supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> spectaclesFuture;

  @override
  void initState() {
    super.initState();
    spectaclesFuture = fetchSpectacles();
  }

  Future<List<Map<String, dynamic>>> fetchSpectacles() async {
    final response = await supabase
        .from('spectacles')
        .select('*')
        .order('date_time', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dostępne spektakle')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: spectaclesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Błąd: ${snapshot.error}'));
          }

          final spectacles = snapshot.data!;
          if (spectacles.isEmpty) {
            return const Center(child: Text('Brak dostępnych spektakli.'));
          }

          return ListView.builder(
            itemCount: spectacles.length,
            itemBuilder: (context, index) {
              final spec = spectacles[index];
              return ListTile(
                title: Text(spec['title']),
                subtitle: Text(spec['description']),
                trailing: Text(DateTime.parse(spec['date_time']).toLocal().toString()),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ReservationScreen(spectacle: spec),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
