import 'dart:developer';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:customerparkapp/constant/constant.dart';
import 'package:customerparkapp/model/parking_model.dart';
import 'package:customerparkapp/utils/fire_store_utils.dart';

class ParkingDetailsController extends GetxController {
  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();
    super.onInit();
  }

  RxBool isLoading = true.obs;
  Rx<ParkingModel> parkingModel = ParkingModel().obs;

  RxString duration = "".obs;
  RxString distance = "".obs;

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      parkingModel.value = argumentData['parkingModel'];
      if (Constant.selectedMapType.toString() == 'osm') {
        calculateOsmAmount();
      } else {
        calculate();
      }
    }
    isLoading.value = false;
    update();
  }

  getData() async {
    await FireStoreUtils.getParkingDetails(parkingModel.value.id.toString()).then((value) {
      if (value != null) {
        parkingModel.value = value;
      }
    });
  }

  calculate() async {
    log("------->");

    await Constant.getDurationDistance(LatLng(Constant.currentLocation!.latitude!, Constant.currentLocation!.longitude!),
            LatLng(parkingModel.value.location!.latitude!, parkingModel.value.location!.longitude!))
        .then((value) {
      if (value != null) {
        log(value.toJson().toString());
        duration.value = value.rows!.first.elements!.first.duration!.text.toString();

        if (Constant.distanceType == "Km") {
          distance.value = "${(value.rows!.first.elements!.first.distance!.value!.toInt() / 1000).toStringAsFixed(1)} Km";
        } else {
          distance.value = "${(value.rows!.first.elements!.first.distance!.value!.toInt() / 1609.34).toStringAsFixed(1)} Miles";
        }
      }
    });
  }

  calculateOsmAmount() async {
    await Constant.getDurationOsmDistance(LatLng(Constant.currentLocation!.latitude!, Constant.currentLocation!.longitude!),
            LatLng(parkingModel.value.location!.latitude!, parkingModel.value.location!.longitude!))
        .then((value) {
      if (value != {} && value.isNotEmpty) {
        int hours = value['routes'].first['duration'] ~/ 3600;
        int minutes = ((value['routes'].first['duration'] % 3600) / 60).round();
        duration.value = '$hours hours $minutes minutes';
        if (Constant.distanceType == "Km") {
          distance.value = (value['routes'].first['distance'] / 1000).toString();
        } else {
          distance.value = (value['routes'].first['distance'] / 1609.34).toString();
        }
      }
    });
  }
}
