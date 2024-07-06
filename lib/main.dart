import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:weather_condition/Controllers/theme_controller.dart';
import 'package:weather_condition/Utils/custom_themes.dart';
import 'package:weather_condition/Views/HomeScreen.dart';

void main() async{
  // Initialise a get Storage for local storage
  await GetStorage.init();
  // use below line for configuring the dark & light mode in all screens
  Get.put(ThemeController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find();

    // wrap with obx for the state management
    return Obx(() {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: CustomThemes.lightTheme,
        darkTheme: CustomThemes.darkTheme,
        themeMode: themeController.isDark.value ? ThemeMode.dark : ThemeMode.light,
        home: HomeScreen(),
      );
    });
  }
}
