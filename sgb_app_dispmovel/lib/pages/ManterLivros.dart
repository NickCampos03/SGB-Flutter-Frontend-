import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../components/SideMenu.dart';

class LivrosPage extends StatefulWidget {
  final String token;
  final String perfil;
  final bool isAdminOrBiblio;
  
  final int userId;

  const LivrosPage({
    super.key,
    required this.token,
    required this.perfil,
    required this.isAdminOrBiblio,
    required this.userId
  });

  @override
  State<LivrosPage> createState() => _LivrosPageState();
}

class _LivrosPageState extends State<LivrosPage> {
  List livros = [];
  List livrosFiltrados = [];
  List generos = [];
  List usuarios = [];

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
    if (widget.isAdminOrBiblio) {
      buscarUsuarios();
    }
  }

  // ====================== USUARIOS ======================
  Future<void> buscarUsuarios() async {
    try {
      final res = await http.get(
        Uri.parse('http://localhost:8080/usuarios'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (res.statusCode == 200) {
        setState(() {
          usuarios = jsonDecode(res.body);
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // ====================== GENEROS ======================
  Future<void> buscarGeneros() async {
    try {
      final res = await http.get(
        Uri.parse('http://localhost:8080/generos'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
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
      final query = {
        if (filtroGenero.isNotEmpty) 'generoId': filtroGenero,
        if (filtroDisponibilidade.isNotEmpty)
          'disponibilidade': filtroDisponibilidade,
      };

      final uri =
          Uri.http('localhost:8080', '/livros', query);

      final res = await http.get(
        uri,
        headers: {'Authorization': 'Bearer ${widget.token}'},
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
    final res = await http.post(
      Uri.parse('http://localhost:8080/livros'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}'
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
    await http.delete(
      Uri.parse('http://localhost:8080/livros/$id'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    buscarLivros();
    Navigator.pop(context);
  }

  // ====================== EDITAR LIVRO ======================
  Future<void> editarLivro(int id, String nome, String autor, String generoId) async {
    final res = await http.put(
      Uri.parse('http://localhost:8080/livros/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}'
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Livro atualizado com sucesso')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao atualizar livro')),
      );
    }
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

  // ====================== MODAL EDITAR ======================
  void abrirModalEditar(Map livro) {
    final nomeController = TextEditingController(text: livro['nome']);
    final autorController = TextEditingController(text: livro['autor']);
    String generoSelecionado = livro['genero']?['id']?.toString() ?? '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Editar Livro"),
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
              value: generoSelecionado.isEmpty ? null : generoSelecionado,
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
              decoration: const InputDecoration(labelText: 'Gênero'),
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
              editarLivro(
                livro['codigoLivro'],
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

  // ====================== CRIAR EMPRESTIMO ======================
  Future<void> criarEmprestimo(int codigoLivro, int codigoUsuario) async {
    final hoje = DateTime.now();
    final dataRetirada = hoje.toIso8601String().substring(0, 10);
    final dataPrevista = hoje.add(const Duration(days: 14)).toIso8601String().substring(0, 10);

    final res = await http.post(
      Uri.parse('http://localhost:8080/emprestimos'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}'
      },
      body: jsonEncode({
        'usuario': {'codigoLogin': codigoUsuario},
        'livro': {'codigoLivro': codigoLivro},
        'dataRetirada': dataRetirada,
        'dataPrevista': dataPrevista,
      }),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      Navigator.of(context).pop();
      buscarLivros();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Empréstimo realizado com sucesso')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao realizar empréstimo: ${res.body}')),
      );
    }
  }

  // ====================== MODAL NOVO EMPRESTIMO ======================
  void abrirModalNovoEmprestimo(Map livro) {
    String usuarioSelecionado = widget.perfil == 'USUARIO' ? widget.userId.toString() : '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Novo Empréstimo"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Livro: ${livro['nome']} #${livro['codigoLivro']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (widget.perfil == 'USUARIO')
              const Text('Usuário: Você')
            else 
              DropdownButtonFormField<String>(
                value: usuarioSelecionado.isEmpty ? null : usuarioSelecionado,
                items: usuarios
                    .map<DropdownMenuItem<String>>(
                      (u) => DropdownMenuItem(
                        value: u['codigoLogin'].toString(),
                        child: Text('${u['nome']} #${u['codigoLogin']}'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  usuarioSelecionado = value ?? '';
                },
                decoration: const InputDecoration(labelText: 'Usuário'),
              ),
            const SizedBox(height: 8),
            const Text(
              'Data de retirada: Hoje\nData prevista: +14 dias',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text("Emprestar"),
            onPressed: () {
              if (usuarioSelecionado.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Selecione um usuário')),
                );
                return;
              }
              criarEmprestimo(
                livro['codigoLivro'],
                int.parse(usuarioSelecionado),
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
        onTap: () {
          final List<Widget> actions = [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
          ];

          // Botão de Emprestar - apenas para admin/biblio e se livro disponível
          if (disponivel) {
            actions.add(
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  abrirModalNovoEmprestimo(livro);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text("Emprestar"),
              ),
            );
          }

          // Botões de Editar e Excluir - apenas para admin/biblio
          if (widget.isAdminOrBiblio) {
            actions.add(
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  abrirModalEditar(livro);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: const Text("Editar"),
              ),
            );
            actions.add(
              ElevatedButton(
                onPressed: () => excluirLivro(livro['codigoLivro']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text("Excluir"),
              ),
            );
          }

          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text("Opções - ${livro['nome']}"),
              content: const Text("Escolha uma ação:"),
              actions: actions,
            ),
          );
        },
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
      body: Row(
        children: [
          // SideMenu
          SideMenu(
            perfil: widget.perfil,
            selected: 'livros',
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
              } else if (route == 'generos') {
                Navigator.pushReplacementNamed(
                  context,
                  '/generos',
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
          ),
        ],
      ),
    );
  }
}
