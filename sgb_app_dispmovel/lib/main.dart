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
      routes: {
        '/': (context) => const LoginPage(),
        '/cadastro': (context) => const CadastroPage(),
        '/usuarios': (context) => const UsuarioPage(
              token: 'SEU_TOKEN_JWT_AQUI',
              perfil: 'ADMIN',
            ),
      },
    );
  }
}
