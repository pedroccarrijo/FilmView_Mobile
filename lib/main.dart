import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'main_screen.dart'; // Importante para redirecionar quem já está logado

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDiNfJwj0e73dex0MSkVDFB1Hlgtlug-v4",
      authDomain: "filmview-mobile.firebaseapp.com",
      projectId: "filmview-mobile",
      storageBucket: "filmview-mobile.firebasestorage.app",
      messagingSenderId: "250810585865",
      appId: "1:250810585865:web:5626c97fe4ca849e6379d8",
    ),
  );

  runApp(const FilmViewApp());
}

class FilmViewApp extends StatelessWidget {
  const FilmViewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FilmView Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFBB2F),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
      ),
      // MÁGICA AQUI: O AuthStateChanges verifica se você já fez login antes
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Enquanto verifica, mostra tela de carregamento vazia
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFFFFBB2F)),
              ),
            );
          }
          // Se encontrou usuário salvo, vai pra MainScreen. Senão, LoginPage.
          if (snapshot.hasData) {
            return const MainScreen();
          }
          return const LoginPage();
        },
      ),
    );
  }
}
