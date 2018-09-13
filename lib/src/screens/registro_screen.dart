import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../blocs/provider_registro.dart';

import '../resources/week_utils.dart';
import '../models/registro_planificado.dart';

import '../widgets/cumplimiento.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:async';

class Registro extends StatelessWidget {
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
      floatingActionButton: new FloatingActionButton(
        child: Icon(Icons.add, size: 40.0,),
          onPressed: () { sumaCompromiso(context);}
                ),
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

    if (bloc.muestraAdd) {return;}

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
                        bloc.cargaSemana();
                      });
                },
              ),
            ],
          ),
        );
      });
    }
  }



  void sumaCompromiso(context) async {



    BlocRegistro bloc = ProviderRegistro.of(context);
    if (bloc.flagBuscar) {
      Navigator.pop(context);
      bloc.flagBuscar = false;
    }


    if (bloc.muestraAdd == true) {
      bloc.muestraAdd = false;
      Navigator.pop(context);
      return;
    }
    bloc.muestraAdd = true;
    await bloc.cargaNoPlanificado();
    bloc.myKey.currentState.showBottomSheet((context) {
      return Container(

      height: 160.0,
      child: ListView.builder(
        itemCount: bloc.noPlanificado.length,
        itemBuilder: (context, index) {
          return Container(
             decoration: BoxDecoration(
              color: Colors.blue,
              border: Border(bottom: BorderSide(color: Colors.white, width: 2.0)),),
          child: ListTile(
            // ignore: conflicting_dart_import
            title: Text(bloc.noPlanificado[index].nombre, style: TextStyle(color:Colors.white),),
            subtitle: Text(bloc.noPlanificado[index].tipo, style: TextStyle(color:Colors.white),) ,
            onTap: () async {
              await bloc.addPlanificado(bloc.noPlanificado[index]);
              await bloc.cargaSemana();
              Navigator.pop(context);
              bloc.muestraAdd = false;
            }
          ),
          );
        }
      ),
      );


    });
  }

  Widget seleccionFecha(context) {
    final BlocRegistro bloc = ProviderRegistro.of(context);
    bloc.changeFechaSelect(DateTime.now());
    bloc.cargaSemana();
    bloc.changeCumplimiento(0);
    TextStyle estilo = TextStyle(
      color: Colors.white,
      fontSize: 16.0,
    );
    TextStyle estiloDrop = TextStyle(
      color: Colors.white,
      fontSize: 12.0,
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
                    labelText: DateFormat("EEEEE, d 'de' MMM", 'es')
                        .format(snapshot.data),
                    labelStyle: estilo,
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
      new Expanded(
        flex: 3,
        child: StreamBuilder(
            stream: bloc.cumplimiento,
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return Container();
              }

              List<DropdownMenuItem> cumplimientoMenu = new List();
              cumplimientoMenu.add(DropdownMenuItem(
                value: 100,
                child: Container(
                    child: Text(
                      'Completado',
                      style: estiloDrop,
                    ),
                    color: Colors.blue.shade900),
              ));
              cumplimientoMenu.add(DropdownMenuItem(
                value: 50,
                child: Container(
                    child: Text('Parcial', style: estiloDrop),
                    color: Colors.blue.shade500),
              ));
              cumplimientoMenu.add(DropdownMenuItem(
                value: 0,
                child: Container(
                    child: Text(
                      'No Cumplido',
                      style: estiloDrop,
                    ),
                    color: Colors.blue.shade100),
              ));

              return InputDecorator(
                decoration: new InputDecoration(
                  labelText: 'Cumplimento',
                  labelStyle: estilo,
                ),
                baseStyle: estiloDrop,
                child: new DropdownButton(
                    value: snapshot.data,
                    elevation: 0,
                    items: cumplimientoMenu,
                    isDense: true,
                    onChanged: (value) => bloc.changeCumplimiento(value)),
              );
            }),
      ),
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
            final List<String> diaTitulo = [
              'Lun',
              'Mar',
              'Mie',
              'Jue',
              'Vie',
              'Sab',
              'Dom'
            ];
            Color color;

            titulos.add(
              Container(
                width: orientation == Orientation.portrait ? 150.0 : 250.0,
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

            for (int i = 0; i < 7; i++) {
              columnas.add(Padding(padding: EdgeInsets.only(left: 2.0)));
              columnas.add(
                Container(
                  padding: EdgeInsets.only(top: 12.0, bottom: 12.0),
                  width: orientation == Orientation.portrait ? 52.0 : 72.0,
                  color: Colors.indigo.shade100,
                  child: Center(
                      child: Text(
                    diaTitulo[i],
                    style: TextStyle(fontSize: 12.0),
                  )),
                ),
              );
            }
            filas.add(Row(children: columnas));

            for (RegistroPlanificado reg in snapshot.data) {
              titulos.add(Padding(padding: EdgeInsets.only(top: 2.0)));
              titulos.add(Slidable(delegate: new SlidableDrawerDelegate(),
                actionExtentRatio: 0.30,

                actions: <Widget>[
                  new SlideAction(
                      child: Icon(Icons.remove_circle_outline, size: 20.0, color: Colors.white),
                      color: Colors.blue,
                      onTap: () {
                        if (bloc.muestraAdd == true) {
                          bloc.muestraAdd = false;
                          Navigator.pop(context);
                        }

                        bloc.deletePlan(reg.idCompromiso).
                        then((onValue) => bloc.cargaSemana());
                      }),
                  new SlideAction(
                      child: Icon(Icons.edit, size: 20.0, color: Colors.white),
                      color: Colors.blue,
                      onTap: () {
                        bloc.editaPlan(reg.idCompromiso, context);
                          }),
                ],
                secondaryActions: <Widget>[
                  new SlideAction(
                      child: Icon(Icons.remove_circle_outline, size: 20.0, color: Colors.white),
                      color: Colors.blue,
                      onTap: () {if (bloc.muestraAdd == true) {
                        bloc.muestraAdd = false;
                        Navigator.pop(context);
                      }

                      bloc.deletePlan(reg.idCompromiso).
                      then((onValue) => bloc.cargaSemana());
                      }),
                  new SlideAction(
                      child: Icon(Icons.edit, size: 20.0, color: Colors.white),
                      color: Colors.blue,
                      onTap: () {
                        bloc.editaPlan(reg.idCompromiso, context);
                      }),
                ],
                child: Container(
                  width: orientation == Orientation.portrait ? 140.0 : 240.0,
                  color: Colors.indigo.shade100,
                  padding: EdgeInsets.only(top: 12.0, bottom: 12.0, left: 8.0),
                  child: Text(
                    '${reg.tipo.substring(0,1)} ${reg.nombre}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.0),
                  ),
                ),
              ),
              );

              columnas = new List();
              for (int i = 0; i < 7; i++) {

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
                    width: orientation == Orientation.portrait ? 52.0 : 72.0,
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
           //   height: orientation == Orientation.portrait ? 600.0 : 330.0,
            //  height: (window.physicalSize.height/window.devicePixelRatio),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
              //    height: snapshot.data.length * 46.0,
                  child: Row(children: [
                    Container(
                        width:
                            orientation == Orientation.portrait ? 140.0 : 240.0,
                        child: Column(children: titulos)),
                    Container(
                      width:
                          orientation == Orientation.portrait ?
                            (window.physicalSize.width/window.devicePixelRatio) - 141:
                            (window.physicalSize.width/window.devicePixelRatio) -241,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          width: orientation == Orientation.portrait
                              ? 60.0 * 7
                              : 80.0 * 7,
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
