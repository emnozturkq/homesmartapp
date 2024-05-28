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
    mqttManager.subscribeToTopic('fan');
  }

  void _handleMessage(String topic, String message) {
    if (topic == 'light') {
      context.read<LightState>().setLightState(message.trim() == '1');
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
        actions: [
          CupertinoSwitch(
            value: context.watch<LightState>().isLightOpen,
            onChanged: _toggleLight,
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Işık kontrol sayfası',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
