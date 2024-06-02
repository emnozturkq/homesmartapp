import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homesmartapp/mqtt/mqtt_manager.dart';
import 'package:homesmartapp/providers/light_state.dart';

class IsikKontrol extends StatefulWidget {
  @override
  _IsikKontrolState createState() => _IsikKontrolState();
}

class _IsikKontrolState extends State<IsikKontrol> {
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
    mqttManager.subscribeToTopic('isik');
    mqttManager.subscribeToTopic('lights_distance');
  }

  void _handleMessage(String topic, String message) {
    switch (topic) {
      case 'isik':
        context.read<LightState>().setLightState(message.trim() == '1');
        break;
      case 'lights_distance':
        setState(() {
          distance = double.tryParse(message.trim()) ?? 0.0;
        });
        break;
    }
  }

  void _toggleLight(bool value) {
    context.read<LightState>().setLightState(value);
    mqttManager.publishMessage('lights', value ? '1' : '0');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Işık Kontrolü'),
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
              'Işık Durumu',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            CupertinoSwitch(
              value: context.watch<LightState>().isLightOpen,
              onChanged: _toggleLight,
            ),
          ],
        ),
      ),
    );
  }
}
