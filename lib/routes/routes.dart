import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:hapusbackground/splash_screen.dart';
import 'package:hapusbackground/view/editor/editor_screen.dart';
import 'package:hapusbackground/view/home/home_screen.dart';

class Routes {
  static BuildContext? context;

  static getPages() {
    return [
      GetPage(name: SPLASH_SCREEN, page: () => SplashScreen()),
      GetPage(name: DASHBOARD, page: () => HomeScreen()),
      GetPage(name: EDITOR, page: () => EditorScreen()),
    ];
  }

  // static navigateTo(page) {
  //   return GoRouter.of(context!).go(page);
  // }

  // static replacePage(page) {
  //   return GoRouter.of(context!).pushReplacement(page);
  // }

  static const HOME = "/";
  static const SPLASH_SCREEN = "/splashscreen";
  static const DASHBOARD = "/dashboard";
  static const EDITOR = "/editor";
}
