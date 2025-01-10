import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customerparkapp/model/admin_commission.dart';
import 'package:customerparkapp/model/coupon_model.dart';
import 'package:customerparkapp/model/parking_model.dart';
import 'package:customerparkapp/model/tax_model.dart';
import 'package:customerparkapp/model/user_vehicle_model.dart';

class OrderModel {
  String? id;
  String? userId;
  String? parkingId;
  String? parkingSlotId;
  Timestamp? bookingDate;
  Timestamp? bookingStartTime;
  Timestamp? bookingEndTime;
  String? duration;
  String? status;
  String? paymentType;
  String? subTotal;
  bool? paymentCompleted;
  UserVehicleModel? userVehicle;
  ParkingModel? parkingDetails;
  List<TaxModel>? taxList;
  AdminCommission? adminCommission;
  CouponModel? coupon;
  Timestamp? createdAt;
  Timestamp? updateAt;

  OrderModel({
    this.id,
    this.userId,
    this.parkingId,
    this.parkingSlotId,
    this.bookingDate,
    this.bookingStartTime,
    this.bookingEndTime,
    this.duration,
    this.status,
    this.paymentType,
    this.subTotal,
    this.paymentCompleted,
    this.userVehicle,
    this.parkingDetails,
    this.taxList,
    this.adminCommission,
    this.coupon,
    this.createdAt,
    this.updateAt,
  });

  OrderModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    parkingId = json['parkingId'];
    parkingSlotId = json['parkingSlotId'];
    bookingDate = json['bookingDate'];
    bookingStartTime = json['bookingStartTime'];
    bookingEndTime = json['bookingEndTime'];
    duration = json['duration'];
    status = json['status'];
    paymentType = json['paymentType'];
    subTotal = json['subTotal'];
    paymentCompleted = json['paymentCompleted'];
    userVehicle = json['userVehicle'] != null ? UserVehicleModel.fromJson(json['userVehicle']) : null;
    parkingDetails = json['parkingDetails'] != null ? ParkingModel.fromJson(json['parkingDetails']) : null;
    if (json['taxList'] != null) {
      taxList = <TaxModel>[];
      json['taxList'].forEach((v) {
        taxList!.add(TaxModel.fromJson(v));
      });
    }
    adminCommission = json['adminCommission'] != null ? AdminCommission.fromJson(json['adminCommission']) : null;
    coupon = json['coupon'] != null ? CouponModel.fromJson(json['coupon']) : null;
    createdAt = json['createdAt'];
    updateAt = json['updateAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['userId'] = userId;
    data['parkingId'] = parkingId;
    data['parkingSlotId'] = parkingSlotId;
    data['bookingDate'] = bookingDate;
    data['bookingStartTime'] = bookingStartTime;
    data['bookingEndTime'] = bookingEndTime;
    data['duration'] = duration;
    data['status'] = status;
    data['paymentType'] = paymentType;
    data['subTotal'] = subTotal;
    data['paymentCompleted'] = paymentCompleted;

    if (userVehicle != null) {
      data['userVehicle'] = userVehicle!.toJson();
    }
    if (parkingDetails != null) {
      data['parkingDetails'] = parkingDetails!.toJson();
    }
    if (taxList != null) {
      data['taxList'] = taxList!.map((v) => v.toJson()).toList();
    }
    if (adminCommission != null) {
      data['adminCommission'] = adminCommission!.toJson();
    }
    if (coupon != null) {
      data['coupon'] = coupon!.toJson();
    }
    data['createdAt'] = createdAt;
    data['updateAt'] = updateAt;
    return data;
  }
}
