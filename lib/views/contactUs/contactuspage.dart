import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fecrmeal/core/constants/color_constants.dart';
import 'package:fecrmeal/views/contactUs/widgets/textfield.dart';
import 'package:fecrmeal/widgets/whitetext.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController isimsoyisim = TextEditingController();

    TextEditingController email = TextEditingController();
    TextEditingController aciklamalar = TextEditingController();

    String? encodeQueryParameters(Map<String, String> params) {
      return params.entries
          .map((MapEntry<String, String> e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
    }

    Future<void> _launchEmail(String adsoyad, String text) async {
      final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: 'fcr@fcr.com.tr',
        queryParameters: {'subject': 'FecrMeal', 'body': '$adsoyad/n$text'},
      );

      try {
        if (await canLaunchUrl(emailLaunchUri)) {
          await launchUrl(emailLaunchUri);
        } else {
          _showAlertDialog(context, "Email Client Not Found",
              "Please ensure you have an email app installed to send an email.");
        }
      } catch (e) {
        _showAlertDialog(context, "Error", "Unable to launch email: $e");
      }
    }

    return Scaffold(
      backgroundColor: ColorConstants.primaryColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Görüş ve Önerileriniz',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: 'Axiforma',
            fontWeight: FontWeight.w700,
            height: 0,
          ),
        ),
        toolbarHeight: 80,
        backgroundColor: ColorConstants.primaryColor,
        leading: Padding(
          padding: const EdgeInsets.all(0.0),
          child: IconButton(
              onPressed: () => Get.back(),
              icon: Icon(
                Icons.arrow_back,
                size: 30,
                color: ColorConstants.whiteColor,
              )),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(left: 25.w, right: 25.w, top: 20),
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            WhiteText(
              text: "Ad ve Soyad *",
            ),
            SizedBox(
              height: 15.h,
            ),
            CustomTextfield(
                text: "Adınızı ve Soyadınızı Girin", controller: isimsoyisim),
            SizedBox(
              height: 43,
            ),
            WhiteText(
              text: "E-Posta * ",
            ),
            SizedBox(
              height: 15.h,
            ),
            CustomTextfield(text: "E-Postanızı Girin", controller: email),
            SizedBox(
              height: 43,
            ),
            Container(
              padding: EdgeInsets.only(right: 15, top: 8),
              decoration: BoxDecoration(
                color: Colors.white, // Arka plan rengi beyaz
                borderRadius: BorderRadius.circular(15.0), // Yuvarlak kenarlık
              ),
              child: TextField(
                controller: aciklamalar,
                maxLines: 7, // 7 satırlık metin alanı
                decoration: InputDecoration(
                  hintText: "Görüş ve Önerilerinizi Girin",
                  hintStyle: TextStyle(
                    color: ColorConstants.primaryColor3,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide.none, // Kenarlıkları kaldır
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 60.h,
            ),
            Align(
              alignment: Alignment.centerLeft, // Butonu sola hizalar
              child: Container(
                // width: 132, // Genişlik
                height: 60, // Yükseklik
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Color(0xFFE86014)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Yuvarlak köşe
                      ),
                    ),
                  ),
                  onPressed: () {
                    if (isimsoyisim.text == "") {
                      _showAlertDialog(
                          context,
                          "LÜTFEN\nEKSİK YERLERİ DOLDURUN",
                          "İsim ve Soyisim \nBilginizi girin. ");
                    } else if (email.text == "") {
                      _showAlertDialog(
                          context,
                          "LÜTFEN\nEKSİK YERLERİ DOLDURUN",
                          "E-Posta \nAdresinizi girin.");
                    } else if (aciklamalar.text == "") {
                      _showAlertDialog(
                          context,
                          "LÜTFEN\nEKSİK YERLERİ DOLDURUN",
                          "Açıklamanızı girin.");
                    } else {
                      _launchEmail(
                          "${aciklamalar.text}", "${isimsoyisim.text}");
                      _showAlertDialog(context, "TEŞEKKÜR EDERİZ!",
                          "Değerli görüş ve önerilerinizi bizimle paylaştığınız için teşekkür ederiz. ");
                      email.clear();
                      isimsoyisim.clear();
                    }
                  },
                  child: Text(
                    "GÖNDER",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'Axiforma',
                      fontWeight: FontWeight.w700,
                      height: 0,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }

  void _showAlertDialog(BuildContext context, String text1, String text2) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          surfaceTintColor: Colors.white,
          // backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8, // Boyutu arttır
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                Text(
                  text1,
                  style: TextStyle(
                    color: Colors.black, // Text1 rengi
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(
                  color: Colors.black,
                  thickness: 1,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  text2,
                  style: TextStyle(
                    color: Colors.black, // Text2 rengi
                    fontWeight: FontWeight.normal,
                    fontSize: 17,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
