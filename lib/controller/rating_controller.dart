import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:customerparkapp/model/order_model.dart';
import 'package:customerparkapp/model/parking_model.dart';
import 'package:customerparkapp/model/user_model.dart';
import 'package:customerparkapp/utils/fire_store_utils.dart';

import '../model/review_model.dart';

class RatingController extends GetxController {
  RxBool isLoading = true.obs;
  RxDouble rating = 0.0.obs;
  Rx<TextEditingController> commentController = TextEditingController().obs;

  Rx<ReviewModel> reviewModel = ReviewModel().obs;
  Rx<ParkingModel> parkingModel = ParkingModel().obs;
  Rx<UserModel> userModel = UserModel().obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getArgument();
  }

  Rx<OrderModel> orderModel = OrderModel().obs;

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      orderModel.value = argumentData['orderModel'];
    }
    await FireStoreUtils.getParkingDetails(orderModel.value.parkingId.toString()).then((value) {
      if (value != null) {
        parkingModel.value = value;
      }
    });
    await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()).then((value) {
      if (value != null) {
        userModel.value = value;
      }
    });
    await FireStoreUtils.getReview(orderModel.value.id.toString()).then((value) {
      if (value != null) {
        reviewModel.value = value;
        rating.value = double.parse(reviewModel.value.rating.toString());
        commentController.value.text = reviewModel.value.comment.toString();
      }
    });
    isLoading.value = false;
    update();
  }
}
