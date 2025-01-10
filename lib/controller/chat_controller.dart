// import 'dart:async';
// import 'dart:developer';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:customerparkapp/constant/collection_name.dart';
// import 'package:customerparkapp/constant/constant.dart';
// import 'package:customerparkapp/constant/send_notification.dart';
// import 'package:customerparkapp/model/user_model.dart';
// import 'package:customerparkapp/ui/chat/model/chat_model.dart';
// import 'package:customerparkapp/ui/chat/model/inbox_model.dart';
// import 'package:customerparkapp/utils/fire_store_utils.dart';
//
// class ChatController extends GetxController {
//   final messageTextEditorController = TextEditingController().obs;
//
//   @override
//   void onInit() {
//     // TODO: implement onInit
//     getArgument();
//     super.onInit();
//   }
//
//   late StreamSubscription<QuerySnapshot> chatListner;
//
//   changeStatus() {
//     chatListner = FireStoreUtils.fireStore
//         .collection(CollectionName.chat)
//         .doc(senderUserModel.value.id.toString())
//         .collection(receiverUserModel.value.id.toString())
//         .where("seen", isEqualTo: false)
//         .snapshots()
//         .listen((documentSnapshot) {
//       for (int i = 0; i < documentSnapshot.docs.length; i++) {
//         log("----->${documentSnapshot.docs[i]['receiverId']}");
//         log("----->${senderUserModel.value.id.toString()}");
//         if (documentSnapshot.docs[i]['receiverId'] == senderUserModel.value.id.toString()) {
//           FireStoreUtils.fireStore
//               .collection(CollectionName.chat)
//               .doc(documentSnapshot.docs[i]['senderId'])
//               .collection(documentSnapshot.docs[i]['receiverId'])
//               .doc(documentSnapshot.docs[i]['chatID'])
//               .update({'seen': true}).catchError((error) {
//             log("Failed : $error");
//           });
//
//           FireStoreUtils.fireStore
//               .collection(CollectionName.chat)
//               .doc(documentSnapshot.docs[i]['receiverId'])
//               .collection(documentSnapshot.docs[i]['senderId'])
//               .doc(documentSnapshot.docs[i]['chatID'])
//               .update({'seen': true}).catchError((error) {
//             log("Failed : $error");
//           });
//
//           FireStoreUtils.fireStore
//               .collection(CollectionName.chat)
//               .doc(documentSnapshot.docs[i]['senderId'])
//               .collection("inbox")
//               .doc(documentSnapshot.docs[i]['receiverId'])
//               .update({
//             'seen': true,
//           }).catchError((error) {
//             log("Failed to add: $error");
//           });
//
//           FireStoreUtils.fireStore
//               .collection(CollectionName.chat)
//               .doc(documentSnapshot.docs[i]['receiverId'])
//               .collection("inbox")
//               .doc(documentSnapshot.docs[i]['senderId'])
//               .update({
//             'seen': true,
//           }).catchError((error) {
//             log("Failed to add: $error");
//           });
//         }
//       }
//     });
//   }
//
//   RxBool isLoading = true.obs;
//   Rx<UserModel> receiverUserModel = UserModel().obs;
//   Rx<UserModel> senderUserModel = UserModel().obs;
//
//   getArgument() async {
//     dynamic argumentData = Get.arguments;
//     if (argumentData != null) {
//       receiverUserModel.value = argumentData['receiverModel'];
//     }
//     await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()).then((value) {
//       senderUserModel.value = value!;
//     });
//     changeStatus();
//     isLoading.value = false;
//   }
//
//   sendMessage() async {
//     InboxModel inboxModel = InboxModel(
//         archive: false,
//         lastMessage: messageTextEditorController.value.text.trim(),
//         mediaUrl: "",
//         receiverId: receiverUserModel.value.id.toString(),
//         seen: false,
//         senderId: senderUserModel.value.id.toString(),
//         timestamp: Timestamp.now(),
//         type: "text");
//
//     await FireStoreUtils.fireStore
//         .collection(CollectionName.chat)
//         .doc(senderUserModel.value.id.toString())
//         .collection("inbox")
//         .doc(receiverUserModel.value.id.toString())
//         .set(inboxModel.toJson());
//
//     await FireStoreUtils.fireStore
//         .collection(CollectionName.chat)
//         .doc(receiverUserModel.value.id.toString())
//         .collection("inbox")
//         .doc(senderUserModel.value.id.toString())
//         .set(inboxModel.toJson());
//
//     ChatModel chatModel = ChatModel(
//         type: "text",
//         timestamp: Timestamp.now(),
//         senderId: senderUserModel.value.id.toString(),
//         seen: false,
//         receiverId: receiverUserModel.value.id.toString(),
//         mediaUrl: "",
//         chatID: Constant.getUuid(),
//         message: messageTextEditorController.value.text.trim());
//
//     await FireStoreUtils.fireStore
//         .collection(CollectionName.chat)
//         .doc(senderUserModel.value.id.toString())
//         .collection(receiverUserModel.value.id.toString())
//         .doc(chatModel.chatID)
//         .set(chatModel.toJson());
//     await FireStoreUtils.fireStore
//         .collection(CollectionName.chat)
//         .doc(receiverUserModel.value.id.toString())
//         .collection(senderUserModel.value.id.toString())
//         .doc(chatModel.chatID)
//         .set(chatModel.toJson());
//
//     Map<String, dynamic> playLoad = <String, dynamic>{
//       "type": "chat",
//       "senderId": senderUserModel.value.id.toString(),
//       "receiverId": receiverUserModel.value.id.toString(),
//     };
//
//     await SendNotification.sendOneNotification(
//         token: receiverUserModel.value.fcmToken.toString(), title: receiverUserModel.value.fullName.toString(), body: messageTextEditorController.value.text, payload: playLoad);
//     messageTextEditorController.value.clear();
//   }
//
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     chatListner.cancel();
//     super.dispose();
//   }
// }
