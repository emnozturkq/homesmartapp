import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homesmartapp/providers/curtain_state.dart';
import 'package:homesmartapp/providers/door_state.dart';
import 'package:homesmartapp/providers/fan_state.dart';
import 'package:homesmartapp/providers/light_state.dart'; // Fan durumu eklendi
import 'package:homesmartapp/screens/anasayfa.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CurtainState()),
        ChangeNotifierProvider(create: (_) => DoorState()),
        ChangeNotifierProvider(create: (_) => FanState()),
        ChangeNotifierProvider(create: (_) => LightState())
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home Smart App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AnaSayfa(),
    );
  }
}
