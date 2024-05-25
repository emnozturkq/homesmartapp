import 'package:flutter/material.dart';
import 'package:homesmartapp/utils/sabit.dart';
import 'package:homesmartapp/widgets/cihazDugmeleri.dart';
import 'package:homesmartapp/widgets/odaWidget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class AnaSayfa extends StatelessWidget {
  const AnaSayfa({super.key});

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
                            /* OdaWidget(
                              resim: 'bedroom',
                              baslik: 'Yatak Odası',
                            ),
                             OdaWidget(
                              resim: 'kitchen',
                              baslik: 'Mutfak',
                            ),*/
                          ],
                        ),
                      ),
                    ],
                  ),
                  /* Positioned(
                    bottom: 70,
                    child: SmoothPageIndicator(
                      controller: kontrol,
                      count: 1,
                    ),
                  ), */
                ],
              ),
            ),
            SizedBox(height: 30),
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 15,
                  ),
                  itemBuilder: (context, index) => Cihaztus(
                      index: index,
                      icon: tusIcons[index],
                      baslik: tusAd[index]),
                  itemCount: tusIcons.length,
                  physics: NeverScrollableScrollPhysics(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
