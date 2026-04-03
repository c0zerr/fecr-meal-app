import 'package:fecrmeal/core/constants/color_constants.dart';
import 'package:fecrmeal/core/controller/homepageController.dart';
import 'package:fecrmeal/core/services/quran_data_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Merkezi controller'ı buluyoruz
  final HomePageController homePageController = Get.find<HomePageController>();

  // -- Meal Versiyonu (yerel kalsın) --
  int _localVersion = 0;
  int _serverVersion = -1; // -1 = kontrol ediliyor
  bool _isDownloaded = false;

  // -- İndirme durumu --
  bool _isDownloading = false;
  double _downloadProgress = 0;

  @override
  void initState() {
    super.initState();
    _loadVersionInfo();
  }

  Future<void> _loadVersionInfo() async {
    final local = await QuranDataManager.getLocalVersion();
    final downloaded = await QuranDataManager.isDataDownloaded();
    setState(() {
      _localVersion = local;
      _isDownloaded = downloaded;
    });
    final server = await QuranDataManager.getServerVersion();
    setState(() {
      _serverVersion = server;
    });
  }

  Future<void> _downloadOrUpdate() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    final result = await QuranDataManager.checkAndUpdateData(
      onProgress: (p) {
        setState(() => _downloadProgress = p);
      },
    );

    await _loadVersionInfo();
    setState(() => _isDownloading = false);

    if (!mounted) return;
    if (result == "updated") {
      _showSnack("Meal başarı ile güncellendi.", Colors.green);
    } else if (result == "uptodate") {
      _showSnack("Meal başarı ile güncellendi.", Colors.green);
    } else {
      _showSnack("Güncelleme başarısız. İnternet bağlantınızı kontrol edin.", Colors.red);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.primaryColor,
      appBar: AppBar(
        backgroundColor: ColorConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Ayarlar",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _sectionHeader("1. Ayet Kart Görünümü"),

          // --- Meal Metin Boyutu ---
          Obx(() => _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _settingTitle(
                  icon: Icons.text_fields,
                  title: "Meal Metin Boyutu",
                  subtitle: "${homePageController.yazipuntosu.value.round()} Punto",
                ),
                _fontSizeSlider(
                  value: homePageController.yazipuntosu.value,
                  min: 12.0,
                  max: 40.0,
                  divisions: 28,
                  onChanged: (v) => homePageController.yazipuntosu.value = v,
                ),
              ],
            ),
          )),

          const SizedBox(height: 8),

          // --- Arapça Metin Ayarları ---
          Obx(() => _card(
            child: Column(
              children: [
                _switchRow(
                  icon: Icons.format_align_right,
                  label: "Arapça Metin",
                  value: homePageController.arapcametin.value,
                  onChanged: (v) => homePageController.arapcametin.value = v,
                ),
                if (homePageController.arapcametin.value) ...[
                  const Divider(color: Colors.white10),
                  _settingTitle(
                    icon: Icons.text_fields,
                    title: "Arapça Metin Boyutu",
                    subtitle: "${homePageController.arapcaPuntosu.value.round()} Punto",
                  ),
                  _fontSizeSlider(
                    value: homePageController.arapcaPuntosu.value,
                    min: 14.0,
                    max: 50.0,
                    divisions: 36,
                    onChanged: (v) => homePageController.arapcaPuntosu.value = v,
                  ),
                ],
              ],
            ),
          )),

          const SizedBox(height: 8),

          // --- Dipnot Ayarları ---
          Obx(() => _card(
            child: Column(
              children: [
                _switchRow(
                  icon: Icons.notes,
                  label: "Dipnot Metni",
                  value: homePageController.dipnotlar.value,
                  onChanged: (v) => homePageController.dipnotlar.value = v,
                ),
                if (homePageController.dipnotlar.value) ...[
                  const Divider(color: Colors.white10),
                  _settingTitle(
                    icon: Icons.text_fields,
                    title: "Dipnot Metin Boyutu",
                    subtitle: "${homePageController.dipnotPuntosu.value.round()} Punto",
                  ),
                  _fontSizeSlider(
                    value: homePageController.dipnotPuntosu.value,
                    min: 10.0,
                    max: 30.0,
                    divisions: 20,
                    onChanged: (v) => homePageController.dipnotPuntosu.value = v,
                  ),
                ],
              ],
            ),
          )),

          const SizedBox(height: 24),
          _sectionHeader("2. Meal Verisi"),

          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık
                const Row(
                  children: [
                    Icon(Icons.menu_book, color: Color(0xff60A6BB), size: 24),
                    SizedBox(width: 10),
                    Text(
                      "Kur'an Aydınlığı Meal",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Progress bar
                if (_isDownloading) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _downloadProgress > 0 ? _downloadProgress : null,
                      backgroundColor: Colors.white12,
                      color: const Color(0xff60A6BB),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _downloadProgress > 0
                        ? "İndiriliyor... %${(_downloadProgress * 100).round()}"
                        : "Bağlanıyor...",
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                ],

                // Versiyon satırı
                _buildVersionRow(),

                const SizedBox(height: 16),

                // Butonlar
                Row(
                  children: [
                    // İndir / Güncelle butonu
                    Expanded(
                      child: _buildDownloadButton(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildVersionRow() {
    final bool serverKnown = _serverVersion >= 0;
    final bool isUpToDate = serverKnown && _serverVersion <= _localVersion;

    Widget statusWidget;
    if (!serverKnown) {
      statusWidget = const SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white38),
      );
    } else if (isUpToDate) {
      statusWidget = const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: Colors.greenAccent, size: 16),
          SizedBox(width: 4),
          Text("Güncel", style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
        ],
      );
    } else {
      statusWidget = const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.update, color: Colors.orangeAccent, size: 16),
          SizedBox(width: 4),
          Text("Güncelleme var", style: TextStyle(color: Colors.orangeAccent, fontSize: 12)),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white38, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                "Sürüm  Yerel: $_localVersion  |  Sunucu: ${serverKnown ? _serverVersion : '...'}",
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const SizedBox(width: 22),
            statusWidget,
          ],
        ),
      ],
    );
  }

  Widget _buildDownloadButton() {
    final bool serverKnown = _serverVersion >= 0;
    final bool isUpToDate = serverKnown && _serverVersion <= _localVersion;
    final bool needsUpdate = serverKnown && _serverVersion > _localVersion;

    String label;
    IconData icon;
    Color color;

    if (_isDownloading) {
      label = "İndiriliyor...";
      icon = Icons.hourglass_empty;
      color = Colors.white38;
    } else if (isUpToDate) {
      label = "Güncel";
      icon = Icons.check;
      color = Colors.white38;
    } else if (needsUpdate) {
      label = "Güncelle";
      icon = Icons.update;
      color = Colors.orangeAccent;
    } else {
      label = "İndir";
      icon = Icons.download_rounded;
      color = const Color(0xff60A6BB);
    }

    final bool enabled = !_isDownloading && !isUpToDate;

    return ElevatedButton.icon(
      onPressed: enabled ? _downloadOrUpdate : null,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled ? color : Colors.white12,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.white12,
        disabledForegroundColor: Colors.white38,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 0,
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xff60A6BB),
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  Widget _settingTitle({required IconData icon, required String title, required String subtitle}) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xff60A6BB), size: 28),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  Widget _fontSizeSlider({
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        const Text("A", style: TextStyle(color: Colors.white54, fontSize: 12)),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xff60A6BB),
              inactiveTrackColor: const Color(0xff60A6BB).withOpacity(0.25),
              thumbColor: const Color(0xff60A6BB),
              overlayColor: const Color(0xff60A6BB).withOpacity(0.15),
              trackHeight: 3,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ),
        const Text("A", style: TextStyle(color: Colors.white70, fontSize: 22)),
      ],
    );
  }

  Widget _switchRow({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xff60A6BB), size: 22),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 15)),
        const Spacer(),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: const Color(0xff60A6BB),
        ),
      ],
    );
  }
}
