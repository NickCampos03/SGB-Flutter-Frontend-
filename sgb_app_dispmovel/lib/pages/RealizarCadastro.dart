import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final telefoneController = TextEditingController();
  final dataNascimentoController = TextEditingController();
  final senhaController = TextEditingController();

  bool loading = false;
  String error = "";
  bool success = false;

  Future<void> cadastrarUsuario() async {
    setState(() {
      error = "";
      success = false;
      loading = true;
    });

    try {
      final response = await http.post(
        Uri.parse("http://localhost:8080/usuarios/publico"), // Android Emulator
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nome": nomeController.text,
          "email": emailController.text,
          "telefone": telefoneController.text,
          "dataDeNascimento": dataNascimentoController.text,
          "senha": senhaController.text,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          success = true;
          nomeController.clear();
          emailController.clear();
          telefoneController.clear();
          dataNascimentoController.clear();
          senhaController.clear();
        });
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          error = data["message"] ?? "Erro ao cadastrar usuário.";
        });
      }
    } catch (e) {
      setState(() {
        error = "Erro de conexão com o servidor.";
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> selecionarData() async {
    DateTime? data = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (data != null) {
      setState(() {
        dataNascimentoController.text =
            "${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}";
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
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // ✅ SIGLA DO PROJETO
                  Text(
                    "SGB",
                    style: TextStyle(
                      fontSize: 32,
                      color: HSLColor.fromAHSL(1, 239, 0.84, 0.67).toColor(),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                  const Text(
                    "SISTEMA DE GERENCIAMENTO DE BIBLIOTECA",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color.fromRGBO(100, 116, 139, 1),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: nomeController,
                    decoration: const InputDecoration(
                      labelText: "Nome completo",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Campo obrigatório" : null,
                  ),
                  const SizedBox(height: 15),

                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: "E-mail",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        value!.isEmpty ? "Campo obrigatório" : null,
                  ),
                  const SizedBox(height: 15),

                  TextFormField(
                    controller: telefoneController,
                    decoration: const InputDecoration(
                      labelText: "Telefone",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    
                    validator: (value) =>
                        value!.length < 11 ? "Telefone inválido" : null,
                  ),
                  const SizedBox(height: 15),

                  TextFormField(
                    controller: dataNascimentoController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "Data de nascimento",
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_month),
                    ),
                    onTap: selecionarData,
                    validator: (value) =>
                        value!.isEmpty ? "Selecione a data" : null,
                  ),
                  const SizedBox(height: 15),

                  TextFormField(
                    controller: senhaController,
                    decoration: const InputDecoration(
                      labelText: "Senha",
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) =>
                        value!.length < 4 ? "Senha muito curta" : null,
                  ),
                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            HSLColor.fromAHSL(1, 239, 0.84, 0.67).toColor(),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: loading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                cadastrarUsuario();
                              }
                            },
                      child: Text(
                        loading ? "Cadastrando..." : "Cadastrar",
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

                  if (success)
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        "Usuário cadastrado com sucesso!",
                        style: TextStyle(color: Colors.green),
                      ),
                    ),

                  const SizedBox(height: 15),

                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/');
                    },
                    child: const Text("Já tem conta? Faça login"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}