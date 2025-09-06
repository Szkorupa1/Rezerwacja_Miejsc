import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rezerwacja_miejsc/features/admin/screens/admin_spectacle_list_screen.dart';
import 'package:rezerwacja_miejsc/features/user/screens/reset_password_screen.dart';
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
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/auth',
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
          path: '/admin/spectacle-list',
          builder: (context, state) => const AdminSpectacleListScreen(),
        ),
        GoRoute(
          path: '/admin/add-show',
          builder: (context, state) => const AddShowScreen(),
        ),
        GoRoute(
          path: '/user/reset-password',
          builder: (context, state) => const ResetPasswordScreen(),
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

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();


    final session = supabase.auth.currentSession;
    if (session != null) {
      _redirectBasedOnRole(session.user.id);
    } else {

      supabase.auth.onAuthStateChange.listen((data) {
        final event = data.event;
        final session = data.session;

        if (session != null && (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.initialSession)) {
          _redirectBasedOnRole(session.user.id);
        } else if (event == AuthChangeEvent.signedOut) {
          context.go('/auth');
        }
      });


      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && supabase.auth.currentSession == null) {
          context.go('/auth');
        }
      });
    }
  }

  Future<void> _redirectBasedOnRole(String userId) async {
    final role = await _getUserRole(userId);
    if (!mounted) return;

    if (role == 'admin') {
      context.go('/admin');
    } else {
      context.go('/user_home');
    }
  }

  Future<String?> _getUserRole(String userId) async {
    final data = await supabase
        .from('profiles')
        .select('role')
        .eq('id', userId)
        .maybeSingle();
    return data?['role'] as String?;
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}


