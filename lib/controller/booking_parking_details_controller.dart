import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:customerparkapp/model/parking_model.dart';
import 'package:customerparkapp/model/user_vehicle_model.dart';
import 'package:customerparkapp/utils/fire_store_utils.dart';

class BookingParkingDetailsController extends GetxController {
  RxBool isLoading = false.obs;
  RxString currentMonth = DateFormat.yMMMM().format(DateTime.now()).obs;
  Rx<DateTime> selectedDateTime = DateTime.now().obs;
  RxDouble selectedDuration = 2.0.obs;

  Rx<ParkingModel> parkingModel = ParkingModel().obs;
  Rx<UserVehicleModel> vehicle = UserVehicleModel().obs;

  Rx<DateTime> startTime = DateTime.now().obs;
  Rx<DateTime> endTime = DateTime.now().obs;

  Rx<TextEditingController> startTimeController = TextEditingController().obs;
  Rx<TextEditingController> endTimeController = TextEditingController().obs;

  Rx<UserVehicleModel> selectedVehicle = UserVehicleModel().obs;

  @override
  void onInit() {
    getArgument();
    super.onInit();
  }

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      parkingModel.value = argumentData['parkingModel'];
      getParkingDetails();
    }

    startTimeController.value.text = DateFormat('HH:mm').format(startTime.value);
    Duration duration = Duration(hours: selectedDuration.value.toInt());

    endTime.value = startTime.value.add(duration);
    endTimeController.value.text = DateFormat('HH:mm').format(endTime.value);

    isLoading.value = false;
    update();
  }

  getParkingDetails() async {
    await FireStoreUtils.getParkingDetails(parkingModel.value.id.toString()).then((value) {
      if (value != null) {
        parkingModel.value = value;
      }
    });
  }

  calculateParkingAmount() {
    return double.parse(parkingModel.value.perHrPrice.toString()) * selectedDuration.value;
  }

  String calculateDuration(String? startTime, String? endTime) {
    if (startTime != null && startTime.isNotEmpty && endTime != null && endTime.isNotEmpty) {
      return DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, int.parse(endTime.split(":").first), int.parse(endTime.split(":").last))
          .difference(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, int.parse(startTime.split(":").first), int.parse(startTime.split(":").last)))
          .inHours
          .toString();
    } else {
      return "";
    }
  }
}
