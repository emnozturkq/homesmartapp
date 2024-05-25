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
    required this.topic,
  }) : super(key: key);

  final int index;
  final IconData icon;
  final String baslik;
  final MqttManager mqttManager;
  final String topic;

  @override
  State<Cihaztus> createState() => _CihaztusState();
}

class _CihaztusState extends State<Cihaztus> {
  bool aktiflik = false;

  @override
  void initState() {
    super.initState();
    print('Subscribing to topic: ${widget.topic}');
    widget.mqttManager.subscribeToTopic(widget.topic);
    widget.mqttManager.onMessageReceived = (topic, message) {
      print(
          'onMessageReceived callback invoked for topic $topic with message $message');
      if (topic == widget.topic) {
        print('Updating state for topic $topic with message $message');
        setState(() {
          aktiflik = message == '1';
        });
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
              widget.index == 0
                  ? Container()
                  : CupertinoSwitch(
                      value: aktiflik,
                      onChanged: (value) {
                        setState(() {
                          aktiflik = value;
                        });
                        // MQTT mesajı gönder
                        String message = value ? '1' : '0';
                        print(
                            'Publishing message: $message to topic: ${widget.topic}');
                        widget.mqttManager
                            .publishMessage(widget.topic, message);
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
