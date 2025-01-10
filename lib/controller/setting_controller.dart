import 'package:get/get.dart';
import 'package:customerparkapp/constant/constant.dart';
import 'package:customerparkapp/model/language_model.dart';
import 'package:customerparkapp/utils/preferences.dart';

class SettingController extends GetxController {
  RxString lightDarkMode = "Light".obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getThem();
    super.onInit();
  }

  void handleGenderChange(String? value) {
    lightDarkMode.value = value!;
  }

  Rx<LanguageModel> selectedLanguage = LanguageModel().obs;

  getThem() {
    lightDarkMode.value = Preferences.getString(Preferences.themKey);

    selectedLanguage.value = Constant.getLanguage();
  }
}
