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
    backgroundColor: Colors.white,
    body: Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(24),
            width: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // ✅ SIGLA DO PROJETO
                Text(
                  "SGB",
                  style: TextStyle(
                    fontSize: 32,
                    color: HSLColor.fromAHSL(1, 239, 0.84, 0.67).toColor(),
                    fontWeight: FontWeight.bold
                  ),
                ),
                const Text(
                  "SISTEMA DE GERENCIAMENTO DE BIBLIOTECA",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color.fromRGBO(100, 116, 139, 1)
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(color: Color.fromRGBO(100, 116, 139, 1))
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Senha",
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(color: Color.fromRGBO(100, 116, 139, 1))
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HSLColor.fromAHSL(1, 239, 0.84, 0.67).toColor(),
                    ), 
                    onPressed: loading ? null : realizarLogin,
                    child: 
                    Text(
                      loading ? "Entrando..." : "Entrar",
                      style: const TextStyle(color: Colors.white), 
                    ),
                  ),
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
        ),
      ),
    ),
  );
}
}
