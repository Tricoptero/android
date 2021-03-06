import 'package:flutter/material.dart';
import '../blocs/provider_compromisos.dart';


class CompromisoDetalle extends StatelessWidget {
  Widget build(context) {
    BlocCompromisos bloc = ProviderCompromisos.of(context);

    return
      StreamBuilder(stream: bloc.editarCompromiso, builder: (context, editar) {
        if (editar.data == null) {
          return new Container();
        }
        return Scaffold(
          appBar: new AppBar(
            title: Text('Compromiso'),
            actions: editar.data ?
              null :
            <Widget>[
              IconButton(icon: Icon(Icons.edit), onPressed: () {
                bloc.changeEditarCompromiso(true);
              })
            ],
          ),

          body: ListView(
            children: <Widget>[

              Padding(padding: EdgeInsets.all(4.0)),
              nombreField(bloc, editar.data),
              Padding(padding: EdgeInsets.all(4.0)),
              tipoField(bloc, editar.data),
              Divider(),

              duracionField(bloc, editar.data),
              // Padding(padding: EdgeInsets.all(16.0)),
              periodicidadField(bloc, editar.data),
              // Padding(padding: EdgeInsets.all(16.0)),

              Padding(padding: EdgeInsets.all(4.0)),
              comentarioField(bloc, editar.data),
              Row(children: [activoField(bloc, editar.data),Padding(padding: EdgeInsets.all(32.0),),
              submitButton(context, editar.data)]),
            ],
          ),
        );
      });
  }

  Widget nombreField(BlocCompromisos bloc, bool editar) {
    return StreamBuilder(
      stream: bloc.nombre,
      builder: (context, snapshot) {
        return TextField(
          enabled: editar ? true : false,
          keyboardType: TextInputType.text,
          controller: bloc.controllerNombre,
          style: Theme
              .of(context)
              .textTheme
              .title,
          decoration: InputDecoration(
            hintText: 'Nombre del Compromiso',
            labelText: 'Título',
            icon: Icon(Icons.label_outline),
            errorText: snapshot.error,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(0.0),
            ),
          ),
          onChanged: bloc.changeNombre,
        );
      },
    );
  }

  Widget tipoField(BlocCompromisos bloc, editar) {
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
   tiposMenu.add(DropdownMenuItem(
      value: 'nuevo',
      child: Text('** Nuevo Tipo **'),
    ),
    );


    return StreamBuilder(
      stream: bloc.selectTipo,
      builder: (context, snapshot) {
        List<Widget> children = new List();

        children.add(Padding(padding: EdgeInsets.only(left: 4.0)));
        children.add(Text(
          'Tipo',
          style: TextStyle(
            color: snapshot.error == null ? Colors.black26: Colors.red,
            //fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),);
        children.add(Padding(padding: EdgeInsets.only(left: 16.0)));
        if (editar == true) {
          children.add(DropdownButton(
              value: snapshot.data,
              items: tiposMenu,
              style: Theme
                  .of(context)
                  .textTheme
                  .subhead,
              hint: Text('Seleccionar Tipo'),
              onChanged: (value) {
                bloc.changeSelectTipo(value);
                if (value!='nuevo') {bloc.controllerNuevoTipo = TextEditingController(text: '');}
              }
          ),
          );
           children.add(Padding(padding: EdgeInsets.only(left: 16.0)));
           children.add(
                Container(width:180.0,child:TextField(
                  enabled: snapshot.data == 'nuevo' ? true : false,
                  keyboardType: TextInputType.text,
                  controller: bloc.controllerNuevoTipo,

                  decoration: InputDecoration(
                    hintText: snapshot.data == 'nuevo' ?'Nuevo Tipo': '',
                    icon: Icon(Icons.add),


                  ),
                  onChanged: bloc.changeNuevoTipo,
                ),

            ));


        } else {
          children.add(Text(
            snapshot.data ?? '',
            style: Theme
                .of(context)
                .textTheme
                .subhead,
          ),
          );
        }

        return Row(children: children);
    }
    );

  }

  Widget duracionField(BlocCompromisos bloc, editar) {
    return StreamBuilder(
      stream: bloc.duracion,
      builder: (context, snapshot) {
        return TextField(
          enabled: editar ? true : false,
          keyboardType: TextInputType.text,
          controller: bloc.controllerDuracion,
          decoration: InputDecoration(
            hintText: 'Tiempo dedicado por día',
            labelText: 'Duración',
            icon: Icon(Icons.timer),
            errorText: snapshot.error,

          ),
          onChanged: bloc.changeDuracion,
        );
      },
    );
  }

  Widget periodicidadField(BlocCompromisos bloc, editar) {
    return StreamBuilder(
      stream: bloc.periodicidad,
      builder: (context, snapshot) {
        return TextField(
          enabled: editar ? true : false,
          keyboardType: TextInputType.number,
          controller: bloc.controllerPeriodicidad,
          decoration: InputDecoration(
            hintText: 'Numero de días por semana',
            labelText: 'Periodicidad',
            icon: Icon(Icons.calendar_today),
            errorText: snapshot.error,


          ),
          onChanged: bloc.changePeriodicidad,
        );
      },
    );
  }

  Widget activoField(BlocCompromisos bloc, editar) {
    return Row(
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
                  value: snapshot.data ?? false,
                  tristate: false,
                  onChanged: !editar ? null :
                      (value) {
                    bloc.changeSelectActivo(value);
                  },
                );
              }),
        ]);
  }


  Widget comentarioField(BlocCompromisos bloc, editar) {
    return StreamBuilder(
      stream: bloc.comentario,
      builder: (context, snapshot) {
        return
          TextField(
            enabled: editar ? true : false,
            maxLines: 10,
            keyboardType: TextInputType.multiline,
            controller: bloc.controllerComentario,

            decoration: InputDecoration(
              hintText: 'Comentarios',
              labelText: '  Comentarios  ',
              icon: Icon(Icons.speaker_notes),
              errorText: snapshot.error,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
            ),
            onChanged: bloc.changeComentario,
          );
      },
    );
  }

  Widget submitButton(context, editar) {
    final BlocCompromisos bloc = ProviderCompromisos.of(context);
    /*return   StreamBuilder(
        stream: bloc.submitValid,
        builder: (context, snapshot) { */
    if (editar) {
      return Center(child: RaisedButton(
        child: Text('confirmar'),
        color: Colors.blue,
        onPressed:  () {

              FocusScope.of(context).requestFocus(new FocusNode());
              bloc.submitLogin(context);
            } ,
      ),);
    } else {
      return Container();
    }
    // });
  }

}
