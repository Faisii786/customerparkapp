import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:customerparkapp/constant/constant.dart';
import 'package:customerparkapp/model/parking_model.dart';
import 'package:customerparkapp/utils/fire_store_utils.dart';

class SavedController extends GetxController {
  Rx<TextEditingController> searchController = TextEditingController().obs;

  RxBool isLoading = true.obs;
  RxList<ParkingModel> bookMarkedList = <ParkingModel>[].obs;

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  getData() async {
    await FireStoreUtils.getBookMarkedList().then((value) {
      if (value != null) {
        bookMarkedList.value = value;
      }
    });
    isLoading.value = false;
  }

  Future<String> getDistance(LatLng source, LatLng latLng) async {
    String distance = "";
    if (Constant.selectedMapType.toString() == 'osm') {
      await Constant.getDurationOsmDistance(source, latLng).then((value) {
        if (value != {} && value.isNotEmpty) {
          if (Constant.distanceType == "Km") {
            distance = (value['routes'].first['distance'] / 1000).toString();
          } else {
            distance = (value['routes'].first['distance'] / 1609.34).toString();
          }
        }
      });
    } else {
      await Constant.getDurationDistance(source, latLng).then((value) {
        if (value != null) {
          if (Constant.distanceType == "Km") {
            distance = "${(value.rows!.first.elements!.first.distance!.value!.toInt() / 1000).toStringAsFixed(1)} Km";
          } else {
            distance = "${(value.rows!.first.elements!.first.distance!.value!.toInt() / 1609.34).toStringAsFixed(1)} Miles";
          }
        }
      });
    }
    return distance;
  }
}
