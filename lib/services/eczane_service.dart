import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myapp/constants/api_constants.dart';
import 'package:myapp/model/eczane_model.dart';
import 'package:url_launcher/url_launcher.dart';

class EczaneService {
  Future<List<Data>> getEczane(String city, String district) async {
    var response = await http.get(
      Uri.parse("$url&city=$city&district=$district"),
    );
    var responseBody = json.decode(response.body);
    List<Data> eczaneList = [];
    eczaneList =
        responseBody["data"].map<Data>((json) {
          return Data.fromJson(json);
        }).toList();
    return eczaneList;
  }

  Future<void> openMap(  final double latitude,
  final double longitude) async {
    // Platformdan bağımsız geo URI
    final Uri geoUri = Uri.parse("geo:$latitude,$longitude?q=$latitude,$longitude");

    // Önce cihazdaki harita uygulaması açılmaya çalışılır
    if (await canLaunchUrl(geoUri)) {
      await launchUrl(geoUri, mode: LaunchMode.externalApplication);
    } else {
      // Harita uygulaması yoksa tarayıcıda Google Maps açılır
      final Uri googleMapsUrl = Uri.parse(
          "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude");
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    }
  }

    Future<void> makePhoneCall(String phoneNumber) async {
    final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      throw 'Arama başlatılamadı!';
    }
  }

}
