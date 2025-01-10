import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:customerparkapp/constant/constant.dart';
import 'package:customerparkapp/constant/show_toast_dialog.dart';
import 'package:customerparkapp/controller/saved_controller.dart';
import 'package:customerparkapp/model/parking_model.dart';
import 'package:customerparkapp/themes/app_them_data.dart';
import 'package:customerparkapp/themes/common_ui.dart';
import 'package:customerparkapp/themes/responsive.dart';
import 'package:customerparkapp/ui/parking_details_screen/parking_details_screen.dart';
import 'package:customerparkapp/utils/dark_theme_provider.dart';
import 'package:customerparkapp/utils/fire_store_utils.dart';
import 'package:customerparkapp/utils/network_image_widget.dart';
import 'package:provider/provider.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      appBar: UiInterface().customAppBar(
        context,
        themeChange,
        isBack: false,
        'saved'.tr,
      ),
      body: GetX<SavedController>(
          init: SavedController(),
          builder: (controller) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: controller.isLoading.value
                  ? Constant.loader()
                  : controller.bookMarkedList.isEmpty
                      ? Constant.showEmptyView(message: "No Parking Found".tr)
                      : ListView.separated(
                          itemCount: controller.bookMarkedList.length,
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          itemBuilder: (context, int index) {
                            ParkingModel parkingModel = controller.bookMarkedList[index];
                            return InkWell(
                              onTap: () {
                                Get.to(() => const ParkingDetailsScreen(), arguments: {"parkingModel": parkingModel});
                              },
                              child: Container(
                                height: Responsive.height(15, context),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.white,
                                ),
                                child: Stack(
                                  children: [
                                    Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                                          child: NetworkImageWidget(
                                            imageUrl: parkingModel.image.toString(),
                                            height: Responsive.height(100, context),
                                            width: 110,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        parkingModel.name.toString(),
                                                        style: TextStyle(
                                                          color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey10,
                                                          fontSize: 14,
                                                          fontFamily: AppThemData.semiBold,
                                                        ),
                                                      ),
                                                    ),
                                                    InkWell(
                                                        onTap: () async {
                                                          ShowToastDialog.showLoader("Please wait..".tr);
                                                          if (parkingModel.bookmarkedUser!.contains(FireStoreUtils.getCurrentUid())) {
                                                            await FireStoreUtils.removeBookMarked(parkingModel).then((value) {
                                                              controller.getData();
                                                              ShowToastDialog.closeLoader();
                                                            });
                                                          } else {
                                                            await FireStoreUtils.bookMarked(parkingModel).then((value) {
                                                              controller.getData();
                                                              ShowToastDialog.closeLoader();
                                                            });
                                                          }
                                                        },
                                                        child: Icon(
                                                            parkingModel.bookmarkedUser!.contains(FireStoreUtils.getCurrentUid()) && parkingModel.bookmarkedUser != null
                                                                ? Icons.bookmark
                                                                : Icons.bookmark_border,
                                                            color: AppThemData.primary08)),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  parkingModel.address.toString(),
                                                  maxLines: 2,
                                                  style: const TextStyle(color: AppThemData.grey07, fontSize: 12, fontFamily: AppThemData.regular, overflow: TextOverflow.ellipsis),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    FutureBuilder<String>(
                                                        future: controller.getDistance(LatLng(Constant.currentLocation!.latitude!, Constant.currentLocation!.longitude!),
                                                            LatLng(parkingModel.location!.latitude!, parkingModel.location!.longitude!)),
                                                        builder: (context, snapshot) {
                                                          switch (snapshot.connectionState) {
                                                            case ConnectionState.waiting:
                                                              return const SizedBox();
                                                            case ConnectionState.done:
                                                              if (snapshot.hasError) {
                                                                return Text(
                                                                  snapshot.error.toString(),
                                                                  style: const TextStyle(),
                                                                );
                                                              } else {
                                                                return Text(
                                                                  snapshot.data!,
                                                                  style: const TextStyle(
                                                                    color: AppThemData.blueLight07,
                                                                    fontSize: 12,
                                                                    fontFamily: AppThemData.semiBold,
                                                                  ),
                                                                );
                                                              }
                                                            default:
                                                              return Text('Error'.tr);
                                                          }
                                                        }),
                                                    const SizedBox(height: 10, child: VerticalDivider(thickness: 1, color: AppThemData.grey05)),
                                                    Text(
                                                      "${Constant.amountShow(amount: parkingModel.perHrPrice.toString())}/hour".tr,
                                                      style: const TextStyle(
                                                        color: AppThemData.blueLight07,
                                                        fontSize: 12,
                                                        fontFamily: AppThemData.semiBold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10, child: VerticalDivider(thickness: 1, color: AppThemData.grey05)),
                                                    Row(
                                                      children: [
                                                        SvgPicture.asset(parkingModel.parkingType == "2" ? "assets/icon/ic_bike.svg" : "assets/icon/ic_car_fill.svg",
                                                            color: AppThemData.blueLight07),
                                                        Text(
                                                          " ${parkingModel.parkingType.toString()} wheel".tr,
                                                          maxLines: 1,
                                                          style: const TextStyle(
                                                            color: AppThemData.blueLight07,
                                                            fontSize: 12,
                                                            height: 1.57,
                                                            overflow: TextOverflow.ellipsis,
                                                            fontFamily: AppThemData.semiBold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    Get.to(() => const ParkingDetailsScreen(), arguments: {"parkingModel": parkingModel});
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 5),
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          'View Details'.tr,
                                                          style: const TextStyle(
                                                            color: AppThemData.primary08,
                                                            fontSize: 14,
                                                            fontFamily: AppThemData.medium,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        const Padding(
                                                          padding: EdgeInsets.only(top: 3),
                                                          child: Icon(Icons.arrow_forward_ios, color: AppThemData.primary08, size: 14),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Positioned(
                                      top: 10,
                                      left: 5,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: AppThemData.primary01,
                                          borderRadius: BorderRadius.all(Radius.circular(20)),
                                        ),
                                        child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.star, size: 16, color: AppThemData.primary07),
                                                const SizedBox(width: 5),
                                                Text(
                                                  Constant.calculateReview(reviewCount: parkingModel.reviewCount, reviewSum: parkingModel.reviewSum),
                                                  style: const TextStyle(color: AppThemData.grey10, fontFamily: AppThemData.semiBold),
                                                ),
                                              ],
                                            )),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return const SizedBox(
                              height: 8,
                            );
                          },
                        ),
            );
          }),
    );
  }
}
