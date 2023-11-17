import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hapusbackground/constant/admob_code.dart';
import 'package:hapusbackground/constant/api_constant.dart';
import 'package:hapusbackground/constant/app_color.dart';
import 'package:hapusbackground/model/language_model.dart';
import 'package:hapusbackground/view/home/controller/home_controller.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:logger/logger.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';

class EditorController {
  var screenshootController = ScreenshotController();
  var homeController = HomeController();
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;
  Color pickerColor = Color(0xff443a49);
  Color currentColor = Color(0xff443a49);
  var changeColorCallback;

  getFilePath(uniqueFileName) async {
    if (await homeController.requestPermission(Permission.storage)) {
      return '/storage/emulated/0/DCIM/HapusBackground/$uniqueFileName';
    }
  }

  saveWidgetToImage(widget, callback) async {
    screenshootController.captureFromWidget(widget).then((capturedImage) async {
      var currentTime = DateTime.now().millisecondsSinceEpoch;
      var fileName = '${currentTime}_HapusBackground.png';
      final filepath = await getFilePath(fileName);
      File imgFile = File(filepath);
      imgFile.writeAsBytes(capturedImage).then((value) async {
        MediaScanner.loadMedia(path: await getFilePath(fileName));
        callback({"status": true, "message": 'success save image'});
      });

      // callback(result);
    });
  }

  loadListBackgroundImage(response, onError) async {
    var dio = Dio();
    var request = await dio
        .get("${baseUrl}/api/v1/user/list/background",
            options: Options(headers: {
              "Content-Type": "application/json",
            }))
        .then((value) {
      Map responseBody = value.data;
      return response(responseBody);
    }).catchError((onError) {});
  }

  showWarningDialog(context, message) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: 160,
              child: Column(
                children: [
                  Image(
                    image: AssetImage('assets/images/warning.png'),
                    height: 50,
                    width: 50,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: iconColor,
                          textStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: "RobotoCondenseRegular")),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Okay'))
                ],
              ),
            ),
            // actions: [
            //   TextButton(
            //     child: Text("Close"),
            //     onPressed: () {
            //       Navigator.of(context).pop();
            //     },
            //   )
            // ],
          );
        });
  }

  showColorPicker(context, onColorChanged, onColorSelected) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: pickerColor,
                onColorChanged: onColorChanged,
              ),
            ),
            actions: [
              ElevatedButton(
                child: Text(LanguageModel.data["select_color"]),
                style: ElevatedButton.styleFrom(
                    backgroundColor: iconColor,
                    textStyle:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                onPressed: () {
                  onColorSelected();
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  showDownloadDialog(context, callback) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: 150,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Image(
                      image: AssetImage('assets/images/cloud-computing.png'),
                      height: 50,
                      width: 50,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Text(
                      "${LanguageModel.data["saving_image_completed"]}",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: iconColor,
                          textStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: "RobotoCondenseRegular")),
                      onPressed: () {
                        Navigator.of(context).pop();
                        callback();
                      },
                      child: Text('Okay'))
                ],
              ),
            ),
            // actions: [
            //   TextButton(
            //     child: Text("Close"),
            //     onPressed: () {
            //       Navigator.of(context).pop();
            //     },
            //   )
            // ],
          );
        });
  }

  showLoadingMessage(context, message, callback) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          callback(context);
          return AlertDialog(
            content: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              constraints: BoxConstraints(maxHeight: 70),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: CircularProgressIndicator(
                      color: primaryColor,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // ElevatedButton(
                  //     style: ElevatedButton.styleFrom(
                  //         backgroundColor: iconColor,
                  //         textStyle: TextStyle(
                  //             fontSize: 14,
                  //             fontWeight: FontWeight.bold,
                  //             fontFamily: "RobotoCondenseRegular")),
                  //     onPressed: () {
                  //       Navigator.of(context).pop();
                  //     },
                  //     child: Text('Okay'))
                ],
              ),
            ),
            // actions: [
            //   TextButton(
            //     child: Text("Close"),
            //     onPressed: () {
            //       Navigator.of(context).pop();
            //     },
            //   )
            // ],
          );
        });
  }

  loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialCode,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              loadInterstitialAd();
            },
          );

          _isInterstitialAdReady = true;
        },
        onAdFailedToLoad: (err) {
          print('Failed to load an interstitial ad: ${err.message}');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  void showInterstitial() async {
    _interstitialAd!.show();
  }
}
