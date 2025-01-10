import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customerparkapp/model/location_lat_lng.dart';
import 'package:customerparkapp/model/parking_facilities_model.dart';
import 'package:customerparkapp/model/positions_model.dart';

class ParkingModel {
  String? id;
  String? userId;
  bool? isEnable;
  LocationLatLng? location;
  Positions? position;
  String? address;
  String? name;
  String? description;
  String? image;
  String? parkingSpace;
  String? perHrPrice;
  String? reviewCount;
  String? reviewSum;
  String? parkingType;
  List<ParkingFacilitiesModel>? facilities;
  List<dynamic>? bookmarkedUser;
  Timestamp? createdAt;

  ParkingModel(
      {this.id,
      this.userId,
      this.isEnable,
      this.location,
      this.position,
      this.address,
      this.name,
      this.description,
      this.image,
      this.facilities,
      this.bookmarkedUser,
      this.perHrPrice,
      this.parkingSpace,
      this.reviewCount,
      this.reviewSum,
      this.parkingType,
      this.createdAt});

  ParkingModel.fromJson(Map<String, dynamic> json) {
    if (json['facilities'] != null) {
      facilities = <ParkingFacilitiesModel>[];
      json['facilities'].forEach((v) {
        facilities!.add(ParkingFacilitiesModel.fromJson(v));
      });
    }
    id = json['id'];
    name = json['name'] ?? '';
    description = json['description'] ?? '';
    userId = json['userId'];
    address = json['address'] ?? '';
    isEnable = json['isEnable'] ?? false;
    image = json['image'] ?? '';
    bookmarkedUser = json['bookmarkedUser'] ?? [];
    perHrPrice = json['perHrPrice'] ?? "";
    parkingSpace = json['parkingSpace'] ?? "";
    reviewCount = json['reviewCount'] ?? "0.0";
    reviewSum = json['reviewSum'] ?? "0.0";
    parkingType = json['parkingType'] ?? "2";
    createdAt = json['createdAt'] ?? Timestamp.now();
    location = json['location'] != null ? LocationLatLng.fromJson(json['location']) : LocationLatLng();
    position = json['position'] != null ? Positions.fromJson(json['position']) : Positions();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (facilities != null) {
      data['facilities'] = facilities!.map((v) => v.toJson()).toList();
    }
    data['id'] = id;
    data['userId'] = userId;
    data['name'] = name;
    data['description'] = description;
    data['address'] = address;
    data['isEnable'] = isEnable;
    data['image'] = image;
    data['bookmarkedUser'] = bookmarkedUser;
    data['perHrPrice'] = perHrPrice;
    data['parkingSpace'] = parkingSpace;
    data['reviewCount'] = reviewCount;
    data['reviewSum'] = reviewSum;
    data['parkingType'] = parkingType;
    data['createdAt'] = createdAt ?? Timestamp.now();
    if (location != null) {
      data['location'] = location!.toJson();
    }
    if (position != null) {
      data['position'] = position!.toJson();
    }
    return data;
  }
}

// class Slot {
//   String? day;
//   List<Timeslot>? timeslot;
//
//   Slot({
//     this.day,
//     this.timeslot,
//   });
//
//   Slot.fromJson(Map<String, dynamic> json) {
//     day = json['day'];
//     if (json['timeslot'] != null) {
//       timeslot = <Timeslot>[];
//       json['timeslot'].forEach((v) {
//         timeslot!.add(Timeslot.fromJson(v));
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['day'] = day;
//     if (timeslot != null) {
//       data['timeslot'] = timeslot!.map((v) => v.toJson()).toList();
//     }
//
//     return data;
//   }
// }

// class Timeslot {
//   String? id;
//   String? from;
//   String? to;
//   String? price;
//   VehicleModel? vehicle;
//   String? duration;
//
//   Timeslot({
//     this.id,
//     this.from,
//     this.to,
//     this.price,
//     this.vehicle,
//     this.duration,
//   });
//
//   Timeslot.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     from = json['from'];
//     to = json['to'];
//     price = json['price'];
//     duration = json['duration'];
//     vehicle = json['vehicle'] != null ? VehicleModel.fromJson(json['vehicle']) : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = id;
//     data['from'] = from;
//     data['to'] = to;
//     data['price'] = price;
//     data['duration'] = duration;
//     if (vehicle != null) {
//       data['vehicle'] = vehicle!.toJson();
//     }
//     return data;
//   }
// }
