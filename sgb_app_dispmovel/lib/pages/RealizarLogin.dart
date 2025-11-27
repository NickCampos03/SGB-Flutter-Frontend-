import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  String error = "";

  Future<void> realizarLogin() async {
    setState(() {
      loading = true;
      error = "";
    });

    try {
      final response = await http.post(
        Uri.parse("http://localhost:8080/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text,
          "password": passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (data["status"] == "success" && data["token"] != null) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString("token", data["token"]);
        await prefs.setString("perfil", data["perfil"]);
        await prefs.setString("user", data["user"]);
        await prefs.setInt("userId", data["userId"]);

        Navigator.pushReplacementNamed(context, "/home");
      } else {
        setState(() {
          error = "Login inválido.";
        });
      }
    } catch (e) {
      setState(() {
        error = "Erro ao conectar com o servidor.";
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Senha",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: loading ? null : realizarLogin,
              child: Text(loading ? "Entrando..." : "Entrar"),
            ),

            if (error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  error,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            const SizedBox(height: 15),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, "/cadastro");
              },
              child: const Text("Não tem cadastro? Clique aqui"),
            ),
          ],
        ),
      ),
    );
  }
}
