import 'dart:developer';

import 'package:get/get.dart';
import 'package:customerparkapp/model/order_model.dart';
import 'package:customerparkapp/model/parking_model.dart';
import 'package:customerparkapp/utils/fire_store_utils.dart';

class ParkingViewController extends GetxController {
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();
    super.onInit();
  }

  RxString selectedParking = "".obs;
  Rx<OrderModel> orderModel = OrderModel().obs;
  Rx<ParkingModel> parkingModel = ParkingModel().obs;

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      orderModel.value = argumentData['orderModel'];
      getParkingDetails();
      getBookedParking();
    }
    update();
  }

  getParkingDetails() async {
    await FireStoreUtils.getParkingDetails(orderModel.value.parkingDetails!.id.toString()).then((value) {
      if (value != null) {
        parkingModel.value = value;
      }
    });
    isLoading.value = false;
  }

  RxList<OrderModel> selectedOrderModel = <OrderModel>[].obs;

  getBookedParking() async {
    log("myTime ===>${orderModel.value.bookingDate!.toDate()} \n==>StartTime ${orderModel.value.bookingStartTime!.toDate()} \n==>endTime ${orderModel.value.bookingEndTime!.toDate()}");

    await FireStoreUtils.getOrder(orderModel.value.bookingDate!, orderModel.value.bookingStartTime!, orderModel.value.bookingEndTime!, orderModel.value.parkingId.toString())
        .then((value) {
      if (value != null) {
        for (var element in value) {
          OrderModel orderModel1 = element;
          if (orderModel1.bookingStartTime!.toDate().isBefore(orderModel.value.bookingStartTime!.toDate()) &&
              orderModel1.bookingEndTime!.toDate().isAfter(orderModel.value.bookingStartTime!.toDate())) {
            log("parking ===>${orderModel1.parkingSlotId}");
            selectedOrderModel.add(orderModel1);
          } else if (orderModel.value.bookingStartTime!.toDate().isAtSameMomentAs(orderModel1.bookingStartTime!.toDate())) {
            selectedOrderModel.add(orderModel1);
            log("parking ===>4 ${orderModel1.parkingSlotId}");
          } else if (orderModel.value.bookingStartTime!.toDate().isBefore(orderModel1.bookingStartTime!.toDate())) {
            if (orderModel.value.bookingEndTime!.toDate().isAfter(orderModel1.bookingEndTime!.toDate())) {
              selectedOrderModel.add(orderModel1);
              log("parking ===>2 ${orderModel1.parkingSlotId}");
            } else if (orderModel.value.bookingEndTime!.toDate().isAtSameMomentAs(orderModel1.bookingEndTime!.toDate())) {
              selectedOrderModel.add(orderModel1);
              log("parking ===>2 ${orderModel1.parkingSlotId}");
            } else if (orderModel.value.bookingEndTime!.toDate().isBefore(orderModel1.bookingEndTime!.toDate()) &&
                orderModel.value.bookingEndTime!.toDate().isAfter(orderModel1.bookingStartTime!.toDate())) {
              selectedOrderModel.add(orderModel1);
              log("parking ===>3 ${orderModel1.parkingSlotId}");
            } else {
              log("parking ===>2 else");
            }
          } else {
            log("parking ===>1 else");
          }
        }
      }
    });
  }
}
