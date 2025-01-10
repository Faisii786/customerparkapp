import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:customerparkapp/constant/constant.dart';
import 'package:customerparkapp/constant/show_toast_dialog.dart';
import 'package:customerparkapp/model/referral_model.dart';
import 'package:customerparkapp/model/user_model.dart';
import 'package:customerparkapp/ui/dashboard_screen.dart';
import 'package:customerparkapp/utils/fire_store_utils.dart';
import 'package:customerparkapp/utils/notification_service.dart';

class InformationController extends GetxController {
  Rx<TextEditingController> fullNameController = TextEditingController().obs;
  Rx<TextEditingController> emailController = TextEditingController().obs;
  Rx<TextEditingController> phoneNumberController = TextEditingController().obs;
  Rx<TextEditingController> referralCodeController = TextEditingController().obs;
  Rx<TextEditingController> countryCode = TextEditingController().obs;
  RxString loginType = "".obs;
  final ImagePicker imagePicker = ImagePicker();
  RxString profileImage = "".obs;

  @override
  void onInit() {
    getArgument();
    super.onInit();
  }

  Rx<UserModel> userModel = UserModel().obs;

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      userModel.value = argumentData['userModel'];
      loginType.value = userModel.value.loginType.toString();
      if (loginType.value == Constant.phoneLoginType) {
        phoneNumberController.value.text = userModel.value.phoneNumber.toString();
        countryCode.value.text = userModel.value.countryCode.toString();
      } else {
        emailController.value.text = userModel.value.email.toString();
        fullNameController.value.text = userModel.value.fullName.toString();
      }
    }
    update();
  }

  createAccount() async {
    String fcmToken = await NotificationService.getToken();
    if (profileImage.value.isNotEmpty) {
      profileImage.value = await Constant.uploadUserImageToFireStorage(
        File(profileImage.value),
        "profileImage/${FireStoreUtils.getCurrentUid()}",
        File(profileImage.value).path.split('/').last,
      );
    }
    if (referralCodeController.value.text.isNotEmpty) {
      await FireStoreUtils.checkReferralCodeValidOrNot(referralCodeController.value.text).then((value) async {
        if (value == true) {
          ShowToastDialog.showLoader("please_wait".tr);
          UserModel userModelData = userModel.value;
          userModelData.fullName = fullNameController.value.text;
          userModelData.email = emailController.value.text;
          userModelData.countryCode = countryCode.value.text;
          userModelData.phoneNumber = phoneNumberController.value.text;
          userModelData.profilePic = profileImage.value;
          userModelData.fcmToken = fcmToken;
          userModelData.createdAt = Timestamp.now();
          userModelData.isActive = true;
          userModelData.role = Constant.roleType;

          FireStoreUtils.getReferralUserByCode(referralCodeController.value.text).then((value) async {
            if (value != null) {
              ReferralModel ownReferralModel = ReferralModel(id: FireStoreUtils.getCurrentUid(), referralBy: value.id, referralCode: Constant.getReferralCode());
              await FireStoreUtils.referralAdd(ownReferralModel);
            } else {
              ReferralModel referralModel = ReferralModel(id: FireStoreUtils.getCurrentUid(), referralBy: "", referralCode: Constant.getReferralCode());
              await FireStoreUtils.referralAdd(referralModel);
            }
          });

          await FireStoreUtils.updateUser(userModelData).then((value) {
            ShowToastDialog.closeLoader();
            if (value == true) {
              Get.offAll(
                const DashBoardScreen(),
              );
            }
          });
        } else {
          ShowToastDialog.showToast("referral_code_invalid".tr);
        }
      });
    } else {
      ShowToastDialog.showLoader("please_wait".tr);
      UserModel userModelData = userModel.value;
      userModelData.fullName = fullNameController.value.text;
      userModelData.email = emailController.value.text;
      userModelData.countryCode = countryCode.value.text;
      userModelData.phoneNumber = phoneNumberController.value.text;
      userModelData.profilePic = profileImage.value;
      userModelData.fcmToken = fcmToken;
      userModelData.createdAt = Timestamp.now();
      userModelData.isActive = true;
      userModelData.role = Constant.roleType;

      ReferralModel referralModel = ReferralModel(id: FireStoreUtils.getCurrentUid(), referralBy: "", referralCode: Constant.getReferralCode());
      await FireStoreUtils.referralAdd(referralModel);

      await FireStoreUtils.updateUser(userModelData).then((value) {
        ShowToastDialog.closeLoader();
        if (value == true) {
          Get.offAll(const DashBoardScreen());
        }
      });
    }
  }

  Future pickFile({required ImageSource source}) async {
    try {
      XFile? image = await imagePicker.pickImage(source: source);
      if (image == null) return;
      Get.back();
      profileImage.value = image.path;
    } on PlatformException catch (e) {
      ShowToastDialog.showToast("${"failed_to_pick".tr} : \n $e");
    }
  }
}
