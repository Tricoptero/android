import 'dart:async';

class Validators {
  
  final validateEmail = StreamTransformer<String, String>.fromHandlers(
    handleData: (email, sink) {
    final String emailRegexp =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    final RegExp regExp = RegExp(emailRegexp);
      if (regExp.hasMatch(email)) {
        sink.add(email);
      } else{
        sink.addError('Introduzca un Email válido');
      }
      }
    );

    final validatePassword = StreamTransformer<String, String>.fromHandlers(
      handleData: (password, sink) {
        if (password.length > 3) {
          sink.add(password);
        } else {
          sink.addError('El password debe tener al menos 4 caracteres');
        }
      }
    );


}




