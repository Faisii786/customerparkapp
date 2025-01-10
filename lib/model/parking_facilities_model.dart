class ParkingFacilitiesModel {
  bool? isEnable;
  String? name;
  String? id;
  String? image;

  ParkingFacilitiesModel({this.isEnable, this.name, this.id, this.image});

  ParkingFacilitiesModel.fromJson(Map<String, dynamic> json) {
    isEnable = json['isEnable'];
    name = json['name'];
    id = json['id'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isEnable'] = isEnable;
    data['name'] = name;
    data['id'] = id;
    data['image'] = image;
    return data;
  }
}
