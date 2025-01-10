import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:customerparkapp/constant/constant.dart';
import 'package:customerparkapp/controller/edit_profile_controller.dart';
import 'package:customerparkapp/themes/app_them_data.dart';
import 'package:customerparkapp/themes/common_ui.dart';
import 'package:customerparkapp/themes/mobile_number_textfield.dart';
import 'package:customerparkapp/themes/responsive.dart';
import 'package:customerparkapp/themes/round_button_fill.dart';
import 'package:customerparkapp/utils/dark_theme_provider.dart';
import 'package:customerparkapp/utils/network_image_widget.dart';
import 'package:provider/provider.dart';

import '../../themes/text_field_widget.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<EditProfileController>(
      init: EditProfileController(),
      builder: (controller) {
        return Scaffold(
          appBar: UiInterface().customAppBar(
            context,
            themeChange,
            'edit_profile'.tr,
          ),
          body: Column(
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
                          : Constant().hasValidUrl(controller.profileImage.value) == false
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(60),
                                  child: Image.file(
                                    File(controller.profileImage.value),
                                    height: Responsive.width(30, context),
                                    width: Responsive.width(30, context),
                                    fit: BoxFit.fill,
                                  ),
                                )
                              : NetworkImageWidget(
                                  imageUrl: controller.profileImage.value.toString(),
                                  height: Responsive.width(30, context),
                                  width: Responsive.width(30, context),
                                )),
                  Positioned(
                    right: Responsive.width(34, context),
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
                height: 30,
              ),
              Expanded(
                child: controller.isLoading.value
                    ? Constant.loader()
                    : Form(
                        key: controller.formKey.value,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFieldWidget(
                                  title: 'Full Name'.tr,
                                  onPress: () {},
                                  controller: controller.fullNameController.value,
                                  hintText: 'Enter Full Name'.tr,
                                  textInputType: TextInputType.emailAddress,
                                  prefix: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: SvgPicture.asset(
                                      "assets/icon/ic_email.svg",
                                    ),
                                  ),
                                ),
                                TextFieldWidget(
                                  title: 'Email Address'.tr,
                                  onPress: () {},
                                  controller: controller.emailController.value,
                                  hintText: 'Enter Email Address'.tr,
                                  textInputType: TextInputType.emailAddress,
                                  enable: controller.userModel.value.loginType == Constant.googleLoginType || controller.userModel.value.loginType == Constant.appleLoginType
                                      ? false
                                      : true,
                                  prefix: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: SvgPicture.asset(
                                      "assets/icon/ic_email.svg",
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    await Constant.selectDate(context).then((value) {
                                      if (value != null) {
                                        controller.dateOfBirthController.value.text = DateFormat('MMMM dd,yyyy').format(value);
                                      }
                                    });
                                  },
                                  child: TextFieldWidget(
                                    title: 'Date of Birth'.tr,
                                    onPress: () async {},
                                    controller: controller.dateOfBirthController.value,
                                    hintText: 'Select Date of Birth'.tr,
                                    enable: false,
                                    prefix: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: SvgPicture.asset(
                                        "assets/icon/ic_cake.svg",
                                      ),
                                    ),
                                  ),
                                ),
                                MobileNumberTextField(
                                  title: "Phone Number".tr,
                                  controller: controller.phoneNumberController.value,
                                  countryCodeController: controller.countryCodeController.value,
                                  enabled: controller.userModel.value.loginType == Constant.phoneLoginType ? false : true,
                                  onPress: () {},
                                ),
                                Text("Gender".tr, style: const TextStyle(fontFamily: AppThemData.medium, fontSize: 14, color: AppThemData.grey07)),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: themeChange.getThem() ? AppThemData.grey09 : AppThemData.grey03,
                                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
                                        child: Row(
                                          children: [
                                            Radio<String>(
                                              value: "Male".tr,
                                              groupValue: controller.gender.value,
                                              activeColor: AppThemData.primary07,
                                              onChanged: controller.handleGenderChange,
                                            ),
                                            Text("Male".tr),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.grey03,
                                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
                                        child: Row(
                                          children: [
                                            Radio<String>(
                                              value: "Female".tr,
                                              groupValue: controller.gender.value,
                                              activeColor: AppThemData.primary07,
                                              onChanged: controller.handleGenderChange,
                                            ),
                                            Text("Female".tr),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 40,
                                ),
                                RoundedButtonFill(
                                  title: "Save".tr,
                                  color: AppThemData.primary06,
                                  onPress: () {
                                    if (controller.formKey.value.currentState!.validate()) {
                                      controller.updateProfile();
                                    }
                                  },
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  buildBottomSheet(BuildContext context, EditProfileController controller) {
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
