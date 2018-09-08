import 'package:flutter/material.dart';
import '../blocs/provider_compromisos.dart';
import '../models/compromiso_model.dart';
import 'dart:async';

class CompromisosList extends StatelessWidget {
  Widget build(context) {
    BlocCompromisos bloc = ProviderCompromisos.of(context);
    bloc.fetchCompromisos();
    final _myKey = GlobalKey<ScaffoldState>();
    return new WillPopScope(
      onWillPop: () {
        _requestPop(context, bloc);
      },
      child: new Scaffold(
        key: _myKey,
        appBar: AppBar(
            title: Row(children: [
              Icon(Icons.assignment),
              Text('   Compromisos'),
            ]),
            actions: <Widget>[
              IconButton(
                tooltip: 'seleccionar',
                icon: Icon(Icons.search),
                onPressed: () {
                  buscarControl(context, _myKey);
                },
              )
            ]),
        body: Listado(context, bloc),
      ),
    );
  }

  Future<bool> _requestPop(context, bloc) {
    if (bloc.flagBuscar) {
      bloc.flagBuscar = false;
      Navigator.pop(context);
    }
    Navigator.pop(context);
  }

  void buscarControl(context, _myKey) {
    BlocCompromisos bloc = ProviderCompromisos.of(context);

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
      _myKey.currentState.showBottomSheet((context) {
        bloc.changeSelectActivo(false);

        return Container(
          color: Color(0xFFFCFCFF),
          height: 80.0,
          child: Row(
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(
                left: 16.0,
              )),
              Text("Activo"),
              StreamBuilder(
                  stream: bloc.selectActivo,
                  builder: (context, snapshot) {
                    return Checkbox(
                      value: snapshot.data,
                      tristate: true,
                      onChanged: (value) {
                        bloc.changeSelectActivo(value);
                        bloc.seleccionarActivo(value);
                      },
                    );
                  }),
              Padding(
                padding: EdgeInsets.only(left: 16.0),
              ),
              StreamBuilder(
                stream: bloc.selectTipo,
                builder: (context, snapshot) {
                  return DropdownButton(
                      value: snapshot.data,
                      items: tiposMenu,
                      hint: Text('Seleccionar Tipo'),
                      onChanged: (value) {
                        bloc.changeSelectTipo(value);
                        bloc.seleccionarTipo(value);
                      });
                },
              ),
            ],
          ),
        );
      });
    }
  }

  Widget Listado(context, BlocCompromisos bloc) {
    return StreamBuilder(
      stream: bloc.compromisoList,
      builder: (context, AsyncSnapshot<List<CompromisoModel>> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, int index) {
              Duration duracion = snapshot.data[index].duracion;
              String dura =
                  "${(duracion.inHours % 60) < 10 ? 0 : ''}${(duracion.inHours % 60)}h:" +
                      "${(duracion.inMinutes % 60) < 10 ? 0 : ''}${(duracion.inMinutes % 60)}m";
              return GestureDetector(
                onTap: () {
                  bloc.cargaCompromiso(snapshot.data[index]);
                  Navigator.pushNamed(context, '/compromisoDetalle');
                },
                child: Container(
                  margin: EdgeInsets.only(
                      top: 2.0, bottom: 2.0, right: 4.0, left: 4.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 1.0),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 80.0,
                        height: 40.0,
                        padding: EdgeInsets.all(2.0),
                        alignment: Alignment.center,
                        color: Colors.blue,
                        margin: EdgeInsets.all(16.0),
                        child: Text(
                          snapshot.data[index].tipo,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Container(
                        child: Column(
                          children: <Widget>[
                            // Padding(padding: EdgeInsets.only(left:32.0),),

                            Text(
                              snapshot.data[index].nombre,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18.0),
                            ),
                            Padding(padding: EdgeInsets.all(4.0)),
                            Row(
                              children: <Widget>[
                                Text(
                                    ' Duración: $dura     Dias Semana:${snapshot.data[index].periodicidad}'),
                                Checkbox(
                                  value: snapshot.data[index].activo,
                                  onChanged: null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
      },
    );
  }
}
