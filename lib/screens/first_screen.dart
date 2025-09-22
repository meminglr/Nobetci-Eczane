import 'package:expressive_loading_indicator/expressive_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:myapp/home_controller.dart';
import 'package:myapp/services/yeni_eczane_service.dart';
import 'package:myapp/widgets/companents.dart';
import 'package:permission_handler/permission_handler.dart';

class FirstScreen extends StatefulWidget {
  final Companents companents;
  final HomeController controller;
  final YeniEczaneService yeniEczaneService;
  const FirstScreen({
    super.key,
    required this.companents,
    required this.controller,
    required this.yeniEczaneService,
  });

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  bool isGettingCityDistrict = false;

  Future<void> _requestLocationPermission() async {
    if (mounted) setState(() {});

    final status = await Permission.location.request();

    if (!mounted) return; // widget hâlâ aktif mi?

    if (status.isGranted) {
      await getCityAndDistrict();
    } else if (status.isDenied || status.isPermanentlyDenied) {
      if (!mounted) return; // yine kontrol
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status.isPermanentlyDenied
                ? 'Konum izni kalıcı olarak reddedildi. Lütfen ayarlarınızı kontrol edin.'
                : 'Konum izni reddedildi. Harita varsayılan konumu gösterecek.',
          ),
        ),
      );
    }

    if (mounted) setState(() {});
  }

  Future<void> getCityAndDistrict() async {
    isGettingCityDistrict = true;
    setState(() {});
    // 2. Konumu al
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
    );

    // 3. Adresi çözümle
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    String formatIlce(String? ilce, String? il) {
      if (ilce == null) return '';
      // Eğer ilçe ismi şehir ismiyle aynı ise "Merkez" olarak değiştir
      if (ilce.contains("$il")) {
        return "Merkez";
      }
      return ilce;
    }

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;

      String? il = place.administrativeArea; // İl
      String? ilce = place.subAdministrativeArea; // İlçe

      widget.controller.secilenSehir = il;
      widget.controller.secilenIlce = formatIlce(ilce, il);
    }

    isGettingCityDistrict = false;
    widget.controller.isFirst = false;
    widget.controller.saveData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Center(
        child: Column(
          spacing: 5,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Nöbetçi Eczane",
              style: TextStyle(
                color: Colors.white,

                fontWeight: FontWeight.w700,
                fontSize: 45,
              ),
              textAlign: TextAlign.center,
            ),
            widget.companents.firstScreenIl(context, widget.controller, () {
              setState(() {});
            }),
            widget.companents.firstScreenIlce(context, widget.controller, () {
              setState(() {});
            }),
            isGettingCityDistrict
                ? SizedBox(
                    child: ExpressiveLoadingIndicator(
                      color: Colors.white,
                      // Accessibility
                      semanticsLabel: 'Loading',
                      semanticsValue: 'In progress',
                    ),
                  )
                : InkWell(
                    onTap: () {
                      _requestLocationPermission();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on, color: Colors.white),
                          Text(
                            "Otomatik Bul",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
