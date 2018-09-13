import 'package:flutter/material.dart';
import '../blocs/provider_registro.dart';

class Cumplimiento extends StatelessWidget {
  final int id;
  final int dia;
  final double width;
  final Color color;
  final Widget child;
  final EdgeInsetsGeometry padding;


  Cumplimiento({this.id, this.dia, this.width, this.child, this.color, this.padding});

  Widget build(context) {
    BlocRegistro bloc = ProviderRegistro.of(context);

    return GestureDetector(
      onTap: () {
        bloc.modificaCumplimiento(id, dia);
      },
      child:Container(
      color: color,
      padding: EdgeInsets.only(top:12.0, bottom: 12.0),
      width: width,
      child: child
      ),
    );
  }


}
