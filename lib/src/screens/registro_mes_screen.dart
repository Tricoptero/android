import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../blocs/provider_registro.dart';

import '../resources/week_utils.dart';
import '../models/registro_planificado.dart';

import '../widgets/cumplimiento.dart';
import 'dart:ui';
import 'dart:async';

class RegistroMes extends StatelessWidget {
  Widget build(context) {
    BlocRegistro bloc = ProviderRegistro.of(context);
    bloc.changeSelectTipo(null);

    return new WillPopScope(
        onWillPop: () {
      return _requestPop(context, bloc);

    },

      child: Scaffold(
      key: bloc.myKey,
      appBar: AppBar(
        title: seleccionFecha(context),
        actions:[
          IconButton(
            tooltip: 'seleccionar',
            icon: Icon(Icons.search),
            onPressed: () {
              buscarControl(context);
            },
          )
        ]
      ),
      body: tablaSemana(context),
    ),
    );
  }

  Future<bool> _requestPop(context, BlocRegistro bloc) {
    if (bloc.flagBuscar != null) {
      if (bloc.flagBuscar) {
        bloc.flagBuscar = false;
        Navigator.pop(context);
      }}
    // Navigator.pop(context);
    return new Future.value(true);

  }


  void buscarControl(context) {
    BlocRegistro bloc = ProviderRegistro.of(context);

    List<DropdownMenuItem> tiposMenu = new List();
    tiposMenu.add(DropdownMenuItem(
      value: null,
      child: Text('Seleccionar Tipo'),
    ));
    bloc.tipos.forEach((tipo) {
      tiposMenu.add(DropdownMenuItem(
        value: tipo,
        child: Text(tipo),
      ));
    });

    if (bloc.flagBuscar) {
      bloc.flagBuscar = false;
      Navigator.pop(context);
    } else {
      bloc.flagBuscar = true;
      bloc.myKey.currentState.showBottomSheet((context) {

        return Container(
          color: Color(0xFFFCFCFF),
          height: 80.0,
          child: Row(
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(
                    left: 16.0,
                  )),
              StreamBuilder(
                stream: bloc.selectTipo,
                builder: (context, snapshot) {
                  return DropdownButton(
                      value: snapshot.data,
                      items: tiposMenu,
                      hint: Text('Seleccionar Tipo'),
                      onChanged: (value) {
                        bloc.changeSelectTipo(value);
                        bloc.cargaMes();
                      });
                },
              ),
            ],
          ),
        );
      });
    }
  }

  Widget seleccionFecha(context) {
    final BlocRegistro bloc = ProviderRegistro.of(context);
    bloc.changeFechaSelect(DateTime.now());
    bloc.cargaMes();
    bloc.changeCumplimiento(0);
    // ignore: conflicting_dart_import
    TextStyle estilo = TextStyle(
      color: Colors.white,
      fontSize: 16.0,
    );


    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      new Expanded(
        flex: 5,
        child: new StreamBuilder(
            stream: bloc.fechaSelect,
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return CircularProgressIndicator();
              }

              return InkWell(
                onTap: () async {
                  final fechaSelect = await showDatePicker(
                      context: context,
                      initialDate: snapshot.data,
                      firstDate: DateTime(2014),
                      lastDate: DateTime(2200));
                  if (fechaSelect != null) {
                    bloc.changeFechaSelect(fechaSelect);
                    bloc.cargaSemana();
                  }
                },
                child: InputDecorator(
                  decoration: new InputDecoration(
                    labelText: DateFormat("EEEEE, d 'de' MMMM", 'es')
                        .format(snapshot.data),
                    labelStyle: TextStyle(),
                  ),
                  baseStyle: estilo,
                  child: new Row(children: [
                    new Text(
                      'Semana ${Week(date: snapshot.data).getWeekOfYear()}/${Week(date: snapshot.data).getWeekYear()}',
                      style: estilo,
                    ),
                    new Icon(Icons.arrow_drop_down,
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.grey.shade200
                            : Colors.white70),
                  ]),
                ),
              );
            }),
      ),
      const SizedBox(width: 2.0),

    ]);
  }

  Widget tablaSemana(context) {
    BlocRegistro bloc = ProviderRegistro.of(context);

    return StreamBuilder(
        stream: bloc.semana,
        builder: (context, AsyncSnapshot<List<RegistroPlanificado>> snapshot) {
          if (snapshot.data == null) {return Container();}
          return OrientationBuilder(builder: (context, orientation) {
            List<Widget> filas = new List();
            List<Widget> titulos = new List();

            Color color;

            titulos.add(
              Container(
                width: orientation == Orientation.portrait ? 140.0 : 200.0,
                color: Colors.indigo.shade100,
                padding: EdgeInsets.only(top: 12.0, bottom: 12.0, left: 8.0),
                child: Text(
                  '(T)ipo Compromiso',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.0),
                ),
              ),
            );

            List<Widget> columnas = new List();

            for (int i = 0; i < snapshot.data[0].cumplimientos.length; i++) {
              columnas.add(Padding(padding: EdgeInsets.only(left: 2.0)));
              columnas.add(
                Container(
                  padding: EdgeInsets.only(top: 12.0, bottom: 12.0),
                  width: orientation == Orientation.portrait ? 22.0 : 28.0,
                  color: Colors.indigo.shade100,
                  child: Center(
                      child: Text('${i+1}',
                    style: TextStyle(fontSize: 12.0),
                  )),
                ),
              );
            }
            filas.add(Row(children: columnas));

            for (RegistroPlanificado reg in snapshot.data) {
              titulos.add(Padding(padding: EdgeInsets.only(top: 2.0)));
              titulos.add(Container(
                  width: orientation == Orientation.portrait ? 140.0 : 200.0,
                  color: Colors.indigo.shade100,
                  padding: EdgeInsets.only(top: 12.0, bottom: 12.0, left: 8.0),
                  child: Text(
                    '${reg.tipo.substring(0,1)} ${reg.nombre}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.0),
                  ),
                ),

              );

              columnas = new List();
              for (int i = 0; i < reg.cumplimientos.length; i++) {

                if (reg.cumplimientos[i] > 50) {
                  color = Colors.blue.shade900;
                } else if (reg.cumplimientos[i] > 0) {
                  color = Colors.blue.shade500;
                } else {
                  color = Colors.blue.shade100;
                }
                columnas.add(Padding(padding: EdgeInsets.only(left: 2.0)));
                columnas.add(
                  Cumplimiento(
                    color: color,
                    padding: EdgeInsets.only(top: 12.0, bottom: 12.0),
                    width: orientation == Orientation.portrait ? 22.0 : 28.0,
                    child: Center(
                      child: Text( ' ',
                        style: TextStyle(fontSize: 12.0),
                      ),
                    ),
                    id: reg.idCompromiso,
                    dia: i+1,
                  ),
                );
              }
              filas.add(Padding(padding: EdgeInsets.only(top: 2.0)));
              filas.add(Row(children: columnas));
            }

            return Container(
             // height: orientation == Orientation.portrait ? 60.0 : 330.0,
              height: (window.physicalSize.height/window.devicePixelRatio),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
         //         height: snapshot.data.length * 46.0,
                  child: Row(children: [
                    Container(
                        width:
                            orientation == Orientation.portrait ? 140.0 : 200.0,
                        child: Column(children: titulos)),
                    Container(
                      width:
                          orientation == Orientation.portrait ?
                          (window.physicalSize.width/window.devicePixelRatio) - 141:
                          (window.physicalSize.width/window.devicePixelRatio) -201,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          width: orientation == Orientation.portrait
                              ? 30.0 * snapshot.data[0].cumplimientos.length
                              : 36.0 * snapshot.data[0].cumplimientos.length,
                          child: Column(
                            children: filas,
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            );
          });
        });
  }
}
