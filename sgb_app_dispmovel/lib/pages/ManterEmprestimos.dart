import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../components/SideMenu.dart';

class EmprestimosPage extends StatefulWidget {
  final String token;
  final String perfil;
  final bool isAdminOrBiblio;
  final int userId;

  const EmprestimosPage({
    super.key,
    required this.token,
    required this.perfil,
    required this.isAdminOrBiblio,
    required this.userId,
  });

  @override
  State<EmprestimosPage> createState() => _EmprestimosPageState();
}

class _EmprestimosPageState extends State<EmprestimosPage> {
  List emprestimos = [];
  List emprestimosFiltrados = [];
  bool loading = false;
  String error = '';
  
  String filtroNomeLivro = '';
  String filtroNomeUsuario = '';
  String filtroStatus = ''; // '', 'true', 'false', 'entregue'

  bool get isUsuario => widget.perfil == 'USUARIO';

  @override
  void initState() {
    super.initState();
    buscarEmprestimos();
  }

  // ====================== BUSCAR EMPRESTIMOS ======================
  Future<void> buscarEmprestimos() async {
    setState(() {
      loading = true;
      error = '';
    });

    try {
      final params = <String, String>{};
      
      if (filtroStatus == 'true') params['emAtraso'] = 'true';
      if (filtroStatus == 'false') params['emAtraso'] = 'false';
      if (filtroStatus == 'entregue') params['entregue'] = 'true';

      final uri = Uri.http('localhost:8080', '/emprestimos', params);

      final res = await http.get(
        uri,
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (res.statusCode == 200) {
        List data = jsonDecode(res.body);
        
        data.sort((a, b) => a['codigoEmprestimo'].compareTo(b['codigoEmprestimo']));

        setState(() {
          emprestimos = data;
          filtrarLocal();
        });
      } else {
        setState(() => error = 'Erro ao buscar empréstimos');
      }
    } catch (e) {
      setState(() => error = 'Erro ao buscar empréstimos');
      debugPrint(e.toString());
    }

    setState(() => loading = false);
  }

  // ====================== FILTRAR LOCAL ======================
  void filtrarLocal() {
    List lista = emprestimos.where((e) {
      if (filtroNomeLivro.isNotEmpty) {
        final nomeLivro = e['livro']?['nome']?.toString().toLowerCase() ?? '';
        if (!nomeLivro.contains(filtroNomeLivro.toLowerCase())) return false;
      }

      if (filtroNomeUsuario.isNotEmpty) {
        final nomeUsuario = e['usuario']?['nome']?.toString().toLowerCase() ?? '';
        if (!nomeUsuario.contains(filtroNomeUsuario.toLowerCase())) return false;
      }

      return true;
    }).toList();

    setState(() => emprestimosFiltrados = lista);
  }

  // ====================== RECEBER EMPRESTIMO (PUT) ======================
  Future<void> receberEmprestimo(int codigoEmprestimo, String dataEntrega) async {
    final res = await http.put(
      Uri.parse('http://localhost:8080/emprestimos/$codigoEmprestimo'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}'
      },
      body: jsonEncode({'dataDeEntrega': dataEntrega}),
    );

    if (res.statusCode == 200) {
      Navigator.of(context).pop();
      buscarEmprestimos();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Empréstimo recebido com sucesso')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao receber empréstimo')),
      );
    }
  }

  // ====================== EXCLUIR EMPRESTIMO ======================
  Future<void> excluirEmprestimo(int codigoEmprestimo) async {
    final res = await http.delete(
      Uri.parse('http://localhost:8080/emprestimos/$codigoEmprestimo'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (res.statusCode == 200) {
      Navigator.of(context).pop();
      buscarEmprestimos();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Empréstimo excluído com sucesso')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao excluir empréstimo')),
      );
    }
  }

  // ====================== MODAL DETALHES ======================
  void abrirModalDetalhes(Map emprestimo) {
    final entregue = emprestimo['dataDeEntrega'] != null;
    final dataEntregaController = TextEditingController(
      text: emprestimo['dataDeEntrega'] != null
          ? emprestimo['dataDeEntrega'].toString().substring(0, 10)
          : DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Empréstimo #${emprestimo['codigoEmprestimo']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Livro: ${emprestimo['livro']['nome']} #${emprestimo['livro']['codigoLivro']}'),
              const SizedBox(height: 8),
              Text('Usuário: ${emprestimo['usuario']['nome']} #${emprestimo['usuario']['codigoLogin']}'),
              const SizedBox(height: 8),
              Text('Retirada: ${formatarData(emprestimo['dataDeRetirada'])}'),
              const SizedBox(height: 8),
              Text('Prevista: ${formatarData(emprestimo['dataPrevista'])}'),
              const SizedBox(height: 8),
              Text('Entrega: ${formatarData(emprestimo['dataDeEntrega'])}'),
              const SizedBox(height: 16),
              
              // Status
              if (emprestimo['emAtraso'] && !entregue) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Em atraso - R\$ ${emprestimo['valorDevendo']?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ] else if (!entregue) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Em dia',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Entregue',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (!entregue) ...[
            ElevatedButton(
              onPressed: () {
                receberEmprestimo(
                  emprestimo['codigoEmprestimo'],
                  dataEntregaController.text,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Receber'),
            ),
          ],
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Confirmar Exclusão'),
                  content: const Text('Deseja realmente excluir este empréstimo?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () => excluirEmprestimo(emprestimo['codigoEmprestimo']),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Excluir'),
                    ),
                  ],
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  // ====================== CARD ======================
  Widget emprestimoCard(Map emprestimo) {
    final entregue = emprestimo['dataDeEntrega'] != null;
    final emAtraso = emprestimo['emAtraso'] == true && !entregue;

    return Card(
      margin: const EdgeInsets.all(8),
      color: emAtraso ? Colors.red.shade50 : null,
      child: ListTile(
        title: Text('Empréstimo #${emprestimo['codigoEmprestimo']}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Livro: ${emprestimo['livro']['nome']} #${emprestimo['livro']['codigoLivro']}'),
            Text('Usuário: ${emprestimo['usuario']['nome']} #${emprestimo['usuario']['codigoLogin']}'),
            const SizedBox(height: 4),
            Text('Retirada: ${formatarData(emprestimo['dataDeRetirada'])}'),
            Text('Prevista: ${formatarData(emprestimo['dataPrevista'])}'),
            Text('Entrega: ${formatarData(emprestimo['dataDeEntrega'])}'),
            const SizedBox(height: 8),
            
            // Status
            Row(
              children: [
                if (emAtraso) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Em atraso - R\$ ${emprestimo['valorDevendo']?.toStringAsFixed(2) ?? '0.00'}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ] else if (!entregue) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Em dia',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Entregue',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        onTap: !isUsuario ? () => abrirModalDetalhes(emprestimo) : null,
      ),
    );
  }

  // ====================== UI ======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Empréstimos')),
      body: Row(
        children: [
          // SideMenu
          SideMenu(
            perfil: widget.perfil,
            selected: 'emprestimos',
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
              }
            },
          ),

          // Conteúdo principal
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Filtros
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Filtrar por nome do livro',
                      prefixIcon: Icon(Icons.book),
                    ),
                    onChanged: (value) {
                      filtroNomeLivro = value;
                      filtrarLocal();
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Filtrar por usuário',
                      prefixIcon: Icon(Icons.person),
                    ),
                    onChanged: (value) {
                      filtroNomeUsuario = value;
                      filtrarLocal();
                    },
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: filtroStatus.isEmpty ? null : filtroStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      prefixIcon: Icon(Icons.filter_list),
                    ),
                    items: const [
                      DropdownMenuItem(value: '', child: Text('Todos')),
                      DropdownMenuItem(value: 'true', child: Text('Em atraso')),
                      DropdownMenuItem(value: 'false', child: Text('Em dia')),
                      DropdownMenuItem(value: 'entregue', child: Text('Entregue')),
                    ],
                    onChanged: (value) {
                      setState(() => filtroStatus = value ?? '');
                      buscarEmprestimos();
                    },
                  ),
                  const SizedBox(height: 16),

                  // Lista
                  Expanded(
                    child: loading
                        ? const Center(child: CircularProgressIndicator())
                        : error.isNotEmpty
                            ? Center(child: Text(error))
                            : emprestimosFiltrados.isEmpty
                                ? const Center(child: Text('Nenhum empréstimo encontrado'))
                                : ListView.builder(
                                    itemCount: emprestimosFiltrados.length,
                                    itemBuilder: (context, index) {
                                      return emprestimoCard(emprestimosFiltrados[index]);
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

  String formatarData(dynamic data) {
    if (data == null) return '-';
    try {
      final dateStr = data.toString();
      if (dateStr.contains('T')) {
        final date = DateTime.parse(dateStr);
        return DateFormat('dd/MM/yyyy').format(date);
      } else if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateStr)) {
        final parts = dateStr.split('-');
        return '${parts[2]}/${parts[1]}/${parts[0]}';
      }
      return dateStr;
    } catch (e) {
      return data.toString();
    }
  }
}
