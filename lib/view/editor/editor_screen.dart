import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:hapusbackground/constant/api_constant.dart';
import 'package:hapusbackground/constant/app_color.dart';
import 'package:hapusbackground/constant/padding_constant.dart';
import 'package:hapusbackground/constant/size_constant.dart';
import 'package:hapusbackground/model/language_model.dart';
import 'package:hapusbackground/routes/routes.dart';
import 'package:hapusbackground/view/editor/controller/editor_controller.dart';
import 'package:hapusbackground/view/home/controller/home_controller.dart';
import 'package:hapusbackground/view/home/partials/overlay_widget.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animated_rotation/animated_rotation.dart' as rotateHelper;

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late BuildContext mContext;
  int _selectedIndex = 1;
  var controller = EditorController();
  var angelRotation = 0;
  var selectedBackgroundImage;
  var selectedTransparentImage =
      "https://ranispace.com/storage/images/removed/default.png";
  var listBackground = <Widget>[];
  var arguments = Get.arguments;
  var transformPosition;
  var selectedColor = primaryColor;
  bool isReselectedBackground = false;
  bool isBackgroundColor = false;
  ImagePicker picker = ImagePicker();
  Color currentColor = Colors.amber;
  List<Color> currentColors = [Colors.yellow, Colors.green];
  List<Color> colorHistory = [];
  void changeColor(Color color) => setState(() => currentColor = color);
  void changeColors(List<Color> colors) =>
      setState(() => currentColors = colors);

  _onItemTapped(int index) {
    if (index == 0) {
      Get.offAndToNamed(Routes.DASHBOARD);
    }
    if (index == 2) {
      // homeController.showWarningDialog(mContext,
      //     "Community feature under maintenance!, please try again later.");
      // homeController.openExternalBrowser(
      //     mContext,
      //     Uri.parse("https://tawk.to/chat/63d7593dc2f1ac1e20304725/1go0j975a"),
      //     false);
      // homeController.showReportDialog(context, translation["report_problems"]);
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  getTransformedPosition(isSave) {
    if (isReselectedBackground) {
      return transformPosition;
    }
    if (isSave) {
      return transformPosition;
    }
    return null;
  }

  getEditedImage(isSave) {
    if (isBackgroundColor) {
      Logger().d('bg color');
      return RepaintBoundary(
        child: Container(
          constraints: const BoxConstraints(
            maxHeight: editedImageMaxHeight,
          ),
          width: MediaQuery.of(context).size.width,
          color: selectedColor,
          child: rotateHelper.AnimatedRotation(
            angle: angelRotation,
            duration: const Duration(milliseconds: 300),
            child: OverlayWidget(
                child: Image.network(selectedTransparentImage),
                transform: getTransformedPosition(isSave),
                onTransformUpdate: (value) {
                  transformPosition = value;
                }),
          ),
        ),
      );
    }
    // Background from local file
    if (selectedBackgroundImage != null &&
        selectedBackgroundImage
            .contains("/data/user/0/com.ranispace.hapusbackground")) {
      return RepaintBoundary(
        child: Container(
          width: MediaQuery.of(context).size.width,
          constraints: const BoxConstraints(
            maxHeight: editedImageMaxHeight,
          ),
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: Image.file(File(selectedBackgroundImage)).image,
                  fit: BoxFit.cover)),
          child: rotateHelper.AnimatedRotation(
            angle: angelRotation,
            duration: const Duration(milliseconds: 300),
            child: OverlayWidget(
                child: Image.network(selectedTransparentImage),
                transform: getTransformedPosition(isSave),
                onTransformUpdate: (value) {
                  transformPosition = value;
                }),
          ),
        ),
      );
    }
    // Reselected with transparent background
    if (selectedBackgroundImage != null &&
        selectedBackgroundImage == "assets/images/transparent.jpg") {
      Logger()
          .d('disini transaprent reselected transform: ${transformPosition}');

      if (isSave) {
        return RepaintBoundary(
          child: Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.transparent,
            child: rotateHelper.AnimatedRotation(
              angle: angelRotation,
              duration: const Duration(milliseconds: 300),
              child: OverlayWidget(
                  child: Image.network(selectedTransparentImage),
                  transform: getTransformedPosition(isSave),
                  onTransformUpdate: (value) {
                    transformPosition = value;
                  }),
            ),
          ),
        );
      }

      // not save
      return RepaintBoundary(
        child: Container(
          constraints: const BoxConstraints(
            maxHeight: editedImageMaxHeight,
          ),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(selectedBackgroundImage),
                  fit: BoxFit.cover)),
          child: rotateHelper.AnimatedRotation(
            angle: angelRotation,
            duration: const Duration(milliseconds: 300),
            child: OverlayWidget(
              child: Image.network(selectedTransparentImage),
              transform: getTransformedPosition(isSave),
              onTransformUpdate: (value) {
                transformPosition = value;
              },
            ),
          ),
        ),
      );
    }
    // background from server
    if (selectedBackgroundImage != null &&
        selectedBackgroundImage.contains("https://ranispace.com")) {
      Logger().d('bg server');
      return RepaintBoundary(
        child: Container(
          width: MediaQuery.of(context).size.width,
          constraints: const BoxConstraints(
            maxHeight: editedImageMaxHeight,
          ),
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: NetworkImage(selectedBackgroundImage),
                  fit: BoxFit.cover)),
          child: rotateHelper.AnimatedRotation(
            angle: angelRotation,
            duration: const Duration(milliseconds: 300),
            child: OverlayWidget(
                child: Image.network(selectedTransparentImage),
                transform: getTransformedPosition(isSave),
                onTransformUpdate: (value) {
                  transformPosition = value;
                }),
          ),
        ),
      );
    }

    // Default image and save
    if (isSave) {
      return RepaintBoundary(
        child: Container(
          constraints: const BoxConstraints(
            maxHeight: editedImageMaxHeight,
          ),
          width: MediaQuery.of(context).size.width,
          color: Colors.transparent,
          child: rotateHelper.AnimatedRotation(
            angle: angelRotation,
            duration: const Duration(milliseconds: 300),
            child: OverlayWidget(
                transform: getTransformedPosition(isSave),
                onTransformUpdate: (value) {
                  transformPosition = value;
                },
                child: Image.network(selectedTransparentImage)),
          ),
        ),
      );
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      constraints: const BoxConstraints(
        minHeight: editedImageMaxHeight,
        maxHeight: editedImageMaxHeight,
      ),
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/images/transparent.jpg'),
            fit: BoxFit.cover),
      ),
      child: rotateHelper.AnimatedRotation(
        angle: angelRotation,
        duration: const Duration(milliseconds: 300),
        child: OverlayWidget(
            transform: getTransformedPosition(isSave),
            onTransformUpdate: (value) {
              transformPosition = value;
            },
            child: Image.network(selectedTransparentImage)),
      ),
    );
  }

  getTopMenu() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
            padding: EdgeInsets.only(left: 0),
            onPressed: () {
              Get.offAndToNamed(Routes.DASHBOARD);
            },
            icon: const Icon(
              Icons.chevron_left,
              color: primaryColor,
            )),
        SizedBox(
          width: 70,
        ),
        // IconButton(
        //     onPressed: () {
        //       angelRotation = angelRotation - 90;
        //       setState(() {});
        //     },
        //     icon: Icon(
        //       Icons.rotate_left,
        //       color: primaryColor,
        //     )),

        IconButton(
            padding: EdgeInsets.only(left: 0),
            onPressed: () {
              angelRotation = angelRotation + 90;
              setState(() {});
            },
            icon: Icon(
              Icons.rotate_right,
              color: primaryColor,
            )),
        IconButton(
            padding: EdgeInsets.only(left: 0),
            onPressed: () {
              controller.showWarningDialog(
                  context, "Sorry, history feature under developement!");
            },
            icon: Icon(
              Icons.flip,
              color: primaryColor,
            )),
        const SizedBox(
          width: 80,
        ),
        IconButton(
            onPressed: () {
              var dialogContext;
              controller.showLoadingMessage(
                  context, LanguageModel.data["saving_image"], (ctx) {
                dialogContext = ctx;
              });
              controller.saveWidgetToImage(getEditedImage(true), (result) {
                if (result["status"]) {
                  Navigator.pop(dialogContext);
                  Logger().d(result);

                  controller.showDownloadDialog(context, () {
                    controller.showInterstitial();
                  });
                }
              });
            },
            icon: Icon(
              Icons.save_alt,
              color: primaryColor,
            )),
      ],
    );
  }

  getMenuBottom() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
            onPressed: () {
              controller.showWarningDialog(
                  context, "Sorry crop feature under developement!");
            },
            icon: Icon(
              Icons.crop,
              color: primaryColor,
            )),
        SizedBox(
          width: 20,
        ),
        IconButton(
            onPressed: () {
              controller.showWarningDialog(
                  context, "Sorry add text feature under developement!");
            },
            icon: Icon(
              Icons.text_fields,
              color: primaryColor,
            )),
        SizedBox(
          width: 20,
        ),
        IconButton(
            onPressed: () {
              controller.showWarningDialog(
                  context, "Sorry effect feature under developement!");
            },
            icon: Icon(
              Icons.filter,
              color: primaryColor,
            )),
        SizedBox(
          width: 20,
        ),
        IconButton(
            onPressed: () {
              controller.showWarningDialog(
                  context, "Sorry brigthness feature under developement!");
            },
            icon: Icon(
              Icons.brightness_1_outlined,
              color: primaryColor,
            )),
        SizedBox(
          width: 20,
        ),
        IconButton(
            onPressed: () {
              controller.showWarningDialog(
                  context, "Sorry beautify feature under developement!");
            },
            icon: Icon(
              Icons.auto_awesome,
              color: primaryColor,
            )),
      ],
    );
  }

  getListBackground() {
    return listBackground;
  }

  @override
  void initState() {
    if (arguments != null && arguments["image_url"] != null) {
      selectedTransparentImage = arguments["image_url"];
      setState(() {});
    }
    controller.loadListBackgroundImage((response) {
      if (response["status"]) {
        for (var item in response["data"]) {
          Logger().d('list: ${item["image_url"]}');

          var widget = Padding(
              padding: const EdgeInsets.only(top: 10, left: paddingEffect),
              child: InkWell(
                onTap: () {
                  selectedBackgroundImage = item["image_url"];
                  isBackgroundColor = false;
                  setState(() {});
                },
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(item["image_url"]),
                          fit: BoxFit.cover)),
                  width: effectSize,
                  height: effectSize,
                ),
              ));
          listBackground.add(widget);
        }
        controller.loadInterstitialAd();
        setState(() {});
      }
    }, (error) {
      Logger().d('load list background err: $error');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    mContext = context;
    return Scaffold(
      body: Container(
          // height: 200,
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(top: 50, bottom: 15),
            constraints: BoxConstraints(maxHeight: 120),
            child: getTopMenu(),
          ),
          getEditedImage(false),
          Padding(
            padding: EdgeInsets.only(left: 15, top: 15, bottom: 10),
            child: Text(
              LanguageModel.data["title_select_background"],
              style: TextStyle(
                  fontSize: 17,
                  fontFamily: 'UbuntuRegular',
                  color: Colors.black),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                    padding: EdgeInsets.only(
                      left: paddingEffect,
                      top: 10,
                    ),
                    child: InkWell(
                      onTap: () {
                        selectedBackgroundImage =
                            "assets/images/transparent.jpg";
                        selectedTransparentImage = selectedTransparentImage;
                        isBackgroundColor = false;
                        setState(() {});
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image:
                                    AssetImage('assets/images/transparent.jpg'),
                                fit: BoxFit.cover)),
                        width: effectSize,
                        height: effectSize,
                      ),
                    )),
                Padding(
                    padding:
                        const EdgeInsets.only(top: 10, left: paddingEffect),
                    child: InkWell(
                      onTap: () async {
                        // selectedBackgroundImage = image.path;
                        // showDialog(context: context, builder: () {

                        // })
                        controller.showColorPicker(context, (value) {
                          selectedColor = value;
                        }, () {
                          isBackgroundColor = true;
                          setState(() {});
                        });

                        setState(() {});
                        // originalImage = image;
                      },
                      child: Container(
                        color: selectedColor,
                        width: effectSize,
                        height: effectSize,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.color_lens,
                              color: Colors.white,
                            ),
                            Text(
                              LanguageModel.data["select_color"],
                              style: TextStyle(
                                  fontFamily: 'LatoRegular',
                                  color: Colors.white),
                            )
                          ],
                        ),
                      ),
                    )),
                if (listBackground.length > 0) ...getListBackground(),
                Padding(
                    padding: const EdgeInsets.only(
                        top: 10, left: paddingEffect, right: paddingEffect),
                    child: InkWell(
                      onTap: () async {
                        var image =
                            await picker.pickImage(source: ImageSource.gallery);
                        Logger().d(image!.path);
                        selectedBackgroundImage = image.path;
                        listBackground.add(Padding(
                            padding: const EdgeInsets.only(
                                top: 10, left: paddingEffect),
                            child: InkWell(
                              onTap: () {
                                selectedBackgroundImage = image.path;
                                isBackgroundColor = false;
                                setState(() {});
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image:
                                            Image.file(File(image.path)).image,
                                        fit: BoxFit.cover)),
                                width: effectSize,
                                height: effectSize,
                              ),
                            )));
                        selectedBackgroundImage = image.path;

                        setState(() {});
                        // originalImage = image;
                      },
                      child: Container(
                        color: Colors.grey.shade400,
                        width: effectSize,
                        height: effectSize,
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      ),
                    )),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 15, top: 50, bottom: 10),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                'Hapusin: by Ranispace\nMade with love ❤️ | ${appVersion}',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'UbuntuRegular',
                    color: Colors.black),
              ),
            ),
          ),
        ],
      )),
      bottomNavigationBar: Container(
        constraints: const BoxConstraints(maxHeight: 80),
        child: Column(
          children: [
            getMenuBottom(),
            // Padding(
            //   padding: EdgeInsets.only(bottom: 5),
            //   child: Center(
            //     child: ElevatedButton(
            //         style:
            //             ElevatedButton.styleFrom(backgroundColor: primaryColor),
            //         onPressed: () {},
            //         child: Text('Apply')),
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}

// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
// import 'package:logger/logger.dart';
// import 'package:screenshot/screenshot.dart';
// // import 'package:webview_flutter/webview_flutter.dart';
// // import 'package:image_gallery_saver/image_gallery_saver.dart';

// class EditorScreen extends StatefulWidget {
//   @override
//   _EditorScreenState createState() => _EditorScreenState();
// }

// class _EditorScreenState extends State<EditorScreen> {
//   //Create an instance of ScreenshotController
//   ScreenshotController screenshotController = ScreenshotController();

//   @override
//   void initState() {
//     // if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // Here we take the value from the EditorScreen object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text("Title"),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Screenshot(
//               controller: screenshotController,
//               child: Container(
//                   padding: const EdgeInsets.all(30.0),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.blueAccent, width: 5.0),
//                     color: Colors.amberAccent,
//                   ),
//                   child: Stack(
//                     children: [
//                       Image.network(
//                           "https://picsum.photos/seed/picsum/200/300"),
//                       Text("This widget will be captured as an image"),
//                     ],
//                   )),
//             ),
//             SizedBox(
//               height: 25,
//             ),
//             ElevatedButton(
//               child: Text(
//                 'Capture Above Widget',
//               ),
//               onPressed: () {
//                 screenshotController
//                     .capture(delay: Duration(milliseconds: 10))
//                     .then((capturedImage) async {
//                   ShowCapturedWidget(context, capturedImage!);
//                 }).catchError((onError) {
//                   print(onError);
//                 });
//               },
//             ),
//             ElevatedButton(
//               child: Text(
//                 'Capture An Invisible Widget',
//               ),
//               onPressed: () async {
//                 var container = Container(
//                     padding: const EdgeInsets.all(30.0),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.blueAccent, width: 5.0),
//                       color: Colors.redAccent,
//                     ),
//                     child: Stack(
//                       children: [
//                         Image.network(
//                             "https://picsum.photos/seed/picsum/200/300"),
//                         Text(
//                           "This is an invisible widget",
//                           style: Theme.of(context).textTheme.headline6,
//                         ),
//                       ],
//                     ));
//                 final bytes = screenshotController
//                     .captureFromWidget(Container(
//                   color: Colors.red,
//                   width: 300,
//                   height: 300,
//                 ))
//                     .then((capturedImage) async {
//                   // ShowCapturedWidget(context, capturedImage);
//                   var result = await ImageGallerySaver.saveImage(
//                       Uint8List.fromList(capturedImage),
//                       quality: 60,
//                       name: "hello.png");

//                   Logger().d(result);
//                 });
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<dynamic> ShowCapturedWidget(
//       BuildContext context, Uint8List capturedImage) {
//     return showDialog(
//       useSafeArea: false,
//       context: context,
//       builder: (context) => Scaffold(
//         appBar: AppBar(
//           title: Text("Captured widget screenshot"),
//         ),
//         body: Center(
//             child: capturedImage != null
//                 ? Image.memory(capturedImage)
//                 : Container()),
//       ),
//     );
//   }

//   // _saved(File image) async {
//   //   // final result = await ImageGallerySaver.save(image.readAsBytesSync());
//   //   print("File Saved to Gallery");
//   // }
// }
