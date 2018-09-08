import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'dart:async';
import '../models/compromiso_model.dart';


class DbProvider  {
  Database db;

  DbProvider() {
    init();
  }

  void init() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    
    final path = join(documentsDirectory.path, "compromisos1.db");
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
    final List<Map<String,dynamic>> numPara = await db.query("parametros",
        columns: ['COUNT(*)']);
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
    final List<Map<String,dynamic>> mimap = await db.query("parametros",
        columns: null);
    return mimap.last['compromisos_local_id_ini'];

  }

  Future<List<CompromisoModel>> fetchCompromisos() async {

    final maps = await db.query(
      "compromisos",
      columns: null,

    );

    if (maps.length > 0) {
       List<CompromisoModel> compromisos = new List();
       maps.forEach((model) {compromisos.add(CompromisoModel.fromDb(model));});
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

    return db.insert("compromisos", compromiso.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<int> clearCompromisos() {
    return db.delete("compromisos");
    
  }
  Future<int> updateCompromiso(CompromisoModel compromiso) {
    return db.update('compromisos',
                compromiso.toMap(),
                where: "id_compromiso = ?",
                whereArgs: [compromiso.idCompromiso],
              );

  }
}

final dbProvider = DbProvider();
