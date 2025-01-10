import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:customerparkapp/constant/constant.dart';
import 'package:customerparkapp/constant/show_toast_dialog.dart';
import 'package:customerparkapp/controller/rating_controller.dart';
import 'package:customerparkapp/model/parking_model.dart';
import 'package:customerparkapp/themes/app_them_data.dart';
import 'package:customerparkapp/themes/common_ui.dart';
import 'package:customerparkapp/themes/responsive.dart';
import 'package:customerparkapp/themes/round_button_fill.dart';
import 'package:customerparkapp/themes/text_field_widget.dart';
import 'package:customerparkapp/utils/dark_theme_provider.dart';
import 'package:customerparkapp/utils/fire_store_utils.dart';
import 'package:customerparkapp/utils/network_image_widget.dart';
import 'package:provider/provider.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<RatingController>(
        init: RatingController(),
        builder: (controller) {
          return Scaffold(
            appBar: UiInterface().customAppBar(
              context,
              themeChange,
              "Review".tr,
            ),
            body: controller.isLoading.value == true
                ? Constant.loader()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 40,
                        ),
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: NetworkImageWidget(
                              imageUrl: controller.parkingModel.value.image.toString(),
                              height: Responsive.width(26, context),
                              width: Responsive.width(26, context),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          '${controller.parkingModel.value.name}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppThemData.grey10, fontFamily: AppThemData.medium, fontSize: 18),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          '${controller.userModel.value.email}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppThemData.grey07, fontFamily: AppThemData.regular),
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: RatingBar.builder(
                            initialRating: controller.rating.value,
                            minRating: 0,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 32,
                            itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              controller.rating(rating);
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        TextFieldWidget(
                          title: 'Leave review'.tr,
                          onPress: () {},
                          controller: controller.commentController.value,
                          hintText: 'Write Review here...'.tr,
                          maxLine: 5,
                        ),
                        // ButtonThem.buildButton(
                        //   context,
                        //   title: "Submit".tr,
                        //   onPress: () async {
                        //     ShowToastDialog.showLoader("Please wait".tr);
                        //
                        //     await FireStoreUtils.getDriver(
                        //             controller.type.value == "orderModel" ? controller.orderModel.value.driverId.toString() : controller.intercityOrderModel.value.driverId.toString())
                        //         .then((value) async {
                        //       if (value != null) {
                        //         DriverUserModel driverUserModel = value;
                        //
                        //         if (controller.reviewModel.value.id != null) {
                        //           driverUserModel.reviewsSum =
                        //               (double.parse(driverUserModel.reviewsSum.toString()) - double.parse(controller.reviewModel.value.rating.toString())).toString();
                        //           driverUserModel.reviewsCount = (double.parse(driverUserModel.reviewsCount.toString()) - 1).toString();
                        //         }
                        //         driverUserModel.reviewsSum = (double.parse(driverUserModel.reviewsSum.toString()) + double.parse(controller.rating.value.toString())).toString();
                        //         driverUserModel.reviewsCount = (double.parse(driverUserModel.reviewsCount.toString()) + 1).toString();
                        //         await FireStoreUtils.updateDriver(driverUserModel);
                        //       }
                        //     });
                        //
                        //     controller.reviewModel.value.id = controller.type.value == "orderModel" ? controller.orderModel.value.id : controller.intercityOrderModel.value.id;
                        //     controller.reviewModel.value.comment = controller.commentController.value.text;
                        //     controller.reviewModel.value.rating = controller.rating.value.toString();
                        //     controller.reviewModel.value.customerId = FireStoreUtils.getCurrentUid();
                        //     controller.reviewModel.value.driverId =
                        //         controller.type.value == "orderModel" ? controller.orderModel.value.driverId : controller.intercityOrderModel.value.driverId;
                        //     controller.reviewModel.value.date = Timestamp.now();
                        //     controller.reviewModel.value.type = controller.type.value == "orderModel" ? "city" : "intercity";
                        //
                        //     await FireStoreUtils.setReview(controller.reviewModel.value).then((value) {
                        //       if (value != null && value == true) {
                        //         ShowToastDialog.closeLoader();
                        //         ShowToastDialog.showToast("Review submit successfully".tr);
                        //         Get.back();
                        //       }
                        //     });
                        //   },
                        // ),
                      ],
                    ),
                  ),
            bottomNavigationBar: Container(
              color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.grey11,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: RoundedButtonFill(
                  title: "Leave a Review".tr,
                  color: AppThemData.primary06,
                  onPress: () async {
                    ShowToastDialog.showLoader("Please wait".tr);

                    await FireStoreUtils.getParkingDetails(controller.orderModel.value.parkingId.toString()).then((value) async {
                      if (value != null) {
                        ParkingModel parkingModel = value;

                        if (controller.reviewModel.value.id != null) {
                          parkingModel.reviewSum = (double.parse(parkingModel.reviewSum.toString()) - double.parse(controller.reviewModel.value.rating.toString())).toString();
                          parkingModel.reviewCount = (double.parse(parkingModel.reviewCount.toString()) - 1).toString();
                        }
                        parkingModel.reviewSum = (double.parse(parkingModel.reviewSum.toString()) + double.parse(controller.rating.value.toString())).toString();
                        parkingModel.reviewCount = (double.parse(parkingModel.reviewCount.toString()) + 1).toString();
                        await FireStoreUtils.saveParkingDetails(parkingModel);
                      }
                    });

                    controller.reviewModel.value.id = controller.orderModel.value.id;
                    controller.reviewModel.value.comment = controller.commentController.value.text;
                    controller.reviewModel.value.rating = controller.rating.value.toString();
                    controller.reviewModel.value.customerId = FireStoreUtils.getCurrentUid();
                    controller.reviewModel.value.parkingId = controller.orderModel.value.parkingId;
                    controller.reviewModel.value.date = Timestamp.now();

                    await FireStoreUtils.setReview(controller.reviewModel.value).then((value) {
                      if (value != null && value == true) {
                        ShowToastDialog.closeLoader();
                        ShowToastDialog.showToast("Review submit successfully".tr);
                        Get.back();
                      }
                    });
                  },
                ),
              ),
            ),
          );
        });
  }
}
