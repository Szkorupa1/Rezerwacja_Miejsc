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
  final confirmPasswordController = TextEditingController();
  final supabase = Supabase.instance.client;

  bool isLoading = false;
  bool isLogin = true;

  @override
  void initState() {
    super.initState();

    supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.passwordRecovery) {
        context.go('/reset-password');
      }
    });
  }

  void toggleMode() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  Future<String?> authenticate() async {
    setState(() => isLoading = true);

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    try {
      if (isLogin) {
        final res = await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
        if (res.user == null) throw Exception('Brak użytkownika po logowaniu');
      } else {
        if (password != confirmPassword) {
          throw Exception('Hasła nie są identyczne');
        }
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

  Future<void> resetPassword() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Podaj adres email')),
      );
      return;
    }

    try {
      await supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: "http://localhost:55180/user/reset-password",
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sprawdź skrzynkę pocztową, wysłano link resetujący')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd resetu: $e')),
      );
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
      body: Stack(
        children: [
          // ---- Tło ----
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/login_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // ---- Formularz ----
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isLogin ? 'Logowanie' : 'Rejestracja',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Hasło',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      obscureText: true,
                    ),
                    if (!isLogin) const SizedBox(height: 12),
                    if (!isLogin)
                      TextField(
                        controller: confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Powtórz hasło',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        obscureText: true,
                      ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.blueAccent,
                        ),
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
                        child: Text(
                          isLogin ? 'Zaloguj się' : 'Zarejestruj się',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: toggleMode,
                      child: Text(isLogin
                          ? 'Nie masz konta? Zarejestruj się'
                          : 'Masz już konto? Zaloguj się'),
                    ),
                    if (isLogin)
                      TextButton(
                        onPressed: resetPassword,
                        child: const Text('Nie pamiętasz hasła? Zresetuj je'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
