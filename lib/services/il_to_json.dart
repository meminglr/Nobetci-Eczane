import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:myapp/model/sehir_model.dart';

class IlToJson {
  Future<List<dynamic>> illeriGetir() async {
    List<dynamic> illerListesi = [];
    String jsonString = await rootBundle.loadString('json/il-ilce.json');

    final jsonResponse = json.decode(jsonString);

    illerListesi = jsonResponse.map((x) => Iller.fromJson(x)).toList();
    return illerListesi;
  }


}
