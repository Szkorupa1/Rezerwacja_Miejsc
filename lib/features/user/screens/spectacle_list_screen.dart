import 'package:flutter/material.dart';
import 'package:rezerwacja_miejsc/features/user/screens/spectacle_detail_screen.dart';
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

  final now = DateTime.now().toIso8601String();

  Future<List<Map<String, dynamic>>> fetchSpectacles() async {
    final response = await supabase
        .from('spectacles')
        .select('*')
        .eq('is_active', true)
        .gte('date_time', now) // tylko przyszłe spektakle
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

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.6,
            ),
            itemCount: spectacles.length,
            itemBuilder: (context, index) {
              final spec = spectacles[index];
              final dateTime = DateTime.parse(spec['date_time']).toLocal();
              final imageUrl = spec['image_url'];

              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SpectacleDetailScreen(spectacle: spec),
                    ),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                      Expanded(
                        child: imageUrl != null
                            ? Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image, size: 40),
                          ),
                        )
                            : Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, size: 40),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              spec['title'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),

                            Text(
                              spec['description'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),

                            Text(
                              '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} '
                                  '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            if (spec['duration_minutes'] != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Czas trwania: ${spec['duration_minutes']} min',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
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
