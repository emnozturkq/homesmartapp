import 'package:flutter/material.dart';
import 'package:homesmartapp/utils/sabit.dart';

class OdaWidget extends StatelessWidget {
  const OdaWidget({
    super.key,
    required this.resim,
    required this.baslik,
  });

  final String resim;
  final String baslik;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'images/$resim.png',
                  ),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                  topLeft: Radius.circular(200),
                  topRight: Radius.circular(200),
                ),
                boxShadow: [
                  BoxShadow(
                    color: sabitler.golge,
                    offset: Offset(0, 30),
                    blurRadius: 20,
                    spreadRadius: 10,
                  ),
                ],
              ),
              margin: EdgeInsets.only(top: 30),
            ),
          ),
          SizedBox(height: 40),
          Column(
            children: [
              Row(
                children: [
                  Text(
                    baslik,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
