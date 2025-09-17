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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['city'] = this.city;
    data['district'] = this.district;
    data['address'] = this.address;
    data['phone'] = this.phone;
    data['hours'] = this.hours;
    data['closing_info'] = this.closingInfo;
    data['direction_link'] = this.directionLink;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    return data;
  }
}
