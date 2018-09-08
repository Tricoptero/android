import 'package:flutter/material.dart';



class AppBarIniciar extends AppBar {

  AppBarIniciar(BuildContext context) :
               super(
    title:Text('Gestión de Compromisos'),
    actions: <Widget>[
      IconButton(
        tooltip: 'Iniciar Sesión',
        icon: Icon(Icons.lock),
        onPressed: () {
          Navigator.pushNamed(context, '/login');
        },
      ),

    new PopupMenuButton(
        onSelected: (result) => Navigator.pushNamed(context, '/${result}'),
        itemBuilder: (context) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: 'compromisos',
            child: Text('Compromisos'),
          ),
        ]),
  ]


  );



}
