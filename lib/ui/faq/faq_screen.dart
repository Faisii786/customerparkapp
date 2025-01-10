import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:customerparkapp/constant/constant.dart';
import 'package:customerparkapp/model/faq_model.dart';
import 'package:customerparkapp/themes/app_them_data.dart';
import 'package:customerparkapp/themes/common_ui.dart';
import 'package:customerparkapp/utils/dark_theme_provider.dart';
import 'package:customerparkapp/utils/fire_store_utils.dart';
import 'package:provider/provider.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      appBar: UiInterface().customAppBar(
        context,
        themeChange,
        "FAQ's".tr,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("FAQs".tr, style: TextStyle(fontSize: 24, fontFamily: AppThemData.semiBold, color: themeChange.getThem() ? AppThemData.grey02 : AppThemData.grey10)),
              const SizedBox(
                height: 5,
              ),
              Text("Read FAQs solution".tr,
                  style: TextStyle(fontSize: 14, fontFamily: AppThemData.regular, color: themeChange.getThem() ? AppThemData.grey07 : AppThemData.grey07)),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: FutureBuilder<List<FaqModel>?>(
                    future: FireStoreUtils.getFaq(),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return Constant.loader();
                        case ConnectionState.done:
                          if (snapshot.hasError) {
                            return Text(snapshot.error.toString());
                          } else {
                            List<FaqModel> faqList = snapshot.data!;
                            return ListView.builder(
                              itemCount: faqList.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                FaqModel faqModel = faqList[index];
                                return InkWell(
                                  onTap: () {
                                    faqModel.isShow = true;
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 5),
                                    child: ExpansionTile(
                                      title: Text(faqModel.title.toString()),
                                      children: <Widget>[
                                        ListTile(
                                          title: Text(faqModel.description.toString()),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        default:
                          return Text('Error'.tr);
                      }
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
