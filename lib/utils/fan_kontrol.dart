import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homesmartapp/mqtt/mqtt_manager.dart';
import 'package:homesmartapp/providers/fan_state.dart';

class FanKontrol extends StatefulWidget {
  @override
  _FanKontrolState createState() => _FanKontrolState();
}

class _FanKontrolState extends State<FanKontrol> {
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
    if (topic == 'fan') {
      context.read<FanState>().setFanState(message.trim() == '1');
    }
  }

  void _toggleFan(bool value) {
    context.read<FanState>().setFanState(value);
    mqttManager.publishMessage('fan', value ? '1' : '0');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fan Kontrolü'),
        actions: [
          CupertinoSwitch(
            value: context.watch<FanState>().isFanOn,
            onChanged: _toggleFan,
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Fan kontrol sayfası',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
