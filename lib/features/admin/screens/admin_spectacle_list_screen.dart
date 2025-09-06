import 'package:flutter/material.dart';
import 'package:rezerwacja_miejsc/features/shows/screens/add_show_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rezerwacja_miejsc/features/user/screens/spectacle_detail_screen.dart';

class AdminSpectacleListScreen extends StatefulWidget {
  const AdminSpectacleListScreen({super.key});

  @override
  State<AdminSpectacleListScreen> createState() =>
      _AdminSpectacleListScreenState();
}

class _AdminSpectacleListScreenState extends State<AdminSpectacleListScreen> {
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

  Future<void> deactivateSpectacle(String id) async {
    try {
      await supabase.from('spectacles').update({'is_active': false}).eq('id', id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Spektakl został dezaktywowany')),
      );

      setState(() {
        spectaclesFuture = fetchSpectacles(); // odśwież listę
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd przy dezaktywacji: $e')),
      );
    }
  }

  void editSpectacle(Map<String, dynamic> spectacle) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddShowScreen(spectacle: spectacle),
      ),
    );

    if (updated == true) {
      setState(() {
        spectaclesFuture = fetchSpectacles(); // odśwież listę po edycji
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista spektakli (Admin)')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: spectaclesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Błąd: ${snapshot.error}'));
          }

          final spectacles = snapshot.data ?? [];
          if (spectacles.isEmpty) {
            return const Center(child: Text('Brak spektakli.'));
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
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Plakat
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
                          // Info
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
                                const SizedBox(height: 4),
                                Text(
                                  '${dateTime.day.toString().padLeft(2,'0')}.${dateTime.month.toString().padLeft(2,'0')}.${dateTime.year} '
                                      '${dateTime.hour.toString().padLeft(2,'0')}:${dateTime.minute.toString().padLeft(2,'0')}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                if (spec['duration_minutes'] != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Czas trwania: ${spec['duration_minutes']} min',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Akcje (edycja/usuwanie) w prawym górnym rogu
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                              onPressed: () => editSpectacle(spec),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Potwierdź usunięcie'),
                                    content: Text(
                                        'Czy na pewno chcesz usunąć spektakl "${spec['title']}"?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx, false),
                                        child: const Text('Nie'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx, true),
                                        child: const Text('Tak'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await deactivateSpectacle(spec['id']);
                                }
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
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
