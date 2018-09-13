import 'package:flutter/material.dart';

class MiPrueba extends StatelessWidget {

  Widget build(context) {
    int i = 75;
    return Scaffold(
      appBar: AppBar(title:Text('Prueba')),
      body: MiWidget(value: 75),
    );

  }

}

class MiWidget extends StatelessWidget {

  int value;

  MiWidget({this.value});


  Widget build(context) {

    return GestureDetector(
      child: Container(child:Text('  hola   '),color: Colors.red),
      onTap: () {print(value);},
    );

  }
}