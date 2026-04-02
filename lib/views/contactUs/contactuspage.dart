import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fecrmeal/core/constants/color_constants.dart';
import 'package:fecrmeal/views/contactUs/widgets/textfield.dart';
import 'package:fecrmeal/widgets/whitetext.dart';
import 'package:dio/dio.dart' as dio_pkg;

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController isimsoyisim = TextEditingController();

    TextEditingController email = TextEditingController();
    TextEditingController aciklamalar = TextEditingController();

    Future<void> sendEmailJS(String adsoyad, String eposta, String mesaj) async {
      // Show loading
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.white)),
        barrierDismissible: false,
      );

      final dio = dio_pkg.Dio();
      const String serviceId = 'service_8w2okte';
      const String templateId = 'template_gminyi9';
      const String publicKey = 'snei93tuGLkGcVKfr';

      try {
        final response = await dio.post(
          'https://api.emailjs.com/api/v1.0/email/send',
          options: dio_pkg.Options(
            headers: {
              'origin': 'http://localhost',
              'Content-Type': 'application/json',
            },
          ),
          data: {
            'service_id': serviceId,
            'template_id': templateId,
            'user_id': publicKey,
            'template_params': {
              'title': 'FecrMeal Görüş ve Öneriler',
              'name': adsoyad,
              'time': DateTime.now().toLocal().toString().substring(0, 16),
              'message': 'E-Posta: $eposta\n\nMesaj:\n$mesaj',
            },
          },
        );

        Get.back(); // Close loading

        if (response.statusCode == 200) {
          _showAlertDialog(context, "TEŞEKKÜR EDERİZ!", "Değerli görüş ve önerilerinizi bizimle paylaştığınız için teşekkür ederiz.");
          email.clear();
          isimsoyisim.clear();
          aciklamalar.clear();
        } else {
          _showAlertDialog(context, "Hata", "Mesaj gönderilemedi. Lütfen daha sonra tekrar deneyin. (Kod: ${response.statusCode})");
        }
      } catch (e) {
        Get.back(); // Close loading
        _showAlertDialog(context, "Hata", "Bir sorun oluştu: $e");
      }
    }

    return Scaffold(
      backgroundColor: ColorConstants.primaryColor,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
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
              icon: const Icon(
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
            const WhiteText(
              text: "Ad ve Soyad *",
            ),
            SizedBox(
              height: 15.h,
            ),
            CustomTextfield(text: "Adınızı ve Soyadınızı Girin", controller: isimsoyisim),
            const SizedBox(
              height: 43,
            ),
            const WhiteText(
              text: "E-Posta * ",
            ),
            SizedBox(
              height: 15.h,
            ),
            CustomTextfield(text: "E-Postanızı Girin", controller: email),
            const SizedBox(
              height: 43,
            ),
            Container(
              padding: const EdgeInsets.only(right: 15, top: 8),
              decoration: BoxDecoration(
                color: Colors.white, // Arka plan rengi beyaz
                borderRadius: BorderRadius.circular(15.0), // Yuvarlak kenarlık
              ),
              child: TextField(
                controller: aciklamalar,
                maxLines: 7, // 7 satırlık metin alanı
                decoration: InputDecoration(
                  hintText: "Görüş ve Önerilerinizi Girin",
                  hintStyle: const TextStyle(
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
              child: SizedBox(
                // width: 132, // Genişlik
                height: 60, // Yükseklik
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(const Color(0xFFE86014)),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Yuvarlak köşe
                      ),
                    ),
                  ),
                  onPressed: () {
                    if (isimsoyisim.text == "") {
                      _showAlertDialog(context, "LÜTFEN\nEKSİK YERLERİ DOLDURUN", "İsim ve Soyisim \nBilginizi girin. ");
                    } else if (email.text == "") {
                      _showAlertDialog(context, "LÜTFEN\nEKSİK YERLERİ DOLDURUN", "E-Posta \nAdresinizi girin.");
                    } else if (aciklamalar.text == "") {
                      _showAlertDialog(context, "LÜTFEN\nEKSİK YERLERİ DOLDURUN", "Açıklamanızı girin.");
                    } else {
                      sendEmailJS(isimsoyisim.text, email.text, aciklamalar.text);
                    }
                  },
                  child: const Text(
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
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8, // Boyutu arttır
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(
                  height: 10,
                ),
                Text(
                  text1,
                  style: const TextStyle(
                    color: Colors.black, // Text1 rengi
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Divider(
                  color: Colors.black,
                  thickness: 1,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  text2,
                  style: const TextStyle(
                    color: Colors.black, // Text2 rengi
                    fontWeight: FontWeight.normal,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(
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
