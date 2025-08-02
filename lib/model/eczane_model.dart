class NobetciEczane {
  String? status;
  String? message;
  String? messageTR;
  int? systemTime;
  String? endpoint;
  int? rowCount;
  int? creditUsed;
  List<Data>? data;

  NobetciEczane(
      {this.status,
      this.message,
      this.messageTR,
      this.systemTime,
      this.endpoint,
      this.rowCount,
      this.creditUsed,
      this.data});

  NobetciEczane.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    messageTR = json['messageTR'];
    systemTime = json['systemTime'];
    endpoint = json['endpoint'];
    rowCount = json['rowCount'];
    creditUsed = json['creditUsed'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data?.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['messageTR'] = this.messageTR;
    data['systemTime'] = this.systemTime;
    data['endpoint'] = this.endpoint;
    data['rowCount'] = this.rowCount;
    data['creditUsed'] = this.creditUsed;
    if (this.data != null) {
      data['data'] = this.data?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? pharmacyID;
  String? pharmacyName;
  String? address;
  String? city;
  String? district;
  var town;
  String? directions;
  String? phone;
  var phone2;
  var pharmacyDutyStart;
  var pharmacyDutyEnd;
  double? latitude;
  double? longitude;

  Data(
      {this.pharmacyID,
      this.pharmacyName,
      this.address,
      this.city,
      this.district,
      this.town,
      this.directions,
      this.phone,
      this.phone2,
      this.pharmacyDutyStart,
      this.pharmacyDutyEnd,
      this.latitude,
      this.longitude});

  Data.fromJson(Map<String, dynamic> json) {
    pharmacyID = json['pharmacyID'];
    pharmacyName = json['pharmacyName'];
    address = json['address'];
    city = json['city'];
    district = json['district'];
    town = json['town'];
    directions = json['directions'];
    phone = json['phone'];
    phone2 = json['phone2'];
    pharmacyDutyStart = json['pharmacyDutyStart'];
    pharmacyDutyEnd = json['pharmacyDutyEnd'];
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pharmacyID'] = this.pharmacyID;
    data['pharmacyName'] = this.pharmacyName;
    data['address'] = this.address;
    data['city'] = this.city;
    data['district'] = this.district;
    data['town'] = this.town;
    data['directions'] = this.directions;
    data['phone'] = this.phone;
    data['phone2'] = this.phone2;
    data['pharmacyDutyStart'] = this.pharmacyDutyStart;
    data['pharmacyDutyEnd'] = this.pharmacyDutyEnd;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    return data;
  }
}
