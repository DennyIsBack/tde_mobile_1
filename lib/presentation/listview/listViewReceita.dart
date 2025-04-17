import 'package:flutter/material.dart';
import 'package:receitas/bd/banco_helper.dart';
import 'package:receitas/model/receita.dart';
import 'package:receitas/model/ingrediente.dart';
import 'package:receitas/model/sequencia_preparo.dart';
import 'package:receitas/presentation/editview/editViewReceita.dart';

class ListViewReceita extends StatefulWidget {
  const ListViewReceita({super.key});

  @override
  State<ListViewReceita> createState() => _ListViewReceitaState();
}

class _ListViewReceitaState extends State<ListViewReceita> {
  final BancoHelper _bdHelper = BancoHelper();
  final List<Receita> _receitas = [];

  @override
  void initState() {
    super.initState();
    carregarReceitas();
  }

  void carregarReceitas() async {
    var receitas = await _bdHelper.buscarReceitas();
    setState(() {
      _receitas.clear();
      _receitas.addAll(receitas);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receitas'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Expanded(
                child: FutureBuilder<List<Receita>>(
                  future: _bdHelper.buscarReceitas(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('Erro ao carregar receitas.'));
                    }
                    final receitas = snapshot.data ?? [];
                    return ListView.builder(
                      itemCount: receitas.length,
                      itemBuilder: (context, index) {
                        final receita = receitas[index];
                        return FutureBuilder(
                          future: Future.wait([
                            _bdHelper.buscarIngredientes(receita.id!),
                            _bdHelper.buscarSequenciaPreparo(receita.id!),
                          ]),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const ListTile(
                                title: Text('Carregando...'),
                              );
                            }
                            if (snapshot.hasError) {
                              return const ListTile(
                                title: Text('Erro ao carregar dados.'),
                              );
                            }
                            final ingredientes = snapshot.data![0] as List<Ingrediente>;
                            final sequencias = snapshot.data![1] as List<SequenciaPreparo>;
                            return ListTile(
                              title: Text(receita.nome),
                              subtitle: Text(
                                  'Ingredientes: ${ingredientes.length}, Sequências: ${sequencias.length}, Tempo: ${receita.tempoPreparo} min'),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => editViewReceita(
                                        receita: receita,
                                        isEditing: true,
                                      ),
                                    ),
                                  ).then((_) {
                                    carregarReceitas(); 
                                  });
                                },
                              ),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => editViewReceita(
                                      receita: receita,
                                      isEditing: false,
                                    ),
                                  ),
                                ).then((_) {
                                  carregarReceitas(); 
                                });
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => editViewReceita(
                        receita: Receita(
                          id: null,
                          nome: '',
                          nota: 0.0,
                          dataAdicionada: DateTime.now().toIso8601String(),
                          tempoPreparo: 0,
                        ),
                        isEditing: true,
                      ),
                    ),
                  ).then((_) {
                    carregarReceitas();
                  });
                },
                child: const Text('Adicionar Receita'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}