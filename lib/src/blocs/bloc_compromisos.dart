import 'package:rxdart/rxdart.dart';
import '../models/compromiso_model.dart';
import '../resources/db_provider.dart';
import 'package:flutter/material.dart';
import '../models/planificacion_model.dart';

class BlocCompromisos {
  final _compromisoList = BehaviorSubject<List<CompromisoModel>>();
  final _selectActivo = BehaviorSubject<bool>();
  final _selectTipo = BehaviorSubject<String>();
  final db = dbProvider;
  CompromisoModel compromisoEdit;
  PlanificacionModel planificacionEdit;
  CompromisoModel compromisoDel;
  List<CompromisoModel> compromisos;

  // Formulario detalle compromisos

  final _nombre = BehaviorSubject<String>();

  Function(String) get changeNombre => _nombre.sink.add;

  Observable<String> get nombre => _nombre.stream;
  TextEditingController controllerNombre;

  final _duracion = BehaviorSubject<String>();

  Function(String) get changeDuracion => _duracion.sink.add;

  Observable<String> get duracion => _duracion.stream;
  TextEditingController controllerDuracion;

  final _nuevoTipo = BehaviorSubject<String>();

  Function(String) get changeNuevoTipo => _nuevoTipo.sink.add;

  Observable<String> get nuevoTipo => _nuevoTipo.stream;
  TextEditingController controllerNuevoTipo;

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

  Function(List<CompromisoModel>) get changeCompromisoList =>
      _compromisoList.sink.add;

  Observable<List<CompromisoModel>> get compromisoList =>
      _compromisoList.stream;

  Function(bool) get changeSelectActivo => _selectActivo.sink.add;

  Observable<bool> get selectActivo => _selectActivo.stream;

  Function(String) get changeSelectTipo => _selectTipo.sink.add;

  Observable<String> get selectTipo => _selectTipo.stream;

  void fetchCompromisos() async {
    compromisos = await db.fetchCompromisos();
    compromisos.sort((CompromisoModel a, CompromisoModel b) {
      return a.tipo.compareTo(b.tipo);
    });
    tipos = new List<String>();
    compromisos.forEach((CompromisoModel compromiso) {
      if (!tipos.contains(compromiso.tipo)) {
        tipos.add(compromiso.tipo);
      }
    });

    changeCompromisoList(compromisos);
  }


  void seleccionarTipo(String tipo) async {
    compromisos = await db.fetchCompromisos();
    if (tipo != null) {
      compromisos.removeWhere((compromiso) => compromiso.tipo != tipo);
    }
    changeCompromisoList(compromisos);
  }

  void seleccionarActivo(bool activo) async {
    compromisos = await db.fetchCompromisos();
    if (activo == null) {
      compromisos.removeWhere((compromiso) => compromiso.activo == true);
    }
    if (activo == true) {
      compromisos.removeWhere((compromiso) => compromiso.activo == false);
    }
    changeCompromisoList(compromisos);
  }

  void cargaCompromiso(CompromisoModel compromiso) {
    compromisoEdit = compromiso;
    changeEditarCompromiso(false);
    changeNombre(compromiso.nombre);
    controllerNombre = new TextEditingController(text: compromiso.nombre);
    changeSelectTipo(compromiso.tipo);
    if (compromiso.duracion != null) {
      changeDuracion(
          "${compromiso.duracion.inHours < 10 ? '0' : ''}${compromiso.duracion
              .inHours}:${(compromiso.duracion.inMinutes % 60) < 10
              ? '0'
              : ''}${compromiso.duracion.inMinutes % 60}");

      controllerDuracion = new TextEditingController(
          text:
          "${compromiso.duracion.inHours < 10 ? '0' : ''}${compromiso.duracion
              .inHours}:${(compromiso.duracion.inMinutes % 60) < 10
              ? '0'
              : ''}${compromiso.duracion.inMinutes % 60}");


    changePeriodicidad(compromiso.periodicidad.toString());
    controllerPeriodicidad =
        new TextEditingController(text: compromiso.periodicidad.toString());
    changeSelectActivo(compromiso.activo);
  } else {
      changeDuracion('');
      changePeriodicidad('');
      controllerDuracion = new TextEditingController();
      controllerPeriodicidad = new TextEditingController();
      changeSelectActivo(false);
    }

    changeComentario(compromiso.comentario);
    controllerComentario =
        new TextEditingController(text: compromiso.comentario);
     controllerNuevoTipo = new TextEditingController(text: '');
  }

  void submitLogin(context) {
    bool valido = true;

    if (_nombre.value == null || _nombre.value.trim() == '') {
      _nombre.sink.addError('Introducir un Titulo');
      valido = false;
    }
    if (_selectTipo.value == null) {
      _selectTipo.sink.addError('Tipo');
      valido = false;
    }

    if (_nuevoTipo.value == 'nuevo') {
      _selectTipo.sink.addError('Tipo');
      valido = false;
    }

    if ((_selectTipo.value == 'nuevo') &&
        (_nuevoTipo.value == null || _nuevoTipo.value.trim() == '')) {
      _selectTipo.sink.addError('Tipo');
      valido = false;
    }
    if (_periodicidad.value==null || !RegExp("^[1-7]\$").hasMatch(_periodicidad.value)) {
      _periodicidad.addError('Introducir 1 a 7 Días');
      valido = false;
    }
    ;

    if (_duracion.value == null ||
        !((RegExp("^[0-9]{2}:[0-9]{2}\$").hasMatch(_duracion.value) &&
            (int.parse(_duracion.value.substring(0, 2)) < 25) &&
            (int.parse(_duracion.value.substring(3)) < 61)))) {
      _duracion.sink.addError('Introducir duracion hh:mm');
      valido = false;
    }
    if (valido) {
      compromisoEdit.activo = _selectActivo.value;
      compromisoEdit.comentario = _comentario.value;
      compromisoEdit.duracion = Duration(
          hours: int.parse(_duracion.value.substring(0, 2)),
          minutes: int.parse(_duracion.value.substring(3)));
      compromisoEdit.nombre = _nombre.value;
      compromisoEdit.periodicidad = int.parse(_periodicidad.value);
      if (_selectTipo.value == "nuevo") {
        compromisoEdit.tipo = _nuevoTipo.value;
      } else {
        compromisoEdit.tipo = _selectTipo.value;
      }
      compromisoEdit.stamp = DateTime
          .now().toUtc()
          .millisecondsSinceEpoch;

      if (compromisoEdit.idCompromiso > 0) {
        db.updateCompromiso(compromisoEdit).then((i) {Navigator.pop(context);});
      } else {
        db.addNewCompromiso(compromisoEdit).then((i) {Navigator.pop(context);});


      }

    }
  }

  void submitPlan(context) {
    bool valido = true;

    if (_periodicidad.value==null || !RegExp("^[1-7]\$").hasMatch(_periodicidad.value)) {
      _periodicidad.addError('Introducir 1 a 7 Días');
      valido = false;
    }
    ;
    if (_duracion.value == null ||
        !((RegExp("^[0-9]{2}:[0-9]{2}\$").hasMatch(_duracion.value) &&
            (int.parse(_duracion.value.substring(0, 2)) < 25) &&
            (int.parse(_duracion.value.substring(3)) < 61)))) {
      _duracion.sink.addError('Introducir duracion hh:mm');
      valido = false;
    }
    if (valido) {

      planificacionEdit.comentario = _comentario.value;
      planificacionEdit.duracion = Duration(
          hours: int.parse(_duracion.value.substring(0, 2)),
          minutes: int.parse(_duracion.value.substring(3)));

      planificacionEdit.periodicidad = int.parse(_periodicidad.value);

      planificacionEdit.stamp = DateTime
          .now().toUtc()
          .millisecondsSinceEpoch;

    db.updatePlanificacion(planificacionEdit).then((i) {Navigator.pop(context);});


      }

    }


  dispose() {
    _nombre.close();
    _duracion.close();
    _periodicidad.close();
    _compromisoList.close();
    _editar.close();
    _selectActivo.close();
    _selectTipo.close();
    _nuevoTipo.close();
    _comentario.close();
    _editar.close();
  }
}
