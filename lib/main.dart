import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:rezerwacja_miejsc/features/admin/screens/Admin_Reservation_List_Screen.dart';
import 'features/auth/screens/auth_screen.dart';
import 'features/admin/screens/admin_panel_screen.dart';
import 'features/user/screens/user_home_screen.dart';
import 'features/shows/screens/add_show_screen.dart';
import 'package:rezerwacja_miejsc/features/user/screens/UserReservationsScreen.dart';
import 'package:rezerwacja_miejsc/features/user/screens/spectacle_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const AuthScreen(),
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminPanelScreen(),
        ),
        GoRoute(
          path: '/user_home',
          builder: (context, state) => const UserHomeScreen(),
        ),
        GoRoute(
          path: '/admin/Admin_Reservation_List_Screen',
          builder: (context, state) => const AdminReservationListScreen(),
        ),
        GoRoute(
          path: '/admin/add-show',
          builder: (context, state) => const AddShowScreen(),
        ),
        GoRoute(
          path: '/user/reservation_screen.dart',
          builder: (context, state) => const UserReservationsScreen(),
        ),
        GoRoute(
          path: '/user/spectacles',
          builder: (context, state) => const SpectacleListScreen(),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Kino App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: router,
    );
  }
}
