import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hapusbackground/constant/api_constant.dart';
import 'package:hapusbackground/constant/app_color.dart';
import 'package:hapusbackground/model/language_model.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeController {
  uploadImage(File file, onSendProgress, callback, onError) async {
    String fileName = file.path.split('/').last;

    FormData data = FormData.fromMap({
      "image": await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
    });

    Dio dio = new Dio();

    dio.post(
      "${baseUrl}/api/v1/user/remove",
      data: data,
      onSendProgress: (int sent, int total) {
        var progress = ((sent / total) * 100).toStringAsFixed(0);
        onSendProgress(progress);
      },
    ).then((response) {
      Map responseBody = response.data;
      return callback(responseBody);
    }).catchError((error) => onError(error));
  }

  loadTestDevices(response, onError) async {
    var dio = Dio();
    var request = await dio
        .get("${baseUrl}/api/v1/user/list/devices",
            options: Options(headers: {
              "Content-Type": "application/json",
            }))
        .then((value) {
      Map responseBody = value.data;
      return response(responseBody);
    }).catchError((onError) {});
  }

  initTestDevice() {
    var devices = <String>[];
    loadTestDevices((response) {
      if (response["status"]) {
        for (var device in response["data"]) {
          devices.add(device["device_id"]);
        }
        return MobileAds.instance.updateRequestConfiguration(
            RequestConfiguration(testDeviceIds: devices));
      }
    }, (onError) {
      Logger().d('load device error $onError');
    });
  }

  showToast(message) {
    return Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: primaryColor,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  showErrorDialog(context, message) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: 202,
              child: Column(
                children: [
                  Image(
                    image: AssetImage('assets/images/cancel.png'),
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

  showRatingDialog(context, callback) {
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
                  const Image(
                    image: AssetImage('assets/images/rate.png'),
                    height: 50,
                    width: 50,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Text(
                      LanguageModel.data["review_app"],
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: iconColor,
                          textStyle: const TextStyle(
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

  showReportDialog(context, message) {
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

  openExternalBrowser(context, url, launchMode) async {
    var urllaunchable =
        await canLaunchUrl(url); //canLaunch is from url_launcher package
    if (urllaunchable) {
      await launchUrl(url,
          mode: launchMode
              ? LaunchMode.externalApplication
              : LaunchMode.platformDefault);
    } else {
      return showErrorDialog(context, "Error cant open this menu!");
    }
  }

  Future<bool> requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }

  getCountUserReopenApp(callback) async {
    var prefs = await SharedPreferences.getInstance();
    callback(prefs, prefs.getInt('opened'));
  }

  increaseUserReopenApp() async {
    var prefs = await SharedPreferences.getInstance();
    var count = prefs.getInt('opened')! + 1;
    return prefs.setInt('opened', count);
  }

  resetUserReopenApp() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.setInt('opened', 0);
  }
}
