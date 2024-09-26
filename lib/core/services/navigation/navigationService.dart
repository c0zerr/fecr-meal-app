import 'package:fecrmeal/views/pdfviewer/pdfviewer.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:fecrmeal/core/constants/navigation_constants.dart';
import 'package:fecrmeal/views/ayracsureler/ayracview.dart';
import 'package:fecrmeal/views/favorisureler/favoripage.dart';
import 'package:fecrmeal/views/contactUs/contactuspage.dart';
import 'package:fecrmeal/views/homepage.dart';
import 'package:fecrmeal/views/kuranAydinligi/kuranAydinligi.dart';
import 'package:fecrmeal/views/oku/sureokupage.dart';
import 'package:fecrmeal/views/team/team.dart';
import 'package:fecrmeal/views/tuncerNaml%C4%B1/tuncerNamli.dart';

class NavigationService {
  static List<GetPage> routes = [
    GetPage(
      name: NavigationConstants.home,
      page: () => HomePage(),
    ),
    /* GetPage(
      name: NavigationConstants.pdf,
      page: () => MyPdfViewer(),
    ), */
    GetPage(
      name: NavigationConstants.teamPage,
      page: () => TeamInfoPage(),
    ),
    GetPage(
      name: NavigationConstants.contactUsPage,
      page: () => ContactUsPage(),
    ),
    GetPage(
      name: NavigationConstants.kuranAydinliginaDair,
      page: () => KuranAydinligiPage(),
    ),
    GetPage(
      name: NavigationConstants.tuncerNamliPage,
      page: () => TuncerNamliPage(),
    ),
    GetPage(
      name: NavigationConstants.sureOkuPage,
      page: () => SureOkuPage(),
    ),
    GetPage(
      name: NavigationConstants.sureSavedPage,
      page: () => SavedSurePage(),
    ),
    GetPage(
      name: NavigationConstants.ayracSurePage,
      page: () => AyracSurePage(),
    ),
  ];
}
