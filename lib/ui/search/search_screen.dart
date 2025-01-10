// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:customerparkapp/constant/constant.dart';
import 'package:customerparkapp/constant/show_toast_dialog.dart';
import 'package:customerparkapp/controller/search_controller.dart';
import 'package:customerparkapp/model/location_lat_lng.dart';
import 'package:customerparkapp/model/parking_model.dart';
import 'package:customerparkapp/themes/app_them_data.dart';
import 'package:customerparkapp/themes/responsive.dart';
import 'package:customerparkapp/themes/round_button_fill.dart';
import 'package:customerparkapp/ui/parking_details_screen/parking_details_screen.dart';
import 'package:customerparkapp/utils/dark_theme_provider.dart';
import 'package:customerparkapp/utils/fire_store_utils.dart';
import 'package:customerparkapp/utils/network_image_widget.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:customerparkapp/utils/place_picker_osm.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<SearchScreenController>(
      init: SearchScreenController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: themeChange.getThem() ? AppThemData.grey10 : AppThemData.white,
            leading: InkWell(onTap: () => Get.back(), child: Icon(Icons.arrow_back_sharp, color: themeChange.getThem() ? AppThemData.grey02 : AppThemData.grey08)),
            titleSpacing: -10,
            title: InkWell(
              onTap: () async {
                if (Constant.selectedMapType == 'osm') {
                  Get.to(() => const LocationPicker())?.then((value) {
                    if (value != null) {
                      controller.searchController.value.text = value.displayName!.toString();
                      controller.latLng.value = LocationLatLng(latitude: value.lat, longitude: value.lon);
                      controller.getParking();
                    }
                  });
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlacePicker(
                        apiKey: Constant.mapAPIKey,
                        onPlacePicked: (result) async {
                          Get.back();
                          controller.searchController.value.text = result.formattedAddress.toString();
                          controller.latLng.value = LocationLatLng(latitude: result.geometry!.location.lat, longitude: result.geometry!.location.lng);
                          controller.getParking();
                        },
                        initialPosition: const LatLng(-33.8567844, 151.213108),
                        useCurrentLocation: true,
                        selectInitialPosition: true,
                        usePinPointingSearch: true,
                        usePlaceDetailSearch: true,
                        zoomGesturesEnabled: true,
                        zoomControlsEnabled: true,
                        resizeToAvoidBottomInset: false, // only works in page mode, less flickery, remove if wrong offsets
                      ),
                    ),
                  );
                }
              },
              child: TextFormField(
                  controller: controller.searchController.value,
                  textAlign: TextAlign.start,
                  style: TextStyle(color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey09, fontFamily: AppThemData.medium, overflow: TextOverflow.ellipsis),
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: themeChange.getThem() ? AppThemData.grey02 : AppThemData.grey08),
                      hintStyle: TextStyle(
                          fontSize: 14, color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey06, fontWeight: FontWeight.w500, fontFamily: AppThemData.medium),
                      filled: false,
                      enabled: false,
                      border: InputBorder.none,
                      hintText: "Search Here".tr)),
            ),
            actions: [
              InkWell(
                onTap: () {
                  filterBottomSheet(context, controller);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(Icons.filter_list, color: themeChange.getThem() ? AppThemData.grey02 : AppThemData.grey08),
                ),
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: controller.isLoading.value
                ? Constant.loader()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          'Result'.tr,
                          style: const TextStyle(
                            color: AppThemData.grey08,
                            fontSize: 16,
                            fontFamily: AppThemData.medium,
                          ),
                        ),
                      ),
                      Expanded(
                        child: controller.parkingList.isEmpty
                            ? Constant.showEmptyView(message: "No Parking Found".tr)
                            : ListView.separated(
                                itemCount: controller.parkingList.length,
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemBuilder: (context, int index) {
                                  ParkingModel parkingModel = controller.parkingList[index];
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
                                                                    controller.getParking();
                                                                    ShowToastDialog.closeLoader();
                                                                  });
                                                                } else {
                                                                  await FireStoreUtils.bookMarked(parkingModel).then((value) {
                                                                    controller.getParking();
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
                                                        style: const TextStyle(
                                                            color: AppThemData.grey07, fontSize: 12, fontFamily: AppThemData.regular, overflow: TextOverflow.ellipsis),
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      Row(
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
                                                                        "", //snapshot.data!
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
                                                            "${Constant.amountShow(amount: parkingModel.perHrPrice.toString())}/hr",
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
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  filterBottomSheet(BuildContext context, SearchScreenController controller) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (context) => FractionallySizedBox(
              heightFactor: 0.6,
              child: StatefulBuilder(builder: (context1, setState) {
                final themeChange = Provider.of<DarkThemeProvider>(context1);
                return Obx(
                  () => Scaffold(
                    body: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.grey01,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Center(
                                    child: Container(
                                      width: 134,
                                      height: 5,
                                      margin: const EdgeInsets.only(bottom: 6),
                                      decoration: ShapeDecoration(
                                        color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.labelColorLightPrimary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Filter'.tr,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontFamily: AppThemData.medium,
                                            color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey10,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Get.back();
                                        },
                                        child: Icon(
                                          Icons.close,
                                          color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sort By'.tr,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: AppThemData.medium,
                                    color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey10,
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          controller.selectedSortBy.value = "distance".tr;
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          decoration: ShapeDecoration(
                                            gradient: controller.selectedSortBy.value == "distance".tr
                                                ? const LinearGradient(
                                                    begin: Alignment(0.00, 1.00),
                                                    end: Alignment(0, -1),
                                                    colors: AppThemData.gradient03,
                                                  )
                                                : null,
                                            shape: RoundedRectangleBorder(
                                              side: const BorderSide(width: 0.50, color: AppThemData.grey05),
                                              borderRadius: BorderRadius.circular(100),
                                            ),
                                          ),
                                          child: Text(
                                            'Distance'.tr,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: controller.selectedSortBy.value == "distance".tr ? AppThemData.grey10 : AppThemData.grey07,
                                              fontSize: 14,
                                              fontFamily: AppThemData.regular,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          controller.selectedSortBy.value = "lower_price".tr;
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          decoration: ShapeDecoration(
                                            gradient: controller.selectedSortBy.value == "lower_price".tr
                                                ? const LinearGradient(
                                                    begin: Alignment(0.00, 1.00),
                                                    end: Alignment(0, -1),
                                                    colors: AppThemData.gradient03,
                                                  )
                                                : null,
                                            shape: RoundedRectangleBorder(
                                              side: const BorderSide(width: 0.50, color: AppThemData.grey05),
                                              borderRadius: BorderRadius.circular(100),
                                            ),
                                          ),
                                          child: Text(
                                            'Lower Price'.tr,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: controller.selectedSortBy.value == "lower_price".tr ? AppThemData.grey10 : AppThemData.grey07,
                                              fontSize: 14,
                                              fontFamily: AppThemData.regular,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          controller.selectedSortBy.value = "higher_price".tr;
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          decoration: ShapeDecoration(
                                            gradient: controller.selectedSortBy.value == "higher_price".tr
                                                ? const LinearGradient(
                                                    begin: Alignment(0.00, 1.00),
                                                    end: Alignment(0, -1),
                                                    colors: AppThemData.gradient03,
                                                  )
                                                : null,
                                            shape: RoundedRectangleBorder(
                                              side: const BorderSide(width: 0.50, color: AppThemData.grey05),
                                              borderRadius: BorderRadius.circular(100),
                                            ),
                                          ),
                                          child: Text(
                                            'Higher Price'.tr,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: controller.selectedSortBy.value == "higher_price".tr ? AppThemData.grey10 : AppThemData.grey07,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Divider(color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.grey03, thickness: 1),
                                ),
                                Text(
                                  'Choose Parking Type'.tr,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: AppThemData.medium,
                                    color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey10,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        child: Row(
                                      children: [
                                        SvgPicture.asset("assets/icon/ic_bike.svg", color: AppThemData.grey08, height: 24, width: 24),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text("2 Wheel".tr,
                                            style: TextStyle(color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey09, fontFamily: AppThemData.medium)),
                                      ],
                                    )),
                                    Radio<String>(
                                      value: "2",
                                      groupValue: controller.parkingType.value,
                                      activeColor: AppThemData.primary07,
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: const VisualDensity(
                                        horizontal: VisualDensity.minimumDensity,
                                        vertical: VisualDensity.minimumDensity,
                                      ),
                                      onChanged: controller.handleParkingChange,
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        child: Row(
                                      children: [
                                        SvgPicture.asset("assets/icon/ic_car_fill.svg", color: AppThemData.grey08, height: 24, width: 24),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text("4 Wheel".tr,
                                            style: TextStyle(color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey09, fontFamily: AppThemData.medium)),
                                      ],
                                    )),
                                    Radio<String>(
                                      value: "4",
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: const VisualDensity(
                                        horizontal: VisualDensity.minimumDensity,
                                        vertical: VisualDensity.minimumDensity,
                                      ),
                                      groupValue: controller.parkingType.value,
                                      activeColor: AppThemData.primary07,
                                      onChanged: controller.handleParkingChange,
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Divider(color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.grey03, thickness: 1),
                                ),
                                controller.selectedSortBy.value == "distance".tr
                                    ? Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Distance'.tr,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: AppThemData.medium,
                                              color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey10,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Slider(
                                            value: controller.selectedKm.value,
                                            onChanged: (value) {
                                              controller.selectedKm.value = value;
                                            },
                                            autofocus: false,
                                            activeColor: AppThemData.primary06,
                                            inactiveColor: AppThemData.grey03,
                                            min: 0,
                                            max: 24,
                                            divisions: 24,
                                            label: "${controller.selectedKm.value.round().toString()} KM",
                                          ),
                                        ],
                                      )
                                    : Container()
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    bottomNavigationBar: Container(
                      color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.grey11,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          children: [
                            Expanded(
                                child: RoundedButtonFill(
                              title: "Cancel".tr,
                              height: 5.5,
                              color: themeChange.getThem() ? AppThemData.grey09 : AppThemData.grey10,
                              fontSizes: 16,
                              textColor: AppThemData.grey01,
                              onPress: () async {
                                Get.back();
                              },
                            )),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                child: RoundedButtonFill(
                              title: "Apply".tr,
                              height: 5.5,
                              color: AppThemData.primary06,
                              fontSizes: 16,
                              onPress: () async {
                                Get.back();
                                controller.filterParking();
                              },
                            )),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ));
  }
}
