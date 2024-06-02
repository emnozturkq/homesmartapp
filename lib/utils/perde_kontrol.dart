import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homesmartapp/mqtt/mqtt_manager.dart';
import 'package:homesmartapp/providers/curtain_state.dart';

class PerdeKontrol extends StatefulWidget {
  @override
  _PerdeKontrolState createState() => _PerdeKontrolState();
}

class _PerdeKontrolState extends State<PerdeKontrol> {
  late MqttManager mqttManager;
  double lightIntensity = 0.0;

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
    mqttManager.subscribeToTopic('light_intensity');
  }

  void _handleMessage(String topic, String message) {
    switch (topic) {
      case 'curtain':
        context.read<CurtainState>().setCurtainState(message.trim() == '1');
        break;
      case 'light_intensity':
        setState(() {
          lightIntensity = double.tryParse(message.trim()) ?? 0.0;
        });
        break;
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
                      'Düşen Işık Miktarı',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '${lightIntensity.toStringAsFixed(2)} lx',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 10),
                    Icon(
                      Icons.wb_sunny,
                      size: 50,
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 40),
            Text(
              'Perde Durumu',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            CupertinoSwitch(
              value: context.watch<CurtainState>().isCurtainOpen,
              onChanged: _toggleCurtain,
            ),
          ],
        ),
      ),
    );
  }
}
