import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fecrmeal/core/constants/color_constants.dart';

class TuncerNamliPage extends StatelessWidget {
  const TuncerNamliPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
        backgroundColor: ColorConstants.primaryColor,
        title: const Text(
          'Tuncer Namlı',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: 'Axiforma',
            fontWeight: FontWeight.w700,
            height: 0,
          ),
        ),
        centerTitle: true,
        leading: IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.arrow_back)),
      ),
      backgroundColor: ColorConstants.primaryColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                // width: 340,
                // height: 1350.h,
                padding: const EdgeInsets.all(25),
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x26000000),
                      blurRadius: 10,
                      offset: Offset(4, 4),
                      spreadRadius: 0,
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 290,
                      height: 38,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 0,
                            child: SizedBox(width: 290, height: 38),
                          ),
                          Positioned(
                            left: 0,
                            top: 0,
                            child: Text(
                              'Tuncer Namlı',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 26,
                                fontFamily: 'Podkova',
                                fontWeight: FontWeight.w700,
                                height: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      width: 290,
                      decoration: const ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 1,
                            strokeAlign: BorderSide.strokeAlignCenter,
                            color: Color(0xFF60A6BB),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: 290,
                      height: 290.19,
                      child: Image.asset("assets/tuncernamli.png"),
                    ),
                    const SizedBox(height: 25),
                    const SizedBox(
                        width: double.infinity,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    '1959 yılında Yozgat’ın Akdağmadeni ilçesinin Kirsinkavağı köyünde doğdu. İlkokulu köyünde okudu ve üç yıl medrese eğitimi aldı. Zile İmam Hatip Lisesi’nde başladığı orta öğrenimini Tokat İmam Hatip Lisesi’nde tamamladı. Erciyes Üniversitesi İlahiyat Fakültesi’nden 1985 yılında mezun oldu. Aynı fakültede İslam Hukuku alanında Yüksek Lisans eğitimi alan Namlı, Prof Dr. Ali Bardakoğlu’nun gözetiminde Tanzimat ve Sonrası Dönem Kanunlaştırma Tartışmaları başlıklı teziyle ilk çalışmasını yaptı (Kayseri, 1988). Çeşitli nedenlerle akademik camiadan uzak düşse de araştırmacı kimliği yakasını bırakmadı. 1986 yılında Alanya’da başlayan çok sevdiği öğretmenlik hayatını on yıl sonra istifa ederek 1995 yılında Yozgat Çayıralan’da noktaladı. Aynı yıl Fecr Yayınevi’nin kültürel araştırmalar biriminde çalışmaya başladı ve uzun süre yayın editörlüğü yaptı. Fecre Doğru dergisinde yazı hayatına başlayan Namlı,  2001 yılında Ahlakî KavramlardaAnlam Arayışı I adlı ilk kitabını yayınladı. Arkadaşlarının talebi üzerine sekiz yıl süren bu meal çalışmasına başlayınca bazı çalışmalarına ara verdi. 14 Temmuz 2011’de Fecr Yayınevi’ndeki görevinden ayrılarak Anadolu İlahiyat Akademisi’nin kurucu Müdürü olarak görev aldı. Halen bu görevine ek olarak araştırmalarını sürdürmektedir.',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontFamily: 'Source Serif Pro',
                                  fontWeight: FontWeight.w400,
                                  height: 0,
                                ),
                              ),
                              TextSpan(
                                text: '',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontStyle: FontStyle.italic,
                                  fontFamily: 'Source Serif Pro',
                                  fontWeight: FontWeight.w400,
                                  height: 0,
                                ),
                              ),
                              TextSpan(
                                text: ' ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontFamily: 'Source Serif Pro',
                                  fontWeight: FontWeight.w400,
                                  height: 0,
                                ),
                              ),
                              TextSpan(
                                text: '',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontStyle: FontStyle.italic,
                                  fontFamily: 'Source Serif Pro',
                                  fontWeight: FontWeight.w400,
                                  height: 0,
                                ),
                              ),
                              TextSpan(
                                text: '',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontFamily: 'Source Serif Pro',
                                  fontWeight: FontWeight.w400,
                                  height: 0,
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
