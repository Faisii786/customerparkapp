import 'package:flutter/material.dart';
import 'package:customerparkapp/themes/app_them_data.dart';

class Styles {
  static ThemeData themeData(bool isDarkTheme, BuildContext context) {
    return ThemeData(
      scaffoldBackgroundColor: isDarkTheme ? AppThemData.grey11 : AppThemData.grey02,
      primaryColor: isDarkTheme ? AppThemData.primary06 : AppThemData.primary06,
      brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      timePickerTheme: TimePickerThemeData(
        backgroundColor: isDarkTheme ? AppThemData.grey07 : AppThemData.grey03,
        dialTextStyle: TextStyle(fontWeight: FontWeight.bold, color: isDarkTheme ? AppThemData.grey10 : AppThemData.grey10),
        dialTextColor: isDarkTheme ? AppThemData.grey10 : AppThemData.grey10,
        hourMinuteTextColor: isDarkTheme ? AppThemData.grey10 : AppThemData.grey10,
        dayPeriodTextColor: isDarkTheme ? AppThemData.grey10 : AppThemData.grey10,
      ),
    );
  }
}
