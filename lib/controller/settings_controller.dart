import 'package:get/get.dart';
import 'package:customerparkapp/utils/preferences.dart';

class SettingController extends GetxController {
  @override
  void onInit() {
    getLanguage();
    super.onInit();
  }

  RxBool isLoading = true.obs;
  RxList<String> modeList = <String>['Light mode', 'Dark mode', 'System'].obs;
  Rx<String> selectedMode = "".obs;

  getLanguage() async {
    if (Preferences.getString(Preferences.themKey).toString().isNotEmpty) {
      selectedMode.value = Preferences.getString(Preferences.themKey).toString();
    }
    isLoading.value = false;
    update();
  }
}
