// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'package:customerparkapp/constant/collection_name.dart';
// import 'package:customerparkapp/constant/constant.dart';
// import 'package:customerparkapp/constant/show_toast_dialog.dart';
// import 'package:customerparkapp/controller/chat_controller.dart';
// import 'package:customerparkapp/themes/app_them_data.dart';
// import 'package:customerparkapp/themes/responsive.dart';
// import 'package:customerparkapp/ui/chat/model/chat_model.dart';
// import 'package:customerparkapp/utils/dark_theme_provider.dart';
// import 'package:customerparkapp/utils/fire_store_utils.dart';
// import 'package:customerparkapp/utils/network_image_widget.dart';
// import 'package:customerparkapp/widgets/firebase_pagination/src/firestore_pagination.dart';
// import 'package:provider/provider.dart';
//
// class ChatScreen extends StatelessWidget {
//   const ChatScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final themeChange = Provider.of<DarkThemeProvider>(context);
//     return GetX<ChatController>(
//       init: ChatController(),
//       builder: (controller) {
//         return Scaffold(
//           appBar: AppBar(
//             elevation: 0,
//             backgroundColor: themeChange.getThem() ? AppThemData.grey10 : AppThemData.white,
//             leading: InkWell(
//                 onTap: () {
//                   Get.back();
//                 },
//                 child: Icon(Icons.arrow_back, color: themeChange.getThem() ? AppThemData.grey02 : AppThemData.grey09)),
//             titleSpacing: 0,
//             title: Row(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(60),
//                   child: NetworkImageWidget(
//                     imageUrl: controller.receiverUserModel.value.profilePic.toString(),
//                     height: Responsive.width(10, context),
//                     width: Responsive.width(10, context),
//                   ),
//                 ),
//                 const SizedBox(
//                   width: 10,
//                 ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       controller.receiverUserModel.value.fullName.toString(),
//                       style: TextStyle(color: themeChange.getThem() ? AppThemData.grey02 : AppThemData.grey09, fontFamily: AppThemData.semiBold, fontSize: 14),
//                     ),
//                     Text(
//                       controller.receiverUserModel.value.email.toString(),
//                       style: TextStyle(color: themeChange.getThem() ? AppThemData.grey02 : AppThemData.grey09, fontFamily: AppThemData.medium, fontSize: 12),
//                     )
//                   ],
//                 )
//               ],
//             ),
//           ),
//           body: controller.isLoading.value
//               ? Constant.loader()
//               : Column(
//                   children: [
//                     Expanded(
//                       child: FirestorePagination(
//                         scrollDirection: Axis.vertical,
//                         query: FireStoreUtils.fireStore
//                             .collection(CollectionName.chat)
//                             .doc(controller.senderUserModel.value.id)
//                             .collection(controller.receiverUserModel.value.id.toString())
//                             .orderBy("timestamp", descending: true),
//                         // itemBuilderType: PaginateBuilderType.listView,
//                         isLive: true,
//                         physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
//                         shrinkWrap: true,
//                         reverse: true,
//                         onEmpty: Constant.showEmptyView(message: "No conversion found".tr),
//                         itemBuilder: (context, documentSnapshots, index) {
//                           ChatModel chatModel = ChatModel.fromJson(documentSnapshots[index].data() as Map<String, dynamic>);
//                           return Container(
//                               padding: const EdgeInsets.only(left: 14, right: 14, top: 06, bottom: 06),
//                               child: chatBubbles(chatModel.senderId == controller.senderUserModel.value.id ? true : false, chatModel, themeChange));
//                         },
//                       ),
//                     ),
//                     Container(
//                       color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.grey11,
//                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                       child: Padding(
//                         padding: const EdgeInsets.only(bottom: 10),
//                         child: TextFormField(
//                           keyboardType: TextInputType.text,
//                           textCapitalization: TextCapitalization.sentences,
//                           controller: controller.messageTextEditorController.value,
//                           textAlign: TextAlign.start,
//                           maxLines: 1,
//                           textInputAction: TextInputAction.done,
//                           style: TextStyle(
//                               fontSize: 14, color: themeChange.getThem() ? AppThemData.grey02 : AppThemData.grey11, fontWeight: FontWeight.w500, fontFamily: AppThemData.medium),
//                           decoration: InputDecoration(
//                               errorStyle: const TextStyle(color: Colors.red),
//                               isDense: true,
//                               filled: true,
//                               enabled: true,
//                               contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
//                               disabledBorder: OutlineInputBorder(
//                                 borderRadius: const BorderRadius.all(Radius.circular(40)),
//                                 borderSide: BorderSide(color: themeChange.getThem() ? AppThemData.grey09 : AppThemData.grey09, width: 1),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: const BorderRadius.all(Radius.circular(40)),
//                                 borderSide: BorderSide(color: themeChange.getThem() ? AppThemData.primary06 : AppThemData.grey09, width: 1),
//                               ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: const BorderRadius.all(Radius.circular(40)),
//                                 borderSide: BorderSide(color: themeChange.getThem() ? AppThemData.grey09 : AppThemData.grey09, width: 1),
//                               ),
//                               errorBorder: OutlineInputBorder(
//                                 borderRadius: const BorderRadius.all(Radius.circular(40)),
//                                 borderSide: BorderSide(color: themeChange.getThem() ? AppThemData.grey09 : AppThemData.grey09, width: 1),
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: const BorderRadius.all(Radius.circular(40)),
//                                 borderSide: BorderSide(color: themeChange.getThem() ? AppThemData.grey09 : AppThemData.grey09, width: 1),
//                               ),
//                               suffixIcon: InkWell(
//                                 onTap: () {
//                                   if (controller.messageTextEditorController.value.text.isNotEmpty) {
//                                     controller.sendMessage();
//                                   } else {
//                                     ShowToastDialog.showToast("Please enter message".tr);
//                                   }
//                                 },
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: SvgPicture.asset("assets/icon/ic_send.svg"),
//                                 ),
//                               ),
//                               hintText: "Type Message".tr,
//                               hintStyle: TextStyle(
//                                   fontSize: 14,
//                                   color: themeChange.getThem() ? AppThemData.grey06 : AppThemData.grey07,
//                                   fontWeight: FontWeight.w500,
//                                   fontFamily: AppThemData.medium)),
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//         );
//       },
//     );
//   }
//
//   chatBubbles(bool isMe, ChatModel chatModel, themeChange) {
//     return isMe == false
//         ? Row(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(30),
//                       color: AppThemData.primary06,
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                       child: Text(
//                         chatModel.message.toString(),
//                         style: TextStyle(color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.grey10, fontFamily: AppThemData.regular, fontSize: 14),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 5,
//                   ),
//                   Text(
//                     Constant.timestampToTime(chatModel.timestamp!),
//                     style: TextStyle(color: themeChange.getThem() ? AppThemData.grey02 : AppThemData.grey10, fontFamily: AppThemData.regular, fontSize: 12),
//                   )
//                 ],
//               ),
//             ],
//           )
//         : Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Column(
//                 children: [
//                   Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(30),
//                       color: AppThemData.white,
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                       child: Text(
//                         chatModel.message.toString(),
//                         style: TextStyle(color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.grey10, fontFamily: AppThemData.regular, fontSize: 14),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 5,
//                   ),
//                   Text(
//                     Constant.timestampToTime(chatModel.timestamp!),
//                     style: TextStyle(color: themeChange.getThem() ? AppThemData.grey02 : AppThemData.grey10, fontFamily: AppThemData.regular, fontSize: 12),
//                   )
//                 ],
//               ),
//             ],
//           );
//   }
// }
