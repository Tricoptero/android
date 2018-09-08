import 'package:flutter/material.dart';
import '../blocs/provider_login.dart';

class AppBarCerrar extends AppBar {

  AppBarCerrar(BuildContext context,BlocLogin bloc) :
               super(
    title:Text('Gestión de Compromisos'),
    actions: <Widget>[
      IconButton(
        tooltip: 'Sincronizar',
        icon: Icon(Icons.cloud_circle),
        onPressed: () {
          sincronizar(context);
        },
      ),
      IconButton(
        tooltip: 'Cerrar Sesión',
        icon: Icon(Icons.lock_open),
        onPressed: () => confirmarCerrar(context),
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

 static confirmarCerrar(context) {

    showDialog(
        context: context,
        builder: (context) {
          BlocLogin bloc = ProviderLogin.of(context);

          return AlertDialog(
            title: Center(child: Text('Cerrar Sesion')),
            actions: [

              RaisedButton(
                child: Text('Confirmar'),
                textColor: Colors.white,
                color: Colors.blue,
                onPressed: () {
                  bloc.validEmail = null;
                  bloc.validPassword = null;
                  bloc.resetToken();
                  bloc.changeEmailFinal(null);
                  bloc.changeRecuerdaEmail(false);
                  bloc.prefs.removeUsuario();

                  Navigator.pop(context);
                },
              ),
              Padding(padding: EdgeInsets.only(right: 20.0)),
              RaisedButton(
                child: Text('Cancelar'),
                textColor: Colors.white,
                color: Colors.blue,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              Padding(padding: EdgeInsets.only(right: 25.0))
            ],


          );
        });
  }

  static sincronizar(context){
    BlocLogin bloc = ProviderLogin.of(context);
   /* bloc.myKeyMain.currentState.showSnackBar(
        SnackBar(
            backgroundColor: Colors.white,
            content: Center(child:CircularProgressIndicator(backgroundColor: Colors.blue,),
                    ),
        ),
    );*/

    bloc.myKeyMain.currentState.showBottomSheet((context) {

      bloc.sincronizar(context);


    });


  }

}
