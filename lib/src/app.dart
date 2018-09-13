import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'blocs/provider_registro.dart';
import 'blocs/provider_login.dart';
import 'blocs/provider_compromisos.dart';
import 'screens/compromiso_detalle.dart';
import 'screens/main_screen.dart';
import 'screens/compromisos_list.dart';
import 'screens/login_screen.dart';
import 'screens/registro_screen.dart';
import 'package:compromisos/src/demo/date_demo.dart';
import 'package:compromisos/src/demo/prueba.dart';
import 'demo/mi_scrollview.dart';
import 'screens/planificacion_detalle.dart';
import 'screens/registro_mes_screen.dart';

class App extends StatelessWidget {
  Widget build(context) {
    //FocusScope.of(context).requestFocus(new FocusNode());

    return ProviderRegistro(
      child: ProviderLogin(
        child: ProviderCompromisos(
          child: MaterialApp(
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate, // if it's a RTL language
            ],
            supportedLocales: [
              const Locale('es', 'ES'), // include country code too
            ],
            title: 'Compromisos',
            onGenerateRoute: routes,
          ),
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
    } else if (settings.name.contains('/registroMes')) {
      return MaterialPageRoute(
        builder: (context) {
          return RegistroMes();
        },
      );
    } else if (settings.name.contains('/registro')) {
      return MaterialPageRoute(
        builder: (context) {
          return Registro();
        },
      );
    } else if (settings.name.contains('/planificacionDetalle')) {
      return MaterialPageRoute(
        builder: (context) {
          return PlanificacionDetalle();
        },
      );
    }
  }
}
