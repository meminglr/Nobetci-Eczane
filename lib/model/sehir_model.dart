class Iller {
  String? ilAdi;
  String? plakaKodu;
  List<Ilceler>? ilceler;
  String? kisaBilgi;

  Iller({this.ilAdi, this.plakaKodu, this.ilceler, this.kisaBilgi});

  Iller.fromJson(Map<String, dynamic> json) {
    ilAdi = json['il_adi'];
    plakaKodu = json['plaka_kodu'];
    if (json['ilceler'] != null) {
      ilceler = <Ilceler>[];
      json['ilceler'].forEach((v) {
        ilceler!.add(new Ilceler.fromJson(v));
      });
    }
    kisaBilgi = json['kisa_bilgi'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['il_adi'] = this.ilAdi;
    data['plaka_kodu'] = this.plakaKodu;
    if (this.ilceler != null) {
      data['ilceler'] = this.ilceler!.map((v) => v.toJson()).toList();
    }
    data['kisa_bilgi'] = this.kisaBilgi;
    return data;
  }
}

class Ilceler {
  String? ilceAdi;
  String? nufus;
  String? erkekNufus;
  String? kadinNufus;
  String? yuzolcumu;

  Ilceler(
      {this.ilceAdi,
      this.nufus,
      this.erkekNufus,
      this.kadinNufus,
      this.yuzolcumu});

  Ilceler.fromJson(Map<String, dynamic> json) {
    ilceAdi = json['ilce_adi'];
    nufus = json['nufus'];
    erkekNufus = json['erkek_nufus'];
    kadinNufus = json['kadin_nufus'];
    yuzolcumu = json['yuzolcumu'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ilce_adi'] = this.ilceAdi;
    data['nufus'] = this.nufus;
    data['erkek_nufus'] = this.erkekNufus;
    data['kadin_nufus'] = this.kadinNufus;
    data['yuzolcumu'] = this.yuzolcumu;
    return data;
  }
}
