import 'package:flutter/material.dart';
import 'package:receitas/bd/banco_helper.dart';
import 'package:receitas/model/sequencia_preparo.dart';

class EditViewSequenciaPreparo extends StatefulWidget {
  final SequenciaPreparo sequencia;
  final bool isEditing;

  const EditViewSequenciaPreparo({
    super.key,
    required this.sequencia,
    required this.isEditing,
  });

  @override
  State<EditViewSequenciaPreparo> createState() => _EditViewSequenciaPreparoState();
}

class _EditViewSequenciaPreparoState extends State<EditViewSequenciaPreparo> {
  final BancoHelper _bdHelper = BancoHelper();
  late SequenciaPreparo sequenciaAtual;

  @override
  void initState() {
    super.initState();
    sequenciaAtual = widget.sequencia;
  }

  void salvarSequencia() async {
    if (sequenciaAtual.id == null) {
      await _bdHelper.inserirSequenciaPreparo(sequenciaAtual);
    } else {
      // Atualizar sequência no banco
      await _bdHelper.atualizarSequenciaPreparo(sequenciaAtual);
    }
    Navigator.pop(context);
  }

  void deletarSequencia() async {
    if (sequenciaAtual.id != null) {
      await _bdHelper.deletarSequenciaPreparo(sequenciaAtual.id!);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar Sequência' : 'Nova Sequência'),
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: deletarSequencia,
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: salvarSequencia,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: TextEditingController(text: sequenciaAtual.instrucao),
              decoration: const InputDecoration(labelText: 'Instrução'),
              onChanged: (value) {
                setState(() {
                  sequenciaAtual = SequenciaPreparo(
                    id: sequenciaAtual.id,
                    ordem: sequenciaAtual.ordem,
                    instrucao: value,
                    receitaId: sequenciaAtual.receitaId,
                  );
                });
              },
            ),
            TextField(
              controller: TextEditingController(text: sequenciaAtual.ordem.toString()),
              decoration: const InputDecoration(labelText: 'Ordem'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  sequenciaAtual = SequenciaPreparo(
                    id: sequenciaAtual.id,
                    ordem: int.tryParse(value) ?? 1,
                    instrucao: sequenciaAtual.instrucao,
                    receitaId: sequenciaAtual.receitaId,
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}