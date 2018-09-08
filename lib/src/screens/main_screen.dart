import 'package:flutter/material.dart';
import '../widgets/app_bar_iniciar.dart';
import '../widgets/app_bar_cerrar.dart';
import '../blocs/provider_login.dart';

class MainScreen extends StatelessWidget {
  Widget build(context) {
    BlocLogin bloc = ProviderLogin.of(context);


    return StreamBuilder(
        stream: bloc.emailFinal,
        builder: (context, snapshot) {
          AppBar myAppBar = AppBarIniciar(context);
          if ((snapshot.hasData) && (snapshot.data != null)) {
            myAppBar = AppBarCerrar(context, bloc);
          }

          List<Widget> children = new List();
          children.add(Padding(
            padding: EdgeInsets.all(16.0),
          ));
          children.add(Container(
            padding: EdgeInsets.all(16.0),
            alignment: Alignment.bottomLeft,
            child: Container(
              width: 280.0,
              color: Colors.blue,
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.wb_incandescent, color: Colors.white, size: 30.0),
                  Text(
                    '  Planificacion',
                    style: TextStyle(color: Colors.white, fontSize: 24.0),
                  ),
                ],
              ),
            ),
          ));
          children.add(Padding(
            padding: EdgeInsets.all(16.0),
          ));
          children.add(
            Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.bottomLeft,
              child: Container(
                width: 280.0,
                color: Colors.blue,
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.white, size: 30.0),
                    Text(
                      '  Registro',
                      style: TextStyle(color: Colors.white, fontSize: 24.0),
                    ),
                  ],
                ),
              ),
            ),
          );
          children.add(Padding(
            padding: EdgeInsets.all(16.0),
          ));
          children.add(GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/compromisos');
            },
            child: Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.bottomLeft,
              child: Container(
                  width: 280.0,
                  child: Row(children: [
                    Icon(Icons.assignment, color: Colors.white, size: 30.0),
                    Text(
                      '  Compromisos',
                      style: TextStyle(color: Colors.white, fontSize: 24.0),
                    ),
                  ]),
                  padding: EdgeInsets.all(16.0),
                  color: Colors.blue),
            ),
          ));
          children.add(Padding(
            padding: EdgeInsets.all(32.0),
          ));
          if (bloc.sincronizando) {
            children.add(CircularProgressIndicator());
          }


          return Scaffold(
            key: bloc.myKeyMain,
            appBar: myAppBar,
            body: Center(
              child: Container(
                child: ListView(
                  children: children,
                ),
              ),
            ),
          );
        });
  }
}
