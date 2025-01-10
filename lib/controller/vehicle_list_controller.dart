import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:customerparkapp/constant/constant.dart';
import 'package:customerparkapp/constant/show_toast_dialog.dart';
import 'package:customerparkapp/model/user_vehicle_model.dart';
import 'package:customerparkapp/model/vehicle_brand_model.dart';
import 'package:customerparkapp/model/vehicle_model.dart';
import 'package:customerparkapp/utils/fire_store_utils.dart';

class VehicleListController extends GetxController {
  RxBool isLoading = true.obs;

  Rx<TextEditingController> vehicleNumberController = TextEditingController().obs;

  @override
  void onInit() {
    getArgument();
    super.onInit();
  }

  getArgument() async {
    await gerBrand();
    await getVehicleList();
    isLoading.value = false;
    update();
  }

  RxList<VehicleBrandModel> brandList = <VehicleBrandModel>[].obs;
  RxList<VehicleModel> vehicleModelList = <VehicleModel>[].obs;
  Rx<VehicleBrandModel> selectedBrand = VehicleBrandModel().obs;
  Rx<VehicleModel> selectedVehicleModel = VehicleModel().obs;

  gerBrand() async {
    await FireStoreUtils.gerBrand().then((value) {
      if (value != null) {
        brandList.value = value;
      }
    });
  }

  RxList<UserVehicleModel> userVehicle = <UserVehicleModel>[].obs;
  Rx<UserVehicleModel> selectedVehicle = UserVehicleModel().obs;

  getVehicleList() async {
    isLoading.value = true;
    userVehicle.clear();
    await FireStoreUtils.getUserVehicle().then((value) {
      if (value != null) {
        userVehicle.value = value;
        // selectedVehicle.value = userVehicle.first;
      }
    });
    isLoading.value = false;
  }

  getBrandModel() async {
    ShowToastDialog.showLoader("Please wait");
    vehicleModelList.clear();
    selectedVehicleModel.value = VehicleModel();
    await FireStoreUtils.getVehicleModel(selectedBrand.value.id.toString()).then((value) {
      if (value != null) {
        vehicleModelList.value = value;
      }
    });
    ShowToastDialog.closeLoader();
  }

  saveVehicleInformation() async {
    ShowToastDialog.showLoader("Please wait");
    UserVehicleModel userVehicleModel = UserVehicleModel();
    userVehicleModel.vehicleModel = selectedVehicleModel.value;
    userVehicleModel.vehicleBrand = selectedBrand.value;
    userVehicleModel.vehicleNumber = vehicleNumberController.value.text;
    userVehicleModel.id = Constant.getUuid();
    userVehicleModel.userId = FireStoreUtils.getCurrentUid();

    await FireStoreUtils.updateUserVehicle(userVehicleModel).then((value) {
      ShowToastDialog.closeLoader();
      getVehicleList();
      isLoading.value = false;
      Get.back();
    });
  }
}
