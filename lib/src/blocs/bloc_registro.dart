import 'package:rxdart/rxdart.dart';
import 'dart:async';
import '../models/registro_planificado.dart';
import '../models/planificacion_model.dart';
import '../models/compromiso_model.dart';
import '../models/registro_model.dart';
import '../resources/db_provider.dart';
import '../resources/week_utils.dart';
import 'provider_compromisos.dart';

import 'package:flutter/material.dart';

class BlocRegistro {
  final db = dbProvider;
  bool flagBuscar = false;
  bool muestraAdd = false;
  GlobalKey<ScaffoldState> myKey = GlobalKey<ScaffoldState>();
  List<String> tipos;

  List<RegistroPlanificado> noPlanificado = new List();

  final _fechaSelect = BehaviorSubject<DateTime>();

  Function(DateTime) get changeFechaSelect => _fechaSelect.sink.add;

  Observable<DateTime> get fechaSelect => _fechaSelect.stream;

  final _semana = BehaviorSubject<List<RegistroPlanificado>>();

  Function(List<RegistroPlanificado>) get changeSemana => _semana.sink.add;

  Observable<List<RegistroPlanificado>> get semana => _semana.stream;

  final _cumplimiento = BehaviorSubject<int>();

  Function(int) get changeCumplimiento => _cumplimiento.sink.add;

  Observable<int> get cumplimiento => _cumplimiento.stream;

  final _selectTipo = BehaviorSubject<String>();

  Function(String) get changeSelectTipo => _selectTipo.sink.add;

  Observable<String> get selectTipo => _selectTipo.stream;

  void cargaSemana() async {
    final int week = Week(date: _fechaSelect.value).getWeekOfYear();
    final int year = _fechaSelect.value.year;
    tipos = new List();

    List<PlanificacionModel> planes = await db.semanaPlanificada(week, year);

    if (planes == null) {
      List<CompromisoModel> compromisos = await db.fetchCompromisos();

      compromisos.removeWhere((compromiso) => compromiso.activo == false);
      for (CompromisoModel compromiso in compromisos) {
        PlanificacionModel plan = PlanificacionModel(
            year, week, compromiso.idCompromiso,
            duracion: compromiso.duracion,
            periodicidad: compromiso.periodicidad,
            comentario: compromiso.comentario,
            stamp: DateTime.now().toUtc().millisecondsSinceEpoch);
        await db.addPlanificacion(plan);
      }
      planes = await db.semanaPlanificada(week, year);
    }

    List<int> cumplimientos = new List();
    List<RegistroPlanificado> registrosPlan = new List();
    for (PlanificacionModel plan in planes) {
      CompromisoModel compromiso = await db.fetchCompromiso(plan.idCompromiso);
      if (!tipos.contains(compromiso.tipo)) {
        tipos.add(compromiso.tipo);
      }

      if (_selectTipo.value == null || _selectTipo.value == compromiso.tipo) {
        cumplimientos = new List();

        for (int dia = 1; (dia < 8); dia++) {
          RegistroModel reg = await db.fetchRegistro(
              Week(dayOfWeek: dia, week: week, year: _fechaSelect.value.year)
                  .getDayFromWeek(),
              plan.idCompromiso);
          if (reg == null) {
            cumplimientos.add(0);
          } else {
            cumplimientos.add(reg.cumplimiento);
          }
        }

        registrosPlan.add(RegistroPlanificado(plan.idCompromiso,
            compromiso.nombre, compromiso.tipo, cumplimientos));
      }
    }
    changeSemana(registrosPlan);
  }

  void cargaMes() async {
    final int week = Week(date: _fechaSelect.value).getWeekOfYear();
    final int year = _fechaSelect.value.year;
    final int mes = _fechaSelect.value.month;
    int lastDay;
    tipos = new List();

    if (mes < 12) {
      lastDay = DateTime(year, mes + 1, 0).day;
    } else {
      lastDay = DateTime(year + 1, 1, 0).day;
    }
    List<CompromisoModel> compromisos = await db.fetchCompromisos();
    List<RegistroPlanificado> registrosPlan = new List();

    List<int> cumplimientos = new List();

    for (CompromisoModel compromiso in compromisos) {
      if (!tipos.contains(compromiso.tipo)) {
        tipos.add(compromiso.tipo);
      }
      if (_selectTipo.value == null || _selectTipo.value == compromiso.tipo) {
        cumplimientos = new List();
        for (int dia = 1; (dia < lastDay + 1); dia++) {
          RegistroModel reg = await db.fetchRegistro(
              DateTime.utc(year, mes, dia), compromiso.idCompromiso);

          if (reg == null) {
            cumplimientos.add(0);
          } else {
            cumplimientos.add(reg.cumplimiento);
          }
        }
        registrosPlan.add(RegistroPlanificado(compromiso.idCompromiso,
            compromiso.nombre, compromiso.tipo, cumplimientos));
      }
    }

    changeSemana(registrosPlan);
  }

  void modificaCumplimiento(int id, int dia) async {
    final int week = Week(date: _fechaSelect.value).getWeekOfYear();
    final int year = _fechaSelect.value.year;
    final DateTime fecha =
        Week(dayOfWeek: dia, week: week, year: year).getDayFromWeek();

    RegistroModel reg = await db.fetchRegistro(fecha, id);

    RegistroModel newReg = RegistroModel(fecha, id, _cumplimiento.value,
        DateTime.now().toUtc().millisecondsSinceEpoch);

    if (_cumplimiento.value == 0) {
      if (reg != null) {
        await db.deleteRegistro(fecha, id);
      }
    } else if (reg == null) {
      await db.addRegistro(newReg);
    } else {
      await db.updateRegistro(newReg);
    }

    cargaSemana();
  }

  Future<int> deletePlan(id) async {
    final int week = Week(date: _fechaSelect.value).getWeekOfYear();
    final int year = _fechaSelect.value.year;

    return await db.deletePlanificacion(year, week, id);
  }

  void cargaNoPlanificado() async {
    final int week = Week(date: _fechaSelect.value).getWeekOfYear();
    final int year = _fechaSelect.value.year;

    List<CompromisoModel> compromisos = await db.fetchCompromisos();

    noPlanificado = new List();

    List<PlanificacionModel> planes = await db.semanaPlanificada(week, year);


    List<int> plani = planes.map((r) => r.idCompromiso).toList();

    for (CompromisoModel compromiso in compromisos) {
      if (!(plani.contains(compromiso.idCompromiso)) &&
          compromiso.activo == true) {
        noPlanificado.add(RegistroPlanificado(compromiso.idCompromiso,
            compromiso.nombre, compromiso.tipo, new List<int>(7)));
      }
    }
  }

  void addPlanificado(RegistroPlanificado regPlan) async {
    final int week = Week(date: _fechaSelect.value).getWeekOfYear();
    final int year = _fechaSelect.value.year;
    CompromisoModel compromiso = await db.fetchCompromiso(regPlan.idCompromiso);
    PlanificacionModel plan = PlanificacionModel(
        year, week, regPlan.idCompromiso,
        duracion: compromiso.duracion,
        periodicidad: compromiso.periodicidad,
        comentario: compromiso.comentario,
        stamp: DateTime.now().toUtc().millisecondsSinceEpoch);
    db.addPlanificacion(plan);
  }

  void editaPlan(int id, context) async {
    final int week = Week(date: _fechaSelect.value).getWeekOfYear();
    final int year = _fechaSelect.value.year;
    CompromisoModel compromiso = await db.fetchCompromiso(id);
    PlanificacionModel plan = await db.fetchPlanificacion(year, week, id);
    compromiso.duracion = plan.duracion;
    compromiso.periodicidad = plan.periodicidad;
    compromiso.comentario = plan.comentario;

    BlocCompromisos blocCompro = ProviderCompromisos.of(context);

    blocCompro.cargaCompromiso(compromiso);
    blocCompro.planificacionEdit = plan;
    Navigator.pushNamed(context, '/planificacionDetalle');
  }

  dispose() {
    _fechaSelect.close();
    _semana.close();
    _cumplimiento.close();
  }
}
