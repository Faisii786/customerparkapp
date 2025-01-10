import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:customerparkapp/constant/constant.dart';
import 'package:customerparkapp/constant/show_toast_dialog.dart';
import 'package:customerparkapp/controller/parking_details_controller.dart';
import 'package:customerparkapp/model/parking_facilities_model.dart';
import 'package:customerparkapp/model/user_model.dart';
import 'package:customerparkapp/themes/app_them_data.dart';
import 'package:customerparkapp/themes/common_ui.dart';
import 'package:customerparkapp/themes/round_button_fill.dart';
import 'package:customerparkapp/ui/booking_process/booking_parking_details_screen.dart';
import 'package:customerparkapp/ui/chat/chat_screen.dart';
import 'package:customerparkapp/utils/dark_theme_provider.dart';
import 'package:customerparkapp/utils/fire_store_utils.dart';
import 'package:customerparkapp/utils/network_image_widget.dart';
import 'package:provider/provider.dart';

class ParkingDetailsScreen extends StatelessWidget {
  const ParkingDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<ParkingDetailsController>(
        init: ParkingDetailsController(),
        builder: (controller) {
          return Scaffold(
            appBar: UiInterface().customAppBar(context, themeChange, "parking_details".tr),
            body: controller.isLoading.value
                ? Constant.loader()
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: NetworkImageWidget(
                                  imageUrl: controller.parkingModel.value.image.toString(),
                                  height: 180,
                                  width: Get.width,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                right: 10,
                                top: 10,
                                child: InkWell(
                                    onTap: () async {
                                      ShowToastDialog.showLoader("Please wait..".tr);
                                      if (controller.parkingModel.value.bookmarkedUser!.contains(FireStoreUtils.getCurrentUid())) {
                                        await FireStoreUtils.removeBookMarked(controller.parkingModel.value).then((value) {
                                          controller.getData();
                                          ShowToastDialog.closeLoader();
                                        });
                                      } else {
                                        await FireStoreUtils.bookMarked(controller.parkingModel.value).then((value) {
                                          controller.getData();
                                          ShowToastDialog.closeLoader();
                                        });
                                      }
                                    },
                                    child: Icon(
                                        controller.parkingModel.value.bookmarkedUser!.contains(FireStoreUtils.getCurrentUid()) &&
                                                controller.parkingModel.value.bookmarkedUser != null
                                            ? Icons.bookmark
                                            : Icons.bookmark_border,
                                        color: AppThemData.white)),
                              ),
                              Positioned(
                                top: 10,
                                left: 10,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: AppThemData.primary01,
                                    borderRadius: BorderRadius.all(Radius.circular(20)),
                                  ),
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.star, size: 16, color: AppThemData.primary07),
                                          const SizedBox(width: 5),
                                          Text(
                                            Constant.calculateReview(reviewCount: controller.parkingModel.value.reviewCount, reviewSum: controller.parkingModel.value.reviewSum),
                                            style: const TextStyle(color: AppThemData.grey10, fontFamily: AppThemData.semiBold),
                                          ),
                                        ],
                                      )),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      controller.parkingModel.value.name.toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey09,
                                        fontSize: 18,
                                        fontFamily: AppThemData.semiBold,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on_outlined, color: AppThemData.grey07, size: 16),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Expanded(
                                          child: Text(
                                            controller.parkingModel.value.address.toString(),
                                            textAlign: TextAlign.start,
                                            style: const TextStyle(
                                              color: AppThemData.grey07,
                                              fontSize: 14,
                                              fontFamily: AppThemData.medium,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              InkWell(
                                  onTap: () async {
                                    ShowToastDialog.showLoader("Please wait".tr);
                                    UserModel? userModel = await FireStoreUtils.getUserProfile(controller.parkingModel.value.userId.toString());
                                    ShowToastDialog.closeLoader();
                                    Constant.makePhoneCall("${userModel!.countryCode}${userModel.phoneNumber}");
                                  },
                                  child: SvgPicture.asset("assets/icon/ic_call.svg")),
                              const SizedBox(
                                width: 10,
                              ),
                              // InkWell(
                              //     onTap: () async {
                              //       await FireStoreUtils.getUserProfile(controller.parkingModel.value.userId.toString()).then((value) {
                              //         UserModel userModel = value!;
                              //         Get.to(const ChatScreen(), arguments: {"receiverModel": userModel});
                              //       });
                              //     },
                              //     child: SvgPicture.asset("assets/icon/ic_chat.svg"))
                              // InkWell(
                              //     onTap: () async {
                              //       ShowToastDialog.showLoader("Please wait..");
                              //       if (controller.parkingModel.value.bookmarkedUser!.contains(FireStoreUtils.getCurrentUid())) {
                              //         await FireStoreUtils.removeBookMarked(controller.parkingModel.value).then((value) {
                              //           controller.getData();
                              //           ShowToastDialog.closeLoader();
                              //         });
                              //       } else {
                              //         await FireStoreUtils.bookMarked(controller.parkingModel.value).then((value) {
                              //           controller.getData();
                              //           ShowToastDialog.closeLoader();
                              //         });
                              //       }
                              //     },
                              //     child: Icon(
                              //         controller.parkingModel.value.bookmarkedUser!.contains(FireStoreUtils.getCurrentUid()) && controller.parkingModel.value.bookmarkedUser != null
                              //             ? Icons.bookmark
                              //             : Icons.bookmark_border,
                              //         color: AppThemData.primary))
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            height: 40,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                boxDecoration("${controller.parkingModel.value.parkingSpace.toString()} Spots".tr, themeChange, Icons.local_parking),
                                const SizedBox(
                                  width: 10,
                                ),
                                boxDecoration(controller.distance.value, themeChange, Icons.location_on),
                                const SizedBox(
                                  width: 10,
                                ),
                                boxDecoration(controller.duration.value, themeChange, Icons.access_time_outlined),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Divider(color: AppThemData.grey04, thickness: 1),
                          const SizedBox(
                            height: 24,
                          ),
                          Text(
                            'About'.tr,
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: AppThemData.medium,
                              fontWeight: FontWeight.w700,
                              color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey09,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            controller.parkingModel.value.description.toString(),
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: AppThemData.regular,
                              color: themeChange.getThem() ? AppThemData.grey07 : AppThemData.grey07,
                            ),
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          const Divider(color: AppThemData.grey04, thickness: 1),
                          const SizedBox(
                            height: 24,
                          ),
                          Text(
                            'Facilities'.tr,
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: AppThemData.medium,
                              fontWeight: FontWeight.w700,
                              color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey09,
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Wrap(
                            spacing: 6.0,
                            runSpacing: 6.0,
                            children: List<Widget>.generate(controller.parkingModel.value.facilities!.length, (int index) {
                              ParkingFacilitiesModel parkingFacility = controller.parkingModel.value.facilities![index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    NetworkImageWidget(
                                      imageUrl: parkingFacility.image.toString(),
                                      height: 20,
                                      width: 20,
                                      fit: BoxFit.fill,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      parkingFacility.name.toString(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: AppThemData.medium,
                                        color: themeChange.getThem() ? AppThemData.blueLight07 : AppThemData.blueLight07,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          const Divider(color: AppThemData.grey04, thickness: 1),
                          const SizedBox(
                            height: 24,
                          ),
                          Container(
                            width: Get.width,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                            decoration: BoxDecoration(color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.grey03, borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              children: [
                                Text("Per hour".tr,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: AppThemData.medium,
                                      color: themeChange.getThem() ? AppThemData.grey07 : AppThemData.grey07,
                                    )),
                                const SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  Constant.amountShow(amount: controller.parkingModel.value.perHrPrice.toString()),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: AppThemData.semiBold,
                                    color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: RoundedButtonFill(
                  title: "Book Parking".tr,
                  color: AppThemData.primary06,
                  fontSizes: 12,
                  onPress: () {
                    if (controller.parkingModel.value.userId == FireStoreUtils.getCurrentUid()) {
                      ShowToastDialog.showToast("You can't book your own parking.");
                    } else {
                      Get.to(() => const BookingParkingDetailsScreen(), arguments: {"parkingModel": controller.parkingModel.value});
                    }
                  },
                ),
              ),
            ),
          );
        });
  }

  Widget boxDecoration(String title, themeChange, IconData? image) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: AppThemData.primary03),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (image != null)
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Icon(image, size: 20, color: themeChange.getThem() ? AppThemData.primary09 : AppThemData.primary09),
              ),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: AppThemData.medium,
                color: themeChange.getThem() ? AppThemData.primary09 : AppThemData.primary09,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
