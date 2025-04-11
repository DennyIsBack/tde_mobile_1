import 'package:flutter/material.dart';
import 'package:receitas/bd/banco_helper.dart';
import 'package:receitas/model/ingrediente.dart';
import 'package:receitas/model/receita.dart';
import 'package:receitas/model/sequencia_preparo.dart';
import 'package:receitas/presentation/editview/editViewIngrediente.dart';
import 'package:receitas/presentation/editview/editViewSequenciaPreparo.dart';

class editViewReceita extends StatefulWidget {
  final Receita receita;
  final bool isEditing;

  const editViewReceita({
    super.key,
    required this.receita,
    required this.isEditing,
  });

  @override
  State<editViewReceita> createState() => _EditViewReceitaState();
}

class _EditViewReceitaState extends State<editViewReceita> {
  final BancoHelper _bdHelper = BancoHelper();
  late Receita receitaAtual;

  @override
  void initState() {
    super.initState();
    receitaAtual = widget.receita; // Inicializa com a receita passada
  }

  void salvarReceita() async {
    if (receitaAtual.id == null) {
      final novoId = await _bdHelper.inserirReceita(receitaAtual);
      setState(() {
        receitaAtual = Receita(
          id: novoId,
          nome: receitaAtual.nome,
          nota: receitaAtual.nota,
          dataAdicionada: receitaAtual.dataAdicionada,
          tempoPreparo: receitaAtual.tempoPreparo,
        );
      });
    } else {
      await _bdHelper.atualizarReceita(receitaAtual); // Atualiza a receita existente
    }
    Navigator.pop(context);
  }

  void deletarReceita() async {
    await _bdHelper.deletarReceita(receitaAtual.id!);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar Receita' : 'Visualizar Receita'),
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: salvarReceita,
            ),
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: deletarReceita,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campos de edição da receita
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: TextEditingController(text: receitaAtual.nome),
                    decoration: const InputDecoration(labelText: 'Nome da Receita'),
                    readOnly: widget.isEditing == false,
                    onChanged: (value) {
                      setState(() {
                        receitaAtual = Receita(
                          id: receitaAtual.id,
                          nome: value,
                          nota: receitaAtual.nota,
                          dataAdicionada: receitaAtual.dataAdicionada,
                          tempoPreparo: receitaAtual.tempoPreparo,
                        );
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: TextEditingController(
                        text: receitaAtual.tempoPreparo.toString()),
                    decoration:
                        const InputDecoration(labelText: 'Tempo de Preparo (min)'),
                    keyboardType: TextInputType.number,
                    readOnly: widget.isEditing == false,
                    onChanged: (value) {
                      setState(() {
                        receitaAtual = Receita(
                          id: receitaAtual.id,
                          nome: receitaAtual.nome,
                          nota: receitaAtual.nota,
                          dataAdicionada: receitaAtual.dataAdicionada,
                          tempoPreparo: int.tryParse(value) ?? 0,
                        );
                      });
                    },
                  ),
                ),
              // Botões de adicionar ingredientes e sequência de preparo
              if (widget.isEditing)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final novoIngrediente = Ingrediente(
                          nomeIngrediente: '',
                          quantidade: 1,
                          receitaId: receitaAtual.id!,
                        );
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditViewIngrediente(
                              ingrediente: novoIngrediente,
                              isEditing: true,
                            ),
                          ),
                        );
                        setState(() {});
                      },
                      child: const Text('Adicionar Ingrediente'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final novaSequencia = SequenciaPreparo(
                          ordem: (await _bdHelper.buscarSequenciaPreparo(receitaAtual.id!)).length + 1,
                          instrucao: '',
                          receitaId: receitaAtual.id!,
                        );
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditViewSequenciaPreparo(
                              sequencia: novaSequencia,
                              isEditing: true,
                            ),
                          ),
                        );
                        setState(() {}); 
                      },
                      child: const Text('Adicionar Sequência'),
                    ),
                  ],
                ),
              // Lista de ingredientes com altura limitada
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Ingredientes',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              SizedBox(
                height: 200, // Limita a altura da lista de ingredientes
                child: FutureBuilder<List<Ingrediente>>(
                  future: receitaAtual.id != null
                      ? _bdHelper.buscarIngredientes(receitaAtual.id!)
                      : Future.value([]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(
                          child: Text('Erro ao carregar ingredientes.'));
                    }
                    final ingredientes = snapshot.data ?? [];
                    return ListView.builder(
                      itemCount: ingredientes.length,
                      itemBuilder: (context, index) {
                        final ingrediente = ingredientes[index];
                        return ListTile(
                          title: Text(ingrediente.nomeIngrediente),
                          subtitle:
                              Text('Quantidade: ${ingrediente.quantidade}'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditViewIngrediente(
                                  ingrediente: ingrediente,
                                  isEditing: true,
                                ),
                              ),
                            ).then((_) => setState(() {})); // Atualiza a lista após edição
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              // Lista de sequência de preparo com altura limitada
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Sequência de Preparo',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              SizedBox(
                height: 200, // Limita a altura da lista de sequência de preparo
                child: FutureBuilder<List<SequenciaPreparo>>(
                  future: receitaAtual.id != null
                      ? _bdHelper.buscarSequenciaPreparo(receitaAtual.id!)
                      : Future.value([]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(
                          child: Text('Erro ao carregar sequência de preparo.'));
                    }
                    final sequencias = snapshot.data ?? [];
                    return ListView.builder(
                      itemCount: sequencias.length,
                      itemBuilder: (context, index) {
                        final sequencia = sequencias[index];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text('${sequencia.ordem}'),
                          ),
                          title: Text(sequencia.instrucao),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditViewSequenciaPreparo(
                                  sequencia: sequencia,
                                  isEditing: true,
                                ),
                              ),
                            ).then((_) => setState(() {})); // Atualiza a lista após edição
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}