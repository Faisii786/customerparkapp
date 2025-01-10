import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:customerparkapp/themes/app_them_data.dart';
import 'package:customerparkapp/utils/dark_theme_provider.dart';
import 'package:provider/provider.dart';

class MobileNumberTextField extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final TextEditingController countryCodeController;
  final Function() onPress;
  final bool? enabled;

  const MobileNumberTextField({super.key, required this.controller, required this.countryCodeController, required this.onPress, required this.title, this.enabled});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontFamily: AppThemData.medium, fontSize: 14, color: AppThemData.grey07)),
          const SizedBox(
            height: 5,
          ),
          TextFormField(
            keyboardType: TextInputType.number,
            textCapitalization: TextCapitalization.sentences,
            controller: controller,
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 14, color: themeChange.getThem() ? AppThemData.grey02 : AppThemData.grey08, fontWeight: FontWeight.w500, fontFamily: AppThemData.medium),
            decoration: InputDecoration(
                errorStyle: const TextStyle(color: Colors.red),
                isDense: true,
                filled: true,
                enabled: enabled ?? true,
                fillColor: themeChange.getThem() ? AppThemData.grey10 : AppThemData.grey03,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                prefixIcon: CountryCodePicker(
                  onChanged: (value) {
                    countryCodeController.text = value.dialCode.toString();
                  },
                  dialogTextStyle: TextStyle(color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey08, fontWeight: FontWeight.w500, fontFamily: AppThemData.medium),
                  dialogBackgroundColor: themeChange.getThem() ? AppThemData.grey11 : AppThemData.grey02,
                  initialSelection: countryCodeController.text,
                  comparator: (a, b) => b.name!.compareTo(a.name.toString()),
                  flagDecoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                  ),
                  textStyle: TextStyle(color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey08, fontWeight: FontWeight.w500, fontFamily: AppThemData.medium),
                  searchDecoration: InputDecoration(iconColor: themeChange.getThem() ? AppThemData.grey08 : AppThemData.grey08),
                  searchStyle: TextStyle(color: themeChange.getThem() ? AppThemData.grey08 : AppThemData.grey08, fontWeight: FontWeight.w500, fontFamily: AppThemData.medium),
                ),
                disabledBorder: UnderlineInputBorder(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                  borderSide: BorderSide(color: themeChange.getThem() ? AppThemData.grey09 : AppThemData.grey04, width: 1),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                  borderSide: BorderSide(color: themeChange.getThem() ? AppThemData.primary06 : AppThemData.primary06, width: 1),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                  borderSide: BorderSide(color: themeChange.getThem() ? AppThemData.grey09 : AppThemData.grey04, width: 1),
                ),
                errorBorder: UnderlineInputBorder(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                  borderSide: BorderSide(color: themeChange.getThem() ? AppThemData.grey09 : AppThemData.grey04, width: 1),
                ),
                border: UnderlineInputBorder(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                  borderSide: BorderSide(color: themeChange.getThem() ? AppThemData.grey09 : AppThemData.grey04, width: 1),
                ),
                hintText: "Enter Phone Number".tr,
                hintStyle: TextStyle(color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey06, fontWeight: FontWeight.w500, fontFamily: AppThemData.medium)),
          ),
        ],
      ),
    );
  }
}
