import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:customerparkapp/constant/constant.dart';
import 'package:customerparkapp/controller/booking_parking_details_controller.dart';
import 'package:customerparkapp/controller/vehicle_list_controller.dart';
import 'package:customerparkapp/model/user_vehicle_model.dart';
import 'package:customerparkapp/themes/app_them_data.dart';
import 'package:customerparkapp/themes/round_button_fill.dart';
import 'package:customerparkapp/ui/add_select_vehicle/add_new_vehical_screen.dart';
import 'package:customerparkapp/utils/dark_theme_provider.dart';
import 'package:customerparkapp/utils/network_image_widget.dart';
import 'package:provider/provider.dart';

class SelectVehicleScreen extends StatelessWidget {
  const SelectVehicleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: VehicleListController(),
        builder: (controller) {
          return Scaffold(
            body: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                                'Select Vehicle'.tr,
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
                Expanded(
                  child: controller.isLoading.value
                      ? Constant.loader()
                      : controller.userVehicle.isEmpty
                          ? Constant.showEmptyView(message: "You have to create vehicle first".tr)
                          : Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: ListView.separated(
                                itemCount: controller.userVehicle.length,
                                shrinkWrap: true,
                                itemBuilder: (context, int index) {
                                  UserVehicleModel userVehicleModel = controller.userVehicle[index];
                                  return InkWell(
                                    onTap: () {
                                      controller.selectedVehicle.value = userVehicleModel;
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.grey03,
                                      ),
                                      child: Row(
                                        children: [
                                          NetworkImageWidget(
                                            height: 60,
                                            width: 60,
                                            imageUrl: userVehicleModel.vehicleModel!.image.toString(),
                                          ),
                                          const SizedBox(
                                            width: 15,
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  userVehicleModel.vehicleModel!.name.toString(),
                                                  style: TextStyle(
                                                      fontSize: 16, fontFamily: AppThemData.medium, color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey08),
                                                ),
                                                const SizedBox(
                                                  height: 4,
                                                ),
                                                Text(
                                                  userVehicleModel.vehicleNumber.toString(),
                                                  style: TextStyle(
                                                      fontSize: 14, fontFamily: AppThemData.medium, color: themeChange.getThem() ? AppThemData.grey07 : AppThemData.grey07),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Obx(
                                            () => Radio(
                                              value: userVehicleModel,
                                              groupValue: controller.selectedVehicle.value,
                                              activeColor: AppThemData.primary08,
                                              onChanged: (val) {
                                                if (val != null) {
                                                  controller.selectedVehicle.value = val;
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return const SizedBox(
                                    height: 10,
                                  );
                                },
                              ),
                            ),
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
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
                        title: "Add Vehicle".tr,
                        height: 5.5,
                        color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey10,
                        icon: Icon(Icons.add, color: themeChange.getThem() ? AppThemData.grey11 : AppThemData.grey01),
                        textColor: themeChange.getThem() ? AppThemData.grey11 : AppThemData.grey01,
                        fontSizes: 16,
                        isRight: false,
                        onPress: () {
                          Get.to(() => const AddNewVehicleScreen());
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: RoundedButtonFill(
                        title: "Save".tr,
                        height: 5.5,
                        color: AppThemData.primary06,
                        fontSizes: 16,
                        onPress: () {
                          BookingParkingDetailsController bookingParkingDetailsController = Get.put(BookingParkingDetailsController());
                          bookingParkingDetailsController.selectedVehicle.value = controller.selectedVehicle.value;

                          Get.back();
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
