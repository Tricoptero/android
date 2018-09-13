import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'dart:async';
import '../models/compromiso_model.dart';
import '../models/planificacion_model.dart';
import '../models/registro_model.dart';

class DbProvider {
  Database db;

  DbProvider() {
    init();
  }

  void init() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    final path = join(documentsDirectory.path, "sgc.db");
    db = await openDatabase(path, version: 1,
        onCreate: (Database newDb, int version) {
      newDb.execute("""
        CREATE TABLE compromisos
          (
            id_compromiso INTEGER PRIMARY KEY,
            nombre TEXT,
            tipo TEXT,
            comentario TEXT,
            duracion INTEGER,
            periodicidad INTEGER,
            activo INTEGER,
            stamp INTEGER
          ) 
        """);

      newDb.execute("""
      CREATE TABLE parametros
        (
          version INTEGER PRIMARY KEY,
          compromisos_local_id INTEGER,
          compromisos_local_id_ini INTEGER,
          compromisos_cloud_id INTEGER,
          stamp_sincro INTEGER
      )
      """);

      newDb.execute("""
        CREATE TABLE planificacion
          (
            ano INTEGER,
            semana INTEGER,
            id_compromiso INTEGER,
            comentario TEXT,
            duracion INTEGER,
            periodicidad INTEGER,
            stamp INTEGER,
            PRIMARY KEY (ano, semana, id_compromiso)
          ) 
        """);

      newDb.execute("""
        CREATE TABLE registro
          (
            fecha INTEGER,
            id_compromiso INTEGER,
            cumplimiento INTEGER,
            stamp INTEGER,
            PRIMARY KEY (fecha, id_compromiso)
          ) 
        """);
    });
  }

  Future<int> idCompromisoIni() async {
    final List<Map<String, dynamic>> numPara =
        await db.query("parametros", columns: ['COUNT(*)']);
    int i = numPara.first['COUNT(*)'];

    if (i == 0) {
      Map<String, dynamic> map = {
        "version": 1,
        "compromisos_local_id": 500000,
        "compromisos_local_id_ini": 500000,
        "compromisos_cloud_id": 1,
        "stamp_sincro": DateTime.now().millisecondsSinceEpoch,
      };

      db.insert('parametros', map);

      return 500000;
    }
    final List<Map<String, dynamic>> mimap =
        await db.query("parametros", columns: null);
    return mimap.last['compromisos_local_id_ini'];
  }

  Future<List<CompromisoModel>> fetchCompromisos() async {
    final maps = await db.query(
      "compromisos",
      columns: null,
    );

    if (maps.length > 0) {
      List<CompromisoModel> compromisos = new List();
      maps.forEach((model) {
        compromisos.add(CompromisoModel.fromDb(model));
      });

      return compromisos;
    } else {
      return null;
    }
  }

  Future<CompromisoModel> fetchCompromiso(int id) async {
    final maps = await db.query(
      "compromisos",
      columns: null,
      where: "id_compromiso = ?",
      whereArgs: [id],
    );
    if (maps.length > 0) {
      return CompromisoModel.fromDb(maps.first);
    } else {
      return null;
    }
  }

  Future<int> addCompromiso(CompromisoModel compromiso) {
    return db.insert("compromisos", compromiso.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<int> clearCompromisos() {
    return db.delete("compromisos");
  }

  Future<int> updateCompromiso(CompromisoModel compromiso) {
    return db.update(
      'compromisos',
      compromiso.toMap(),
      where: "id_compromiso = ?",
      whereArgs: [compromiso.idCompromiso],
    );
  }

  addNewCompromiso(CompromisoModel compromiso) async {
    List<Map<String, dynamic>> mimap =
        await db.query("parametros", columns: null);
    final idIni = mimap.last['compromisos_local_id_ini'];

    final List<Map<String, dynamic>> idDb = await db.query(
      "compromisos",
      columns: ['MAX(id_compromiso)'],
      where: "id_compromiso > ?",
      whereArgs: [idIni],
    );
    int id = 0;

    if (idDb.first['MAX(id_compromiso)'] != null) {
      id = idDb.first['MAX(id_compromiso)'];
    } else {
      id = idIni;
    }
    compromiso.idCompromiso = ++id;
    addCompromiso(compromiso);

    final Map<String, dynamic> paramNuevo = {
      "version": mimap.last["version"],
      "compromisos_local_id": id,
      "compromisos_local_id_ini": mimap.last["compromisos_local_id_ini"],
      "compromisos_cloud_id": mimap.last["compromisos_cloud_id"],
      "stamp_sincro": mimap.last["stamp_sincro"],
    };

    await db.update(
      'parametros',
      paramNuevo,
      where: "version = ?",
      whereArgs: [mimap.last["version"]],
    );
  }

  Future<int> deleteCompromiso(CompromisoModel compromiso) async {
    bool enUso = false;

    List<Map<String, dynamic>> numPara = await db.query(
      "planificacion",
      columns: ['COUNT(*)'],
      where: 'id_compromiso = ?',
      whereArgs: [compromiso.idCompromiso],
    );
    int i = numPara.first['COUNT(*)'];

    if (i != 0) {
      enUso = true;
    }
    ;

    numPara = await db.query(
      "registro",
      columns: ['COUNT(*)'],
      where: 'id_compromiso = ?',
      whereArgs: [compromiso.idCompromiso],
    );
    i = numPara.first['COUNT(*)'];

    if (i != 0) {
      enUso = true;
    }
    ;

    if (enUso) {
      compromiso.activo = false;
      return updateCompromiso(compromiso);
    } else {
      return db.delete(
        'compromisos',
        where: 'id_compromiso = ?',
        whereArgs: [compromiso.idCompromiso],
      );
    }
  }

  Future<List<PlanificacionModel>> semanaPlanificada(
      int semana, int ano) async {
    List<Map<String, dynamic>> maps = await db.query(
      "planificacion",
      columns: null,
      where: 'semana = ? AND ano = ?',
      whereArgs: [semana, ano],
    );

    if (maps.length > 0) {
      List<PlanificacionModel> planificaciones = new List();
      maps.forEach((model) {
        planificaciones.add(PlanificacionModel.fromDb(model));
      });
      return planificaciones;
    } else {
      return null;
    }
  }

  Future<PlanificacionModel> fetchPlanificacion(
      int ano, int semana, int id) async {
    final maps = await db.query(
      "planificacion",
      columns: null,
      where: "ano = ? AND semana = ? AND id_compromiso = ?",
      whereArgs: [ano, semana, id],
    );
    if (maps.length > 0) {
      return PlanificacionModel.fromDb(maps.first);
    } else {
      return null;
    }
  }

  Future<int> addPlanificacion(PlanificacionModel plan) async {
    return db.insert("planificacion", plan.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<int> updatePlanificacion(PlanificacionModel plan) async {
    return db.update(
      "planificacion",
      plan.toMap(),
      where: "ano = ? AND semana = ? AND id_compromiso = ?",
      whereArgs: [plan.ano, plan.semana, plan.idCompromiso],
    );
  }

  Future<RegistroModel> fetchRegistro(DateTime fecha, int id) async {
    final maps = await db.query(
      "registro",
      columns: null,
      where: "fecha = ? AND id_compromiso = ?",
      whereArgs: [fecha.millisecondsSinceEpoch, id],
    );

    if (maps.length > 0) {
      return RegistroModel.fromDb(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deletePlanificacion(ano, semana, id) async {
    return db.delete(
      "planificacion",
      where: "ano = ? AND semana = ? AND id_compromiso = ?",
      whereArgs: [ano, semana, id],
    );
  }

  Future<int> deleteRegistro(DateTime fecha, int id) async {
    return db.delete(
      "registro",
      where: "fecha = ? AND id_compromiso = ?",
      whereArgs: [fecha.millisecondsSinceEpoch, id],
    );
  }

  Future<int> updateRegistro(RegistroModel reg) async {
    return db.update(
      "registro",
      reg.toMap(),
      where: "fecha = ? AND id_compromiso = ?",
      whereArgs: [reg.fecha.millisecondsSinceEpoch, reg.idCompromiso],
    );
  }

  Future<int> addRegistro(RegistroModel reg) async {
    return db.insert("registro", reg.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }
}

final dbProvider = DbProvider();
