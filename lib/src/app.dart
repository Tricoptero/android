import 'package:flutter/material.dart';
import 'screens/main_screen.dart';
import 'screens/compromisos_list.dart';
import 'screens/login_screen.dart';
import 'blocs/provider_login.dart';
import 'blocs/provider_compromisos.dart';
import 'screens/compromiso_detalle.dart';

class App extends StatelessWidget {
  Widget build(context) {
    FocusScope.of(context).requestFocus(new FocusNode());
    return ProviderLogin(
      child: ProviderCompromisos (
      child: MaterialApp(
        title: 'Compromisos',
        onGenerateRoute: routes,
      ),
    ),
    );
  }

  Route routes(RouteSettings settings) {

    if (settings.name == "/") {

      return MaterialPageRoute(
        builder: (context) {
        BlocLogin bloc = ProviderLogin.of(context);

        bloc.verUsuario();
        bloc.changeRecuerdaEmail(false);

        return MainScreen();
        },
      );
    } else if (settings.name.contains('/compromisos')) {


      return MaterialPageRoute(
        builder: (context) {
          return CompromisosList();
        },
      );
    } else if (settings.name.contains('/login')) {
      return MaterialPageRoute(
        builder: (context) {
          return LoginScreen();
        },
      );
    } else if (settings.name.contains('/compromisoDetalle')) {
      return MaterialPageRoute(
        builder: (context) {
          return CompromisoDetalle();
        },
      );
    }
  }
}
