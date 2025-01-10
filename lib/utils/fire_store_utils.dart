import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:customerparkapp/constant/collection_name.dart';
import 'package:customerparkapp/constant/constant.dart';
import 'package:customerparkapp/model/admin_commission.dart';
import 'package:customerparkapp/model/bank_details_model.dart';
import 'package:customerparkapp/model/coupon_model.dart';
import 'package:customerparkapp/model/faq_model.dart';
import 'package:customerparkapp/model/language_model.dart';
import 'package:customerparkapp/model/on_boarding_model.dart';
import 'package:customerparkapp/model/order_model.dart';
import 'package:customerparkapp/model/parking_model.dart';
import 'package:customerparkapp/model/payment_method_model.dart';
import 'package:customerparkapp/model/referral_model.dart';
import 'package:customerparkapp/model/review_model.dart';
import 'package:customerparkapp/model/tax_model.dart';
import 'package:customerparkapp/model/user_model.dart';
import 'package:customerparkapp/model/user_vehicle_model.dart';
import 'package:customerparkapp/model/vehicle_brand_model.dart';
import 'package:customerparkapp/model/vehicle_model.dart';
import 'package:customerparkapp/model/wallet_transaction_model.dart';
import 'package:customerparkapp/model/withdraw_model.dart';
import 'package:customerparkapp/widgets/geoflutterfire/src/geoflutterfire.dart';

import '../widgets/geoflutterfire/src/models/point.dart';

class FireStoreUtils {
  static FirebaseFirestore fireStore = FirebaseFirestore.instance;

  static String getCurrentUid() {
    return FirebaseAuth.instance.currentUser!.uid;
  }

  static Future<bool> isLogin() async {
    bool isLogin = false;
    if (FirebaseAuth.instance.currentUser != null) {
      isLogin = await userExistOrNot(FirebaseAuth.instance.currentUser!.uid);
    } else {
      isLogin = false;
    }
    return isLogin;
  }

  static Future<bool> userExistOrNot(String uid) async {
    bool isExist = false;

    await fireStore.collection(CollectionName.users).doc(uid).get().then(
      (value) {
        if (value.exists) {
          isExist = true;
        } else {
          isExist = false;
        }
      },
    ).catchError((error) {
      log("Failed to check user exist: $error");
      isExist = false;
    });
    return isExist;
  }

  static Future<List<OnBoardingModel>> getOnBoardingList() async {
    List<OnBoardingModel> onBoardingModel = [];
    await fireStore.collection(CollectionName.onBoarding).get().then((value) {
      for (var element in value.docs) {
        OnBoardingModel documentModel = OnBoardingModel.fromJson(element.data());
        onBoardingModel.add(documentModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return onBoardingModel;
  }

  Future<List<TaxModel>?> getTaxList() async {
    List<TaxModel> taxList = [];

    await fireStore.collection(CollectionName.tax).where('country', isEqualTo: Constant.country).where('enable', isEqualTo: true).get().then((value) {
      for (var element in value.docs) {
        TaxModel taxModel = TaxModel.fromJson(element.data());
        taxList.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return taxList;
  }

  static Future<bool?> checkReferralCodeValidOrNot(String referralCode) async {
    bool? isExit;
    try {
      await fireStore.collection(CollectionName.referral).where("referralCode", isEqualTo: referralCode).get().then((value) {
        if (value.size > 0) {
          isExit = true;
        } else {
          isExit = false;
        }
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return false;
    }
    return isExit;
  }

  static Future<ReferralModel?> getReferralUserByCode(String referralCode) async {
    ReferralModel? referralModel;
    try {
      await fireStore.collection(CollectionName.referral).where("referralCode", isEqualTo: referralCode).get().then((value) {
        referralModel = ReferralModel.fromJson(value.docs.first.data());
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return referralModel;
  }

  static Future<String?> referralAdd(ReferralModel ratingModel) async {
    try {
      await fireStore.collection(CollectionName.referral).doc(ratingModel.id).set(ratingModel.toJson());
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return null;
  }

  static Future<bool> updateUser(UserModel userModel) async {
    bool isUpdate = false;
    await fireStore.collection(CollectionName.users).doc(userModel.id).set(userModel.toJson()).whenComplete(() {
      isUpdate = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isUpdate = false;
    });
    return isUpdate;
  }

  static Future<UserModel?> getUserProfile(String uuid) async {
    UserModel? userModel;
    await fireStore.collection(CollectionName.users).doc(uuid).get().then((value) {
      if (value.exists) {
        userModel = UserModel.fromJson(value.data()!);
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      userModel = null;
    });
    return userModel;
  }

  static Future<UserModel?> getWatchman(String parkingId, String ownerId) async {
    UserModel? userModel;
    await fireStore.collection(CollectionName.users).where("role", isEqualTo: "security").where("parkingId", isEqualTo: parkingId).get().then((value) {
      if (value.docs.isNotEmpty) {
        userModel = UserModel.fromJson(value.docs.first.data());
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      userModel = null;
    });
    return userModel;
  }

  // Future<CurrencyModel?> getCurrency() async {
  //   CurrencyModel? currencyModel;
  //   await fireStore.collection(CollectionName.currency).where("enable", isEqualTo: true).get().then((value) {
  //     if (value.docs.isNotEmpty) {
  //       currencyModel = CurrencyModel.fromJson(value.docs.first.data());
  //     }
  //   });
  //   return currencyModel;
  // }

  static Future<List<LanguageModel>?> getLanguage() async {
    List<LanguageModel> languageList = [];

    await fireStore.collection(CollectionName.languages).get().then((value) {
      for (var element in value.docs) {
        LanguageModel taxModel = LanguageModel.fromJson(element.data());
        languageList.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return languageList;
  }

  static Future<List<VehicleBrandModel>?> gerBrand() async {
    List<VehicleBrandModel> brandList = [];

    await fireStore.collection(CollectionName.brand).where("enable", isEqualTo: true).get().then((value) {
      for (var element in value.docs) {
        VehicleBrandModel taxModel = VehicleBrandModel.fromJson(element.data());
        brandList.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return brandList;
  }

  static Future<List<VehicleModel>?> getVehicleModel(String id) async {
    List<VehicleModel> vehicleModel = [];

    await fireStore.collection(CollectionName.model).where("brandId", isEqualTo: id).where("enable", isEqualTo: true).get().then((value) {
      for (var element in value.docs) {
        VehicleModel taxModel = VehicleModel.fromJson(element.data());
        vehicleModel.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return vehicleModel;
  }

  static Future<bool?> deleteUser() async {
    bool? isDelete;
    try {
      await fireStore.collection(CollectionName.users).doc(FireStoreUtils.getCurrentUid()).delete();

      // delete user  from firebase auth
      await FirebaseAuth.instance.currentUser!.delete().then((value) {
        isDelete = true;
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return false;
    }
    return isDelete;
  }

  getSettings() async {
    fireStore.collection(CollectionName.settings).doc("globalKey").snapshots().listen((event) {
      if (event.exists) {
        Constant.mapAPIKey = event.data()!["googleMapKey"];
        Constant.radius = event.data()!["radius"];
        Constant.distanceType = event.data()!["distanceType"];
      }
    });

    await fireStore.collection(CollectionName.settings).doc("notification_setting").get().then((value) {
      if (value.exists) {
        Constant.senderId = value.data()!['senderId'].toString();
        Constant.jsonNotificationFileURL = value.data()!['serviceJson'].toString();
      }
    });

    await fireStore.collection(CollectionName.settings).doc("global").get().then((value) {
      if (value.exists) {
        Constant.termsAndConditions = value.data()!["termsAndConditions"];
        Constant.privacyPolicy = value.data()!["privacyPolicy"];
        Constant.minimumAmountToDeposit = value.data()!["minimumAmountToDeposit"];
        Constant.minimumAmountToWithdrawal = value.data()!["minimumAmountToWithdrawal"];
        Constant.mapType = value.data()!["mapType"];
        Constant.selectedMapType = value.data()!["selectedMapType"];
        Constant.locationUpdate = value.data()!["locationUpdate"];
      }
    });

    await fireStore.collection(CollectionName.settings).doc("referral").get().then((value) {
      if (value.exists) {
        Constant.referralAmount = value.data()!["referralAmount"];
      }
    });

    await fireStore.collection(CollectionName.settings).doc("contact_us").get().then((value) {
      if (value.exists) {
        Constant.supportURL = value.data()!["supportURL"];
      }
    });

    await fireStore.collection(CollectionName.settings).doc("adminCommission").get().then((value) {
      Constant.adminCommission = AdminCommission.fromJson(value.data()!);
    });
  }

  // static Future<ParkingModel?> getUserParkingDetails(String id) async {
  //   ParkingModel? parkingModel;
  //   await fireStore
  //       .collection(CollectionName.parking)
  //       .doc(id)
  //       .get()
  //       .then((value) {
  //     parkingModel = ParkingModel.fromJson(value.data()!);
  //   });
  //   return parkingModel;
  // }

  static Future<String?> saveParkingDetails(ParkingModel createSlotModel) async {
    try {
      await fireStore.collection(CollectionName.parking).doc(createSlotModel.id).set(createSlotModel.toJson());
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return null;
  }

  // static Future<String?> deleteParking(ParkingModel parkingModel) async {
  //   try {
  //     await fireStore
  //         .collection(CollectionName.parking)
  //         .doc(parkingModel.id)
  //         .delete();
  //   } catch (e, s) {
  //     log('FireStoreUtils.firebaseCreateNewUser $e $s');
  //     return null;
  //   }
  //   return null;
  // }

  Future<PaymentModel?> getPayment() async {
    PaymentModel? paymentModel;
    await fireStore.collection(CollectionName.settings).doc("payment").get().then((value) {
      paymentModel = PaymentModel.fromJson(value.data()!);
    });
    return paymentModel;
  }

  // static Future<List<ParkingFacilitiesModel>> getParkingFacilities() async {
  //   List<ParkingFacilitiesModel> facilitiesModelList = [];
  //   await fireStore
  //       .collection(CollectionName.facilities)
  //       .where('isEnable', isEqualTo: true)
  //       .get()
  //       .then((value) async {
  //     for (var element in value.docs) {
  //       ParkingFacilitiesModel facilitiesModel =
  //           ParkingFacilitiesModel.fromJson(element.data());
  //       facilitiesModelList.add(facilitiesModel);
  //     }
  //   });
  //   return facilitiesModelList;
  // }
  final geo = Geoflutterfire();
  StreamController<List<ParkingModel>>? getNearestOrderRequestController;

  Stream<List<ParkingModel>> getParkingNearest({double? latitude, double? longLatitude}) async* {
    getNearestOrderRequestController = StreamController<List<ParkingModel>>.broadcast();
    List<ParkingModel> ordersList = [];
    var query = fireStore.collection(CollectionName.parking).where("isEnable", isEqualTo: true);

    GeoFirePoint center = geo.point(latitude: latitude ?? 0.0, longitude: longLatitude ?? 0.0);
    Stream<List<DocumentSnapshot>> stream = geo.collection(collectionRef: query).within(center: center, radius: double.parse(Constant.radius), field: 'position', strictMode: true);

    stream.listen((List<DocumentSnapshot> documentList) {
      ordersList.clear();
      for (var document in documentList) {
        final data = document.data() as Map<String, dynamic>;
        ParkingModel orderModel = ParkingModel.fromJson(data);

        ordersList.add(orderModel);
      }
      getNearestOrderRequestController!.sink.add(ordersList);
    });

    yield* getNearestOrderRequestController!.stream;
  }

  StreamController<List<ParkingModel>>? getNearestFilterParking;

  Stream<List<ParkingModel>> getFilterParking({double? latitude, double? longLatitude, String? parkingType, String? distance}) async* {
    getNearestFilterParking = StreamController<List<ParkingModel>>.broadcast();
    List<ParkingModel> ordersList = [];

    var query = fireStore.collection(CollectionName.parking).where("parkingType", isEqualTo: parkingType).where("isEnable", isEqualTo: true);

    GeoFirePoint center = geo.point(latitude: latitude ?? 0.0, longitude: longLatitude ?? 0.0);
    Stream<List<DocumentSnapshot>> stream =
        geo.collection(collectionRef: query).within(center: center, radius: double.parse(distance.toString()), field: 'position', strictMode: true);

    stream.listen((List<DocumentSnapshot> documentList) {
      ordersList.clear();
      for (var document in documentList) {
        final data = document.data() as Map<String, dynamic>;
        ParkingModel orderModel = ParkingModel.fromJson(data);

        ordersList.add(orderModel);
      }
      getNearestFilterParking!.sink.add(ordersList);
    });

    yield* getNearestFilterParking!.stream;
  }

  static Future<ParkingModel?> getParkingDetails(String uuid) async {
    ParkingModel? slotModel;
    await fireStore.collection(CollectionName.parking).doc(uuid).get().then((value) {
      if (value.exists) {
        slotModel = ParkingModel.fromJson(value.data()!);
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      slotModel = null;
    });
    return slotModel;
  }

  static Future<OrderModel?> getSingleOrder(String orderId) async {
    OrderModel? orderModel;
    await fireStore.collection(CollectionName.bookedParkingOrder).doc(orderId).get().then((value) {
      if (value.exists) {
        orderModel = OrderModel.fromJson(value.data()!);
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      orderModel = null;
    });
    return orderModel;
  }

  // static Future<List<ParkingModel>?> getMyParkingList() async {
  //   List<ParkingModel> parkingList = [];
  //   await fireStore
  //       .collection(CollectionName.parking)
  //       .where("userId", isEqualTo: getCurrentUid())
  //       .get()
  //       .then((value) async {
  //     for (var element in value.docs) {
  //       ParkingModel facilitiesModel = ParkingModel.fromJson(element.data());
  //       parkingList.add(facilitiesModel);
  //     }
  //   });
  //   return parkingList;
  // }

  static Future<bool?> bookMarked(ParkingModel parkingModel) async {
    try {
      if (parkingModel.bookmarkedUser == null) {
        parkingModel.bookmarkedUser = [];
        parkingModel.bookmarkedUser!.add(getCurrentUid());
      } else {
        parkingModel.bookmarkedUser!.add(getCurrentUid());
      }
      await fireStore.collection(CollectionName.parking).doc(parkingModel.id).set(parkingModel.toJson());
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return null;
  }

  static Future<bool?> removeBookMarked(ParkingModel parkingModel) async {
    try {
      parkingModel.bookmarkedUser!.remove(getCurrentUid());

      await fireStore.collection(CollectionName.parking).doc(parkingModel.id).set(parkingModel.toJson());
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return null;
  }

  static Future<List<ParkingModel>?> getBookMarkedList() async {
    List<ParkingModel> parkingList = [];
    await fireStore.collection(CollectionName.parking).where("bookmarkedUser", arrayContains: getCurrentUid()).get().then((value) async {
      for (var element in value.docs) {
        ParkingModel facilitiesModel = ParkingModel.fromJson(element.data());
        parkingList.add(facilitiesModel);
      }
    });
    return parkingList;
  }

  static Future<bool> updateUserVehicle(UserVehicleModel userVehicleModel) async {
    bool isUpdate = false;
    await fireStore.collection(CollectionName.userVehicles).doc(userVehicleModel.id).set(userVehicleModel.toJson()).whenComplete(() {
      isUpdate = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isUpdate = false;
    });
    return isUpdate;
  }

  static Future<List<UserVehicleModel>?> getUserVehicle() async {
    List<UserVehicleModel> userVehicleList = [];
    await fireStore.collection(CollectionName.userVehicles).where("userId", isEqualTo: getCurrentUid()).get().then((value) async {
      for (var element in value.docs) {
        UserVehicleModel facilitiesModel = UserVehicleModel.fromJson(element.data());
        userVehicleList.add(facilitiesModel);
      }
    });
    return userVehicleList;
  }

  static Future<bool?> setOrder(OrderModel orderModel) async {
    bool isAdded = false;
    await fireStore.collection(CollectionName.bookedParkingOrder).doc(orderModel.id).set(orderModel.toJson()).then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<List<OrderModel>?> getOrder(Timestamp date, Timestamp startTime, Timestamp endTime, String parkingId) async {
    List<OrderModel> orderList = [];
    await fireStore
        .collection(CollectionName.bookedParkingOrder)
        .where(
          'parkingId',
          isEqualTo: parkingId,
        )
        .where('status', whereIn: [Constant.placed, Constant.onGoing])
        .where('bookingDate', isEqualTo: date)
        .get()
        .then((value) async {
          for (var element in value.docs) {
            OrderModel orderModel = OrderModel.fromJson(element.data());
            orderList.add(orderModel);
          }
        });
    return orderList;
  }

  static Future<bool?> setWalletTransaction(WalletTransactionModel walletTransactionModel) async {
    bool isAdded = false;
    await fireStore.collection(CollectionName.walletTransaction).doc(walletTransactionModel.id).set(walletTransactionModel.toJson()).then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<bool?> updateUserWallet({required String amount}) async {
    bool isAdded = false;
    await getUserProfile(FireStoreUtils.getCurrentUid()).then((value) async {
      if (value != null) {
        UserModel userModel = value;
        userModel.walletAmount = (double.parse(userModel.walletAmount.toString()) + double.parse(amount)).toString();
        await FireStoreUtils.updateUser(userModel).then((value) {
          isAdded = value;
        });
      }
    });
    return isAdded;
  }

  static Future<bool?> updateOtherUserWallet({required String amount, required String id}) async {
    bool isAdded = false;
    await getUserProfile(id).then((value) async {
      if (value != null) {
        UserModel userModel = value;
        userModel.walletAmount = (double.parse(userModel.walletAmount.toString()) + double.parse(amount)).toString();
        await FireStoreUtils.updateUser(userModel).then((value) {
          isAdded = value;
        });
      }
    });
    return isAdded;
  }

  static Future<List<WalletTransactionModel>?> getWalletTransaction() async {
    List<WalletTransactionModel> walletTransactionModel = [];

    await fireStore
        .collection(CollectionName.walletTransaction)
        .where('userId', isEqualTo: FireStoreUtils.getCurrentUid())
        .orderBy('createdDate', descending: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        WalletTransactionModel taxModel = WalletTransactionModel.fromJson(element.data());
        walletTransactionModel.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return walletTransactionModel;
  }

  static Future<List<FaqModel>> getFaq() async {
    List<FaqModel> faqModel = [];
    await fireStore.collection(CollectionName.faq).where('enable', isEqualTo: true).get().then((value) {
      for (var element in value.docs) {
        FaqModel documentModel = FaqModel.fromJson(element.data());
        faqModel.add(documentModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return faqModel;
  }

  static Future<ReviewModel?> getReview(String orderId) async {
    ReviewModel? reviewModel;
    await fireStore.collection(CollectionName.review).doc(orderId).get().then((value) {
      if (value.data() != null) {
        reviewModel = ReviewModel.fromJson(value.data()!);
      }
    });
    return reviewModel;
  }

  static Future<bool?> setReview(ReviewModel reviewModel) async {
    bool isAdded = false;
    await fireStore.collection(CollectionName.review).doc(reviewModel.id).set(reviewModel.toJson()).then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<List<WithdrawModel>> getWithDrawRequest() async {
    List<WithdrawModel> withdrawalList = [];
    await fireStore.collection(CollectionName.withdrawalHistory).where('userId', isEqualTo: getCurrentUid()).orderBy('createdDate', descending: true).get().then((value) {
      for (var element in value.docs) {
        WithdrawModel documentModel = WithdrawModel.fromJson(element.data());
        withdrawalList.add(documentModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return withdrawalList;
  }

  static Future<BankDetailsModel?> getBankDetails() async {
    BankDetailsModel? bankDetailsModel;
    await fireStore.collection(CollectionName.bankDetails).doc(FireStoreUtils.getCurrentUid()).get().then((value) {
      if (value.data() != null) {
        bankDetailsModel = BankDetailsModel.fromJson(value.data()!);
      }
    });
    return bankDetailsModel;
  }

  static Future<bool?> updateBankDetails(BankDetailsModel bankDetailsModel) async {
    bool isAdded = false;
    await fireStore.collection(CollectionName.bankDetails).doc(bankDetailsModel.userId).set(bankDetailsModel.toJson()).then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<bool?> bankDetailsIsAvailable() async {
    bool isAdded = false;
    await fireStore.collection(CollectionName.bankDetails).doc(FireStoreUtils.getCurrentUid()).get().then((value) {
      if (value.exists) {
        isAdded = true;
      } else {
        isAdded = false;
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<bool?> setWithdrawRequest(WithdrawModel withdrawModel) async {
    bool isAdded = false;
    await fireStore.collection(CollectionName.withdrawalHistory).doc(withdrawModel.id).set(withdrawModel.toJson()).then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<ReferralModel?> getReferral() async {
    ReferralModel? referralModel;
    await fireStore.collection(CollectionName.referral).doc(FireStoreUtils.getCurrentUid()).get().then((value) {
      if (value.exists) {
        referralModel = ReferralModel.fromJson(value.data()!);
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      referralModel = null;
    });
    return referralModel;
  }

  static Future<bool> getFirestOrderOrNOt(OrderModel orderModel) async {
    bool isFirst = true;
    await fireStore.collection(CollectionName.bookedParkingOrder).where('userId', isEqualTo: orderModel.userId).get().then((value) {
      if (value.size == 1) {
        isFirst = true;
      } else {
        isFirst = false;
      }
    });
    return isFirst;
  }

  static Future updateReferralAmount(OrderModel orderModel) async {
    ReferralModel? referralModel;
    await fireStore.collection(CollectionName.referral).doc(orderModel.userId).get().then((value) {
      if (value.data() != null) {
        referralModel = ReferralModel.fromJson(value.data()!);
      } else {
        return;
      }
    });
    if (referralModel != null) {
      if (referralModel!.referralBy != null && referralModel!.referralBy!.isNotEmpty) {
        await fireStore.collection(CollectionName.users).doc(referralModel!.referralBy).get().then((value) async {
          DocumentSnapshot<Map<String, dynamic>> userDocument = value;
          if (userDocument.data() != null && userDocument.exists) {
            try {
              log(userDocument.data().toString());
              UserModel user = UserModel.fromJson(userDocument.data()!);
              user.walletAmount = (double.parse(user.walletAmount.toString()) + double.parse(Constant.referralAmount.toString())).toString();
              updateUser(user);

              WalletTransactionModel transactionModel = WalletTransactionModel(
                  id: Constant.getUuid(),
                  amount: Constant.referralAmount.toString(),
                  createdDate: Timestamp.now(),
                  paymentType: "Wallet",
                  transactionId: orderModel.id,
                  userId: user.id.toString(),
                  note: "Referral Amount");

              await FireStoreUtils.setWalletTransaction(transactionModel);
            } catch (error) {
              print(error);
            }
          }
        });
      } else {
        return;
      }
    }
  }

  Future<List<CouponModel>?> getCoupon() async {
    List<CouponModel> couponModel = [];

    await fireStore
        .collection(CollectionName.coupon)
        .where('enable', isEqualTo: true)
        .where("isPublic", isEqualTo: true)
        .where('validity', isGreaterThanOrEqualTo: Timestamp.now())
        .get()
        .then((value) {
      for (var element in value.docs) {
        CouponModel taxModel = CouponModel.fromJson(element.data());
        couponModel.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return couponModel;
  }
}
