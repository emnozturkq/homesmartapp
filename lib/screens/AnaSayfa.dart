import 'package:flutter/material.dart';
import 'package:homesmartapp/utils/sabit.dart';
import 'package:homesmartapp/widgets/cihazDugmeleri.dart';
import 'package:homesmartapp/widgets/odaWidget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:homesmartapp/mqtt/mqtt_manager.dart';

class AnaSayfa extends StatelessWidget {
  final MqttManager mqttManager = MqttManager(
    onConnected: () {
      print('Connected to MQTT broker');
    },
    onMessageReceived: (topic, message) {
      print('Received message: $message from topic: $topic');
    },
  );

  AnaSayfa({super.key}) {
    mqttManager.connect();
  }

  @override
  Widget build(BuildContext context) {
    List<IconData> tusIcons = [
      Icons.tune,
      Icons.lightbulb_outline,
      Icons.light,
      Icons.thermostat,
      Icons.music_note_outlined,
    ];

    List<String> tusAd = [
      'Kontrol\nMerkezi',
      'Işıklar',
      'Sıcaklık',
      'Oda Kapısı',
      'Perde',
    ];

    List<String> topics = [
      'control_center',
      'lights',
      'temperature',
      'door',
      'curtain',
    ];

    PageController kontrol = PageController();
    return Scaffold(
      backgroundColor: sabitler.arkaplan,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: PageView(
                          controller: kontrol,
                          children: [
                            OdaWidget(
                              resim: 'living_room',
                              baslik: 'Salon',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 15,
                  ),
                  itemBuilder: (context, index) => Cihaztus(
                    index: index,
                    icon: tusIcons[index],
                    baslik: tusAd[index],
                    mqttManager: mqttManager,
                    topic: topics[index],
                  ),
                  itemCount: tusIcons.length,
                  physics: const NeverScrollableScrollPhysics(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
