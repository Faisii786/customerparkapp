import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:customerparkapp/constant/show_toast_dialog.dart';
import 'package:customerparkapp/controller/vehicle_list_controller.dart';
import 'package:customerparkapp/model/vehicle_brand_model.dart';
import 'package:customerparkapp/model/vehicle_model.dart';
import 'package:customerparkapp/themes/app_them_data.dart';
import 'package:customerparkapp/themes/common_ui.dart';
import 'package:customerparkapp/themes/round_button_fill.dart';
import 'package:customerparkapp/themes/text_field_widget.dart';
import 'package:customerparkapp/utils/dark_theme_provider.dart';
import 'package:provider/provider.dart';

class AddNewVehicleScreen extends StatelessWidget {
  const AddNewVehicleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: VehicleListController(),
        builder: (controller) {
          return Scaffold(
            appBar: UiInterface().customAppBar(context, themeChange, "add_new_vehicle".tr),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Add Car Details'.tr,
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: AppThemData.semiBold,
                          color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey10,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Customize your parking experience by adding your cars make, model, brand, and license plate.Finding and reserving the perfect spot just got easier with personalized car details!"'
                          .tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: AppThemData.regular,
                        color: themeChange.getThem() ? AppThemData.grey07 : AppThemData.grey07,
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Text("Car Brand".tr, style: const TextStyle(fontFamily: AppThemData.medium, fontSize: 14, color: AppThemData.grey07)),
                    const SizedBox(
                      height: 5,
                    ),
                    DropdownButtonFormField<VehicleBrandModel>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          errorStyle: const TextStyle(color: Colors.red),
                          isDense: true,
                          filled: true,
                          fillColor: themeChange.getThem() ? AppThemData.grey10 : AppThemData.grey03,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SvgPicture.asset("assets/icon/ic_car_image.svg", height: 24, width: 24),
                          ),
                          disabledBorder: UnderlineInputBorder(
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                            borderSide: BorderSide(color: themeChange.getThem() ? AppThemData.grey09 : AppThemData.grey04, width: 1),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                            borderSide: BorderSide(color: themeChange.getThem() ? AppThemData.primary06 : AppThemData.primary06, width: 1),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                            borderSide: BorderSide(color: themeChange.getThem() ? AppThemData.grey09 : AppThemData.grey04, width: 1),
                          ),
                          errorBorder: UnderlineInputBorder(
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                            borderSide: BorderSide(color: themeChange.getThem() ? AppThemData.grey09 : AppThemData.grey04, width: 1),
                          ),
                          border: UnderlineInputBorder(
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                            borderSide: BorderSide(color: themeChange.getThem() ? AppThemData.grey09 : AppThemData.grey04, width: 1),
                          ),
                          hintStyle: TextStyle(
                              fontSize: 14, color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey06, fontWeight: FontWeight.w500, fontFamily: AppThemData.medium),
                        ),
                        value: controller.selectedBrand.value.id == null ? null : controller.selectedBrand.value,
                        onChanged: (value) {
                          controller.selectedBrand.value = value!;
                          controller.getBrandModel();
                        },
                        style: TextStyle(
                            fontSize: 14, color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey08, fontWeight: FontWeight.w500, fontFamily: AppThemData.medium),
                        hint: Text(
                          "Select Vehicle Brand".tr,
                          style: TextStyle(color: themeChange.getThem() ? AppThemData.grey07 : AppThemData.grey07),
                        ),
                        items: controller.brandList.map((item) {
                          return DropdownMenuItem<VehicleBrandModel>(
                            value: item,
                            child: Text(item.name.toString(), style: const TextStyle()),
                          );
                        }).toList()),
                    const SizedBox(
                      height: 16,
                    ),
                    Text("Car Model".tr, style: const TextStyle(fontFamily: AppThemData.medium, fontSize: 14, color: AppThemData.grey07)),
                    const SizedBox(
                      height: 5,
                    ),
                    DropdownButtonFormField<VehicleModel>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          errorStyle: const TextStyle(color: Colors.red),
                          isDense: true,
                          filled: true,
                          fillColor: themeChange.getThem() ? AppThemData.grey10 : AppThemData.grey03,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SvgPicture.asset("assets/icon/ic_car_image.svg", height: 24, width: 24),
                          ),
                          disabledBorder: UnderlineInputBorder(
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                            borderSide: BorderSide(color: themeChange.getThem() ? AppThemData.grey09 : AppThemData.grey04, width: 1),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                            borderSide: BorderSide(color: themeChange.getThem() ? AppThemData.primary06 : AppThemData.primary06, width: 1),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                            borderSide: BorderSide(color: themeChange.getThem() ? AppThemData.grey09 : AppThemData.grey04, width: 1),
                          ),
                          errorBorder: UnderlineInputBorder(
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                            borderSide: BorderSide(color: themeChange.getThem() ? AppThemData.grey09 : AppThemData.grey04, width: 1),
                          ),
                          border: UnderlineInputBorder(
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                            borderSide: BorderSide(color: themeChange.getThem() ? AppThemData.grey09 : AppThemData.grey04, width: 1),
                          ),
                          hintStyle: TextStyle(
                              fontSize: 14, color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey06, fontWeight: FontWeight.w500, fontFamily: AppThemData.medium),
                        ),
                        value: controller.selectedVehicleModel.value.id == null ? null : controller.selectedVehicleModel.value,
                        onChanged: (value) {
                          controller.selectedVehicleModel.value = value!;
                        },
                        style: TextStyle(
                            fontSize: 14, color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey08, fontWeight: FontWeight.w500, fontFamily: AppThemData.medium),
                        hint: Text(
                          "Select Vehicle Model".tr,
                          style: TextStyle(color: themeChange.getThem() ? AppThemData.grey07 : AppThemData.grey07),
                        ),
                        items: controller.vehicleModelList.map((item) {
                          return DropdownMenuItem<VehicleModel>(
                            value: item,
                            child: Text(item.name.toString(), style: const TextStyle()),
                          );
                        }).toList()),
                    const SizedBox(
                      height: 16,
                    ),
                    TextFieldWidget(
                      title: 'Licence Plate Number'.tr,
                      onPress: () {},
                      controller: controller.vehicleNumberController.value,
                      hintText: 'Enter Licence Plate Number'.tr,
                      textInputType: TextInputType.emailAddress,
                      prefix: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SvgPicture.asset(
                          "assets/icon/ic_tag.svg",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: Container(
              color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.grey11,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: RoundedButtonFill(
                  title: "Save".tr,
                  color: AppThemData.primary06,
                  onPress: () {
                    if (controller.selectedBrand.value.id == null) {
                      ShowToastDialog.showToast("Select Vehicle Brand".tr);
                    } else if (controller.selectedVehicleModel.value.id == null) {
                      ShowToastDialog.showToast("Select Vehicle Model".tr);
                    } else if (controller.vehicleNumberController.value.text.isEmpty) {
                      ShowToastDialog.showToast("Enter Plate Number".tr);
                    } else {
                      controller.saveVehicleInformation();
                    }
                  },
                ),
              ),
            ),
          );
        });
  }
}
