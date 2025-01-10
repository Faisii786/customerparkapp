import 'package:get/get.dart';
import 'package:customerparkapp/model/user_model.dart';
import 'package:customerparkapp/utils/fire_store_utils.dart';

class InboxController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<UserModel> senderUserModel = UserModel().obs;

  @override
  void onInit() {
    getUser();
    super.onInit();
  }

  getUser() async {
    await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()).then((value) {
      senderUserModel.value = value!;
    });
    isLoading.value = false;
  }
}
