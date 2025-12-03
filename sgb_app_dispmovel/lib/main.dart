import 'package:flutter/material.dart';
import 'pages/RealizarLogin.dart';
import 'pages/RealizarCadastro.dart';
import 'pages/ManterUsuarios.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SGB',
      initialRoute: '/',
      
      onGenerateRoute: (settings) {
        // Login
        if (settings.name == '/') {
          return MaterialPageRoute(
            builder: (context) => const LoginPage(),
          );
        }

        // Cadastro
        if (settings.name == '/cadastro') {
          return MaterialPageRoute(
            builder: (context) => const CadastroPage(),
          );
        }

        // Usuários (agora recebe TOKEN REAL)
        if (settings.name == '/usuarios') {
          final token = settings.arguments as String;

          return MaterialPageRoute(
            builder: (context) => UsuarioPage(
              token: token,
              perfil: 'ADMIN',
            ),
          );
        }

        return null;
      },
    );
  }
}
