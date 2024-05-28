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
  }

  void _handleMessage(String topic, String message) {
    if (topic == 'door') {
      context.read<DoorState>().setDoorState(message.trim() == '1');
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
        actions: [
          CupertinoSwitch(
            value: context.watch<DoorState>().isKapiOpen,
            onChanged: _toggleKapi,
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Kapı kontrol sayfası',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
