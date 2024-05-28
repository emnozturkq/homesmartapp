import 'package:flutter/material.dart';
import 'package:homesmartapp/mqtt/mqtt_manager.dart';
import 'dart:async';
import 'package:homesmartapp/screens/kontrolEkran.dart';

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({Key? key}) : super(key: key);

  @override
  _AnaSayfaState createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  late MqttManager mqttManager;
  bool isLightOpen = false;
  bool isFanOpen = false;
  bool isDoorOpen = false;
  bool isCurtainOpen = false;
  double distance = 0.0;
  bool fireDetected = false;
  List<String> messages = [];
  Timer? debounceTimer;

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
    mqttManager.subscribeToTopic('lights');
    mqttManager.subscribeToTopic('temperature');
    mqttManager.subscribeToTopic('door');
    mqttManager.subscribeToTopic('curtain');
    mqttManager.subscribeToTopic('fire');
    mqttManager.subscribeToTopic('fan');
  }

  void _handleMessage(String topic, String message) {
    print('Received message from $topic: $message');
    try {
      if (debounceTimer?.isActive ?? false) debounceTimer!.cancel();
      debounceTimer = Timer(const Duration(milliseconds: 1000), () {
        setState(() {
          switch (topic) {
            case 'lights':
              isLightOpen = message.trim() == '1';
              break;
            case 'temperature':
              final temperature = double.tryParse(message.trim());
              if (temperature != null && temperature > 30) {
                _showTemperatureAlert();
              }
              break;
            case 'door':
              isDoorOpen = message.trim() == '1';
              break;
            case 'curtain':
              isCurtainOpen = message.trim() == '1';
              break;
            case 'fire':
              _showFireAlert();
              break;
            case 'fan':
              isFanOpen = message.trim() == '1';
              break;
            default:
              print('Unknown topic: $topic');
          }
          messages.add('Topic: $topic, Message: $message');
        });
      });
    } catch (e) {
      print('Error parsing message: $e');
    }
  }

  void _showTemperatureAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Uyarı!'),
          content: Text('Oda sıcaklığı 30 derecenin üstünde. Fanı açın.'),
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
        color: Color.fromRGBO(53, 55, 75, 1), // Arka plan rengi
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),
              Center(
                child: _buildControlCenterCard(),
              ),
              SizedBox(height: 20),
              Text(
                'Hoşgeldiniz',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    _buildDeviceCard(
                      'Işık',
                      isLightOpen,
                      Icons.lightbulb,
                      () {
                        setState(() {
                          isLightOpen = !isLightOpen;
                          mqttManager.publishMessage(
                              'lights', isLightOpen ? '1' : '0');
                        });
                      },
                    ),
                    _buildDeviceCard(
                      'Fan',
                      isFanOpen,
                      Icons.ac_unit,
                      () {
                        setState(() {
                          isFanOpen = !isFanOpen;
                          mqttManager.publishMessage(
                              'fan', isFanOpen ? '1' : '0');
                        });
                      },
                    ),
                    _buildDeviceCard(
                      'Oda Kapısı',
                      isDoorOpen,
                      Icons.door_sliding,
                      () {
                        setState(() {
                          isDoorOpen = !isDoorOpen;
                          mqttManager.publishMessage(
                              'door', isDoorOpen ? '1' : '0');
                        });
                      },
                    ),
                    _buildDeviceCard(
                      'Perde',
                      isCurtainOpen,
                      Icons.curtains_closed_rounded,
                      () {
                        setState(() {
                          isCurtainOpen = !isCurtainOpen;
                          mqttManager.publishMessage(
                              'curtain', isCurtainOpen ? '1' : '0');
                        });
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
      color: Color.fromRGBO(241, 241, 241, 1), // Kart rengi
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

  Widget _buildControlCenterCard() {
    return Card(
      color: Color.fromRGBO(241, 241, 241, 1), // Kart rengi
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => KontrolEkran()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kontrol Merkezi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                'Kontrol Merkezi',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 10),
              Icon(
                Icons.control_camera,
                size: 40,
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
