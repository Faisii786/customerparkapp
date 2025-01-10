import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:get/get.dart';
import 'package:customerparkapp/constant/collection_name.dart';
import 'package:customerparkapp/constant/show_toast_dialog.dart';
import 'package:customerparkapp/utils/fire_store_utils.dart';

class ContactUsController extends GetxController {
  RxBool isLoading = true.obs;

  Rx<TextEditingController> emailController = TextEditingController().obs;
  Rx<TextEditingController> feedbackController = TextEditingController().obs;

  @override
  void onInit() {
    getContactUsInformation();
    super.onInit();
  }

  RxString email = "".obs;
  RxString phone = "".obs;
  RxString address = "".obs;
  RxString subject = "".obs;

  getContactUsInformation() async {
    await FireStoreUtils.fireStore.collection(CollectionName.settings).doc("contact_us").get().then((value) {
      if (value.exists) {
        email.value = value.data()!["email"];
        phone.value = value.data()!["phone"];
        address.value = value.data()!["address"];
        subject.value = value.data()!["subject"];
        isLoading.value = false;
      }
    });
  }

  submitFeedback() async {
    if (emailController.value.text.isEmpty) {
      ShowToastDialog.showToast(
        "please_enter_email".tr,
      );
    } else if (feedbackController.value.text.isEmpty) {
      ShowToastDialog.showToast(
        "please_enter_feedback".tr,
      );
    } else {
      final Email emailData = Email(
        body: feedbackController.value.text,
        subject: subject.value,
        recipients: [email.value],
        cc: [emailController.value.text],
        isHTML: false,
      );
      await FlutterEmailSender.send(emailData);
      emailController.value.clear();
      feedbackController.value.clear();
    }
  }
}
