import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:customerparkapp/controller/osm_search_place_controller.dart';
import 'package:customerparkapp/themes/app_them_data.dart';
import 'package:customerparkapp/utils/dark_theme_provider.dart';
import 'package:provider/provider.dart';

class OsmSearchPlacesApi extends StatelessWidget {
  const OsmSearchPlacesApi({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: OsmSearchPlaceController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: AppThemData.grey01,
              leading: InkWell(
                onTap: () {
                  Get.back();
                },
                child: Icon(
                  Icons.arrow_back,
                  color: themeChange.getThem() ? AppThemData.grey08 : AppThemData.grey08,
                ),
              ),
              title: Text(
                'Search places',
                style: TextStyle(
                  color: themeChange.getThem() ? AppThemData.grey08 : AppThemData.grey08,
                  fontSize: 16,
                ),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                children: [
                  TextFormField(
                      validator: (value) => value != null && value.isNotEmpty ? null : 'Required',
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.sentences,
                      controller: controller.searchTxtController.value,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontSize: 14, color: themeChange.getThem() ? AppThemData.grey02 : AppThemData.grey08, fontWeight: FontWeight.w500, fontFamily: AppThemData.medium),
                      decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: themeChange.getThem() ? AppThemData.grey10 : AppThemData.grey03,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          prefixIcon: const Icon(Icons.map),
                          disabledBorder: UnderlineInputBorder(
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                            borderSide: BorderSide(color: themeChange.getThem() ? AppThemData.grey09 : AppThemData.grey04, width: 1),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                            borderSide: BorderSide(color: themeChange.getThem() ? AppThemData.primary06 : AppThemData.primary06, width: 1),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                            borderSide: BorderSide(color: themeChange.getThem() ? AppThemData.grey09 : AppThemData.grey04, width: 1),
                          ),
                          errorBorder: UnderlineInputBorder(
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                            borderSide: BorderSide(color: themeChange.getThem() ? AppThemData.grey09 : AppThemData.grey04, width: 1),
                          ),
                          border: UnderlineInputBorder(
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                            borderSide: BorderSide(color: themeChange.getThem() ? AppThemData.grey09 : AppThemData.grey04, width: 1),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.cancel),
                            onPressed: () {
                              controller.searchTxtController.value.clear();
                            },
                          ),
                          hintText: "Search your location here".tr)),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      primary: true,
                      itemCount: controller.suggestionsList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            controller.suggestionsList[index].address.toString(),
                            style: TextStyle(color: themeChange.getThem() ? AppThemData.grey08 : AppThemData.grey08, fontWeight: FontWeight.w500),
                          ),
                          onTap: () {
                            Get.back(result: controller.suggestionsList[index]);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
