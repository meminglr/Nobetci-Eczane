import 'dart:convert';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/model/eczane_model.dart';
import 'package:myapp/model/sehir_model.dart';

class HomeController {
  final box = Hive.box('appData');
  List<dynamic> illerListesi = [];
  String? secilenSehir;
  String? secilenIlce;
  List<SelectedListItem<dynamic>> yeniIllerListesi = [];
  List<SelectedListItem<dynamic>> yeniIcelerListesi = [];
  bool isFirst = true;

  Future<void> illeriGetir() async {
    String jsonString = await rootBundle.loadString('json/il-ilce.json');

    final jsonResponse = json.decode(jsonString);

    illerListesi = jsonResponse.map((x) => Iller.fromJson(x)).toList();
  }

  void modelToString() {
    yeniIllerListesi = [];

    for (var element in illerListesi) {
      yeniIllerListesi.add(SelectedListItem(data: element.ilAdi));
    }
  }

  void secilenIlinIlceleriniGetir(String secilenSehir) {
    yeniIcelerListesi = [];
    for (var element in illerListesi) {
      if (element.ilAdi == secilenSehir) {
        element.ilceler.forEach((element) {
          yeniIcelerListesi.add(SelectedListItem(data: element.ilceAdi));
        });
      }
    }
  }

  String normalizeToEnglish(String input) {
    const Map<String, String> charMap = {
      'ç': 'c',
      'Ç': 'c',
      'ğ': 'g',
      'Ğ': 'g',
      'ı': 'i',
      'İ': 'i',
      'ö': 'o',
      'Ö': 'o',
      'ş': 's',
      'Ş': 's',
      'ü': 'u',
      'Ü': 'u',
    };

    // Her karakteri dönüştür
    String normalized = input
        .split('')
        .map((char) {
          return charMap[char] ?? char;
        })
        .join('');

    return normalized.toLowerCase();
  }

  void loadData() {
    illerListesi = box.get('illerListesi', defaultValue: []).cast<String>();
    secilenSehir = box.get('secilenSehir');
    secilenIlce = box.get('secilenIlce');
    yeniIllerListesi =
        (box.get('yeniIllerListesi', defaultValue: []) as List)
            .cast<SelectedListItem>();
    yeniIcelerListesi =
        (box.get('yeniIcelerListesi', defaultValue: []) as List)
            .cast<SelectedListItem>();

    isFirst = box.get('isFirst', defaultValue: true);
  }

  void saveData() {
    box.put('illerListesi', illerListesi);
    box.put('secilenSehir', secilenSehir);
    box.put('secilenIlce', secilenIlce);
    box.put('yeniIllerListesi', yeniIllerListesi);
    box.put('yeniIcelerListesi', yeniIcelerListesi);
    box.put('isFirst', isFirst);
  }


}
