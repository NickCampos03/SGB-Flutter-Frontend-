import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GeneroPage extends StatefulWidget {
  const GeneroPage({super.key});

  @override
  State<GeneroPage> createState() => _GeneroPageState();
}

class _GeneroPageState extends State <GeneroPage>{
  List Genero = [];
  bool loading = true;
  
}