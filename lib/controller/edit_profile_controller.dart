import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:customerparkapp/constant/constant.dart';
import 'package:customerparkapp/constant/show_toast_dialog.dart';
import 'package:customerparkapp/model/user_model.dart';
import 'package:customerparkapp/utils/fire_store_utils.dart';

class EditProfileController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<UserModel> userModel = UserModel().obs;

  Rx<TextEditingController> fullNameController = TextEditingController().obs;
  Rx<TextEditingController> emailController = TextEditingController().obs;
  Rx<TextEditingController> dateOfBirthController = TextEditingController().obs;
  Rx<TextEditingController> phoneNumberController = TextEditingController().obs;
  Rx<TextEditingController> countryCodeController = TextEditingController(text: "+1").obs;

  Rx<GlobalKey<FormState>> formKey = GlobalKey<FormState>().obs;

  RxString gender = "Male".obs;

  void handleGenderChange(String? value) {
    gender.value = value!;
  }

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  getData() async {
    await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()).then((value) {
      if (value != null) {
        userModel.value = value;

        phoneNumberController.value.text = userModel.value.phoneNumber.toString();
        countryCodeController.value.text = userModel.value.countryCode.toString();
        emailController.value.text = userModel.value.email.toString();
        fullNameController.value.text = userModel.value.fullName.toString();
        dateOfBirthController.value.text = userModel.value.dateOfBirth.toString();
        profileImage.value = userModel.value.profilePic.toString();
        gender.value = userModel.value.gender.toString();
        isLoading.value = false;
      }
    });
  }

  final ImagePicker _imagePicker = ImagePicker();
  RxString profileImage = "".obs;

  Future pickFile({required ImageSource source}) async {
    try {
      XFile? image = await _imagePicker.pickImage(source: source);
      if (image == null) return;
      Get.back();
      profileImage.value = image.path;
    } on PlatformException catch (e) {
      ShowToastDialog.showToast("${"failed_to_pick".tr} : \n $e");
    }
  }

  updateProfile() async {
    ShowToastDialog.showLoader("please_wait".tr);
    if (Constant().hasValidUrl(profileImage.value) == false && profileImage.value.isNotEmpty) {
      profileImage.value = await Constant.uploadUserImageToFireStorage(
        File(profileImage.value),
        "profileImage/${FireStoreUtils.getCurrentUid()}",
        File(profileImage.value).path.split('/').last,
      );
    }

    UserModel userModelData = userModel.value;
    userModelData.fullName = fullNameController.value.text;
    userModelData.profilePic = profileImage.value;
    userModelData.dateOfBirth = dateOfBirthController.value.text;
    userModelData.email = emailController.value.text;
    userModelData.phoneNumber = phoneNumberController.value.text;
    userModelData.countryCode = countryCodeController.value.text;

    FireStoreUtils.updateUser(userModelData).then(
      (value) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(
          "profile_updated_successfully".tr,
        );
        Get.back();
        update();
      },
    );
  }
}
