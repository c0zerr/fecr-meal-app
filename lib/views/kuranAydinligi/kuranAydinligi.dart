import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fecrmeal/core/constants/color_constants.dart';

class KuranAydinligiPage extends StatelessWidget {
  const KuranAydinligiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white, size: 30),
        backgroundColor: ColorConstants.primaryColor,
        title: Text(
          'Kur’an Aydınlığına Dair',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: 'Axiforma',
            fontWeight: FontWeight.w700,
            height: 0,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () => Get.back(), icon: Icon(Icons.arrow_back)),
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
                      // height: 2650.h,
                      padding: const EdgeInsets.all(25),
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        shadows: [
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
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 290,
                                height: 38,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 0,
                                      top: 0,
                                      child: Container(width: 290, height: 38),
                                    ),
                                    Positioned(
                                      left: 0,
                                      top: 0,
                                      child: Text(
                                        'Ön Söz',
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
                                decoration: ShapeDecoration(
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
                                width: double.infinity,
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text:
                                            'Yeryüzündeki yolculuk serüvenimizde bizi kendi sorunlarımızla baş başa bırakmayan, her an yanımızda olduğunu hissettiren, bir mektupla da olsa kendinden haberdar eden, Resul aracılığı ile de olsa muhatap kabul ederek bu kitapla son ahdini bildiren ve yol gösteren bu kutlu sözün sahibine sonsuz hamd ve senalar ediyorum. Yirmi üç yıllık çileli, ıstıraplı ama bir o kadar da başarılı tebliğ mücadelesiyle ilahi seslenişi bize ulaştıran sevgili elçisine, onun aziz arkadaşlarına, bu uğurda mücadele vermiş her ilim adamına ve her mücahide sonsuz salât ve selam ediyorum. Bizi yarattığı, yetiştirdiği ve kutlu vahyinin anlaşılmasına hizmet edenler ordusuna katılma şerefine erdirdiği ve yardımını esirgemediği için aziz Mevla’ya ayrıca minnet, şükür, tesbih ve tazimlerimi arz ediyorum. Başarılarımız da emeğimiz kadar onun lütfudur, kusurlar bize aittir. Şanına yakışır bir hizmet sunamamışsam af ve mağfiret taleplerimi kabul etmesini niyaz ediyorum.\n\nBu şerefli hizmet yolunda yetişmem için bana emek veren ve ahirete irtihal eden annelerime ve babama, yakınlarıma ve değerli hocalarıma şükran duygularımla birlikte rahmet diliyorum. Bu eserin ortaya çıkmasında beni teşvik eden ve yardımlarını esirgemeyen değerli arkadaşlarıma, tashih ve redakte konusunda emek ve desteğini esirgemeyen Prof. Dr. Halit Ünal hocama, Prof. Dr. İbrahim Sarmış, Prof. Dr. Hicabi Kırlangıç, Prof. Dr. Mehmet Ünal, Doç. Dr. Murat Demirkol, Doç. Dr. Enver Arpa, Yard. Doç. Dr. Erdinç Doğru, Yard. Doç. Dr. Murat Özcan üstadlarıma, Av. Ramazan Taşpınar ve Mustafa Demirel ağabeylerime, Cahit Ezerbolatoğlu, Rufi Tiryaki … gibi değerli dostlarıma, eserin mizanpajını gerçekleştiren Mehmet Ali Kırca’ya, tashih ve düzenlemesinden siz değerli okurlarımızın eline ulaşmasına varıncaya dek her aşamada emeği geçen, omuz veren başta çalışma arkadaşım Hüseyin Nazlıaydın olmak üzere Fecr Yayınevinin kurucularına, yönetim kurulu üyelerine, emektar çalışanlarına, ayrıca Anadolu İlahiyat Akademisi yönetim kurulu ve çalışanlarına minnet ve şükranlarımı arz ediyorum.\n\nBu çalışmayı, tashih ve redakte konusunda katkıda bulunan, ömürlerinden aşırdığım günlerin hesabını tutamadığım sevgili eşim Hayriye Hanıma ve bana armağan ettiği üç sevimli yavruya ithaf ediyorum.\nMuhterem okurlarımızın da gördükleri her kusuru işaretleyip yayınevi adresine iletmeleri halinde bize ulaştırdıkları nüsha yerine yenisini göndermeyi taahhüt ettiğimizi bilmelerini isteriz. Rabbimizden göğsümüzü vahyine açmasını ve gereği gibi feyz alıp uygulamamıza yardım etmesini temenni ediyor, hayırlı okumalar ve araştırmalar diliyoruz. Gayret bizden, hedefe vuslat O’ndandır.\n\n',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontFamily: 'Source Serif Pro',
                                          fontWeight: FontWeight.w400,
                                          height: 0,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Tuncer NAMLI\n',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontFamily: 'Source Serif Pro',
                                          fontWeight: FontWeight.w700,
                                          height: 0,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '09 Ekim 2015, Ankara\n',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontStyle: FontStyle.italic,
                                          fontFamily: 'Source Serif Pro',
                                          fontWeight: FontWeight.w400,
                                          height: 0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ]))),
    );
  }
}
