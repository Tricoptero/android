import 'package:flutter/material.dart';
import '../blocs/provider_login.dart';


class LoginScreen extends StatelessWidget {
  Widget build(context) {
    final bloc = ProviderLogin.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('Iniciar Sesion')),
      body: Container(
        margin: EdgeInsets.all(20.0),
        child: Column(
          children: [
            emailField(bloc),
            passwordField(bloc),
            recordarField(bloc),
            Container(margin: EdgeInsets.only(top: 20.0)),
            submitButton(bloc),
          ],
        ),
      ),
    );
  }

  Widget emailField(BlocLogin bloc) {
    return StreamBuilder(
      stream: bloc.email,
      builder: (context, snapshot) {
        return TextField(
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'usuario@ejemplo.com',
            labelText: 'Dirección de Email',
            icon: Icon(Icons.email),
            errorText: snapshot.error,
          ),
          onChanged: bloc.changeEmail,
        );
      },
    );
  }

  Widget passwordField(BlocLogin bloc) {
    return StreamBuilder(
      stream: bloc.password,
      builder: (context, snapshot) {
        return TextField(
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Password',
            icon: Icon (Icons.https),
            errorText: snapshot.error,
          ),
          onChanged: bloc.changePassword,
        );
      },
    );
  }

  Widget submitButton(BlocLogin bloc) {
    return StreamBuilder(
        stream: bloc.submitValid,
        builder: (context, snapshot) {
          return RaisedButton(
            child: Text('Login'),
            color: Colors.blue,
            onPressed: !snapshot.hasData ? null : () {
              bloc.submitLogin(context);
            },
          );
        });
  }

  Widget recordarField(BlocLogin bloc) {
    return StreamBuilder(
      stream: bloc.recuerdaEmail,
      builder: (context, snapshot) {
        bool rec = false;
        if (snapshot.hasData) {
          rec = snapshot.data;
        }

        return Row(children: <Widget>[

          Checkbox(
            value: rec,
            onChanged: bloc.changeRecuerdaEmail,
          ),
          Text('Recordar Email'),

        ],
        );
      },
    );
  }
}
