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
  bool motionDetected = false;

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
        if (message.trim() == 'Motion Detected') {
          setState(() {
            motionDetected = true;
            _toggleLight(true);
          });
        } else if (message.trim() == 'Motion not Detected') {
          setState(() {
            motionDetected = false;
            _toggleLight(false);
          });
        }
        break;
    }
  }

  void _toggleLight(bool value) {
    context.read<LightState>().setLightState(value);
    mqttManager.publishMessage('isik', value ? '1' : '0');
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
