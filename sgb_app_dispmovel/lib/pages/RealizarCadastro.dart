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
        Uri.parse("http://10.0.2.2:8080/usuarios/publico"), // Android Emulator
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
      appBar: AppBar(title: const Text("Cadastro")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: "Nome completo"),
                validator: (value) =>
                    value!.isEmpty ? "Campo obrigatório" : null,
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "E-mail"),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value!.isEmpty ? "Campo obrigatório" : null,
              ),
              TextFormField(
                controller: telefoneController,
                decoration: const InputDecoration(labelText: "Telefone"),
                keyboardType: TextInputType.phone,
                maxLength: 11,
                validator: (value) =>
                    value!.length < 11 ? "Telefone inválido" : null,
              ),
              TextFormField(
                controller: dataNascimentoController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "Data de nascimento",
                  suffixIcon: Icon(Icons.calendar_month),
                ),
                onTap: selecionarData,
                validator: (value) =>
                    value!.isEmpty ? "Selecione a data" : null,
              ),
              TextFormField(
                controller: senhaController,
                decoration: const InputDecoration(labelText: "Senha"),
                obscureText: true,
                validator: (value) =>
                    value!.length < 4 ? "Senha muito curta" : null,
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: loading
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          cadastrarUsuario();
                        }
                      },
                child: Text(loading ? "Cadastrando..." : "Cadastrar"),
              ),

              if (error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(error,
                      style: const TextStyle(color: Colors.red)),
                ),

              if (success)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    "Usuário cadastrado com sucesso!",
                    style: TextStyle(color: Colors.green),
                  ),
                ),

              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/');
                },
                child: const Text("Já tem conta? Faça login"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
