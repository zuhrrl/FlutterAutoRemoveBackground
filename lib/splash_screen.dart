import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapusbackground/constant/api_constant.dart';
import 'package:hapusbackground/constant/app_color.dart';
import 'package:hapusbackground/helper/app_languages.dart';
import 'package:hapusbackground/model/language_model.dart';
import 'package:hapusbackground/routes/routes.dart';
import 'package:logger/logger.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  initLanguage() async {
    var lang = await AppLanguage.getTranslation();
    LanguageModel.data = lang;
  }

  @override
  void initState() {
    super.initState();
    initLanguage();

    Logger().d('splash');

    Timer(Duration(milliseconds: 2000), () {
      Get.offAndToNamed(Routes.DASHBOARD);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          width: MediaQuery.of(context).size.width,
          color: primaryColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Image(
                image: AssetImage('assets/images/logo.png'),
                height: 50,
                width: 50,
              ),
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  'Hapusin',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'UbuntuRegular',
                      color: Colors.white),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  "Made with love ❤️ | ${appVersion}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'RobotoCondensedRegular',
                      color: Colors.white),
                ),
              ),
            ],
          )),
    );
  }
}
