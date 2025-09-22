import 'package:hive/hive.dart';
part 'sehir_model.g.dart';

@HiveType(typeId: 1)
class Iller {
  @HiveField(0)
  String? ilAdi;
  @HiveField(1)
  String? plakaKodu;
  @HiveField(2)
  List<Ilceler>? ilceler;
  @HiveField(3)
  String? kisaBilgi;

  Iller({this.ilAdi, this.plakaKodu, this.ilceler, this.kisaBilgi});

  Iller.fromJson(Map<String, dynamic> json) {
    ilAdi = json['il_adi'];
    plakaKodu = json['plaka_kodu'];
    if (json['ilceler'] != null) {
      ilceler = <Ilceler>[];
      json['ilceler'].forEach((v) {
        ilceler!.add(Ilceler.fromJson(v));
      });
    }
    kisaBilgi = json['kisa_bilgi'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['il_adi'] = ilAdi;
    data['plaka_kodu'] = plakaKodu;
    if (ilceler != null) {
      data['ilceler'] = ilceler!.map((v) => v.toJson()).toList();
    }
    data['kisa_bilgi'] = kisaBilgi;
    return data;
  }
}

@HiveType(typeId: 2)
class Ilceler {
  @HiveField(0)
  String? ilceAdi;
  @HiveField(1)
  String? nufus;
  @HiveField(2)
  String? erkekNufus;
  @HiveField(3)
  String? kadinNufus;
  @HiveField(4)
  String? yuzolcumu;

  Ilceler({
    this.ilceAdi,
    this.nufus,
    this.erkekNufus,
    this.kadinNufus,
    this.yuzolcumu,
  });

  Ilceler.fromJson(Map<String, dynamic> json) {
    ilceAdi = json['ilce_adi'];
    nufus = json['nufus'];
    erkekNufus = json['erkek_nufus'];
    kadinNufus = json['kadin_nufus'];
    yuzolcumu = json['yuzolcumu'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ilce_adi'] = ilceAdi;
    data['nufus'] = nufus;
    data['erkek_nufus'] = erkekNufus;
    data['kadin_nufus'] = kadinNufus;
    data['yuzolcumu'] = yuzolcumu;
    return data;
  }
}
