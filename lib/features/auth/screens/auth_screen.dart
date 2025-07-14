import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final supabase = Supabase.instance.client;

  bool isLoading = false;
  bool isLogin = true;

  void toggleMode() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  Future<String?> authenticate() async {
    setState(() => isLoading = true);

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      if (isLogin) {
        final res = await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
        if (res.user == null) throw Exception('Brak użytkownika po logowaniu');
      } else {
        final res = await supabase.auth.signUp(
          email: email,
          password: password,
        );
        if (res.user == null) throw Exception('Brak użytkownika po rejestracji');
      }

      final role = await _getUserRole();
      return role;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd: ${e.toString()}')),
      );
      return null;
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<String?> _getUserRole() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final data = await supabase
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .maybeSingle();

    final role = data?['role'] as String?;

    if (role == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nie znaleziono roli użytkownika')),
      );
    }

    return role;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Logowanie' : 'Rejestracja')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Hasło'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                final role = await authenticate();
                if (role == null) return;

                if (role == 'admin') {
                  context.go('/admin');
                } else {
                  context.go('/user_home');
                }
              },
              child: Text(isLogin ? 'Zaloguj się' : 'Zarejestruj się'),
            ),
            TextButton(
              onPressed: toggleMode,
              child: Text(isLogin
                  ? 'Nie masz konta? Zarejestruj się'
                  : 'Masz już konto? Zaloguj się'),
            ),
          ],
        ),
      ),
    );
  }
}
