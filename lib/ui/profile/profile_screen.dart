import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:customerparkapp/constant/constant.dart';
import 'package:customerparkapp/controller/profile_controller.dart';
import 'package:customerparkapp/themes/app_them_data.dart';
import 'package:customerparkapp/themes/common_ui.dart';
import 'package:customerparkapp/themes/custom_dialog_box.dart';
import 'package:customerparkapp/themes/responsive.dart';
import 'package:customerparkapp/themes/round_button_fill.dart';
import 'package:customerparkapp/ui/auth_screen/login_screen.dart';
import 'package:customerparkapp/ui/chat/inbox_screen.dart';
import 'package:customerparkapp/ui/contact_us/contact_us_screen.dart';
import 'package:customerparkapp/ui/faq/faq_screen.dart';
import 'package:customerparkapp/ui/profile/edit_profile_screen.dart';
import 'package:customerparkapp/ui/refer_and_earn/refer_and_earn_screen.dart';
import 'package:customerparkapp/ui/setting_screen/setting_screen.dart';
import 'package:customerparkapp/ui/terms_and_condition/terms_and_condition_screen.dart';
import 'package:customerparkapp/ui/wallet/wallet_screen.dart';
import 'package:customerparkapp/utils/dark_theme_provider.dart';
import 'package:customerparkapp/utils/network_image_widget.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: ProfileController(),
        builder: (controller) {
          return Scaffold(
            appBar: UiInterface().customAppBar(
              context,
              themeChange,
              isBack: false,
              'profile'.tr,
              actions: [
                const SizedBox(
                  width: 10,
                ),
                // InkWell(
                //   onTap: () {
                //     Get.to(const InboxScreen());
                //   },
                //   child: Padding(
                //     padding: const EdgeInsets.only(right: 10),
                //     child: Icon(Icons.chat_bubble_outline,
                //         color: themeChange.getThem()
                //             ? AppThemData.grey01
                //             : AppThemData.grey08),
                //   ),
                // )
              ],
            ),
            body: controller.isLoading.value
                ? Constant.loader()
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 30),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(60),
                                  child: NetworkImageWidget(
                                    imageUrl: controller
                                        .userModel.value.profilePic
                                        .toString(),
                                    height: Responsive.width(26, context),
                                    width: Responsive.width(26, context),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      controller.userModel.value.fullName
                                          .toString(),
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontFamily: AppThemData.medium,
                                          color: themeChange.getThem()
                                              ? AppThemData.grey01
                                              : AppThemData.grey10),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      controller.userModel.value.email
                                          .toString(),
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: AppThemData.medium,
                                          color: themeChange.getThem()
                                              ? AppThemData.grey06
                                              : AppThemData.grey06),
                                    ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    RoundedButtonFill(
                                      title: "Edit Details".tr,
                                      textColor: AppThemData.grey11,
                                      width: 40,
                                      height: 05.55,
                                      isRight: false,
                                      icon: const Icon(Icons.edit,
                                          color: AppThemData.grey11),
                                      color: AppThemData.primary06,
                                      onPress: () {
                                        Get.to(const EditProfileScreen());
                                      },
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Divider(
                              color: AppThemData.grey04, thickness: 1),
                          menuItemWidget(
                            title: "Settings".tr,
                            svgImage: "assets/icon/ic_setting.svg",
                            onTap: () {
                              Get.to(() => const SettingScreen());
                            },
                            themeChange: themeChange,
                          ),
                          menuItemWidget(
                            title: "Privacy Policy".tr,
                            svgImage: "assets/icon/ic_privacy_policy.svg",
                            onTap: () {
                              Get.to(const TermsAndConditionScreen(
                                type: "privacy",
                              ));
                            },
                            themeChange: themeChange,
                          ),
                          menuItemWidget(
                            title: "Terms & Conditions".tr,
                            svgImage: "assets/icon/ic_terms_condition.svg",
                            onTap: () {
                              Get.to(const TermsAndConditionScreen(
                                type: "terms",
                              ));
                            },
                            themeChange: themeChange,
                          ),
                          menuItemWidget(
                            title: "Contact us".tr,
                            svgImage: "assets/icon/ic_call_support.svg",
                            onTap: () {
                              Get.to(
                                () => const ContactUsScreen(),
                              );
                            },
                            themeChange: themeChange,
                          ),
                          menuItemWidget(
                            title: "FAQ’s".tr,
                            svgImage: "assets/icon/ic_faq.svg",
                            onTap: () {
                              Get.to(() => const FaqScreen());
                            },
                            themeChange: themeChange,
                          ),
                          const Divider(
                              color: AppThemData.grey04, thickness: 1),
                          menuItemWidget(
                            title: "Log Out".tr,
                            svgImage: "assets/icon/ic_logout.svg",
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CustomDialogBox(
                                      title: "Signing out for now?".tr,
                                      descriptions:
                                          "Ensure your account's security with a quick log out. Your parking solutions will be here when you return!"
                                              .tr,
                                      positiveString: "Log out".tr,
                                      negativeString: "Cancel".tr,
                                      positiveClick: () async {
                                        await FirebaseAuth.instance.signOut();
                                        Get.offAll(const LoginScreen());
                                      },
                                      negativeClick: () {
                                        Get.back();
                                      },
                                      img: SvgPicture.asset(
                                          'assets/images/ic_logout_image.svg'),
                                    );
                                  });
                              // showLogoutAccountDialog(context, themeChange);
                            },
                            themeChange: themeChange,
                          ),
                        ],
                      ),
                    ),
                  ),
          );
        });
  }

  Widget menuItemWidget({
    required String svgImage,
    required String title,
    required VoidCallback onTap,
    required themeChange,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      horizontalTitleGap: 6,
      onTap: onTap,
      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
      leading: SvgPicture.asset(
        svgImage,
        color: title == "Log Out"
            ? AppThemData.error08
            : themeChange.getThem()
                ? AppThemData.grey01
                : AppThemData.grey09,
        height: 26,
      ),
      title: Text(
        title,
        style: TextStyle(
            fontSize: 16,
            fontFamily: AppThemData.medium,
            color: title == "Log Out"
                ? AppThemData.error08
                : themeChange.getThem()
                    ? AppThemData.grey01
                    : AppThemData.grey09),
      ),
    );
  }
}
