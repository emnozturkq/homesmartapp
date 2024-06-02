import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homesmartapp/mqtt/mqtt_manager.dart';
import 'package:homesmartapp/providers/fan_state.dart';
import 'package:homesmartapp/providers/door_state.dart';
import 'package:homesmartapp/providers/light_state.dart';
import 'package:homesmartapp/utils/fan_kontrol.dart';
import 'package:homesmartapp/utils/kapi_kontrol.dart';
import 'package:homesmartapp/utils/isik_kontrol.dart';

class AnaSayfa extends StatefulWidget {
  @override
  _AnaSayfaState createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
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
    mqttManager.subscribeToTopic('isik');
    mqttManager.subscribeToTopic('temperature');
    mqttManager.subscribeToTopic('door');
    mqttManager.subscribeToTopic('alarm');
    mqttManager.subscribeToTopic('fan');
  }

  void _handleMessage(String topic, String message) {
    switch (topic) {
      case 'fan':
        context.read<FanState>().setFanState(message.trim() == '1');
        break;
      case 'isik':
        context.read<LightState>().setLightState(message.trim() == '1');
        break;
      case 'door':
        context.read<DoorState>().setDoorState(message.trim() == '1');
        break;
      case 'alarm':
        _showFireAlert();
        break;
      default:
        print('Unknown topic: $topic');
    }
  }

  void _showFireAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Yangın Alarmı!'),
          content: Text('Yangın tespit edildi. Lütfen güvenli bir yere geçin.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color.fromRGBO(53, 55, 75, 1),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),
              Text(
                'Ev Kontrol Paneli',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    _buildDeviceCard(
                      'Işık',
                      context.watch<LightState>().isLightOpen,
                      Icons.lightbulb,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => IsikKontrol()),
                        );
                      },
                    ),
                    _buildDeviceCard(
                      'Fan',
                      context.watch<FanState>().isFanOn,
                      Icons.ac_unit,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => FanKontrol()),
                        );
                      },
                    ),
                    _buildDeviceCard(
                      'Oda Kapısı',
                      context.watch<DoorState>().isKapiOpen,
                      Icons.door_sliding,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => KapiKontrol()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceCard(
    String title,
    bool isOn,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      color: Color.fromRGBO(241, 241, 241, 1),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                isOn ? 'AÇIK' : 'KAPALI',
                style: TextStyle(
                  fontSize: 16,
                  color: isOn ? Colors.green : Colors.red,
                ),
              ),
              SizedBox(height: 10),
              Icon(
                icon,
                size: 40,
                color: isOn ? Colors.green : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
