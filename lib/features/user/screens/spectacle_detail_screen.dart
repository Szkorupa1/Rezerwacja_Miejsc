import 'package:flutter/material.dart';
import 'package:rezerwacja_miejsc/features/user/screens/reservation_screen.dart';

class SpectacleDetailScreen extends StatelessWidget {
  final Map<String, dynamic> spectacle;

  const SpectacleDetailScreen({super.key, required this.spectacle});

  @override
  Widget build(BuildContext context) {
    final dateTime = DateTime.parse(spectacle['date_time']).toLocal();
    final imageUrl = spectacle['image_url'];

    return Scaffold(
      appBar: AppBar(title: Text(spectacle['title'])),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Zdjęcie po lewej ---
            Container(
              width: 150, // szerokość plakatu
              height: 220, // wysokość plakatu
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: imageUrl != null
                  ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
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

            const SizedBox(width: 16),

            // --- Tekst po prawej ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spectacle['title'],
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${dateTime.day.toString().padLeft(2,'0')}.${dateTime.month.toString().padLeft(2,'0')}.${dateTime.year} '
                        '${dateTime.hour.toString().padLeft(2,'0')}:${dateTime.minute.toString().padLeft(2,'0')}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  if (spectacle['duration_minutes'] != null)
                    Text(
                      'Czas trwania: ${spectacle['duration_minutes']} min',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    spectacle['description'] ?? '',
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ReservationScreen(spectacle: spectacle),
                        ),
                      );
                    },
                    child: const Text('Rezerwuj miejsca'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
