import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:customerparkapp/controller/splash_controller.dart';
import 'package:customerparkapp/themes/app_them_data.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
        init: SplashController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: AppThemData.primary06,
            body: Container(
              decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/smart_splash.png"), fit: BoxFit.fill)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: SizedBox(
                      height: 350,
                      width: 350,
                      child: Image.asset("assets/images/splash_logo.png")),
                ),
              ),
            ),
          );
        });
  }
}
