import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:customerparkapp/constant/constant.dart';
import 'package:customerparkapp/constant/show_toast_dialog.dart';
import 'package:customerparkapp/controller/booking_parking_details_controller.dart';
import 'package:customerparkapp/controller/vehicle_list_controller.dart';
import 'package:customerparkapp/model/order_model.dart';
import 'package:customerparkapp/themes/app_them_data.dart';
import 'package:customerparkapp/themes/common_ui.dart';
import 'package:customerparkapp/themes/responsive.dart';
import 'package:customerparkapp/themes/round_button_fill.dart';
import 'package:customerparkapp/themes/text_field_widget.dart';
import 'package:customerparkapp/ui/add_select_vehicle/select_vehicle_screen.dart';
import 'package:customerparkapp/ui/booking_process/parking_view_screen.dart';
import 'package:customerparkapp/utils/dark_theme_provider.dart';
import 'package:customerparkapp/utils/fire_store_utils.dart';
import 'package:customerparkapp/utils/network_image_widget.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class BookingParkingDetailsScreen extends StatelessWidget {
  const BookingParkingDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: BookingParkingDetailsController(),
        builder: (controller) {
          return Scaffold(
            appBar: UiInterface().customAppBar(context, themeChange, "Select Date and Time".tr),
            body: controller.isLoading.value
                ? Constant.loader()
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'select_date'.tr,
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: AppThemData.medium,
                              fontWeight: FontWeight.w700,
                              color: themeChange.getThem() ? AppThemData.grey07 : AppThemData.grey07,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Container(
                            decoration: BoxDecoration(color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.grey03, borderRadius: BorderRadius.circular(15)),
                            child: SfDateRangePicker(
                              selectionMode: DateRangePickerSelectionMode.single,
                              view: DateRangePickerView.month,
                              selectionColor: AppThemData.primary06,
                              selectionTextStyle: const TextStyle(color: Colors.black),
                              onSelectionChanged: (dateRangePickerSelectionChangedArgs) {
                                controller.selectedDateTime.value = dateRangePickerSelectionChangedArgs.value;
                              },
                              minDate: DateTime.now(),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            'duration'.tr,
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: AppThemData.medium,
                              fontWeight: FontWeight.w700,
                              color: themeChange.getThem() ? AppThemData.grey07 : AppThemData.grey07,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Obx(
                            () => Slider(
                              value: controller.selectedDuration.value,
                              onChanged: (value) {
                                controller.selectedDuration.value = value;

                                controller.startTimeController.value.text = DateFormat('HH:mm').format(controller.startTime.value);
                                Duration duration = Duration(hours: controller.selectedDuration.value.toInt());

                                controller.endTime.value = controller.startTime.value.add(duration);
                                controller.endTimeController.value.text = DateFormat('HH:mm').format(controller.endTime.value);
                              },
                              autofocus: false,
                              activeColor: AppThemData.primary06,
                              inactiveColor: AppThemData.grey03,
                              min: 0,
                              max: 24,
                              divisions: 24,
                              label: "${controller.selectedDuration.value.round().toString()} hours".tr,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Select Time'.tr,
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: AppThemData.medium,
                              fontWeight: FontWeight.w700,
                              color: themeChange.getThem() ? AppThemData.grey07 : AppThemData.grey07,
                            ),
                          ),
                          const SizedBox(
                            height: 14,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    TimeOfDay? startTime = await Constant.selectTime(context);

                                    if (startTime != null) {
                                      controller.startTime.value = DateTime(controller.selectedDateTime.value.year, controller.selectedDateTime.value.month,
                                          controller.selectedDateTime.value.day, startTime.hour, startTime.minute);

                                      controller.startTimeController.value.text = DateFormat('hh:mm a').format(controller.startTime.value);

                                      Duration duration = Duration(hours: controller.selectedDuration.value.toInt());

                                      controller.endTime.value = controller.startTime.value.add(duration);
                                      controller.endTimeController.value.text = DateFormat('hh:mm a').format(controller.endTime.value);
                                    }
                                  },
                                  child: TextFieldWidget(
                                    onPress: () {},
                                    controller: controller.startTimeController.value,
                                    textInputType: const TextInputType.numberWithOptions(decimal: true, signed: true,),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                                    ],
                                    hintText: 'Select Time'.tr,
                                    enable: false,
                                    prefix: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: SvgPicture.asset(
                                        "assets/icon/ic_clock.svg",
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
                                  onTap: () async {
                                    TimeOfDay? startTime = await Constant.selectTime(context);

                                    if (startTime != null) {
                                      controller.endTime.value = DateTime(controller.selectedDateTime.value.year, controller.selectedDateTime.value.month,
                                          controller.selectedDateTime.value.day, startTime.hour, startTime.minute);

                                      controller.endTimeController.value.text = DateFormat('hh:mm a').format(controller.endTime.value);

                                      Duration duration = Duration(hours: controller.selectedDuration.value.toInt());

                                      controller.startTime.value = controller.endTime.value.subtract(duration);
                                      controller.startTimeController.value.text = DateFormat('hh:mm a').format(controller.startTime.value);
                                    }
                                  },
                                  child: TextFieldWidget(
                                    onPress: () {},
                                    controller: controller.endTimeController.value,
                                    textInputType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                                    ],
                                    hintText: 'Select Time'.tr,
                                    enable: false,
                                    prefix: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: SvgPicture.asset(
                                        "assets/icon/ic_clock.svg",
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Vehicle'.tr,
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: AppThemData.medium,
                              fontWeight: FontWeight.w700,
                              color: themeChange.getThem() ? AppThemData.grey07 : AppThemData.grey07,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          controller.selectedVehicle.value.id != null
                              ? Container(
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
                                        imageUrl: controller.selectedVehicle.value.vehicleModel!.image.toString(),
                                      ),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              controller.selectedVehicle.value.vehicleModel!.name.toString(),
                                              style:
                                                  TextStyle(fontSize: 16, fontFamily: AppThemData.medium, color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey08),
                                            ),
                                            const SizedBox(
                                              height: 4,
                                            ),
                                            Text(
                                              controller.selectedVehicle.value.vehicleNumber.toString(),
                                              style:
                                                  TextStyle(fontSize: 14, fontFamily: AppThemData.medium, color: themeChange.getThem() ? AppThemData.grey07 : AppThemData.grey07),
                                            ),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                          onTap: () {
                                            VehicleListController vehicleListController = Get.put(VehicleListController());
                                            vehicleListController.selectedVehicle.value = controller.selectedVehicle.value;
                                            showBottomSheet(context);
                                          },
                                          child: Text(
                                            "Change".tr,
                                            style: TextStyle(
                                                fontSize: 14,
                                                decoration: TextDecoration.underline,
                                                fontFamily: AppThemData.regular,
                                                color: themeChange.getThem() ? AppThemData.blueLight07 : AppThemData.blueLight07),
                                          ))
                                    ],
                                  ),
                                )
                              : InkWell(
                                  onTap: () {
                                    VehicleListController vehicleListController = Get.put(VehicleListController());
                                    vehicleListController.selectedVehicle.value = controller.selectedVehicle.value;
                                    showBottomSheet(context);
                                  },
                                  child: SizedBox(
                                    width: Responsive.width(100, context),
                                    child: DottedBorder(
                                      borderType: BorderType.RRect,
                                      radius: const Radius.circular(40),
                                      color: AppThemData.primary09,
                                      child: Container(
                                        decoration: const BoxDecoration(color: AppThemData.warning03, borderRadius: BorderRadius.all(Radius.circular(40))),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.add,
                                                color: AppThemData.primary09,
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                'Select Vehicle'.tr,
                                                style: const TextStyle(
                                                  color: AppThemData.primary09,
                                                  fontSize: 14,
                                                  fontFamily: AppThemData.medium,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                          const SizedBox(
                            height: 15,
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
                  title: "Next".tr,
                  color: AppThemData.primary06,
                  onPress: () {
                    if (controller.selectedVehicle.value.id == null) {
                      ShowToastDialog.showToast("Please select your vehicle".tr);
                    } else if (controller.selectedDuration.value < 1) {
                      ShowToastDialog.showToast("Please select duration minimum one hour".tr);
                    } else {
                      OrderModel orderModel = OrderModel();
                      orderModel.parkingDetails = controller.parkingModel.value;
                      orderModel.userVehicle = controller.vehicle.value;
                      orderModel.duration = controller.selectedDuration.value.toString();
                      orderModel.bookingDate =
                          Timestamp.fromDate(DateTime(controller.selectedDateTime.value.year, controller.selectedDateTime.value.month, controller.selectedDateTime.value.day));
                      orderModel.bookingStartTime = Timestamp.fromDate(controller.startTime.value);
                      orderModel.bookingEndTime = Timestamp.fromDate(controller.endTime.value);
                      orderModel.status = Constant.placed;
                      orderModel.userId = FireStoreUtils.getCurrentUid();
                      orderModel.id = Constant.getUuid();
                      orderModel.parkingId = controller.parkingModel.value.id;
                      orderModel.subTotal = controller.calculateParkingAmount().toString();
                      orderModel.taxList = Constant.taxList;
                      orderModel.userVehicle = controller.selectedVehicle.value;
                      Get.to(() => const ParkingViewScreen(), arguments: {"orderModel": orderModel});
                    }
                  },
                ),
              ),
            ),
          );
        });
  }

  showBottomSheet(BuildContext context) {
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
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.45,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, scrollController) => const SelectVehicleScreen(),
      ),
    );
  }
}
