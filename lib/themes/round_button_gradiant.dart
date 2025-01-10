import 'package:flutter/material.dart';
import 'package:customerparkapp/themes/app_them_data.dart';
import 'package:customerparkapp/themes/responsive.dart';

class RoundedButtonGradiant extends StatelessWidget {
  final String title;
  final double? width;
  final double? height;
  final Function() onPress;

  const RoundedButtonGradiant({super.key, required this.title, this.height, required this.onPress, this.width});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        onPress();
      },
      child: Container(
        width: Responsive.width(width ?? 100, context),
        height: Responsive.height(height ?? 6, context),
        decoration: ShapeDecoration(
          gradient: const LinearGradient(
            begin: Alignment(0.00, 1.00),
            end: Alignment(0, -1),
            colors: AppThemData.gradient03,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(200),
          ),
        ),
        child: Center(
          child: Text(
            title.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppThemData.medium,
              color: AppThemData.grey11,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
