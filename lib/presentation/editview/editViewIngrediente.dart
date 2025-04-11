import 'package:flutter/material.dart';
import 'package:receitas/bd/banco_helper.dart';
import 'package:receitas/model/ingrediente.dart';

class EditViewIngrediente extends StatefulWidget {
  final Ingrediente ingrediente;
  final bool isEditing;

  const EditViewIngrediente({
    super.key,
    required this.ingrediente,
    required this.isEditing,
  });

  @override
  State<EditViewIngrediente> createState() => _EditViewIngredienteState();
}

class _EditViewIngredienteState extends State<EditViewIngrediente> {
  final BancoHelper _bdHelper = BancoHelper();
  late Ingrediente ingredienteAtual;

  @override
  void initState() {
    super.initState();
    ingredienteAtual = widget.ingrediente;
  }

  void salvarIngrediente() async {
    if (ingredienteAtual.id == null) {
      await _bdHelper.inserirIngrediente(ingredienteAtual);
    } else {
      // Atualizar ingrediente no banco
      await _bdHelper.atualizarIngrediente(ingredienteAtual);
    }
    Navigator.pop(context);
  }

  void deletarIngrediente() async {
    if (ingredienteAtual.id != null) {
      await _bdHelper.deletarIngrediente(ingredienteAtual.id!);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar Ingrediente' : 'Novo Ingrediente'),
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: deletarIngrediente,
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: salvarIngrediente,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: TextEditingController(text: ingredienteAtual.nomeIngrediente),
              decoration: const InputDecoration(labelText: 'Nome do Ingrediente'),
              onChanged: (value) {
                setState(() {
                  ingredienteAtual = Ingrediente(
                    id: ingredienteAtual.id,
                    nomeIngrediente: value,
                    quantidade: ingredienteAtual.quantidade,
                    receitaId: ingredienteAtual.receitaId,
                  );
                });
              },
            ),
            TextField(
              controller: TextEditingController(text: ingredienteAtual.quantidade.toString()),
              decoration: const InputDecoration(labelText: 'Quantidade'),
              onChanged: (value) {
                setState(() {
                  ingredienteAtual = Ingrediente(
                    id: ingredienteAtual.id,
                    nomeIngrediente: ingredienteAtual.nomeIngrediente,
                    quantidade: value.isEmpty ? 0 : int.parse(value),
                    receitaId: ingredienteAtual.receitaId,
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