import 'package:fecrmeal/core/constants/color_constants.dart';
import 'package:fecrmeal/core/constants/navigation_constants.dart';
import 'package:fecrmeal/views/pdfviewer/pdfviewer.dart';
import 'package:fecrmeal/widgets/drawerCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({
    super.key,
  });

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String pathPDF = "";
  String corruptedPathPDF = "";
  @override
  void initState() {
    fromAsset('assets/Kahakkinda.pdf', 'Kahakkinda.pdf').then((f) {
      setState(() {
        corruptedPathPDF = f.path;
      });
    });
    super.initState();
  }

  Future<File> fromAsset(String asset, String filename) async {
    // To open from assets, you can copy them to the app storage folder, and the access them "locally"
    Completer<File> completer = Completer();

    try {
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/$filename");
      var data = await rootBundle.load(asset);
      var bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }

    return completer.future;
  }

  Future<File> createFileOfPdfUrl() async {
    Completer<File> completer = Completer();
    print("Start download file from internet!");
    try {
      // "https://berlin2017.droidcon.cod.newthinking.net/sites/global.droidcon.cod.newthinking.net/files/media/documents/Flutter%20-%2060FPS%20UI%20of%20the%20future%20%20-%20DroidconDE%2017.pdf";
      // final url = "https://pdfkit.org/docs/guide.pdf";
      const url = "http://www.pdf995.com/samples/pdf.pdf";
      final filename = url.substring(url.lastIndexOf("/") + 1);
      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      var dir = await getApplicationDocumentsDirectory();
      print("Download files");
      print("${dir.path}/$filename");
      File file = File("${dir.path}/$filename");

      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.90,
      backgroundColor: ColorConstants.primaryColor,
      child: Padding(
        padding: EdgeInsets.only(left: 15.w),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 60.h,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              height: 100.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    "assets/icon/mainicon.png", // Adjust image path
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Color(0xff60A6BB),
                      size: 30,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 40.h,
            ),
            DrawerCards(
                title: "Kaldığım Yer",
                imageUrl: "assets/icon/kayit.png",
                ontap: () {
                  Get.toNamed(
                    NavigationConstants.ayracSurePage,
                  );
                }),
            DrawerCards(
                title: "Favoriler Ayetlerim",
                imageUrl: "assets/icon/favori.png",
                ontap: () {
                  Get.toNamed(
                    NavigationConstants.sureSavedPage,
                  );
                }),
            const SizedBox(
              height: 15,
            ),
            DrawerCards(
                title: "Önsöz  ",
                imageUrl: "assets/icon/info.png",
                ontap: () {
                  Get.toNamed(
                    NavigationConstants.kuranAydinliginaDair,
                  );
                }),
            DrawerCards(
              title: "Kur’an Aydınlığına Dair",
              imageUrl: "assets/icon/info.png",
              ontap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PDFScreen(path: corruptedPathPDF),
                  ),
                );
              },
            ),
            DrawerCards(
                title: "Tuncer Namlı",
                imageUrl: "assets/icon/user.png",
                ontap: () {
                  Get.toNamed(
                    NavigationConstants.tuncerNamliPage,
                  );
                }),
            const SizedBox(
              height: 15,
            ),
            DrawerCards(
                title: "Görüş ve Önerileriniz",
                imageUrl: "assets/icon/ulasin.png",
                ontap: () {
                  Get.toNamed(
                    NavigationConstants.contactUsPage,
                  );
                }),
            DrawerCards(
                title: "Ekip",
                imageUrl: "assets/icon/team.png",
                ontap: () {
                  Get.toNamed(
                    NavigationConstants.teamPage,
                  );
                }),
          ],
        ),
      ),
    );
  }
}
