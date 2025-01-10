import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:customerparkapp/constant/constant.dart';
import 'package:customerparkapp/constant/send_notification.dart';
import 'package:customerparkapp/constant/show_toast_dialog.dart';
import 'package:customerparkapp/controller/dashboard_controller.dart';
import 'package:customerparkapp/controller/parking_ticket_controller.dart';
import 'package:customerparkapp/model/tax_model.dart';
import 'package:customerparkapp/model/user_model.dart';
import 'package:customerparkapp/themes/app_them_data.dart';
import 'package:customerparkapp/themes/common_ui.dart';
import 'package:customerparkapp/themes/responsive.dart';
import 'package:customerparkapp/themes/round_button_fill.dart';
import 'package:customerparkapp/ui/dashboard_screen.dart';
import 'package:customerparkapp/ui/live_tracking_screen/live_tracking_screen.dart';
import 'package:customerparkapp/utils/dark_theme_provider.dart';
import 'package:customerparkapp/utils/fire_store_utils.dart';
import 'package:customerparkapp/utils/network_image_widget.dart';
import 'package:customerparkapp/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ParkingTicketScreen extends StatelessWidget {
  const ParkingTicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: ParkingTicketController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: themeChange.getThem() ? AppThemData.warning06 : AppThemData.warning06,
            appBar: UiInterface().customAppBar(
              context,
              themeChange,
              "".tr,
              onBackTap: () {
                DashboardScreenController dashboardController = Get.put(DashboardScreenController());
                dashboardController.selectedIndex(2);
                Get.offAll(() => const DashBoardScreen());
              },
              backgroundColor: AppThemData.warning06,
            ),
            body: controller.isLoading.value
                ? Constant.loader()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Stack(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            color: AppThemData.white,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                                    child: NetworkImageWidget(
                                      imageUrl: controller.orderModel.value.parkingDetails!.image.toString(),
                                      height: Responsive.height(12, context),
                                      width: Responsive.height(100, context),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    controller.orderModel.value.parkingDetails!.name.toString(),
                                    style: TextStyle(
                                      color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey09,
                                      fontSize: 18,
                                      fontFamily: AppThemData.semiBold,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.location_on_outlined, color: AppThemData.grey07, size: 20),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                        child: Text(
                                          controller.orderModel.value.parkingDetails!.address.toString(),
                                          style: const TextStyle(
                                            color: AppThemData.grey07,
                                            fontSize: 14,
                                            fontFamily: AppThemData.regular,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Vehicle'.tr,
                                        style: const TextStyle(
                                          color: AppThemData.grey07,
                                          fontSize: 14,
                                          fontFamily: AppThemData.regular,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        "${controller.orderModel.value.userVehicle!.vehicleBrand!.name.toString()} ${controller.orderModel.value.userVehicle!.vehicleModel!.name.toString()}",
                                        style: TextStyle(
                                          color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey09,
                                          fontSize: 14,
                                          fontFamily: AppThemData.medium,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Parking Spot'.tr,
                                        style: const TextStyle(
                                          color: AppThemData.grey07,
                                          fontSize: 14,
                                          fontFamily: AppThemData.regular,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        controller.orderModel.value.parkingSlotId.toString(),
                                        style: TextStyle(
                                          color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey09,
                                          fontSize: 14,
                                          fontFamily: AppThemData.medium,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        child: QrImageView(
                                          data: controller.orderModel.value.id.toString(),
                                          version: QrVersions.auto,
                                          padding: EdgeInsets.zero,
                                          size: 80.0,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Scan this on the scanner machine when you are in the parking slot'.tr,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: AppThemData.medium,
                                            color: themeChange.getThem() ? AppThemData.grey08 : AppThemData.grey08,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 5),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                'Total'.tr,
                                                style: const TextStyle(
                                                  color: AppThemData.grey08,
                                                  fontSize: 14,
                                                  fontFamily: AppThemData.semiBold,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              Constant.amountShow(amount: controller.calculateAmount().toString()),
                                              style: const TextStyle(
                                                color: AppThemData.primary07,
                                                fontSize: 14,
                                                fontFamily: AppThemData.semiBold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Divider(
                                        thickness: 1,
                                        color: themeChange.getThem() ? AppThemData.grey09 : AppThemData.grey03,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 5),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                'Sub Total'.tr,
                                                style: const TextStyle(
                                                  color: AppThemData.grey07,
                                                  fontSize: 14,
                                                  fontFamily: AppThemData.medium,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              Constant.amountShow(amount: controller.orderModel.value.subTotal.toString()),
                                              style: const TextStyle(
                                                color: AppThemData.grey08,
                                                fontSize: 14,
                                                fontFamily: AppThemData.semiBold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 5),
                                        child: Row(
                                          children: [
                                            // Expanded(
                                            //   child: Text(
                                            //     'Coupon Applied'.tr,
                                            //     style: const TextStyle(
                                            //       color: AppThemData.grey07,
                                            //       fontSize: 16,
                                            //       fontFamily: AppThemData.medium,
                                            //     ),
                                            //   ),
                                            // ),
                                            // Text(
                                            //   Constant.amountShow(amount: controller.couponAmount.toString()),
                                            //   style: const TextStyle(
                                            //     color: AppThemData.grey08,
                                            //     fontSize: 16,
                                            //     fontFamily: AppThemData.semiBold,
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                      ),
                                      controller.orderModel.value.taxList == null
                                          ? const SizedBox()
                                          : ListView.builder(
                                              itemCount: controller.orderModel.value.taxList!.length,
                                              shrinkWrap: true,
                                              padding: EdgeInsets.zero,
                                              itemBuilder: (context, index) {
                                                TaxModel taxModel = controller.orderModel.value.taxList![index];
                                                return Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          "${taxModel.title.toString()} (${taxModel.type == "fix" ? Constant.amountShow(amount: taxModel.tax) : "${taxModel.tax}%"})",
                                                          style: const TextStyle(
                                                            color: AppThemData.grey07,
                                                            fontSize: 14,
                                                            fontFamily: AppThemData.medium,
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        "${Constant.amountShow(amount: Constant().calculateTax(amount: (double.parse(controller.orderModel.value.subTotal.toString()) - double.parse(controller.couponAmount.value.toString())).toString(), taxModel: taxModel).toStringAsFixed(Constant.currencyModel!.decimalDigits!).toString())} ",
                                                        style: const TextStyle(
                                                          color: AppThemData.grey08,
                                                          fontSize: 14,
                                                          fontFamily: AppThemData.semiBold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  // Padding(
                                  //   padding: const EdgeInsets.symmetric(vertical: 5),
                                  //   child: Row(
                                  //     children: [
                                  //       const Expanded(
                                  //         child: Text(
                                  //           'Duration',
                                  //           style: TextStyle(
                                  //             color: AppThemData.grey07,
                                  //             fontSize: 16,
                                  //             fontFamily: AppThemData.medium,
                                  //           ),
                                  //         ),
                                  //       ),
                                  //       Text(
                                  //         "${controller.orderModel.value.duration.toString()} hours",
                                  //         style: const TextStyle(
                                  //           color: AppThemData.grey08,
                                  //           fontSize: 16,
                                  //           fontFamily: AppThemData.semiBold,
                                  //         ),
                                  //       ),
                                  //     ],
                                  //   ),
                                  // ),
                                  // Padding(
                                  //   padding: const EdgeInsets.symmetric(vertical: 5),
                                  //   child: Row(
                                  //     children: [
                                  //       const Expanded(
                                  //         child: Text(
                                  //           'Date',
                                  //           style: TextStyle(
                                  //             color: AppThemData.grey07,
                                  //             fontSize: 16,
                                  //             fontFamily: AppThemData.medium,
                                  //           ),
                                  //         ),
                                  //       ),
                                  //       Text(
                                  //         Constant.timestampToDate(controller.orderModel.value.bookingDate!),
                                  //         style: const TextStyle(
                                  //           color: AppThemData.grey08,
                                  //           fontSize: 16,
                                  //           fontFamily: AppThemData.semiBold,
                                  //         ),
                                  //       ),
                                  //     ],
                                  //   ),
                                  // ),
                                  // Padding(
                                  //   padding: const EdgeInsets.symmetric(vertical: 5),
                                  //   child: Row(
                                  //     children: [
                                  //       const Expanded(
                                  //         child: Text(
                                  //           'Name',
                                  //           style: TextStyle(
                                  //             color: AppThemData.grey07,
                                  //             fontSize: 16,
                                  //             fontFamily: AppThemData.medium,
                                  //           ),
                                  //         ),
                                  //       ),
                                  //       Text(
                                  //         "${Constant.timestampToTime(controller.orderModel.value.bookingStartTime!)} to ${Constant.timestampToTime(controller.orderModel.value.bookingEndTime!)}",
                                  //         style: const TextStyle(
                                  //           color: AppThemData.grey08,
                                  //           fontSize: 16,
                                  //           fontFamily: AppThemData.semiBold,
                                  //         ),
                                  //       ),
                                  //     ],
                                  //   ),
                                  // ),
                                  // const SizedBox(
                                  //   height: 20,
                                  // ),
                                  RoundedButtonFill(
                                    title: "Navigate the Parking Slot".tr,
                                    height: 6,
                                    color: AppThemData.primary06,
                                    fontSizes: 16,
                                    onPress: () async {
                                      print(Constant.mapType);
                                      if (Constant.mapType == "inappmap") {
                                        Get.to(() => const LiveTrackingScreen(), arguments: {"orderModel": controller.orderModel.value});
                                      } else {
                                        Utils.redirectMap(
                                            latitude: controller.orderModel.value.parkingDetails!.location!.latitude!,
                                            longLatitude: controller.orderModel.value.parkingDetails!.location!.longitude!,
                                            name: controller.orderModel.value.parkingDetails!.name.toString());
                                      }
                                    },
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  RoundedButtonFill(
                                    title: "Cancel Booking".tr,
                                    height: 6,
                                    color: AppThemData.grey04,
                                    fontSizes: 16,
                                    onPress: () async {
                                      ShowToastDialog.showLoader("Please wait".tr);
                                      controller.orderModel.value.status = Constant.canceled;
                                      UserModel? receiverUserModel = await FireStoreUtils.getUserProfile(controller.orderModel.value.parkingDetails!.userId.toString());

                                      Map<String, dynamic> playLoad = <String, dynamic>{"type": "order", "orderId": controller.orderModel.value.id};

                                      await SendNotification.sendOneNotification(
                                          token: receiverUserModel!.fcmToken.toString(),
                                          title: 'Booking Canceled'.tr,
                                          body:
                                              '${controller.orderModel.value.parkingDetails!.name.toString()} Booking canceled on ${Constant.timestampToDate(controller.orderModel.value.bookingDate!)}.'
                                                  .tr,
                                          payload: playLoad);
                                      if (controller.orderModel.value.paymentType.toString().toLowerCase() != 'cash'.toLowerCase()) {
                                        await controller.canceledOrderWallet();
                                      } else if (controller.orderModel.value.paymentCompleted! &&
                                          controller.orderModel.value.paymentType.toString().toLowerCase() == 'cash'.toLowerCase()) {
                                        await controller.refundCashPaymentAmount();
                                      }

                                      await FireStoreUtils.setOrder(controller.orderModel.value).then((value) {
                                        ShowToastDialog.closeLoader();
                                        DashboardScreenController dashboardController = Get.put(DashboardScreenController());
                                        dashboardController.selectedIndex(2);
                                        Get.offAll(() => const DashBoardScreen());
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                            left: -5,
                            top: Responsive.height(30, context),
                            child: Container(
                              height: 20,
                              width: 20,
                              decoration: const BoxDecoration(color: AppThemData.warning06, shape: BoxShape.circle),
                            )),
                        Positioned(
                            right: -5,
                            top: Responsive.height(30, context),
                            child: Container(
                              height: 20,
                              width: 20,
                              decoration: const BoxDecoration(color: AppThemData.warning06, shape: BoxShape.circle),
                            )),
                      ],
                    ),
                  ),
          );
        });
  }
}
