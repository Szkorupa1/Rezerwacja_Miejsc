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
  Set<String> pendingSeats = {};
  Set<String> selectedSeats = {};

  @override
  void initState() {
    super.initState();
    loadSeats();
  }

  Future<void> loadSeats() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;


    final confirmed = await supabase
        .from('reservations')
        .select('seats')
        .eq('spectacle_id', widget.spectacle['id'])
        .eq('status', 'confirmed');

    final Set<String> loadedReserved = {};
    for (final r in confirmed) {
      loadedReserved.addAll((r['seats'] as List).cast<String>());
    }


    final pending = await supabase
        .from('reservations')
        .select('seats, user_id')
        .eq('spectacle_id', widget.spectacle['id'])
        .eq('status', 'pending');

    final Set<String> loadedPending = {};
    final userPendingSeats = <String>{};

    for (final r in pending) {
      final seats = (r['seats'] as List).cast<String>();
      loadedPending.addAll(seats);
      if (r['user_id'] == user.id) {
        userPendingSeats.addAll(seats);
      }
    }

    setState(() {
      reservedSeats = loadedReserved;
      pendingSeats = loadedPending;

      selectedSeats.removeWhere((s) => userPendingSeats.contains(s));
    });
  }

  Future<void> reserveSeats() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;


    final newSeats = selectedSeats.where((s) => !pendingSeats.contains(s)).toList();

    if (newSeats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wybrane miejsca są już w rezerwacji oczekującej')),
      );
      return;
    }

    final insert = {
      'user_id': user.id,
      'spectacle_id': widget.spectacle['id'],
      'seats': newSeats,
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

    await loadSeats();
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
          Text(
            'Wybierz miejsca:',
            style: Theme.of(context).textTheme.titleLarge,
          ),
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

                final seatId = isSceneView ? 'R$row-S$seat' : 'B$row-S$seat';

                final isReserved = reservedSeats.contains(seatId);
                final isPending = pendingSeats.contains(seatId);
                final isSelected = selectedSeats.contains(seatId);

                Color seatColor;
                if (isReserved) {
                  seatColor = Colors.red; // Zajęte
                } else if (isPending) {
                  seatColor = Colors.yellow; // Czekające na potwierdzenie
                } else if (isSelected) {
                  seatColor = Colors.green; // Wybrane przez użytkownika
                } else {
                  seatColor = Colors.grey[300]!; // Wolne
                }

                return GestureDetector(
                  onTap: (isReserved || isPending)
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
                      color: seatColor,
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
