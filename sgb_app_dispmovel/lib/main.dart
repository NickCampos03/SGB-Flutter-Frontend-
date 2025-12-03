import 'package:flutter/material.dart';
import 'pages/RealizarLogin.dart';
import 'pages/RealizarCadastro.dart';
import 'pages/ManterUsuarios.dart';
import 'pages/ManterLivros.dart';
import 'pages/ManterGenero.dart';
import 'pages/ManterEmprestimos.dart';
import 'pages/Perfil.dart';

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
          return MaterialPageRoute(builder: (context) => const LoginPage());
        }

        // Cadastro
        if (settings.name == '/cadastro') {
          return MaterialPageRoute(builder: (context) => const CadastroPage());
        }
        
        // Empréstimos
        if (settings.name == '/emprestimos') {
          final args = settings.arguments as Map<String, dynamic>;
          final token = args["token"] as String;
          final perfil = args["perfil"] as String;
          final isAdminOrBiblio = args["isAdminOrBiblio"] as bool;
          final userId = args["userId"] as int;

          return MaterialPageRoute(
            builder: (context) => EmprestimosPage(
              token: token,
              perfil: perfil,
              isAdminOrBiblio: isAdminOrBiblio,
              userId: userId,
            ),
          );
        }

        // Livros
        if (settings.name == '/livros') {
          final args = settings.arguments as Map<String, dynamic>;
          final token = args["token"] as String;
          final perfil = args["perfil"] as String;
          final isAdminOrBiblio = args["isAdminOrBiblio"] as bool;
          final userId = args["userId"] as int;

          return MaterialPageRoute(
            builder: (context) => LivrosPage(
              token: token,
              perfil: perfil,
              isAdminOrBiblio: isAdminOrBiblio,
              userId: userId,
            ),
          );
        }

        // Gêneros
        if (settings.name == '/generos') {
          final args = settings.arguments as Map<String, dynamic>;
          final token = args["token"] as String;
          final perfil = args["perfil"] as String;
          final isAdminOrBiblio = args["isAdminOrBiblio"] as bool;
          final userId = args["userId"] as int;

          return MaterialPageRoute(
            builder: (context) => GeneroPage(
              token: token,
              perfil: perfil,
              isAdminOrBiblio: isAdminOrBiblio,
              userId: userId,
            ),
          );
        }

        // Usuários
        if (settings.name == '/usuarios') {
          final args = settings.arguments as Map<String, dynamic>;
          final token = args["token"] as String;
          final perfil = args["perfil"] as String;
          final userId = args["userId"] as int;

          return MaterialPageRoute(
            builder: (context) => UsuarioPage(
              token: token,
              perfil: perfil,
              userId: userId,
            ),
          );
        }

        // Perfil
        if (settings.name == '/perfil') {
          final args = settings.arguments as Map<String, dynamic>;
          final token = args["token"] as String;
          final perfil = args["perfil"] as String;
          final userId = args["userId"] as int;

          return MaterialPageRoute(
            builder: (context) => PerfilPage(
              token: token,
              perfil: perfil,
              userId: userId,
            ),
          );
        }

        return null;
      },
    );
  }
}
