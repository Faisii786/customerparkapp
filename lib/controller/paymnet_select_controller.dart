import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as maths;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:customerparkapp/constant/constant.dart';
import 'package:customerparkapp/constant/send_notification.dart';
import 'package:customerparkapp/constant/show_toast_dialog.dart';
import 'package:customerparkapp/model/order_model.dart';
import 'package:customerparkapp/model/payment/xenditModel.dart';
import 'package:customerparkapp/model/payment_method_model.dart';
import 'package:customerparkapp/model/user_model.dart';
import 'package:customerparkapp/model/wallet_transaction_model.dart';
import 'package:customerparkapp/payment/MercadoPagoScreen.dart';
import 'package:customerparkapp/payment/PayFastScreen.dart';
import 'package:customerparkapp/payment/RazorPayFailedModel.dart';
import 'package:customerparkapp/payment/getPaytmTxtToken.dart';
import 'package:customerparkapp/payment/midtrans_screen.dart';
import 'package:customerparkapp/payment/orangePayScreen.dart';
import 'package:customerparkapp/payment/paystack/pay_stack_screen.dart';
import 'package:customerparkapp/payment/paystack/pay_stack_url_model.dart';
import 'package:customerparkapp/payment/paystack/paystack_url_genrater.dart';
import 'package:customerparkapp/payment/stripe_failed_model.dart';
import 'package:customerparkapp/payment/xenditScreen.dart';
import 'package:customerparkapp/themes/app_them_data.dart';
import 'package:customerparkapp/ui/my_booking/parking_ticket_screen.dart';
import 'package:customerparkapp/utils/fire_store_utils.dart';
// import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:uuid/uuid.dart';

class PaymentSelectController extends GetxController {
  Rx<PaymentModel> paymentModel = PaymentModel().obs;
  RxString selectedPaymentMethod = "".obs;
  RxBool isLoading = false.obs;

  Rx<OrderModel> orderModel = OrderModel().obs;
  Rx<UserModel> userModel = UserModel().obs;

  @override
  void onInit() {
    getArgument();
    getPaymentData();

    super.onInit();
  }

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      orderModel.value = argumentData['orderModel'];
    }
    update();
  }

  getPaymentData() async {
    isLoading.value = true;
    await FireStoreUtils().getPayment().then((value) {
      if (value != null) {
        paymentModel.value = value;
        Stripe.publishableKey = paymentModel.value.strip!.clientpublishableKey.toString();
        Stripe.merchantIdentifier = 'GoRide';
        Stripe.instance.applySettings();
        setRef();
        selectedPaymentMethod.value = orderModel.value.paymentType.toString();

        razorPay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
        razorPay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWaller);
        razorPay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
      }
    });

    await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()).then((value) {
      if (value != null) {
        userModel.value = value;
      }
    });

    isLoading.value = false;
    update();
  }

  RxDouble couponAmount = 0.0.obs;

  double calculateAmount() {
    if (orderModel.value.coupon != null) {
      if (orderModel.value.coupon!.id != null) {
        if (orderModel.value.coupon!.type == "fix") {
          couponAmount.value = double.parse(orderModel.value.coupon!.amount.toString());
        } else {
          couponAmount.value = double.parse(orderModel.value.subTotal.toString()) * double.parse(orderModel.value.coupon!.amount.toString()) / 100;
        }
      }
    }
    RxString taxAmount = "0.0".obs;
    if (orderModel.value.taxList != null) {
      for (var element in orderModel.value.taxList!) {
        taxAmount.value = (double.parse(taxAmount.value) +
                Constant().calculateTax(amount: (double.parse(orderModel.value.subTotal.toString()) - double.parse(couponAmount.toString())).toString(), taxModel: element))
            .toStringAsFixed(Constant.currencyModel!.decimalDigits!);
      }
    }
    return (double.parse(orderModel.value.subTotal.toString()) - double.parse(couponAmount.toString())) + double.parse(taxAmount.value);
  }

  completeCashOrder() async {
    ShowToastDialog.showLoader("Please wait..");
    orderModel.value.paymentCompleted = false;
    orderModel.value.paymentType = selectedPaymentMethod.value;
    orderModel.value.adminCommission = Constant.adminCommission;
    orderModel.value.createdAt = Timestamp.now();
    orderModel.value.updateAt = Timestamp.now();
    await FireStoreUtils.getFirestOrderOrNOt(orderModel.value).then((value) async {
      if (value == true) {
        await FireStoreUtils.updateReferralAmount(orderModel.value);
      }
    });

    UserModel? receiverUserModel = await FireStoreUtils.getUserProfile(orderModel.value.parkingDetails!.userId.toString());

    Map<String, dynamic> playLoad = <String, dynamic>{"type": "order", "orderId": orderModel.value.id};

    await SendNotification.sendOneNotification(
        token: receiverUserModel!.fcmToken.toString(),
        title: 'Booking Placed',
        body: '${orderModel.value.parkingDetails!.name.toString()} Booking placed on ${Constant.timestampToDate(orderModel.value.bookingDate!)}.',
        payload: playLoad);

    await FireStoreUtils.getWatchman(orderModel.value.parkingDetails!.id.toString(), orderModel.value.parkingDetails!.userId.toString()).then((value) async {
      if (value != null) {
        await SendNotification.sendOneNotification(
            token: value.fcmToken.toString(),
            title: 'Booking Placed',
            body: '${orderModel.value.parkingDetails!.name.toString()} Booking placed on ${Constant.timestampToDate(orderModel.value.bookingDate!)}.',
            payload: playLoad);
      }
    });

    await FireStoreUtils.setOrder(orderModel.value).then((value) {
      if (value == true) {
        ShowToastDialog.closeLoader();
        Get.to(() => const ParkingTicketScreen(), arguments: {"orderModel": orderModel.value});
      }
    });
  }


  completeOrder() async {
    ShowToastDialog.showLoader("Please wait..");
    orderModel.value.paymentCompleted = true;
    orderModel.value.paymentType = selectedPaymentMethod.value;
    orderModel.value.adminCommission = Constant.adminCommission;
    orderModel.value.createdAt = Timestamp.now();
    orderModel.value.updateAt = Timestamp.now();

    WalletTransactionModel transactionModel = WalletTransactionModel(
        id: Constant.getUuid(),
        amount: calculateAmount().toString(),
        createdDate: Timestamp.now(),
        paymentType: selectedPaymentMethod.value,
        transactionId: orderModel.value.id,
        isCredit: true,
        userId: orderModel.value.parkingDetails!.userId.toString(),
        note: "Parking amount credited");

    await FireStoreUtils.setWalletTransaction(transactionModel).then((value) async {
      if (value == true) {
        await FireStoreUtils.updateOtherUserWallet(amount: calculateAmount().toString(), id: orderModel.value.parkingDetails!.userId.toString());
      }
    });

    WalletTransactionModel adminCommissionWallet = WalletTransactionModel(
        id: Constant.getUuid(),
        amount:
            "-${Constant.calculateAdminCommission(amount: (double.parse(orderModel.value.subTotal.toString()) - double.parse(couponAmount.toString())).toString(), adminCommission: orderModel.value.adminCommission)}",
        createdDate: Timestamp.now(),
        paymentType: selectedPaymentMethod.value,
        transactionId: orderModel.value.id,
        isCredit: false,
        userId: orderModel.value.parkingDetails!.userId.toString(),
        note: "Admin commission debited");

    await FireStoreUtils.setWalletTransaction(adminCommissionWallet).then((value) async {
      if (value == true) {
        await FireStoreUtils.updateOtherUserWallet(
            amount:
                "-${Constant.calculateAdminCommission(amount: (double.parse(orderModel.value.subTotal.toString()) - double.parse(couponAmount.toString())).toString(), adminCommission: orderModel.value.adminCommission)}",
            id: orderModel.value.parkingDetails!.userId.toString());
      }
    });

    await FireStoreUtils.getFirestOrderOrNOt(orderModel.value).then((value) async {
      if (value == true) {
        await FireStoreUtils.updateReferralAmount(orderModel.value);
      }
    });

    UserModel? receiverUserModel = await FireStoreUtils.getUserProfile(orderModel.value.parkingDetails!.userId.toString());

    Map<String, dynamic> playLoad = <String, dynamic>{"type": "order", "orderId": orderModel.value.id};

    await SendNotification.sendOneNotification(
        token: receiverUserModel!.fcmToken.toString(),
        title: 'Booking Placed',
        body: '${orderModel.value.parkingDetails!.name.toString()} Booking placed on ${Constant.timestampToDate(orderModel.value.bookingDate!)}.',
        payload: playLoad);

    await FireStoreUtils.getWatchman(orderModel.value.parkingDetails!.id.toString(), orderModel.value.parkingDetails!.userId.toString()).then((value) async {
      if (value != null) {
        await SendNotification.sendOneNotification(
            token: value.fcmToken.toString(),
            title: 'Booking Placed',
            body: '${orderModel.value.parkingDetails!.name.toString()} Booking placed on ${Constant.timestampToDate(orderModel.value.bookingDate!)}.',
            payload: playLoad);
      }
    });

    await FireStoreUtils.setOrder(orderModel.value).then((value) {
      if (value == true) {
        ShowToastDialog.closeLoader();
        Get.to(() => const ParkingTicketScreen(), arguments: {"orderModel": orderModel.value});
      }
    });
  }

  // Strip
  Future<void> stripeMakePayment({required String amount}) async {
    log(double.parse(amount).toStringAsFixed(0));
    try {
      Map<String, dynamic>? paymentIntentData = await createStripeIntent(amount: amount);
      if (paymentIntentData!.containsKey("error")) {
        Get.back();
        ShowToastDialog.showToast("Something went wrong, please contact admin.");
      } else {
        await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
                paymentIntentClientSecret: paymentIntentData['client_secret'],
                allowsDelayedPaymentMethods: false,
                googlePay: const PaymentSheetGooglePay(
                  merchantCountryCode: 'US',
                  testEnv: true,
                  currencyCode: "USD",
                ),
                style: ThemeMode.system,
                customFlow: true,
                appearance: const PaymentSheetAppearance(
                  colors: PaymentSheetAppearanceColors(
                    primary: AppThemData.primary06,
                  ),
                ),
                merchantDisplayName: 'GoRide'));
        displayStripePaymentSheet(amount: amount);
      }
    } catch (e, s) {
      log("$e \n$s");
      ShowToastDialog.showToast("exception:$e \n$s");
    }
  }

  displayStripePaymentSheet({required String amount}) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        ShowToastDialog.showToast("Payment successfully");
        completeOrder();
      });
    } on StripeException catch (e) {
      var lo1 = jsonEncode(e);
      var lo2 = jsonDecode(lo1);
      StripePayFailedModel lom = StripePayFailedModel.fromJson(lo2);
      ShowToastDialog.showToast(lom.error.message);
    } catch (e) {
      ShowToastDialog.showToast(e.toString());
    }
  }

  createStripeIntent({required String amount}) async {
    try {
      Map<String, dynamic> body = {
        'amount': ((double.parse(amount) * 100).round()).toString(),
        'currency': "USD",
        'payment_method_types[]': 'card',
        "description": "Strip Payment",
        "shipping[name]": userModel.value.fullName,
        "shipping[address][line1]": "510 Townsend St",
        "shipping[address][postal_code]": "98140",
        "shipping[address][city]": "San Francisco",
        "shipping[address][state]": "CA",
        "shipping[address][country]": "US",
      };
      log(paymentModel.value.strip!.stripeSecret.toString());
      var stripeSecret = paymentModel.value.strip!.stripeSecret;
      var response = await http.post(Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body, headers: {'Authorization': 'Bearer $stripeSecret', 'Content-Type': 'application/x-www-form-urlencoded'});

      return jsonDecode(response.body);
    } catch (e) {
      log(e.toString());
    }
  }

  //mercadoo
  mercadoPagoMakePayment({required BuildContext context, required String amount}) async {
    final headers = {
      'Authorization': 'Bearer ${paymentModel.value.mercadoPago!.accessToken}',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "items": [
        {
          "title": "Test",
          "description": "Test Payment",
          "quantity": 1,
          "currency_id": "BRL", // or your preferred currency
          "unit_price": double.parse(amount),
        }
      ],
      "payer": {"email": userModel.value.email.toString()},
      "back_urls": {
        "failure": "${Constant.globalUrl}payment/failure",
        "pending": "${Constant.globalUrl}payment/pending",
        "success": "${Constant.globalUrl}payment/success",
      },
      "auto_return": "approved" // Automatically return after payment is approved
    });

    final response = await http.post(
      Uri.parse("https://api.mercadopago.com/checkout/preferences"),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final bool isDone = await Navigator.push(context, MaterialPageRoute(builder: (context) => MercadoPagoScreen(initialURl: data['init_point'])));

      if (isDone) {
        ShowToastDialog.showToast("Payment Successful!!");
        completeOrder();
      } else {
        ShowToastDialog.showToast("Payment UnSuccessful!!");
      }
    } else {
      print('Error creating preference: ${response.body}');
      return null;
    }
  }

  flutterWaveInitiatePayment({required BuildContext context, required String amount}) async {
    final url = Uri.parse('https://api.flutterwave.com/v3/payments');
    final headers = {
      'Authorization': 'Bearer ${paymentModel.value.flutterWave!.secretKey.toString().trim()}',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "tx_ref": _ref,
      "amount": amount,
      "currency": "NGN",
      "redirect_url": "${Constant.globalUrl}payment/success",
      "payment_options": "ussd, card, barter, payattitude",
      "customerparkapp": {
        "email": userModel.value.email.toString(),
        "phonenumber": userModel.value.phoneNumber.toString(), // Add a real phone number
        "name": userModel.value.fullName.toString(), // Add a real customerparkapp name
      },
      "customizations": {
        "title": "Payment for Services",
        "description": "Payment for XYZ services",
      }
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final bool isDone = await Navigator.push(context, MaterialPageRoute(builder: (context) => MercadoPagoScreen(initialURl: data['data']['link'])));

      if (isDone) {
        ShowToastDialog.showToast("Payment Successful!!");
        completeOrder();
      } else {
        ShowToastDialog.showToast("Payment UnSuccessful!!");
      }
    } else {
      print('Payment initialization failed: ${response.body}');
      return null;
    }
  }

  ///PayStack Payment Method
  payStackPayment(String totalAmount) async {
    await PayStackURLGen.payStackURLGen(
            amount: (double.parse(totalAmount) * 100).toString(), currency: "NGN", secretKey: paymentModel.value.payStack!.secretKey.toString(), userModel: userModel.value)
        .then((value) async {
      if (value != null) {
        PayStackUrlModel payStackModel = value;
        Get.to(PayStackScreen(
          secretKey: paymentModel.value.payStack!.secretKey.toString(),
          callBackUrl: paymentModel.value.payStack!.callbackURL.toString(),
          initialURl: payStackModel.data.authorizationUrl,
          amount: totalAmount,
          reference: payStackModel.data.reference,
        ))!
            .then((value) {
          if (value) {
            ShowToastDialog.showToast("Payment Successful!!");
            completeOrder();
          } else {
            ShowToastDialog.showToast("Payment UnSuccessful!!");
          }
        });
      } else {
        ShowToastDialog.showToast("Something went wrong, please contact admin.");
      }
    });
  }

  String? _ref;

  setRef() {
    maths.Random numRef = maths.Random();
    int year = DateTime.now().year;
    int refNumber = numRef.nextInt(20000);
    if (Platform.isAndroid) {
      _ref = "AndroidRef$year$refNumber";
    } else if (Platform.isIOS) {
      _ref = "IOSRef$year$refNumber";
    }
  }

  // payFast
  payFastPayment({required BuildContext context, required String amount}) {
    PayStackURLGen.getPayHTML(payFastSettingData: paymentModel.value.payfast!, amount: amount.toString(), userModel: userModel.value).then((String? value) async {
      bool isDone = await Get.to(PayFastScreen(htmlData: value!, payFastSettingData: paymentModel.value.payfast!));
      if (isDone) {
        ShowToastDialog.showToast("Payment successfully");
        completeOrder();
      } else {
        ShowToastDialog.showToast("Payment Failed");
      }
    });
  }

  ///Paytm payment function
  // getPaytmCheckSum(context, {required double amount}) async {
  //   final String orderId = DateTime.now().millisecondsSinceEpoch.toString();
  //   String getChecksum = "${Constant.globalUrl}payments/getpaytmchecksum";

  //   final response = await http.post(
  //       Uri.parse(
  //         getChecksum,
  //       ),
  //       headers: {},
  //       body: {
  //         "mid": paymentModel.value.paytm!.paytmMID.toString(),
  //         "order_id": orderId,
  //         "key_secret": paymentModel.value.paytm!.merchantKey.toString(),
  //       });

  //   final data = jsonDecode(response.body);
  //   log(paymentModel.value.paytm!.paytmMID.toString());

  //   await verifyCheckSum(checkSum: data["code"], amount: amount, orderId: orderId).then((value) {
  //     initiatePayment(amount: amount, orderId: orderId).then((value) {
  //       String callback = "";
  //       if (paymentModel.value.paytm!.isSandbox == true) {
  //         callback = "${callback}https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
  //       } else {
  //         callback = "${callback}https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
  //       }

  //       GetPaymentTxtTokenModel result = value;
  //       startTransaction(context, txnTokenBy: result.body.txnToken, orderId: orderId, amount: amount, callBackURL: callback, isStaging: paymentModel.value.paytm!.isSandbox);
  //     });
  //   });
  // }

  // Future<void> startTransaction(context, {required String txnTokenBy, required orderId, required double amount, required callBackURL, required isStaging}) async {
  //   try {
  //     var response = AllInOneSdk.startTransaction(
  //       paymentModel.value.paytm!.paytmMID.toString(),
  //       orderId,
  //       amount.toString(),
  //       txnTokenBy,
  //       callBackURL,
  //       isStaging,
  //       true,
  //       true,
  //     );

  //     response.then((value) {
  //       if (value!["RESPMSG"] == "Txn Success") {
  //         log("txt done!!");
  //         ShowToastDialog.showToast("Payment Successful!!");
  //         completeOrder();
  //       }
  //     }).catchError((onError) {
  //       if (onError is PlatformException) {
  //         Get.back();

  //         ShowToastDialog.showToast(onError.message.toString());
  //       } else {
  //         log("======>>2");
  //         Get.back();
  //         ShowToastDialog.showToast(onError.message.toString());
  //       }
  //     });
  //   } catch (err) {
  //     Get.back();
  //     ShowToastDialog.showToast(err.toString());
  //   }
  // }

  // Future verifyCheckSum({required String checkSum, required double amount, required orderId}) async {
  //   String getChecksum = "${Constant.globalUrl}payments/validatechecksum";
  //   final response = await http.post(
  //       Uri.parse(
  //         getChecksum,
  //       ),
  //       headers: {},
  //       body: {
  //         "mid": paymentModel.value.paytm!.paytmMID.toString(),
  //         "order_id": orderId,
  //         "key_secret": paymentModel.value.paytm!.merchantKey.toString(),
  //         "checksum_value": checkSum,
  //       });
  //   final data = jsonDecode(response.body);
  //   return data['status'];
  // }

  Future<GetPaymentTxtTokenModel> initiatePayment({required double amount, required orderId}) async {
    String initiateURL = "${Constant.globalUrl}payments/initiatepaytmpayment";
    String callback = "";
    if (paymentModel.value.paytm!.isSandbox == true) {
      callback = "${callback}https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
    } else {
      callback = "${callback}https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
    }
    final response = await http.post(Uri.parse(initiateURL), headers: {}, body: {
      "mid": paymentModel.value.paytm!.paytmMID,
      "order_id": orderId,
      "key_secret": paymentModel.value.paytm!.merchantKey,
      "amount": amount.toString(),
      "currency": "INR",
      "callback_url": callback,
      "custId": FireStoreUtils.getCurrentUid(),
      "issandbox": paymentModel.value.paytm!.isSandbox == true ? "1" : "2",
    });
    log(response.body);
    final data = jsonDecode(response.body);
    if (data["body"]["txnToken"] == null || data["body"]["txnToken"].toString().isEmpty) {
      Get.back();
      ShowToastDialog.showToast("something went wrong, please contact admin.");
    }
    return GetPaymentTxtTokenModel.fromJson(data);
  }

  ///RazorPay payment function
  final Razorpay razorPay = Razorpay();

  void openCheckout({required amount, required orderId}) async {
    var options = {
      'key': paymentModel.value.razorpay!.razorpayKey,
      'amount': amount * 100,
      'name': 'GoRide',
      'order_id': orderId,
      "currency": "INR",
      'description': 'wallet Topup',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {
        'contact': userModel.value.phoneNumber,
        'email': userModel.value.email,
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      razorPay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void handlePaymentSuccess(PaymentSuccessResponse response) {
    ShowToastDialog.showToast("Payment Successful!!");
    completeOrder();
  }

  void handleExternalWaller(ExternalWalletResponse response) {
    ShowToastDialog.showToast("Payment Processing!! via");
  }

  void handlePaymentError(PaymentFailureResponse response) {
    RazorPayFailedModel lom = RazorPayFailedModel.fromJson(jsonDecode(response.message!.toString()));
    ShowToastDialog.showToast("Payment Failed!!");
  }

//XenditPayment
  xenditPayment(context, amount) async {
    await createXenditInvoice(amount: amount).then((model) {
      if (model.id != null) {
        Get.to(() => XenditScreen(
                  initialURl: model.invoiceUrl ?? '',
                  transId: model.id ?? '',
                  apiKey: paymentModel.value.xendit!.apiKey!.toString() ?? "",
                ))!
            .then((value) {
          if (value == true) {
            ShowToastDialog.showToast("Payment Successful!!");
            completeOrder();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Payment Unsuccessful!! \n"),
              backgroundColor: Colors.red,
            ));
          }
        });
      }
    });
  }

  Future<XenditModel> createXenditInvoice({required var amount}) async {
    const url = 'https://api.xendit.co/v2/invoices';
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': generateBasicAuthHeader(paymentModel.value.xendit!.apiKey!.toString()),
      // 'Cookie': '__cf_bm=yERkrx3xDITyFGiou0bbKY1bi7xEwovHNwxV1vCNbVc-1724155511-1.0.1.1-jekyYQmPCwY6vIJ524K0V6_CEw6O.dAwOmQnHtwmaXO_MfTrdnmZMka0KZvjukQgXu5B.K_6FJm47SGOPeWviQ',
    };

    final body = jsonEncode({
      'external_id': const Uuid().v1(),
      'amount': amount,
      'payer_email': 'customerparkapp@domain.com',
      'description': 'Test - VA Successful invoice payment',
      'currency': 'IDR', //IDR, PHP, THB, VND, MYR
    });

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        XenditModel model = XenditModel.fromJson(jsonDecode(response.body));
        return model;
      } else {
        return XenditModel();
      }
    } catch (e) {
      return XenditModel();
    }
  }

  String generateBasicAuthHeader(String apiKey) {
    String credentials = '$apiKey:';
    String base64Encoded = base64Encode(utf8.encode(credentials));
    return 'Basic $base64Encoded';
  }

//Orangepay payment
  static String accessToken = '';
  static String payToken = '';
  static String orderId = '';
  static String amount = '';

  orangeMakePayment({required String amount, required BuildContext context}) async {
    reset();
    var id = const Uuid().v4();
    var paymentURL = await fetchToken(context: context, orderId: id, amount: amount, currency: 'USD');

    if (paymentURL.toString() != '') {
      Get.to(() => OrangeMoneyScreen(
                initialURl: paymentURL,
                accessToken: accessToken,
                amount: amount,
                orangePay: paymentModel.value.orangePay!,
                orderId: orderId,
                payToken: payToken,
              ))!
          .then((value) {
        if (value == true) {
          ShowToastDialog.showToast("Payment Successful!!");
          completeOrder();
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Payment Unsuccessful!! \n"),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future fetchToken({required String orderId, required String currency, required BuildContext context, required String amount}) async {
    String apiUrl = 'https://api.orange.com/oauth/v3/token';
    Map<String, String> requestBody = {
      'grant_type': 'client_credentials',
    };

    var response = await http.post(Uri.parse(apiUrl),
        headers: <String, String>{
          'Authorization': "Basic ${paymentModel.value.orangePay!.auth!}",
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: requestBody);

    // Handle the response

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);

      accessToken = responseData['access_token'];
      // ignore: use_build_context_synchronously
      return await webpayment(context: context, amountData: amount, currency: currency, orderIdData: orderId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Color(0xff635bff),
          content: Text(
            "Something went wrong, please contact admin.",
            style: TextStyle(fontSize: 17),
          )));

      return '';
    }
  }

  Future webpayment({required String orderIdData, required BuildContext context, required String currency, required String amountData}) async {
    orderId = orderIdData;
    amount = amountData;
    String apiUrl = paymentModel.value.orangePay!.isSandbox! == true
        ? 'https://api.orange.com/orange-money-webpay/dev/v1/webpayment'
        : 'https://api.orange.com/orange-money-webpay/cm/v1/webpayment';
    Map<String, String> requestBody = {
      "merchant_key": paymentModel.value.orangePay!.merchantKey ?? '',
      "currency": paymentModel.value.orangePay!.isSandbox == true ? "OUV" : currency,
      "order_id": orderId,
      "amount": amount,
      "reference": 'Y-Note Test',
      "lang": "en",
      "return_url": paymentModel.value.orangePay!.returnUrl!.toString(),
      "cancel_url": paymentModel.value.orangePay!.cancelUrl!.toString(),
      "notif_url": paymentModel.value.orangePay!.notifyUrl!.toString(),
    };

    var response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{'Authorization': 'Bearer $accessToken', 'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: json.encode(requestBody),
    );

    // Handle the response
    if (response.statusCode == 201) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData['message'] == 'OK') {
        payToken = responseData['pay_token'];
        return responseData['payment_url'];
      } else {
        return '';
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Color(0xff635bff),
          content: Text(
            "Something went wrong, please contact admin.",
            style: TextStyle(fontSize: 17),
          )));
      return '';
    }
  }

  static reset() {
    accessToken = '';
    payToken = '';
    orderId = '';
    amount = '';
  }

//Midtrans payment
  midtransMakePayment({required String amount, required BuildContext context}) async {
    await createPaymentLink(amount: amount).then((url) {
      if (url != '') {
        Get.to(() => MidtransScreen(
                  initialURl: url,
                ))!
            .then((value) {
          if (value == true) {
            ShowToastDialog.showToast("Payment Successful!!");
            completeOrder();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Payment Unsuccessful!! \n"),
              backgroundColor: Colors.red,
            ));
          }
        });
      }
    });
  }

  Future<String> createPaymentLink({required var amount}) async {
    var ordersId = const Uuid().v1();
    final url = Uri.parse(paymentModel.value.midtrans!.isSandbox! ? 'https://api.sandbox.midtrans.com/v1/payment-links' : 'https://api.midtrans.com/v1/payment-links');

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': generateBasicAuthHeader(paymentModel.value.midtrans!.serverKey!),
      },
      body: jsonEncode({
        'transaction_details': {
          'order_id': ordersId,
          'gross_amount': double.parse(amount.toString()).toInt(),
        },
        'usage_limit': 2,
        "callbacks": {"finish": "https://www.google.com?merchant_order_id=$ordersId"},
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      print('Payment link created: ${responseData['payment_url']}');
      return responseData['payment_url'];
    } else {
      return '';
    }
  }
}
