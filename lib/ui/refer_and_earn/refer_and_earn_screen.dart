import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:customerparkapp/constant/constant.dart';
import 'package:customerparkapp/constant/show_toast_dialog.dart';
import 'package:customerparkapp/controller/referral_controller.dart';
import 'package:customerparkapp/themes/app_them_data.dart';
import 'package:customerparkapp/themes/common_ui.dart';
import 'package:customerparkapp/themes/responsive.dart';
import 'package:customerparkapp/themes/round_button_fill.dart';
import 'package:customerparkapp/utils/dark_theme_provider.dart';
import 'package:provider/provider.dart';

class ReferAndEarnScreen extends StatelessWidget {
  const ReferAndEarnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX(
        init: ReferralController(),
        builder: (controller) {
          return Scaffold(
            appBar: UiInterface().customAppBar(
              context,
              themeChange,
              'Refer and Earn'.tr,
            ),
            body: controller.isLoading.value
                ? Constant.loader()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(child: SvgPicture.asset("assets/icon/ic_reward.svg", width: 50, height: 52)),
                        const SizedBox(
                          height: 10,
                        ),
                        Center(
                          child: Text(
                            "Refer & Earn Rewards".tr,
                            style: TextStyle(
                              fontFamily: AppThemData.semiBold,
                              fontSize: 18,
                              color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey09,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Share the love of hassle-free parking! Refer friends to our app and earn rewards for both you and your friends. Start saving while parking today.".tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: AppThemData.regular, fontSize: 14, color: themeChange.getThem() ? AppThemData.grey07 : AppThemData.grey07),
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        Center(
                          child: Text(
                            "Referral Code".tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontFamily: AppThemData.medium, fontSize: 14, color: themeChange.getThem() ? AppThemData.grey07 : AppThemData.grey07),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        DottedBorder(
                          borderType: BorderType.RRect,
                          radius: const Radius.circular(10),
                          dashPattern: const [6, 6, 6, 6],
                          color: AppThemData.primary08,
                          child: Container(
                              height: Responsive.height(6, context),
                              decoration: const BoxDecoration(color: AppThemData.primary01, borderRadius: BorderRadius.all(Radius.circular(10))),
                              child: Center(
                                  child: Text(
                                controller.referralModel.value.referralCode.toString(),
                                style: TextStyle(color: themeChange.getThem() ? AppThemData.primary07 : AppThemData.primary07, fontFamily: AppThemData.semiBold),
                              ))),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          "How it Works".tr,
                          style: TextStyle(fontFamily: AppThemData.medium, fontSize: 14, color: themeChange.getThem() ? AppThemData.grey07 : AppThemData.grey07),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            children: [
                              SvgPicture.asset("assets/icon/ic_email_share.svg"),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Share Your Code".tr,
                                      style: TextStyle(fontFamily: AppThemData.semiBold, fontSize: 14, color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey08),
                                    ),
                                    const SizedBox(
                                      height: 2,
                                    ),
                                    Text(
                                      "Get a unique referral code after signup.".tr,
                                      style: TextStyle(fontFamily: AppThemData.regular, fontSize: 12, color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey06),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            children: [
                              SvgPicture.asset("assets/icon/ic_friend_join.svg"),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Friends Join".tr,
                                      style: TextStyle(fontFamily: AppThemData.semiBold, fontSize: 14, color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey08),
                                    ),
                                    const SizedBox(
                                      height: 2,
                                    ),
                                    Text(
                                      "They use your code for sign-up and booking.".tr,
                                      style: TextStyle(fontFamily: AppThemData.regular, fontSize: 12, color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey06),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            children: [
                              SvgPicture.asset("assets/icon/ic_eran_reward.svg"),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Earn Rewards".tr,
                                      style: TextStyle(fontFamily: AppThemData.semiBold, fontSize: 14, color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey08),
                                    ),
                                    const SizedBox(
                                      height: 2,
                                    ),
                                    Text(
                                      "You and your friends earn rewards for successful referrals.".tr,
                                      style: TextStyle(fontFamily: AppThemData.regular, fontSize: 12, color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey06),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
            bottomNavigationBar: Container(
              color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.grey11,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: RoundedButtonFill(
                  title: "Refer Now".tr,
                  color: AppThemData.primary06,
                  onPress: () {
                    ShowToastDialog.showLoader("Please wait".tr);
                    share(controller);
                  },
                ),
              ),
            ),
          );
        });
  }

  Future<void> share(ReferralController controller) async {
    ShowToastDialog.closeLoader();
    await Share.share(
      "Hey there, thanks for choosing SP Customer. Hope you love our product. If you do, share it with your friends using code ${controller.referralModel.value.referralCode.toString()} and get ${Constant.amountShow(amount: Constant.referralAmount)}.",
    );
  }
}
