import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../components/SideMenu.dart';

class GeneroPage extends StatefulWidget {
  final String token;
  final String perfil;
  final bool isAdminOrBiblio;
  final int userId;

  const GeneroPage({
    super.key,
    required this.token,
    required this.perfil,
    required this.isAdminOrBiblio,
    required this.userId,
  });

  @override
  State<GeneroPage> createState() => _GeneroPageState();
}

class _GeneroPageState extends State<GeneroPage> {
  List generos = [];
  List generosFiltrados = [];
  bool loading = false;
  String error = '';
  String filtroNome = '';

  @override
  void initState() {
    super.initState();
    buscarGeneros();
  }

  // ====================== BUSCAR GENEROS ======================
  Future<void> buscarGeneros() async {
    setState(() {
      loading = true;
      error = '';
    });

    try {
      final res = await http.get(
        Uri.parse('http://localhost:8080/generos'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (res.statusCode == 200) {
        List data = jsonDecode(res.body);
        
        data.sort((a, b) =>
            a['nome'].toString().compareTo(b['nome'].toString()));

        setState(() {
          generos = data;
          filtrarLocal();
        });
      } else {
        setState(() => error = 'Erro ao buscar gêneros');
      }
    } catch (e) {
      setState(() => error = 'Erro ao buscar gêneros');
      debugPrint(e.toString());
    }

    setState(() => loading = false);
  }

  // ====================== FILTRAR LOCAL ======================
  void filtrarLocal() {
    List lista = generos.where((g) {
      final nome = g['nome'].toString().toLowerCase();

      if (filtroNome.isNotEmpty &&
          !nome.contains(filtroNome.toLowerCase())) return false;

      return true;
    }).toList();

    setState(() => generosFiltrados = lista);
  }

  // ====================== CRIAR GENERO ======================
  Future<void> criarGenero(String nome) async {
    final res = await http.post(
      Uri.parse('http://localhost:8080/generos'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}'
      },
      body: jsonEncode({'nome': nome}),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      Navigator.of(context).pop();
      buscarGeneros();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gênero criado com sucesso')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao criar gênero')),
      );
    }
  }

  // ====================== EDITAR GENERO ======================
  Future<void> editarGenero(int id, String nome) async {
    final res = await http.put(
      Uri.parse('http://localhost:8080/generos/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}'
      },
      body: jsonEncode({'nome': nome}),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      Navigator.of(context).pop();
      buscarGeneros();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gênero atualizado com sucesso')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao atualizar gênero')),
      );
    }
  }

  // ====================== DELETE ======================
  Future<void> excluirGenero(int id) async {
    final res = await http.delete(
      Uri.parse('http://localhost:8080/generos/$id'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (res.statusCode == 200) {
      buscarGeneros();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gênero excluído com sucesso')),
      );
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao excluir gênero')),
      );
    }
  }

  // ====================== MODAL CRIAR ======================
  void abrirModalCriar() {
    final nomeController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Novo Gênero"),
        content: TextField(
          controller: nomeController,
          decoration: const InputDecoration(labelText: 'Nome do Gênero'),
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Salvar"),
            onPressed: () {
              if (nomeController.text.isNotEmpty) {
                criarGenero(nomeController.text);
              }
            },
          )
        ],
      ),
    );
  }

  // ====================== MODAL EDITAR ======================
  void abrirModalEditar(Map genero) {
    final nomeController = TextEditingController(text: genero['nome']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Editar Gênero"),
        content: TextField(
          controller: nomeController,
          decoration: const InputDecoration(labelText: 'Nome do Gênero'),
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Salvar"),
            onPressed: () {
              if (nomeController.text.isNotEmpty) {
                editarGenero(genero['id'], nomeController.text);
              }
            },
          )
        ],
      ),
    );
  }

  // ====================== CARD ======================
  Widget generoCard(genero) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text(genero['nome']),
        subtitle: Text('ID: ${genero['id']}'),
        trailing: widget.isAdminOrBiblio
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => abrirModalEditar(genero),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Confirmar Exclusão"),
                          content: Text(
                              "Deseja realmente excluir o gênero '${genero['nome']}'?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancelar"),
                            ),
                            ElevatedButton(
                              onPressed: () => excluirGenero(genero['id']),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text("Excluir"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              )
            : null,
      ),
    );
  }

  // ====================== UI ======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gêneros')),
      floatingActionButton: widget.isAdminOrBiblio
          ? FloatingActionButton(
              onPressed: abrirModalCriar,
              child: const Icon(Icons.add),
            )
          : null,
      body: Row(
        children: [
          // SideMenu
          SideMenu(
            perfil: widget.perfil,
            selected: 'generos',
            onSelect: (String route) async {
              if (route == 'perfil') {
                Navigator.pushNamed(
                  context,
                  '/perfil',
                  arguments: {
                    'token': widget.token,
                    'perfil': widget.perfil,
                    'userId': widget.userId,
                  },
                );
              } else if (route == 'livros') {
                Navigator.pushReplacementNamed(
                  context,
                  '/livros',
                  arguments: {
                    'token': widget.token,
                    'perfil': widget.perfil,
                    'isAdminOrBiblio': widget.isAdminOrBiblio,
                    'userId': widget.userId,
                  },
                );
              } else if (route == 'usuarios') {
                Navigator.pushReplacementNamed(
                  context,
                  '/usuarios',
                  arguments: {
                    'token': widget.token,
                    'perfil': widget.perfil,
                    'userId': widget.userId,
                  },
                );
              } else if (route == 'emprestimos') {
                Navigator.pushReplacementNamed(
                  context,
                  '/emprestimos',
                  arguments: {
                    'token': widget.token,
                    'perfil': widget.perfil,
                    'isAdminOrBiblio': widget.isAdminOrBiblio,
                    'userId': widget.userId,
                  },
                );
              }
            },
          ),

          // Conteúdo principal
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Filtro
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Filtrar por nome',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      filtroNome = value;
                      filtrarLocal();
                    },
                  ),
                  const SizedBox(height: 10),

                  // Lista de gêneros
                  Expanded(
                    child: loading
                        ? const Center(child: CircularProgressIndicator())
                        : error.isNotEmpty
                            ? Center(child: Text(error))
                            : generosFiltrados.isEmpty
                                ? const Center(
                                    child: Text("Nenhum gênero encontrado"))
                                : ListView.builder(
                                    itemCount: generosFiltrados.length,
                                    itemBuilder: (context, index) {
                                      return generoCard(
                                          generosFiltrados[index]);
                                    },
                                  ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}