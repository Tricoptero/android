import 'package:flutter/material.dart';
import 'bloc_registro.dart';
export 'bloc_registro.dart';

class ProviderRegistro extends InheritedWidget {
  final bloc = BlocRegistro();

  ProviderRegistro({Key key, Widget child}) : super(key: key, child: child);

  bool updateShouldNotify(_) => true;

  static BlocRegistro of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(ProviderRegistro) as ProviderRegistro).bloc;
  }
}
