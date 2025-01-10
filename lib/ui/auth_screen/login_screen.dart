import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:customerparkapp/controller/login_controller.dart';
import 'package:customerparkapp/themes/app_them_data.dart';
import 'package:customerparkapp/themes/mobile_number_textfield.dart';
import 'package:customerparkapp/themes/responsive.dart';
import 'package:customerparkapp/themes/round_button_gradiant.dart';
import 'package:customerparkapp/ui/terms_and_condition/terms_and_condition_screen.dart';
import 'package:customerparkapp/utils/dark_theme_provider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<LoginController>(
      init: LoginController(),
      builder: (controller) {
        return Scaffold(
          body: Center(
            child: SingleChildScrollView(
              child: Form(
                key: controller.formKey.value,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(40),
                        child: Image.asset("assets/images/smart_logo.png"),
                      ),
                      Text(
                        "Log in or Sign up".tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey10,
                          fontSize: 24,
                          fontFamily: AppThemData.semiBold,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Text(
                        "Instant parking at your fingertips. No more circling - find, reserve, and pay instantly!".tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppThemData.grey07,
                          fontSize: 14,
                          fontFamily: AppThemData.regular,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(
                        height: Responsive.height(10, context),
                      ),
                      MobileNumberTextField(
                        title: "Phone Number".tr,
                        controller: controller.phoneNumberController.value,
                        countryCodeController: controller.countryCode.value,
                        onPress: () {},
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      RoundedButtonGradiant(
                        title: "Continue".tr,
                        onPress: () {
                          if (controller.formKey.value.currentState!.validate()) {
                            controller.sendCode();
                          }
                        },
                      ),


                    ],
                  ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  text: "${'tapping_next_agree'.tr} ",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    fontFamily: AppThemData.regular,
                    color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey08,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Get.to(
                            const TermsAndConditionScreen(
                              type: "terms",
                            ),
                          );
                        },
                      text: 'terms_and_conditions'.tr,
                      style: TextStyle(
                        color: themeChange.getThem() ? AppThemData.blueLight : AppThemData.blueLight,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        fontFamily: AppThemData.regular,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    TextSpan(
                      text: " ${"and".tr} ",
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey08),
                    ),
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Get.to(
                            const TermsAndConditionScreen(
                              type: "privacy",
                            ),
                          );
                        },
                      text: 'privacy_policy'.tr,
                      style: TextStyle(
                        color: themeChange.getThem() ? AppThemData.blueLight : AppThemData.blueLight,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        fontFamily: AppThemData.regular,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              )),
        );
      },
    );
  }
}
