import 'dart:async';
import '../model/receita.dart';
import '../model/ingrediente.dart';
import '../model/sequencia_preparo.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class BancoHelper {
  static const arquivoDoBancoDeDados = 'receitasBD.db';
  static const arquivoDoBancoDeDadosVersao = 1;

  static const tabelaReceita = 'receitas';
  static const tabelaIngredientes = 'ingredientes';
  static const tabelaSequenciaPreparo = 'sequencia_preparo';

  static const colunaId = 'id';

  static late Database _bancoDeDados;

  Future<void> iniciarBD() async {
    try {
      String caminhoBD = await getDatabasesPath();
      String path = join(caminhoBD, arquivoDoBancoDeDados);
      _bancoDeDados = await openDatabase(
        path,
        version: arquivoDoBancoDeDadosVersao,
        onCreate: funcaoCriacaoBD
      );
    } catch (e) {
      print('Erro ao iniciar o banco de dados: $e');
    }
  }

  Future<void> funcaoCriacaoBD(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tabelaReceita (
        $colunaId INTEGER PRIMARY KEY,
        nome TEXT NOT NULL,
        nota REAL NOT NULL,
        data_adicionada TEXT NOT NULL,
        tempo_preparo INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tabelaIngredientes (
        $colunaId INTEGER PRIMARY KEY,
        nome_ingrediente TEXT NOT NULL,
        quantidade INTEGER NOT NULL,
        receita_id INTEGER NOT NULL,
        FOREIGN KEY (receita_id) REFERENCES $tabelaReceita($colunaId)
      )
    ''');

    await db.execute('''
      CREATE TABLE $tabelaSequenciaPreparo (
        $colunaId INTEGER PRIMARY KEY,
        ordem INTEGER NOT NULL,
        instrucao TEXT NOT NULL,
        receita_id INTEGER NOT NULL,
        FOREIGN KEY (receita_id) REFERENCES $tabelaReceita($colunaId)
      )
    ''');
  }

  Future<int> inserirReceita(Receita receita) async {
    await iniciarBD();
    return await _bancoDeDados.insert(tabelaReceita, receita.toMap());
  }

  Future<int> inserirIngrediente(Ingrediente ingrediente) async {
    await iniciarBD();
    return await _bancoDeDados.insert(tabelaIngredientes, ingrediente.toMap());
  }

  Future<int> inserirSequenciaPreparo(SequenciaPreparo sequencia) async {
    await iniciarBD();
    return await _bancoDeDados.insert(tabelaSequenciaPreparo, sequencia.toMap());
  }

  Future<List<Receita>> buscarReceitas() async {
    await iniciarBD();
    final List<Map<String, dynamic>> receitasNoBanco =
        await _bancoDeDados.query(tabelaReceita);
    return receitasNoBanco.map((e) => Receita.fromMap(e)).toList();
  }

  Future<List<Ingrediente>> buscarIngredientes(int receitaId) async {
    await iniciarBD();
    final List<Map<String, dynamic>> ingredientesNoBanco =
        await _bancoDeDados.query(
      tabelaIngredientes,
      where: 'receita_id = ?',
      whereArgs: [receitaId],
    );
    return ingredientesNoBanco.map((e) => Ingrediente.fromMap(e)).toList();
  }

  Future<List<SequenciaPreparo>> buscarSequenciaPreparo(int receitaId) async {
    await iniciarBD();
    final List<Map<String, dynamic>> sequenciasNoBanco =
        await _bancoDeDados.query(
      tabelaSequenciaPreparo,
      where: 'receita_id = ?',
      whereArgs: [receitaId],
    );
    return sequenciasNoBanco.map((e) => SequenciaPreparo.fromMap(e)).toList();
  }

  Future<int> atualizarIngrediente(Ingrediente ingrediente) async {
  await iniciarBD();
  return await _bancoDeDados.update(
      tabelaIngredientes,
      ingrediente.toMap(),
      where: 'id = ?',
      whereArgs: [ingrediente.id],
    );
  }

  Future<int> atualizarSequenciaPreparo(SequenciaPreparo sequencia) async {
  await iniciarBD();
    return await _bancoDeDados.update(
      tabelaSequenciaPreparo,
      sequencia.toMap(),
      where: 'id = ?',
      whereArgs: [sequencia.id],
    );
  }

  Future<int> atualizarReceita(Receita receita) async {
    await iniciarBD();
    return await _bancoDeDados.update(
      tabelaReceita,
      receita.toMap(),
      where: 'id = ?',
      whereArgs: [receita.id],
    );
  }

  Future<int> deletarReceita(int receitaId) async {
  await iniciarBD();
  // Primeiro, deleta os ingredientes e sequência de preparo associados
  await _bancoDeDados.delete(
    tabelaIngredientes,
    where: 'receita_id = ?',
    whereArgs: [receitaId],
  );
  await _bancoDeDados.delete(
    tabelaSequenciaPreparo,
    where: 'receita_id = ?',
    whereArgs: [receitaId],
  );
  // Depois deleta a receita
  return await _bancoDeDados.delete(
    tabelaReceita,
    where: 'id = ?',
    whereArgs: [receitaId],
  );
}

Future<int> deletarIngrediente(int ingredienteId) async {
  await iniciarBD();
  return await _bancoDeDados.delete(
    tabelaIngredientes,
    where: 'id = ?',
    whereArgs: [ingredienteId],
  );
}

Future<int> deletarSequenciaPreparo(int sequenciaId) async {
  await iniciarBD();
  return await _bancoDeDados.delete(
    tabelaSequenciaPreparo,
    where: 'id = ?',
    whereArgs: [sequenciaId],
  );
}
}
