import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReservationScreen extends StatefulWidget {
  final Map<String, dynamic> spectacle;

  const ReservationScreen({super.key, required this.spectacle});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final supabase = Supabase.instance.client;

  static const int sceneRows = 12;
  static const int sceneSeatsPerRow = 15;

  static const int balconyRows = 3;
  static const int balconySeatsPerRow = 8;

  bool isSceneView = true;

  Set<String> reservedSeats = {};
  Set<String> selectedSeats = {};

  @override
  void initState() {
    super.initState();
    loadReservedSeats();
  }

  Future<void> loadReservedSeats() async {
    final data = await supabase
        .from('reservations')
        .select('seats')
        .eq('spectacle_id', widget.spectacle['id'])
        .eq('status', 'confirmed');

    final Set<String> loaded = {};

    for (final r in data) {
      final List<dynamic> seats = r['seats'];
      loaded.addAll(seats.cast<String>());
    }

    setState(() {
      reservedSeats = loaded;
    });
  }

  Future<void> reserveSeats() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final insert = {
      'user_id': user.id,
      'spectacle_id': widget.spectacle['id'],
      'seats': selectedSeats.toList(),
      'status': 'pending',
      'confirmed_at': null,
    };

    await supabase.from('reservations').insert(insert);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rezerwacja oczekuje na potwierdzenie')),
    );

    setState(() {
      selectedSeats.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final int rows = isSceneView ? sceneRows : balconyRows;
    final int seatsPerRow = isSceneView ? sceneSeatsPerRow : balconySeatsPerRow;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.spectacle['title']),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                isSceneView = !isSceneView;
                selectedSeats.clear();
              });
            },
            child: Text(
              isSceneView ? 'Balkon' : 'Scena',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Text('Wybierz miejsca:', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: seatsPerRow,
                childAspectRatio: 1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: rows * seatsPerRow,
              itemBuilder: (context, index) {
                final row = index ~/ seatsPerRow + 1;
                final seat = index % seatsPerRow + 1;
                final seatId = 'R$row-S$seat';

                final isReserved = reservedSeats.contains(seatId);
                final isSelected = selectedSeats.contains(seatId);

                return GestureDetector(
                  onTap: isReserved
                      ? null
                      : () {
                    setState(() {
                      if (isSelected) {
                        selectedSeats.remove(seatId);
                      } else {
                        selectedSeats.add(seatId);
                      }
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isReserved
                          ? Colors.red
                          : isSelected
                          ? Colors.green
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(seatId),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: selectedSeats.isEmpty ? null : reserveSeats,
              child: const Text('Zarezerwuj wybrane miejsca'),
            ),
          ),
        ],
      ),
    );
  }
}
