// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:customerparkapp/constant/constant.dart';
import 'package:customerparkapp/constant/show_toast_dialog.dart';
import 'package:customerparkapp/controller/home_controller.dart';
import 'package:customerparkapp/model/parking_model.dart';
import 'package:customerparkapp/themes/app_them_data.dart';
import 'package:customerparkapp/themes/responsive.dart';
import 'package:customerparkapp/themes/round_button_fill.dart';
import 'package:customerparkapp/ui/booking_process/booking_parking_details_screen.dart';
import 'package:customerparkapp/ui/chat/inbox_screen.dart';
import 'package:customerparkapp/ui/parking_details_screen/parking_details_screen.dart';
import 'package:customerparkapp/ui/search/search_screen.dart';
import 'package:customerparkapp/utils/dark_theme_provider.dart';
import 'package:customerparkapp/utils/fire_store_utils.dart';
import 'package:customerparkapp/utils/network_image_widget.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: themeChange.getThem() ? AppThemData.grey10 : AppThemData.white,
          leading: Icon(Icons.search, color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey08),
          titleSpacing: 0,
          title: InkWell(
            onTap: () {
              Get.to(const SearchScreen());
            },
            child: TextFormField(
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                    hintStyle: TextStyle(
                        fontSize: 14, color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey06, fontWeight: FontWeight.w500, fontFamily: AppThemData.medium),
                    filled: false,
                    enabled: false,
                    border: InputBorder.none,
                    hintText: "Search Here".tr)),
          ),
          actions: const [
            // InkWell(
            //   onTap: () {
            //     Get.to(const InboxScreen());
            //   },
            //   child: Padding(
            //     padding: const EdgeInsets.only(right: 10),
            //     child: Icon(Icons.chat_bubble_outline, color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey08),
            //   ),
            // )
          ],
        ),
        body: GetX<HomeController>(
            init: HomeController(),
            builder: (controller) {
              return controller.isLoading.value
                  ? Constant.loader()
                  : controller.permissionDenied.value
                      ? Center(
                          child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 62),
                          child: RoundedButtonFill(
                            title: "Allow Permission".tr,
                            height: 5.5,
                            color: AppThemData.primary06,
                            fontSizes: 16,
                            onPress: () async {
                              controller.getLocation();
                            },
                          ),
                        ))
                      : Stack(
                          children: [
                            Constant.selectedMapType == 'osm'
                                ? OSMFlutter(
                                    controller: controller.mapOsmController,
                                    osmOption: const OSMOption(
                                      userTrackingOption: UserTrackingOption(
                                        enableTracking: false,
                                        unFollowUser: false,
                                      ),
                                      zoomOption: ZoomOption(
                                        initZoom: 16,
                                        minZoomLevel: 2,
                                        maxZoomLevel: 19,
                                        stepZoom: 1.0,
                                      ),
                                    ),
                                    onMapIsReady: (active) async {
                                      if (active) {
                                        // controller.getArgument();
                                        // ShowToastDialog.closeLoader();
                                      }
                                    })
                                : GoogleMap(
                                    myLocationEnabled: true,
                                    myLocationButtonEnabled: true,
                                    zoomControlsEnabled: false,
                                    mapType: MapType.terrain,
                                    markers: Set<Marker>.of(controller.markers.values),
                                    onMapCreated: (GoogleMapController mapController) {
                                      controller.mapController = mapController;
                                    },
                                    mapToolbarEnabled: true,
                                    initialCameraPosition: CameraPosition(
                                      zoom: 18,
                                      target: LatLng(
                                        Constant.currentLocation != null ? Constant.currentLocation!.latitude! : 45.521563,
                                        Constant.currentLocation != null ? Constant.currentLocation!.longitude! : -122.677433,
                                      ),
                                    ),
                                  ),
                            controller.parkingList.isEmpty
                                ? Container()
                                : Align(
                                    alignment: Alignment.bottomCenter,
                                    child: SizedBox(
                                      height: Responsive.height(30, context),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 22),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                    child: Text("Near You".tr,
                                                        style: const TextStyle(
                                                          color: AppThemData.grey10,
                                                          fontSize: 16,
                                                          fontFamily: AppThemData.semiBold,
                                                        ))),
                                                InkWell(
                                                  onTap: () {
                                                    Get.to(const SearchScreen());
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Text("View All".tr,
                                                          style: const TextStyle(
                                                            color: AppThemData.primary09,
                                                            fontSize: 14,
                                                            fontFamily: AppThemData.semiBold,
                                                          )),
                                                      const Icon(
                                                        Icons.chevron_right,
                                                        color: AppThemData.primary09,
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: PageView.builder(
                                              pageSnapping: true,
                                              controller: PageController(viewportFraction: 0.88),
                                              onPageChanged: (value) {
                                                if (Constant.selectedMapType == 'osm') {
                                                  controller.mapOsmController.goToLocation(
                                                      GeoPoint(
                                                          latitude: controller.parkingList[value].location!.latitude!,
                                                          longitude: controller.parkingList[value].location!.longitude!),
                                                      );
                                                } else {
                                                  CameraUpdate cameraUpdate = CameraUpdate.newCameraPosition(CameraPosition(
                                                    zoom: 18,
                                                    target: LatLng(
                                                      controller.parkingList[value].location!.latitude!,
                                                      controller.parkingList[value].location!.longitude!,
                                                    ),
                                                  ));
                                                  controller.mapController!.animateCamera(cameraUpdate);
                                                }
                                              },
                                              itemCount: controller.parkingList.length,
                                              scrollDirection: Axis.horizontal,
                                              itemBuilder: (context, index) {
                                                ParkingModel parkingModel = controller.parkingList[index];
                                                return Padding(
                                                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: index == 0 ? 0 : 10),
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(15),
                                                    child: Container(
                                                      color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.white,
                                                      child: Stack(
                                                        children: [
                                                          Column(
                                                            children: [
                                                              Expanded(
                                                                child: SizedBox(
                                                                  width: Responsive.width(100, context),
                                                                  child: NetworkImageWidget(imageUrl: parkingModel.image.toString()),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                                child: Column(
                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Expanded(
                                                                          child: Text(
                                                                            parkingModel.name.toString(),
                                                                            style: TextStyle(
                                                                              color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey10,
                                                                              fontSize: 16,
                                                                              height: 1.57,
                                                                              fontFamily: AppThemData.bold,
                                                                              fontWeight: FontWeight.w500,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          "${Constant.amountShow(amount: parkingModel.perHrPrice.toString())} / hour",
                                                                          style: const TextStyle(
                                                                            color: AppThemData.blueLight07,
                                                                            fontSize: 14,
                                                                            height: 1.57,
                                                                            fontFamily: AppThemData.medium,
                                                                            fontWeight: FontWeight.w500,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        Expanded(
                                                                          child: Text(
                                                                            parkingModel.address.toString(),
                                                                            maxLines: 1,
                                                                            style: const TextStyle(
                                                                              color: AppThemData.grey07,
                                                                              fontSize: 12,
                                                                              height: 1.57,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              fontFamily: AppThemData.regular,
                                                                              fontWeight: FontWeight.w500,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          width: 10,
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            SvgPicture.asset(
                                                                                parkingModel.parkingType == "2" ? "assets/icon/ic_bike.svg" : "assets/icon/ic_car_fill.svg",
                                                                                color: AppThemData.grey09),
                                                                            Text(
                                                                              " ${parkingModel.parkingType.toString()} wheel".tr,
                                                                              maxLines: 1,
                                                                              style: TextStyle(
                                                                                color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey09,
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
                                                                    const SizedBox(
                                                                      height: 10,
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        Expanded(
                                                                          child: RoundedButtonFill(
                                                                            title: "Book Now".tr,
                                                                            height: 4.5,
                                                                            color: AppThemData.primary06,
                                                                            fontSizes: 12,
                                                                            onPress: () {
                                                                              if (parkingModel.userId == FireStoreUtils.getCurrentUid()) {
                                                                                ShowToastDialog.showToast("You can't book your own parking.");
                                                                              } else {
                                                                                Get.to(() => const BookingParkingDetailsScreen(), arguments: {"parkingModel": parkingModel});
                                                                              }
                                                                            },
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          width: 10,
                                                                        ),
                                                                        Expanded(
                                                                          child: RoundedButtonFill(
                                                                            title: "View Details".tr,
                                                                            height: 4.5,
                                                                            icon: Icon(Icons.chevron_right, color: themeChange.getThem() ? AppThemData.white : AppThemData.grey11),
                                                                            color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.white,
                                                                            textColor: themeChange.getThem() ? AppThemData.white : AppThemData.grey11,
                                                                            fontSizes: 12,
                                                                            isRight: true,
                                                                            onPress: () {
                                                                              Get.to(() => const ParkingDetailsScreen(), arguments: {"parkingModel": parkingModel});
                                                                            },
                                                                          ),
                                                                        )
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                  ],
                                                                ),
                                                              )
                                                            ],
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
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          ],
                        );
            }),
      ),
    );
  }
}
