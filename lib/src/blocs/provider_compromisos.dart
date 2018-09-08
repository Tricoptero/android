import 'package:flutter/material.dart';
import 'bloc_compromisos.dart';
export 'bloc_compromisos.dart';

class ProviderCompromisos extends InheritedWidget {
  final bloc = BlocCompromisos();

  ProviderCompromisos({Key key, Widget child}) : super(key: key, child: child);

  bool updateShouldNotify(_) => true;

  static BlocCompromisos of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(ProviderCompromisos) as ProviderCompromisos).bloc;
  }
}
