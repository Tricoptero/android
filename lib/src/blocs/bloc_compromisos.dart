
import 'package:rxdart/rxdart.dart';
import '../models/compromiso_model.dart';
import '../resources/db_provider.dart';
import 'package:flutter/material.dart';



class BlocCompromisos {


  final _compromisoList = BehaviorSubject<List<CompromisoModel>>();
  final _selectActivo = BehaviorSubject<bool>();
  final _selectTipo = BehaviorSubject<String>();
  final db = dbProvider;

  // Formulario detalle compromisos

  final _nombre = BehaviorSubject<String>();
  Function(String) get changeNombre => _nombre.sink.add;
  Observable<String> get nombre => _nombre.stream;
  TextEditingController controllerNombre;

  final _duracion = BehaviorSubject<String>();
  Function(String) get changeDuracion => _duracion.sink.add;
  Observable<String> get duracion => _duracion.stream;
  TextEditingController controllerDuracion;

  final _periodicidad = BehaviorSubject<String>();
  Function(String) get changePeriodicidad => _periodicidad.sink.add;
  Observable<String> get periodicidad => _periodicidad.stream;
  TextEditingController controllerPeriodicidad;

  final _comentario = BehaviorSubject<String>();
  Function(String) get changeComentario => _comentario.sink.add;
  Observable<String> get comentario => _comentario.stream;
  TextEditingController controllerComentario;

  final _editar = BehaviorSubject<bool>();
  Function(bool) get changeEditarCompromiso => _editar.sink.add;
  Observable<bool> get editarCompromiso => _editar.stream;

  Observable<bool> get submitValid =>
      Observable.combineLatest2(nombre, duracion, (e, p) => true);

  List<String> tipos;

  bool flagBuscar = false;

  Function(List<CompromisoModel>) get changeCompromisoList => _compromisoList.sink.add;
  Observable<List<CompromisoModel>> get compromisoList => _compromisoList.stream;

  Function(bool) get changeSelectActivo => _selectActivo.sink.add;
  Observable<bool> get selectActivo => _selectActivo.stream;

  Function(String) get changeSelectTipo => _selectTipo.sink.add;
  Observable<String> get selectTipo => _selectTipo.stream;


  void fetchCompromisos() async {
    List<CompromisoModel> compromisos = await db.fetchCompromisos();
    compromisos.sort((CompromisoModel a,CompromisoModel b) { return a.tipo.compareTo(b.tipo);});
    tipos = new List<String>();
    compromisos.forEach((CompromisoModel compromiso) {
      if (!tipos.contains(compromiso.tipo)) {
        tipos.add(compromiso.tipo);
      }
    });

    changeCompromisoList(compromisos);
  }
  void seleccionarTipo(String tipo) async {
    List<CompromisoModel> compromisos = await db.fetchCompromisos();
    if (tipo != null) {
      compromisos.removeWhere((compromiso) => compromiso.tipo != tipo);
    }
    changeCompromisoList(compromisos);
  }

  void seleccionarActivo(bool activo) async {
    List<CompromisoModel> compromisos = await db.fetchCompromisos();
    if (activo == null) {
      compromisos.removeWhere((compromiso) => compromiso.activo == true);
    }
    if (activo == true) {
      compromisos.removeWhere((compromiso) => compromiso.activo == false);
    }
    changeCompromisoList(compromisos);
  }

  void cargaCompromiso(CompromisoModel compromiso) {

    changeEditarCompromiso(false);
    changeNombre(compromiso.nombre);
    controllerNombre = new TextEditingController(text: compromiso.nombre);
    changeSelectTipo(compromiso.tipo);
    changeDuracion("${compromiso.duracion.inHours<10?'0':''}${compromiso.duracion.inHours}hh:${(compromiso.duracion.inMinutes%60)<10?'0':''}${compromiso.duracion.inMinutes % 60}mm");
    controllerDuracion = new TextEditingController(text:"${compromiso.duracion.inHours<10?'0':''}${compromiso.duracion.inHours}hh:${(compromiso.duracion.inMinutes%60)<10?'0':''}${compromiso.duracion.inMinutes % 60}mm");
    changePeriodicidad(compromiso.periodicidad.toString());
    controllerPeriodicidad = new TextEditingController(text: compromiso.periodicidad.toString());
    changeComentario(compromiso.comentario);
    controllerComentario = new TextEditingController(text: compromiso.comentario);
    changeSelectActivo(compromiso.activo);


  }

  dispose() {
    _nombre.close();
    _duracion.close();
    _periodicidad.close();
    _compromisoList.close();
    _editar.close();
    _selectActivo.close();
    _selectTipo.close();

  }

}