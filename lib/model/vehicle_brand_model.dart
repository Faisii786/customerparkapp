class VehicleBrandModel {
  bool? enable;
  String? name;
  String? id;

  VehicleBrandModel({this.enable, this.name, this.id});

  VehicleBrandModel.fromJson(Map<String, dynamic> json) {
    enable = json['enable'];
    name = json['name'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['enable'] = enable;
    data['name'] = name;
    data['id'] = id;
    return data;
  }
}
