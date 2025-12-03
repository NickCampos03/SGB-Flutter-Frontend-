import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LivrosPage extends StatefulWidget {
  final bool isAdminOrBiblio;

  const LivrosPage({Key? key, required this.isAdminOrBiblio}) : super(key: key);

  @override
  State<LivrosPage> createState() => _LivrosPageState();
}

class _LivrosPageState extends State<LivrosPage> {
  List livros = [];
  List livrosFiltrados = [];
  List generos = [];

  bool loading = false;
  String error = '';

  String filtroNome = '';
  String filtroAutor = '';
  String filtroGenero = '';
  String filtroDisponibilidade = '';

  @override
  void initState() {
    super.initState();
    buscarGeneros();
    buscarLivros();
  }

  // ====================== TOKEN ======================
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ====================== GENEROS ======================
  Future<void> buscarGeneros() async {
    try {
      final token = await getToken();
      final res = await http.get(
        Uri.parse('http://SEU_IP:8080/generos'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        setState(() {
          generos = jsonDecode(res.body);
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // ====================== LIVROS ======================
  Future<void> buscarLivros() async {
    setState(() {
      loading = true;
      error = '';
    });

    try {
      final token = await getToken();

      final query = {
        if (filtroGenero.isNotEmpty) 'generoId': filtroGenero,
        if (filtroDisponibilidade.isNotEmpty)
          'disponibilidade': filtroDisponibilidade,
      };

      final uri =
          Uri.http('SEU_IP:8080', '/livros', query);

      final res = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        List data = jsonDecode(res.body);

        data.sort((a, b) =>
            a['nome'].toString().compareTo(b['nome'].toString()));

        setState(() {
          livros = data;
          filtrarLocal();
        });
      } else {
        setState(() => error = 'Erro ao buscar livros');
      }
    } catch (e) {
      setState(() => error = 'Erro ao buscar livros');
    }

    setState(() => loading = false);
  }

  // ====================== FILTRAR LOCAL ======================
  void filtrarLocal() {
    List lista = livros.where((l) {
      final nome = l['nome'].toString().toLowerCase();
      final autor = l['autor'].toString().toLowerCase();

      if (filtroNome.isNotEmpty &&
          !nome.contains(filtroNome.toLowerCase())) return false;

      if (filtroAutor.isNotEmpty &&
          !autor.contains(filtroAutor.toLowerCase())) return false;

      return true;
    }).toList();

    setState(() => livrosFiltrados = lista);
  }

  // ====================== CRIAR LIVRO ======================
  Future<void> criarLivro(String nome, String autor, String generoId) async {
    final token = await getToken();

    final res = await http.post(
      Uri.parse('http://SEU_IP:8080/livros'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'nome': nome,
        'autor': autor,
        'genero': {'id': int.parse(generoId)}
      }),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      Navigator.of(context).pop();
      buscarLivros();
    }
  }

  // ====================== DELETE ======================
  Future<void> excluirLivro(int id) async {
    final token = await getToken();

    await http.delete(
      Uri.parse('http://SEU_IP:8080/livros/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    buscarLivros();
    Navigator.pop(context);
  }

  // ====================== MODAL CRIAR ======================
  void abrirModalCriar() {
    final nomeController = TextEditingController();
    final autorController = TextEditingController();
    String generoSelecionado = '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Novo Livro"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: autorController,
              decoration: const InputDecoration(labelText: 'Autor'),
            ),
            DropdownButtonFormField(
              value:
                  generoSelecionado.isEmpty ? null : generoSelecionado,
              items: generos
                  .map<DropdownMenuItem<String>>(
                    (g) => DropdownMenuItem(
                      value: g['id'].toString(),
                      child: Text(g['nome']),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                generoSelecionado = value.toString();
              },
              decoration:
                  const InputDecoration(labelText: 'Gênero'),
            )
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Salvar"),
            onPressed: () {
              criarLivro(
                nomeController.text,
                autorController.text,
                generoSelecionado,
              );
            },
          )
        ],
      ),
    );
  }

  // ====================== CARD ======================
  Widget livroCard(livro) {
    final disponivel = livro['disponibilidade'] == 'DISPONIVEL';

    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text(livro['nome']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Autor: ${livro['autor']}'),
            Text('ID: ${livro['codigoLivro']}'),
            Text('Gênero: ${livro['genero']?['nome'] ?? ''}'),
            Text(
              disponivel ? 'Disponível' : 'Indisponível',
              style: TextStyle(
                color: disponivel ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        onTap: widget.isAdminOrBiblio
            ? () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Opções"),
                    content: const Text(
                        "Deseja excluir este livro?"),
                    actions: [
                      TextButton(
                          onPressed: () =>
                              Navigator.pop(context),
                          child: const Text("Cancelar")),
                      ElevatedButton(
                          onPressed: () =>
                              excluirLivro(
                                  livro['codigoLivro']),
                          child: const Text("Excluir")),
                    ],
                  ),
                );
              }
            : null,
      ),
    );
  }

  // ====================== UI ======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Livros")),
      floatingActionButton: widget.isAdminOrBiblio
          ? FloatingActionButton(
              onPressed: abrirModalCriar,
              child: const Icon(Icons.add),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // ---------- FILTROS ----------
            TextField(
              decoration:
                  const InputDecoration(labelText: 'Nome'),
              onChanged: (value) {
                filtroNome = value;
                filtrarLocal();
              },
            ),
            TextField(
              decoration:
                  const InputDecoration(labelText: 'Autor'),
              onChanged: (value) {
                filtroAutor = value;
                filtrarLocal();
              },
            ),
            DropdownButtonFormField(
              value: filtroGenero.isEmpty ? null : filtroGenero,
              items: [
                const DropdownMenuItem(
                  value: '',
                  child: Text("Todos os gêneros"),
                ),
                ...generos.map((g) => DropdownMenuItem(
                    value: g['id'].toString(),
                    child: Text(g['nome'])))
              ],
              onChanged: (v) {
                filtroGenero = v.toString();
                buscarLivros();
              },
              decoration: const InputDecoration(labelText: 'Gênero'),
            ),
            DropdownButtonFormField(
              value: filtroDisponibilidade.isEmpty
                  ? null
                  : filtroDisponibilidade,
              items: const [
                DropdownMenuItem(
                    value: '', child: Text("Todos")),
                DropdownMenuItem(
                    value: 'DISPONIVEL',
                    child: Text("Disponível")),
                DropdownMenuItem(
                    value: 'INDISPONIVEL',
                    child: Text("Indisponível")),
              ],
              onChanged: (v) {
                filtroDisponibilidade = v.toString();
                buscarLivros();
              },
              decoration: const InputDecoration(
                labelText: 'Disponibilidade',
              ),
            ),

            const SizedBox(height: 10),

            // ---------- LISTA ----------
            Expanded(
              child: loading
                  ? const Center(
                      child: CircularProgressIndicator())
                  : livrosFiltrados.isEmpty
                      ? const Center(
                          child:
                              Text("Nenhum livro encontrado"))
                      : ListView.builder(
                          itemCount: livrosFiltrados.length,
                          itemBuilder: (context, index) {
                            return livroCard(
                                livrosFiltrados[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
