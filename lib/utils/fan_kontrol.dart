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
  double temperature = 0.0;
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
    mqttManager.subscribeToTopic('temperature');
  }

  void _handleMessage(String topic, String message) {
    switch (topic) {
      case 'fan':
        context.read<FanState>().setFanState(message.trim() == '1');
        break;
      case 'temperature':
        setState(() {
          temperature = double.tryParse(message.trim()) ?? 0.0;
        });
        break;
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
                      'Sıcaklık',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '${temperature.toStringAsFixed(1)}°C',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 10),
                    Icon(
                      Icons.thermostat_outlined,
                      size: 50,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 40),
            Text(
              'Fan Durumu',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            CupertinoSwitch(
              value: context.watch<FanState>().isFanOn,
              onChanged: _toggleFan,
            ),
          ],
        ),
      ),
    );
  }
}
