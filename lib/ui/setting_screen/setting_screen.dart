import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:customerparkapp/constant/show_toast_dialog.dart';
import 'package:customerparkapp/controller/setting_controller.dart';
import 'package:customerparkapp/themes/app_them_data.dart';
import 'package:customerparkapp/themes/common_ui.dart';
import 'package:customerparkapp/themes/custom_dialog_box.dart';
import 'package:customerparkapp/themes/round_button_fill.dart';
import 'package:customerparkapp/ui/auth_screen/login_screen.dart';
import 'package:customerparkapp/ui/choose_language/choose_language_screen.dart';
import 'package:customerparkapp/utils/dark_theme_provider.dart';
import 'package:customerparkapp/utils/fire_store_utils.dart';
import 'package:customerparkapp/utils/preferences.dart';
import 'package:provider/provider.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: SettingController(),
        builder: (controller) {
          return Scaffold(
            appBar: UiInterface().customAppBar(
              context,
              themeChange,
              'Settings'.tr,
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [

                  InkWell(
                    onTap: () {
                      showThem(context, controller);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Icon(Icons.color_lens_outlined, color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey08),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                              child: Text("Theme".tr,
                                  style: TextStyle(fontSize: 16, fontFamily: AppThemData.regular, color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey08))),
                          Row(children: [
                            Text(
                              controller.lightDarkMode.value,
                              style: TextStyle(color: themeChange.getThem() ? AppThemData.primary07 : AppThemData.primary07, fontFamily: AppThemData.medium, fontSize: 14),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Icon(Icons.arrow_forward_ios, size: 16, color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey10)
                          ]),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CustomDialogBox(
                              title: "Delete Account".tr,
                              descriptions: "Deleting your account removes all your data and settings from the app.".tr,
                              positiveClick: () async {
                                ShowToastDialog.showLoader("please_wait".tr);
                                await FireStoreUtils.deleteUser().then((value) {
                                  ShowToastDialog.closeLoader();
                                  if (value == true) {
                                    ShowToastDialog.showToast("account_deleted_successfully".tr);
                                    Get.offAll(const LoginScreen());
                                  } else {
                                    ShowToastDialog.showToast("contact_administrator".tr);
                                  }
                                });
                              },
                              positiveString: "Yes, Sure".tr,
                              negativeString: "No".tr,
                              negativeClick: () {
                                Get.back();
                              },
                              img: SvgPicture.asset('assets/images/ic_delete_image.svg'),
                            );
                          });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: themeChange.getThem() ? AppThemData.error08 : AppThemData.error08),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                              child: Text("Delete Account".tr,
                                  style: TextStyle(fontSize: 16, fontFamily: AppThemData.regular, color: themeChange.getThem() ? AppThemData.error08 : AppThemData.error08))),
                          Icon(Icons.arrow_forward_ios, size: 16, color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey10)
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  showThem(BuildContext context, SettingController controller) {
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
        initialChildSize: 0.42,
        minChildSize: 0.20,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) {
          final themeChange = Provider.of<DarkThemeProvider>(context);
          return Obx(
            () => Scaffold(
              body: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: Container(
                        width: 134,
                        height: 5,
                        margin: const EdgeInsets.only(top: 12, bottom: 6),
                        decoration: ShapeDecoration(
                          color: AppThemData.labelColorLightPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Select Theme'.tr,
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: AppThemData.medium,
                        color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey10,
                      ),
                    ),
                  ),
                  Divider(color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.grey03, thickness: 1),
                  InkWell(
                    onTap: () {
                      controller.lightDarkMode.value = "Light";
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      child: Row(
                        children: [
                          Icon(Icons.circle, color: themeChange.getThem() ? AppThemData.white : AppThemData.white),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                              child: Text("Light",
                                  style: TextStyle(fontSize: 16, fontFamily: AppThemData.medium, color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey08))),
                          Radio<String>(
                            value: "Light",
                            groupValue: controller.lightDarkMode.value,
                            activeColor: AppThemData.primary07,
                            onChanged: controller.handleGenderChange,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(thickness: 1, color: AppThemData.grey04),
                  InkWell(
                    onTap: () {
                      controller.lightDarkMode.value = "Dark";
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      child: Row(
                        children: [
                          Icon(Icons.circle, color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.grey10),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                              child: Text("Dark",
                                  style: TextStyle(fontSize: 16, fontFamily: AppThemData.medium, color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey08))),
                          Radio<String>(
                            value: "Dark",
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            groupValue: controller.lightDarkMode.value,
                            activeColor: AppThemData.primary07,
                            onChanged: controller.handleGenderChange,
                          ),
                        ],
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
                  child: RoundedButtonFill(
                    title: "Save",
                    height: 5.5,
                    color: AppThemData.primary06,
                    fontSizes: 16,
                    onPress: () {
                      Preferences.setString(Preferences.themKey, controller.lightDarkMode.value);
                      if (controller.lightDarkMode.value == "Dark") {
                        themeChange.darkTheme = 0;
                      } else if (controller.lightDarkMode.value == "Light") {
                        themeChange.darkTheme = 1;
                      } else {
                        themeChange.darkTheme = 2;
                      }
                      Get.back();
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
