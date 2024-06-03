import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homesmartapp/mqtt/mqtt_manager.dart';
import 'package:homesmartapp/providers/door_state.dart';

class KapiKontrol extends StatefulWidget {
  @override
  _KapiKontrolState createState() => _KapiKontrolState();
}

class _KapiKontrolState extends State<KapiKontrol> {
  late MqttManager mqttManager;
  double distance = 0.0;

  @override
  void initState() {
    super.initState();
    mqttManager = MqttManager(
      onMessageReceived: _handleMessage,
      onConnected: _onMqttConnected,
    );
    mqttManager.connect();
  }

  void _onMqttConnected() {
    mqttManager.subscribeToTopic('door');
    mqttManager.subscribeToTopic('door_distance');
  }

  void _handleMessage(String topic, String message) {
    switch (topic) {
      case 'door':
        context.read<DoorState>().setDoorState(message.trim() == '1');
        break;
      case 'door_distance':
        double newDistance = double.tryParse(message.trim()) ?? 0.0;
        setState(() {
          distance = newDistance;
        });
        MesafeKontrolKapi(newDistance);
        break;
    }
  }

  void MesafeKontrolKapi(double distance) {
    if (distance < 50.0) {
      _toggleKapi(true);
    } else {
      _toggleKapi(false);
    }
  }

  void _toggleKapi(bool value) {
    context.read<DoorState>().setDoorState(value);
    mqttManager.publishMessage('door', value ? '1' : '0');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kapı Kontrolü'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Mesafe Bilgisi',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '${distance.toStringAsFixed(2)} m',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 10),
                    Icon(
                      Icons.speed,
                      size: 50,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 40),
            Text(
              'Kapı Durumu',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            CupertinoSwitch(
              value: context.watch<DoorState>().isKapiOpen,
              onChanged: _toggleKapi,
            ),
          ],
        ),
      ),
    );
  }
}
