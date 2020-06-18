import 'package:flutter/material.dart';
import './widgets/home.dart';

void main() {
  runApp(MyApp());
}

/*

  hiperbole 1 -1 1
  elipse = 21 2 21 32 4 -5

  100 200 100 100 -100

 */

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Análise De Cônicas',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Home(),
    );
  }
}
