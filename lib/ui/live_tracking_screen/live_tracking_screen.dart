import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:customerparkapp/constant/constant.dart';
import 'package:customerparkapp/controller/live_tracking_controller.dart';
import 'package:customerparkapp/themes/app_them_data.dart';
import 'package:customerparkapp/themes/common_ui.dart';
import 'package:customerparkapp/utils/dark_theme_provider.dart';
import 'package:provider/provider.dart';

class LiveTrackingScreen extends StatelessWidget {
  const LiveTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX(
        init: LiveTrackingController(),
        builder: (controller) {
          return Scaffold(
            appBar: UiInterface().customAppBar(
              context,
              themeChange,
              isBack: true,
              ''.tr,
            ),
            body: controller.isLoading.value
                ? Constant.loader()
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
                                roadConfiguration: RoadOption(
                                  roadColor: AppThemData.primary06,
                                  roadWidth: 25,
                                  roadBorderColor: AppThemData.primary06,
                                  roadBorderWidth: 5,
                                  zoomInto: false,
                                ),
                              ),
                              onMapIsReady: (active) async {
                                if (active) {}
                              })
                          : GoogleMap(
                              mapType: MapType.terrain,
                              myLocationEnabled: false,
                              myLocationButtonEnabled: false,
                              zoomControlsEnabled: false,
                              polylines: Set<Polyline>.of(controller.polyLines.values),
                              padding: const EdgeInsets.only(
                                top: 22.0,
                              ),
                              markers: Set<Marker>.of(controller.markers.values),
                              onMapCreated: (GoogleMapController mapController) {
                                controller.mapController = mapController;
                              },
                              initialCameraPosition: CameraPosition(
                                zoom: 15,
                                target: LatLng(Constant.currentLocation != null ? Constant.currentLocation!.latitude! : 45.521563,
                                    Constant.currentLocation != null ? Constant.currentLocation!.longitude! : -122.677433),
                              ),
                            ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: Container(
                          decoration: BoxDecoration(color: themeChange.getThem() ? AppThemData.blue : AppThemData.blue, borderRadius: BorderRadius.circular(60)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                  child: SvgPicture.asset("assets/icon/ic_current_location.svg"),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        controller.orderModel.value.parkingDetails!.address.toString(),
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: AppThemData.semiBold,
                                          color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey01,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${double.parse(controller.distance.value).toStringAsFixed(1)} Km",
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: AppThemData.semiBold,
                                          color: themeChange.getThem() ? AppThemData.blueLight01 : AppThemData.blueLight01,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
            bottomNavigationBar: Container(
              color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.grey11,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      "assets/icon/ic_location_image.svg",
                      height: 40,
                      width: 40,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            controller.orderModel.value.parkingDetails!.name.toString(),
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: AppThemData.semiBold,
                              color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey01,
                            ),
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          Text(
                            controller.orderModel.value.parkingDetails!.address.toString(),
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: AppThemData.regular,
                              color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey07,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: const Icon(Icons.close, color: AppThemData.error07))
                  ],
                ),
              ),
            ),
          );
        });
  }
}
