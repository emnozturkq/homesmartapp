import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homesmartapp/screens/kontrolEkran.dart';
import 'package:homesmartapp/utils/sabit.dart';
import 'package:homesmartapp/mqtt/mqtt_manager.dart';

class Cihaztus extends StatefulWidget {
  Cihaztus({
    Key? key,
    required this.index,
    required this.icon,
    required this.baslik,
    required this.mqttManager,
    required this.topics,
  }) : super(key: key);

  final int index;
  final IconData icon;
  final String baslik;
  final MqttManager mqttManager;
  final List<String> topics;

  @override
  State<Cihaztus> createState() => _CihaztusState();
}

class _CihaztusState extends State<Cihaztus> {
  bool aktiflik = false;

  // Her bir switch için ayrı bool değişkenlerini tanımla
  bool aktiflikForDoor = false;
  bool aktiflikForTemperature = false;
  bool aktiflikForLights = false;
  bool aktiflikForCurtain = false;

  @override
  void initState() {
    super.initState();
    _subscribeToTopics();
  }

  void _subscribeToTopics() {
    widget.mqttManager.onMessageReceived = (topic, message) {
      print('Received message: $message from topic: $topic');
      if (widget.topics.contains(topic)) {
        switch (topic) {
          case 'curtain':
            print('Curtain topic received: $message');
            setState(() {
              aktiflik = message == '1';
            });
            break;
          case 'door':
            print('Door topic received: $message');
            setState(() {
              aktiflikForDoor = message == '1';
            });
            break;
          case 'temperature':
            print('Temperature topic received: $message');
            setState(() {
              aktiflikForTemperature = message == '1';
            });
            break;
          case 'lights':
            print('Lights topic received: $message');
            setState(() {
              aktiflikForLights = message == '1';
            });
            break;
          case 'control_center':
            print('Control Center topic received: $message');
            break;
          default:
            print('Unknown topic: $topic');
        }
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    Color golgeRenk = widget.index == 0 ? sabitler.pembe : sabitler.grirenk;
    Color yaziRenk = widget.index == 0 ? Colors.white : Colors.black;
    return GestureDetector(
      onTap: () {
        if (widget.index == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => KontrolEkran(),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: widget.index == 0 ? sabitler.pembe : null,
          gradient: widget.index == 0
              ? null
              : LinearGradient(
                  colors: [
                    sabitler.golge,
                    sabitler.arkaplan,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.3, 0.6],
                ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: aktiflik
              ? []
              : [
                  BoxShadow(
                    color: golgeRenk,
                    offset: Offset(5, 5),
                    blurRadius: widget.index == 0 ? 20 : 15,
                    spreadRadius: widget.index == 0 ? -5 : 2,
                  ),
                  BoxShadow(
                    color: sabitler.arkaplan,
                    offset: Offset(-5, -5),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            children: [
              Icon(
                widget.icon,
                color: sabitler.grirenk,
              ),
              Text(
                widget.baslik,
                style: TextStyle(
                  color: yaziRenk,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // Her bir switch için ayrı bir CupertinoSwitch ekle
              if (widget.index == 1)
                CupertinoSwitch(
                  value: aktiflikForDoor,
                  onChanged: (value) {
                    setState(() {
                      aktiflikForDoor = value;
                    });
                    // MQTT mesajı gönder
                    String message = value ? '1' : '0';
                    widget.mqttManager.publishMessage('door', message);
                  },
                ),
              if (widget.index == 2)
                CupertinoSwitch(
                  value: aktiflikForTemperature,
                  onChanged: (value) {
                    setState(() {
                      aktiflikForTemperature = value;
                    });
                    // MQTT mesajı gönder
                    String message = value ? '1' : '0';
                    widget.mqttManager.publishMessage('temperature', message);
                  },
                ),
              if (widget.index == 3)
                CupertinoSwitch(
                  value: aktiflikForLights,
                  onChanged: (value) {
                    setState(() {
                      aktiflikForLights = value;
                    });
                    // MQTT mesajı gönder
                    String message = value ? '1' : '0';
                    widget.mqttManager.publishMessage('lights', message);
                  },
                ),
              if (widget.index == 4)
                CupertinoSwitch(
                  value:
                      aktiflikForCurtain, // Değiştirildi: aktiflikForcurtain -> aktiflikForCurtain
                  onChanged: (value) {
                    setState(() {
                      aktiflikForCurtain = value;
                    });
                    // MQTT mesajı gönder
                    String message = value ? '1' : '0';
                    widget.mqttManager.publishMessage('curtain', message);
                  },
                ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ),
      ),
    );
  }
}
