class YeniEczane {
  String? name;
  String? city;
  String? district;
  String? address;
  String? phone;
  String? hours;
  String? closingInfo;
  String? directionLink;
  double? latitude;
  double? longitude;

  YeniEczane({
    this.name,
    this.city,
    this.district,
    this.address,
    this.phone,
    this.hours,
    this.closingInfo,
    this.directionLink,
    this.latitude,
    this.longitude,
  });

  YeniEczane.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    city = json['city'];
    district = json['district'];
    address = json['address'];
    phone = json['phone'];
    hours = json['hours'];
    closingInfo = json['closing_info'];
    directionLink = json['direction_link'];
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['city'] = city;
    data['district'] = district;
    data['address'] = address;
    data['phone'] = phone;
    data['hours'] = hours;
    data['closing_info'] = closingInfo;
    data['direction_link'] = directionLink;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}
