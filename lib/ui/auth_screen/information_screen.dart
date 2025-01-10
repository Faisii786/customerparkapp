import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:customerparkapp/constant/constant.dart';
import 'package:customerparkapp/constant/show_toast_dialog.dart';
import 'package:customerparkapp/controller/information_controller.dart';
import 'package:customerparkapp/themes/common_ui.dart';
import 'package:customerparkapp/themes/mobile_number_textfield.dart';
import 'package:customerparkapp/themes/responsive.dart';
import 'package:customerparkapp/themes/round_button_gradiant.dart';
import 'package:customerparkapp/themes/text_field_widget.dart';
import 'package:customerparkapp/utils/dark_theme_provider.dart';
import 'package:provider/provider.dart';

class InformationScreen extends StatelessWidget {
  const InformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<InformationController>(
      init: InformationController(),
      builder: (controller) {
        return Scaffold(
          appBar: UiInterface().customAppBar(
            context,
            themeChange,
            "fill_your_profile".tr,
          ),
          body: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Center(
                            child: controller.profileImage.isEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(60),
                                    child: Image.asset(
                                      Constant.userPlaceHolder,
                                      height: Responsive.width(30, context),
                                      width: Responsive.width(30, context),
                                      fit: BoxFit.fill,
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(60),
                                    child: Image.file(
                                      File(controller.profileImage.value),
                                      height: Responsive.width(30, context),
                                      width: Responsive.width(30, context),
                                      fit: BoxFit.fill,
                                    ),
                                  )),
                        Positioned(
                          right: Responsive.width(28, context),
                          child: InkWell(
                            onTap: () {
                              buildBottomSheet(context, controller);
                            },
                            child: SvgPicture.asset(
                              "assets/images/ic_profile_edit.svg",
                              width: 40,
                              height: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 53,
                    ),
                    TextFieldWidget(
                      title: 'Full Name'.tr,
                      onPress: () {},
                      controller: controller.fullNameController.value,
                      hintText: 'Enter Full Name'.tr,
                      prefix: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SvgPicture.asset(
                          "assets/icon/ic_user.svg",
                        ),
                      ),
                    ),
                    MobileNumberTextField(
                      title: "Phone Number".tr,
                      controller: controller.phoneNumberController.value,
                      countryCodeController: controller.countryCode.value,
                      enabled: controller.loginType.value == Constant.phoneLoginType ? false : true,
                      onPress: () {},
                    ),
                    TextFieldWidget(
                      title: 'Email Address'.tr,
                      onPress: () {},
                      controller: controller.emailController.value,
                      hintText: 'Enter Email Address'.tr,
                      textInputType: TextInputType.emailAddress,
                      enable: controller.loginType.value == Constant.googleLoginType ? false : true,
                      prefix: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SvgPicture.asset(
                          "assets/icon/ic_email.svg",
                        ),
                      ),
                    ),
                    TextFieldWidget(
                      title: 'Coupon Code (Optional)'.tr,
                      onPress: () {},
                      controller: controller.referralCodeController.value,
                      textInputType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                      ],
                      hintText: 'Enter Coupon Code (Optional)'.tr,
                      prefix: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SvgPicture.asset(
                          "assets/icon/ic_coupon.svg",
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    RoundedButtonGradiant(
                      title: "create_account".tr,
                      onPress: () {
                        if (controller.fullNameController.value.text.isEmpty) {
                          ShowToastDialog.showToast("Please enter full name");
                        } else if (controller.emailController.value.text.isEmpty) {
                          ShowToastDialog.showToast("Please enter email address");
                        } else if (controller.phoneNumberController.value.text.isEmpty) {
                          ShowToastDialog.showToast("Please enter phone number");
                        } else {
                          controller.createAccount();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  buildBottomSheet(BuildContext context, InformationController controller) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              height: Responsive.height(22, context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Text("please_select".tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                                onPressed: () => controller.pickFile(source: ImageSource.camera),
                                icon: const Icon(
                                  Icons.camera_alt,
                                  size: 32,
                                )),
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(
                                "camera".tr,
                                style: const TextStyle(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                                onPressed: () => controller.pickFile(source: ImageSource.gallery),
                                icon: const Icon(
                                  Icons.photo_library_sharp,
                                  size: 32,
                                )),
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(
                                "gallery".tr,
                                style: const TextStyle(),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
