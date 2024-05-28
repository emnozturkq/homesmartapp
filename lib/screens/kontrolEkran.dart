import 'package:flutter/material.dart';
import 'package:homesmartapp/mqtt/mqtt_manager.dart';

class KontrolEkran extends StatefulWidget {
  const KontrolEkran({Key? key}) : super(key: key);

  @override
  _KontrolEkranState createState() => _KontrolEkranState();
}

class _KontrolEkranState extends State<KontrolEkran> {
  late MqttManager mqttManager;
  String distance = 'Bekleniyor...';
  List<String> messages = [];

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
    mqttManager.subscribeToTopic('control_center');
  }

  void _handleMessage(String topic, String message) {
    if (topic == 'control_center') {
      try {
        setState(() {
          distance = 'Mesafe: $message cm';
          messages.add('Mesaj: $message');
        });
      } catch (e) {
        print('Error parsing message: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text('Kontrol Merkezi'),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              distance,
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(messages[index]),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
