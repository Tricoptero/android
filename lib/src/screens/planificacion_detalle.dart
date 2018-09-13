import 'package:flutter/material.dart';
import '../blocs/provider_compromisos.dart';


class PlanificacionDetalle extends StatelessWidget {
  Widget build(context) {
    BlocCompromisos bloc = ProviderCompromisos.of(context);

    return
      StreamBuilder(stream: bloc.editarCompromiso, builder: (context, editar) {
        if (editar.data == null) {
          return new Container();
        }
        return Scaffold(
          appBar: new AppBar(
            title: Text('Modificar Plan'),

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

              submitButton(context, editar.data),
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
          enabled: false,
          keyboardType: TextInputType.text,
          controller: bloc.controllerNombre,
          style: Theme
              .of(context)
              .textTheme
              .subhead,
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
            fontSize: 14.0,
          ),
        ),);
        children.add(Padding(padding: EdgeInsets.only(left: 16.0)));

          children.add(Text(
            snapshot.data ?? '',
            style: Theme
                .of(context)
                .textTheme
                .subhead,
          ),
          );


        return Row(children: children);
    }
    );

  }

  Widget duracionField(BlocCompromisos bloc, editar) {
    return StreamBuilder(
      stream: bloc.duracion,
      builder: (context, snapshot) {
        return TextField(
          enabled: true,
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
          enabled: true,
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


  Widget comentarioField(BlocCompromisos bloc, editar) {
    return StreamBuilder(
      stream: bloc.comentario,
      builder: (context, snapshot) {
        return
          TextField(
            enabled: true,
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

      return Center(child: RaisedButton(
        child: Text('confirmar'),
        color: Colors.blue,
        onPressed:  () {

              FocusScope.of(context).requestFocus(new FocusNode());
              bloc.submitPlan(context);
            } ,
      ),);
  }

}
