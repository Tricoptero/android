import 'dart:async';
import 'validators.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import '../resources/my_preferences.dart';
import '../resources/api_provider.dart';
import '../resources/db_provider.dart';
import '../models/compromiso_model.dart';


class BlocLogin extends Object with Validators {
  final _email = BehaviorSubject<String>();
  final _password = BehaviorSubject<String>();
  final _emailFinal = BehaviorSubject<String>();
  final _recuerdaEmail= BehaviorSubject<bool>();
  final  MyPreferences prefs =  MyPreferences();
  final  myKeyMain = GlobalKey<ScaffoldState>();
  bool sincronizando = false;
  final db = dbProvider;

  String validEmail;
  String validPassword;


  Function(String) get changeEmail => _email.sink.add;
  Stream<String> get email => _email.stream.transform(validateEmail);

  Function(String) get changePassword => _password.sink.add;
  Stream<String> get password => _password.stream.transform(validatePassword);

  Observable<bool> get submitValid =>
      Observable.combineLatest2(email, password, (e, p) => true);

  Function(String) get changeEmailFinal => _emailFinal.sink.add;
  Observable<String> get emailFinal => _emailFinal.stream;

  Function(bool) get changeRecuerdaEmail => _recuerdaEmail.sink.add;
  Observable<bool> get recuerdaEmail => _recuerdaEmail.stream;

  submitLogin (context) async {
    validEmail = _email.value;
    validPassword = _password.value;
    var respuesta = await api.validaUsuario(validEmail, validPassword);

  switch (respuesta.statusCode) {
    case 401:
      changeEmail(validEmail);
      changePassword(validPassword);
      validEmail = null;
      validPassword = null;
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                title: Center(child: Text('Usuario No Valido')),
                actions: [
                  RaisedButton(
                  child: Text('Aceptar'),
                  textColor: Colors.white,
                  color: Colors.blue,
                  onPressed: () {Navigator.pop(context);},
                  ),
                  Padding(padding: EdgeInsets.only(right: 80.0),)
                  ],
            );}
            );
       break;
    case 201:
      changeEmail(validEmail);
      changePassword(validPassword);
      changeEmailFinal(validEmail);
      if (_recuerdaEmail.value)  {prefs.setUsuario(validEmail, validPassword);}
      Navigator.pop(context);
      break;
    default:
      changeEmail(validEmail);
      changePassword(validPassword);
      validEmail = null;
      validPassword = null;
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Center(child: Text('Conexión no válida')),
              content: Text('Intentelo más tarde'),
              actions: [
                RaisedButton(
                  child: Text('Aceptar'),
                  textColor: Colors.white,
                  color: Colors.blue,
                  onPressed: () {Navigator.pop(context);},
                ),
              ],
            );}
      );
      break;
  }
 }



  void verUsuario() async {
    await prefs.init();

    if ((prefs.getEmail() != null)) {
      validEmail = prefs.getEmail();
      validPassword = prefs.getPassword();
      var respuesta = await api.validaUsuario(validEmail, validPassword);

      if (respuesta.statusCode != 201) {
        validEmail = null;
        validPassword = null;
      } else {
        changeEmailFinal(validEmail);
      }
    }
  }

  resetToken(){
    api.token = null;
  }

  void sincronizar(context) async {
    sincronizando = true;
    changeEmailFinal(validEmail);

    int idMax = await db.idCompromisoIni();

    List<CompromisoModel> compromisos = await api.fetchCompromisos();
    compromisos.where((compromiso) => (compromiso.idCompromiso < idMax))
        .toList()
        .forEach((compromiso) => db.addCompromiso(compromiso));
    sincronizando =false;
    changeEmailFinal(validEmail);
    Navigator.pop(context);

  }

  dispose() {
    _email.close();
    _password.close();
  }
}
