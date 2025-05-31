import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Para salvar os dados localmente
import 'dart:convert'; // Para converter os dados entre JSON e objetos
import 'package:uuid/uuid.dart'; // Para gerar IDs únicos

void main() {
  runApp(const MyApp()); // Inicia o aplicativo
}

/// Modelo do Agendamento
class Agendamento {
  String id;
  String nomeCliente;
  String servico;
  String dataHora;

  // Construtor do modelo
  Agendamento({
    required this.id,
    required this.nomeCliente,
    required this.servico,
    required this.dataHora,
  });

  // Construtor que cria um Agendamento a partir de um mapa JSON
  factory Agendamento.fromJson(Map<String, dynamic> json) {
    return Agendamento(
      id: json['id'],
      nomeCliente: json['nomeCliente'],
      servico: json['servico'],
      dataHora: json['dataHora'],
    );
  }

  // Método que converte o objeto Agendamento em um mapa JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'nomeCliente': nomeCliente,
    'servico': servico,
    'dataHora': dataHora,
  };
}

/// Serviço responsável por gerenciar agendamentos (padrão Singleton)
class AgendamentoService {
  static final AgendamentoService _instancia = AgendamentoService._interno();
  final List<Agendamento> _agendamentos = []; // Lista interna de agendamentos
  final _uuid = const Uuid(); // Gerador de IDs únicos

  factory AgendamentoService() {
    return _instancia;
  }

  AgendamentoService._interno();

  // Retorna todos os agendamentos
  List<Agendamento> listar() => _agendamentos;

  // Carrega os dados salvos localmente
  Future<void> carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    final dados = prefs.getString('agendamentos');
    if (dados != null) {
      final jsonList = jsonDecode(dados) as List;
      _agendamentos.clear();
      _agendamentos.addAll(jsonList.map((e) => Agendamento.fromJson(e)));
    }
  }

  // Salva os dados localmente
  Future<void> salvarDados() async {
    final prefs = await SharedPreferences.getInstance();
    final dados = jsonEncode(_agendamentos.map((e) => e.toJson()).toList());
    await prefs.setString('agendamentos', dados);
  }

  // Adiciona um novo agendamento à lista
  Future<void> adicionar(Agendamento agendamento) async {
    agendamento.id = _uuid.v4(); // Gera um novo ID
    _agendamentos.add(agendamento);
    await salvarDados();
  }

  // Atualiza um agendamento existente
  Future<void> atualizar(Agendamento agendamento) async {
    final index = _agendamentos.indexWhere((e) => e.id == agendamento.id);
    if (index != -1) {
      _agendamentos[index] = agendamento;
      await salvarDados();
    }
  }

  // Remove um agendamento pelo ID
  Future<void> remover(String id) async {
    _agendamentos.removeWhere((e) => e.id == id);
    await salvarDados();
  }
}

/// App principal
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Agendamentos',
      theme: ThemeData(
        primarySwatch: Colors.purple, // Cor roxa padrão
        useMaterial3: true, // Habilita o Material Design 3
      ),
      home: const ListaPage(), // Página inicial
      debugShowCheckedModeBanner: false, // Remove a faixa de debug
    );
  }
}

/// Tela de listagem dos agendamentos
class ListaPage extends StatefulWidget {
  const ListaPage({super.key});

  @override
  State<ListaPage> createState() => _ListaPageState();
}

class _ListaPageState extends State<ListaPage> {
  final TextEditingController _buscaController = TextEditingController();
  String _filtro = ''; // Texto do filtro de busca
  List<Agendamento> _agendamentosFiltrados = [];

  @override
  void initState() {
    super.initState();
    _carregarAgendamentos();
  }

  // Carrega os dados e aplica o filtro inicial
  Future<void> _carregarAgendamentos() async {
    await AgendamentoService().carregarDados();
    _aplicarFiltro();
  }

  // Aplica o filtro à lista de agendamentos
  void _aplicarFiltro() {
    final todos = AgendamentoService().listar();
    setState(() {
      _agendamentosFiltrados =
          todos.where((ag) {
            return ag.nomeCliente.toLowerCase().contains(
                  _filtro.toLowerCase(),
                ) ||
                ag.servico.toLowerCase().contains(_filtro.toLowerCase());
          }).toList();
    });
  }

  // Remove um agendamento pelo ID
  void _removerAgendamento(String id) async {
    await AgendamentoService().remover(id);
    _aplicarFiltro();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agendamentos')),
      body: Column(
        children: [
          // Campo de busca
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _buscaController,
              decoration: const InputDecoration(
                labelText: 'Buscar por nome ou serviço',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _filtro = value;
                _aplicarFiltro(); // Atualiza a lista conforme digita
              },
            ),
          ),
          // Lista dos agendamentos filtrados
          Expanded(
            child: ListView.builder(
              itemCount: _agendamentosFiltrados.length,
              itemBuilder: (context, index) {
                final ag = _agendamentosFiltrados[index];
                return ListTile(
                  title: Text(ag.nomeCliente),
                  subtitle: Text('${ag.servico} - ${ag.dataHora}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botão de editar
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CadastroPage(agendamento: ag),
                            ),
                          );
                          _aplicarFiltro();
                        },
                      ),
                      // Botão de deletar
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _removerAgendamento(ag.id);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // Botão flutuante para adicionar novo agendamento
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CadastroPage()),
          );
          _aplicarFiltro();
        },
      ),
    );
  }
}

/// Tela de cadastro ou edição de agendamentos
class CadastroPage extends StatefulWidget {
  final Agendamento? agendamento; // Se for passado, significa que está editando

  const CadastroPage({super.key, this.agendamento});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _servicoController = TextEditingController();
  final _dataHoraController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Se for edição, preenche os campos com os dados existentes
    if (widget.agendamento != null) {
      _nomeController.text = widget.agendamento!.nomeCliente;
      _servicoController.text = widget.agendamento!.servico;
      _dataHoraController.text = widget.agendamento!.dataHora;
    }
  }

  // Salva os dados do formulário
  void _salvar() async {
    if (_formKey.currentState!.validate()) {
      final agendamento = Agendamento(
        id: widget.agendamento?.id ?? '',
        nomeCliente: _nomeController.text,
        servico: _servicoController.text,
        dataHora: _dataHoraController.text,
      );

      // Se for novo, adiciona; se for edição, atualiza
      if (widget.agendamento == null) {
        await AgendamentoService().adicionar(agendamento);
      } else {
        await AgendamentoService().atualizar(agendamento);
      }

      Navigator.pop(context); // Volta para a tela anterior
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.agendamento == null
              ? 'Novo Agendamento'
              : 'Editar Agendamento',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Campo: Nome do Cliente
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome do Cliente'),
                validator: (value) => value!.isEmpty ? 'Informe o nome' : null,
              ),
              // Campo: Serviço
              TextFormField(
                controller: _servicoController,
                decoration: const InputDecoration(labelText: 'Serviço'),
                validator:
                    (value) => value!.isEmpty ? 'Informe o serviço' : null,
              ),
              // Campo: Data e Hora
              TextFormField(
                controller: _dataHoraController,
                decoration: const InputDecoration(labelText: 'Data e Hora'),
                validator:
                    (value) => value!.isEmpty ? 'Informe a data e hora' : null,
              ),
              const SizedBox(height: 20),
              // Botão: Salvar
              ElevatedButton(onPressed: _salvar, child: const Text('Salvar')),
            ],
          ),
        ),
      ),
    );
  }
}
