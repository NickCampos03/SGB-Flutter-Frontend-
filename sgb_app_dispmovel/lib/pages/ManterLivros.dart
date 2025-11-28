import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
class LivroPage extends StatefulWidget {
  const LivroPage({super.key});

  @override
  State<LivroPage> createState() => _LivroPageState();
}

class _LivroPageState extends State <LivroPage>{
  List Livro = [];
  bool loading = true;
  String filtroNome = '';
  String filtroLivro = "";
  
  @override
  void initState() {
    super.initState();
    carregarLivros();
  }
}