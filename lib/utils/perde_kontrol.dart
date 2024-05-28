import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:homesmartapp/mqtt/mqtt_manager.dart';
import 'package:homesmartapp/providers/curtain_state.dart';

class PerdeKontrol extends StatefulWidget {
  @override
  _PerdeKontrolState createState() => _PerdeKontrolState();
}

class _PerdeKontrolState extends State<PerdeKontrol> {
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
    mqttManager.subscribeToTopic('curtain');
  }

  void _handleMessage(String topic, String message) {
    if (topic == 'curtain') {
      context.read<CurtainState>().setCurtainState(message.trim() == '1');
    }
  }

  void _toggleCurtain(bool value) {
    context.read<CurtainState>().setCurtainState(value);
    mqttManager.publishMessage('curtain', value ? '1' : '0');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perde Kontrolü'),
        actions: [
          CupertinoSwitch(
            value: context.watch<CurtainState>().isCurtainOpen,
            onChanged: _toggleCurtain,
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Perde kontrol sayfası',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
