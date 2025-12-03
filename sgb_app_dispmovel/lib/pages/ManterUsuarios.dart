import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../components/SideMenu.dart';

class UsuarioPage extends StatefulWidget {
  final String token;
  final String perfil;
  final int userId;

  const UsuarioPage({
    super.key,
    required this.token,
    required this.perfil,
    required this.userId,
  });

  @override
  State<UsuarioPage> createState() => _UsuarioPageState();
}

class _UsuarioPageState extends State<UsuarioPage> {
  List usuarios = [];
  bool loading = true;
  String filtroNome = '';

  @override
  void initState() {
    super.initState();
    carregarUsuarios();
  }

  Future<void> carregarUsuarios() async {
    setState(() => loading = true);

    final response = await http.get(
      Uri.parse('http://localhost:8080/usuarios'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        usuarios = json.decode(response.body);
        loading = false;
      });
    } else {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao buscar usuários')),
      );
    }
  }

  List get usuariosFiltrados {
    if (filtroNome.isEmpty) return usuarios;
    return usuarios.where((u) =>
        u['nome'].toLowerCase().contains(filtroNome.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usuários')),
      body: Row(
        children: [
          // ✅ SideMenu
          SideMenu(
            perfil: widget.perfil,
            selected: 'usuarios',
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
                    'isAdminOrBiblio': widget.perfil == 'ADMIN' || widget.perfil == 'BIBLIOTECARIO',
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
                    'isAdminOrBiblio': widget.perfil == 'ADMIN' || widget.perfil == 'BIBLIOTECARIO',
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
                    'isAdminOrBiblio': widget.perfil == 'ADMIN' || widget.perfil == 'BIBLIOTECARIO',
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
            TextField(
              decoration: const InputDecoration(
                labelText: 'Filtrar por nome',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() => filtroNome = value);
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: usuariosFiltrados.length,
                      itemBuilder: (context, index) {
                        final u = usuariosFiltrados[index];
                        return Card(
                          child: ListTile(
                            title: Text(u['nome']),
                            subtitle: Text(u['email']),
                            trailing: Text(u['perfil']),
                            onTap: () => abrirModalUsuario(u),
                          ),
                        );
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

  void abrirModalUsuario(Map usuario) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Usuário #${usuario['codigoLogin']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Nome: ${usuario['nome']}'),
            Text('Email: ${usuario['email']}'),
            Text('Telefone: ${usuario['telefone']}'),
            Text('Perfil: ${usuario['perfil']}'),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Excluir'),
            onPressed: () async {
              Navigator.pop(context);
              await excluirUsuario(usuario['codigoLogin']);
            },
          ),
          TextButton(
            child: const Text('Fechar'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> excluirUsuario(int codigo) async {
    final response = await http.delete(
      Uri.parse('http://localhost:8080/usuarios/$codigo'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      carregarUsuarios();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Usuário excluído')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Erro ao excluir')));
    }
  }
}
