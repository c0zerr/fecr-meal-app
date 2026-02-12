import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:fecrmeal/core/constants/navigation_constants.dart';
import 'package:fecrmeal/views/ayracsureler/ayracview.dart';
import 'package:fecrmeal/views/favorisureler/favoripage.dart';
import 'package:fecrmeal/views/contactUs/contactuspage.dart';
import 'package:fecrmeal/views/homepage.dart';
import 'package:fecrmeal/views/kuranAydinligi/kuranAydinligi.dart';
import 'package:fecrmeal/views/oku/sureokupage.dart';
import 'package:fecrmeal/views/team/team.dart';
import 'package:fecrmeal/views/search/searchPage.dart';
import 'package:fecrmeal/views/tuncerNaml%C4%B1/tuncerNamli.dart';

class NavigationService {
  static List<GetPage> routes = [
    GetPage(
      name: NavigationConstants.home,
      page: () => const HomePage(),
    ),
    /* GetPage(
      name: NavigationConstants.pdf,
      page: () => MyPdfViewer(),
    ), */
    GetPage(
      name: NavigationConstants.teamPage,
      page: () => const TeamInfoPage(),
    ),
    GetPage(
      name: NavigationConstants.contactUsPage,
      page: () => const ContactUsPage(),
    ),
    GetPage(
      name: NavigationConstants.kuranAydinliginaDair,
      page: () => const KuranAydinligiPage(),
    ),
    GetPage(
      name: NavigationConstants.tuncerNamliPage,
      page: () => const TuncerNamliPage(),
    ),
    GetPage(
      name: NavigationConstants.sureOkuPage,
      page: () => const SureOkuPage(),
    ),
    GetPage(
      name: NavigationConstants.sureSavedPage,
      page: () => const SavedSurePage(),
    ),
    GetPage(
      name: NavigationConstants.ayracSurePage,
      page: () => const AyracSurePage(),
    ),
    GetPage(
      name: NavigationConstants.searchPage,
      page: () => const SearchPage(),
    ),
  ];
}
