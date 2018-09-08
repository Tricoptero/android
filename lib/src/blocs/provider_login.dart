import 'package:flutter/material.dart';
import 'bloc_login.dart';
export 'bloc_login.dart';

class ProviderLogin extends InheritedWidget {
  final bloc = BlocLogin();

  ProviderLogin({Key key, Widget child}) : super(key: key, child: child);

  bool updateShouldNotify(_) => true;

  static BlocLogin of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(ProviderLogin) as ProviderLogin).bloc;
  }
}
