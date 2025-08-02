import 'dart:convert';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/model/sehir_model.dart';
import 'package:myapp/services/eczane_service.dart';
import 'package:myapp/widgets/widgets.dart';
import 'package:drop_down_list/drop_down_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final box = Hive.box('appData');
  List<dynamic> illerListesi = [];
  String? secilenSehir;
  String? secilenIlce;
  List<SelectedListItem<dynamic>> yeniIllerListesi = [];
  List<SelectedListItem<dynamic>> yeniIcelerListesi = [];

  Future<void> illeriGetir() async {
    String jsonString = await rootBundle.loadString('json/il-ilce.json');

    final jsonResponse = json.decode(jsonString);

    illerListesi = jsonResponse.map((x) => Iller.fromJson(x)).toList();
  }

  void modelToString() {
    yeniIllerListesi = [];

    illerListesi.forEach((element) {
      yeniIllerListesi.add(SelectedListItem(data: element.ilAdi));
    });
    setState(() {});
  }

  void secilenIlinIlceleriniGetir(String secilenSehir) {
    yeniIcelerListesi = [];
    illerListesi.forEach((element) {
      if (element.ilAdi == secilenSehir) {
        element.ilceler.forEach((element) {
          yeniIcelerListesi.add(SelectedListItem(data: element.ilceAdi));
        });
      }
    });
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

  void _loadData() {
    illerListesi = box.get('illerListesi', defaultValue: []).cast<String>();
    secilenSehir = box.get('secilenSehir');
    secilenIlce = box.get('secilenIlce');
    yeniIllerListesi =
        (box.get('yeniIllerListesi', defaultValue: []) as List)
            .cast<SelectedListItem>();
    yeniIcelerListesi =
        (box.get('yeniIcelerListesi', defaultValue: []) as List)
            .cast<SelectedListItem>();
    setState(() {});
  }

  void _saveData() {
    box.put('illerListesi', illerListesi);
    box.put('secilenSehir', secilenSehir);
    box.put('secilenIlce', secilenIlce);
    box.put('yeniIllerListesi', yeniIllerListesi);
    box.put('yeniIcelerListesi', yeniIcelerListesi);
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    illeriGetir().then((onValue) => modelToString());
  }

  @override
  Widget build(BuildContext context) {
    EczaneService eczaneService = EczaneService();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,

        centerTitle: true,
        title: Text(
          "Nöbetçi Eczane",
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w700,
            fontSize: 30,
          ),
        ),
        actions: [],
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 5,
              children: [ilSelectButton(context), ilceSelectButton(context)],
            ),

            secilenIlce != null
                ? Expanded(
                  child: Widgets().Future(
                    eczaneService,
                    normalizeToEnglish(secilenSehir!),
                    normalizeToEnglish(secilenIlce!),
                  ),
                )
                : Text("Konum Bilgisi Girin"),
            //EczaneItem(),
          ],
        ),
      ),
    );
  }

  FilledButton ilceSelectButton(BuildContext context) {
    return FilledButton(
      onPressed: () {
        DropDownState(
          dropDown: DropDown(
            searchHintText: "İlçe Ara",
            data: yeniIcelerListesi,
            onSelected: (ilceSelectedItem) {
              secilenIlce = ilceSelectedItem[0].data;
              _saveData();
              setState(() {});
            },
          ),
        ).showModal(context);
      },
      child: Text(secilenIlce == null ? "İlçe Seçiniz" : secilenIlce!),
    );
  }

  FilledButton ilSelectButton(BuildContext context) {
    return FilledButton(
      onPressed: () {
        DropDownState(
          dropDown: DropDown(
            searchHintText: "Şehir Ara",
            data: yeniIllerListesi,
            onSelected: (ilSelectedItem) {
              secilenSehir = ilSelectedItem[0].data;
              secilenIlce = null;
              secilenIlinIlceleriniGetir(secilenSehir!);
              _saveData();
              setState(() {});
            },
          ),
        ).showModal(context);
      },
      child: Text(secilenSehir == null ? "Şehir Seçiniz" : secilenSehir!),
    );
  }
}

class EczaneItem extends StatelessWidget {
  const EczaneItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 100,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: InkWell(
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(20),
                ),
                onTap: () {},
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map_outlined, color: Colors.blue[100]),
                      Text(
                        "Yol Tarifi Al",
                        style: TextStyle(color: Colors.blue[100]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                color: Colors.grey[100],
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Yaprak Eczanesi", style: TextStyle(fontSize: 20)),
                      Text(
                        "Yeşilyurt Mahallesi, Muş-Bitlis Soşesi Caddesi, Aksoy Yapı Altı No:81/4 Merkez / Muş",
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: InkWell(
                borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(20),
                ),
                onTap: () {},
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.call, color: Colors.green[100]),
                      Text("Ara", style: TextStyle(color: Colors.green[100])),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
