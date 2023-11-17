import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hapusbackground/constant/api_constant.dart';
import 'package:hapusbackground/constant/app_color.dart';
import 'package:hapusbackground/constant/app_constant.dart';
import 'package:hapusbackground/helper/app_languages.dart';
import 'package:hapusbackground/model/language_model.dart';
import 'package:hapusbackground/routes/routes.dart';
import 'package:hapusbackground/view/home/controller/home_controller.dart';
import 'package:hapusbackground/view/home/partials/overlay_widget.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late BuildContext mContext;
  int _selectedIndex = 0;
  double imageContainerHeight = 250;
  bool isUploading = false;
  bool isDownloaded = false;
  bool isUploaded = false;
  bool downloading = false;
  bool isDialogDownloadedShow = false;
  var translation;

  String progress = '0';
  String uploadingStatus = '';

  ImagePicker picker = ImagePicker();
  XFile? originalImage;
  HomeController homeController = HomeController();
  List<Widget> addedWidget = [];

  var removedImageBackground = "";
  var removedImageBackgroundFileName = "";

  _onItemTapped(int index) {
    if (index == 1) {
      // homeController.showReportDialog(context, translation["edit_maintenance"]);
      if (removedImageBackground.isNotEmpty) {
        return Get.toNamed(Routes.EDITOR,
            arguments: {"image_url": removedImageBackground});
      }
      return Get.toNamed(Routes.EDITOR);
    }
    if (index == 2) {
      // homeController.showWarningDialog(mContext,
      //     "Community feature under maintenance!, please try again later.");
      // homeController.openExternalBrowser(
      //     mContext,
      //     Uri.parse("https://tawk.to/chat/63d7593dc2f1ac1e20304725/1go0j975a"),
      //     false);

      homeController.showReportDialog(context, translation["report_problems"]);
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  getImageDecoration() {
    if (removedImageBackground.isNotEmpty) {
      return AssetImage('assets/images/transparent.jpg');
    }

    if (originalImage != null) {
      return Image.file(File(originalImage!.path)).image;
    }

    return AssetImage('assets/images/transparent.jpg');
  }

  showDownloadDialog(context) {
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
                      "${translation["saving_image_completed"]} ${progress}%",
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
                        isDialogDownloadedShow = false;
                        setState(() {});
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

  getImageContainer() {
    return Column(
      children: [
        Stack(
          children: [
            if (originalImage == null) ...[
              Container(
                height: 250,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/default_image.png'),
                        fit: BoxFit.cover)),
              ),
            ],
            if (originalImage != null) ...[
              SizedBox(
                width: double.infinity,
                height: 250,
                child: Shimmer.fromColors(
                  enabled: false,
                  baseColor: Colors.grey,
                  highlightColor: primaryColor,
                  child: Container(
                    color: Colors.grey,
                  ),
                ),
              ),
              // Container(
              //   height: 250,
              //   decoration: const BoxDecoration(
              //       image: DecorationImage(
              //           image: AssetImage('assets/images/transparent.jpg'),
              //           fit: BoxFit.cover)),
              // ),
              Container(
                height: 250,
                width: double.infinity,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/transparent.jpg'),
                        fit: BoxFit.cover)),
                child: OverlayWidget(
                    child: Image.file(File(originalImage!.path)),
                    transform: null,
                    onTransformUpdate: (value) {
                      // transformPosition = value;
                      // setState(() {});
                    }),
              ),
            ],
            // if (originalImage != null) ...[
            //   SizedBox(
            //     width: double.infinity,
            //     height: 250,
            //     child: Shimmer.fromColors(
            //       baseColor: Colors.grey,
            //       highlightColor: primaryColor,
            //       child: Container(
            //         color: Colors.grey,
            //       ),
            //     ),
            //   ),
            //   Container(
            //     height: 250,
            //     decoration: const BoxDecoration(
            //         image: DecorationImage(
            //             image: AssetImage('assets/images/transparent.jpg'),
            //             fit: BoxFit.cover)),
            //     child: OverlayWidget(
            //       child: Image(
            //         image: NetworkImage(removedImageBackground),
            //       ),
            //     ),
            //   )
            // ],
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: ElevatedButton.icon(
              icon: const Icon(Icons.image),
              onPressed: () async {
                await homeController.requestPermission(Permission.storage);

                var image = await picker.pickImage(source: ImageSource.gallery);
                originalImage = image;

                if (removedImageBackground.isNotEmpty) {
                  removedImageBackground = "";
                  removedImageBackgroundFileName = "";
                }
                setState(() {});
                try {
                  isUploading = true;

                  homeController.uploadImage(File(originalImage!.path),
                      (progress) {
                    if (progress == '100') {
                      isUploaded = true;
                      uploadingStatus = translation["processing_image"];
                    } else {
                      uploadingStatus =
                          "${translation["uploading_image"]} ${progress}%";
                    }

                    setState(() {});
                  }, (response) {
                    // homeController.showToast(responseServer["message"]);
                    // homeController.showToast(response);
                    // var response = json.decode(respo)

                    if (!response["status"]) {
                      var message = response["message"];
                      homeController.showErrorDialog(context,
                          "Aw error please try to upload image again or other image. message: ${message} code: ${response["code"]}");

                      originalImage = null;
                      isUploading = false;
                      setState(() {});
                      return;
                    }
                    removedImageBackground =
                        response["data"]["removed_background"];
                    removedImageBackgroundFileName =
                        response["data"]["file_name"];
                    Logger().d(response);
                    isUploading = false;

                    setState(() {});
                    Get.toNamed(Routes.EDITOR,
                        arguments: {"image_url": removedImageBackground});
                  }, (error) {});
                } catch (exception) {
                  isUploading = false;
                }

                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: iconColor,
                  textStyle:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              label: Text(removedImageBackground.isNotEmpty
                  ? translation["btn_select_other_image"]
                  : translation["btn_select_image"])),
        ),
      ],
    );
  }

  getDescriptionHome() {
    return ListView(
      shrinkWrap: true,
      children: [
        // getRemovedBackgroundContainer(),
        Visibility(
            visible: isUploading ? true : false,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Transform.scale(
                scale: 0.5,
                child: CircularProgressIndicator(
                  color: primaryColor,
                ),
              ),
              Text(
                uploadingStatus,
                style: TextStyle(color: textColor),
              ),
            ])),
        Visibility(
            visible: downloading ? true : false,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Transform.scale(
                scale: 0.5,
                child: CircularProgressIndicator(
                  color: primaryColor,
                ),
              ),
              Text(
                "${translation["saving_image"]} ${progress}%",
                style: TextStyle(color: textColor),
              ),
            ])),

        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            translation["app_title"],
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 24, fontFamily: 'UbuntuRegular', color: textColor),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(left: 15, top: 20, right: 15),
          child: Text(
            translation["home_text"],
            textAlign: TextAlign.left,
            style: TextStyle(
                fontSize: 14, fontFamily: 'UbuntuRegular', color: textColor),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 15, top: 50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(right: 10),
                child: InkWell(
                  onTap: () {
                    homeController.openExternalBrowser(
                        context,
                        Uri.parse(
                            "https://play.google.com/store/apps/details?id=${packageName}"),
                        true);
                  },
                  child: Text(
                    translation["rate_us"],
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: 17,
                        fontFamily: 'UbuntuRegular',
                        color: primaryColor),
                  ),
                ),
              ),
              // InkWell(
              //   onTap: () {
              //     homeController.showReportDialog(context,
              //         "Please report your problem at contact@ranispace.com");
              //   },
              //   child: const Text(
              //     'Report Problems',
              //     textAlign: TextAlign.left,
              //     style: TextStyle(
              //         fontSize: 14,
              //         fontFamily: 'UbuntuRegular',
              //         color: primaryColor),
              //   ),
              // ),
              Padding(
                padding: EdgeInsets.only(left: 5),
                child: InkWell(
                  onTap: () {
                    homeController.openExternalBrowser(context,
                        Uri.parse("${baseUrl}/terms-of-service"), true);
                  },
                  child: Text(
                    translation["terms_of_service"],
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: 17,
                        fontFamily: 'UbuntuRegular',
                        color: primaryColor),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 30,
        )
      ],
    );
  }

  getRemovedBackgroundContainer() {
    return InteractiveViewer(
      child: Stack(children: [
        Container(
          constraints: BoxConstraints(
            minHeight: imageContainerHeight,
            maxHeight: double.infinity,
          ),
          margin: const EdgeInsets.all(10),
          width: MediaQuery.of(context).size.width,
          // height: imageContainerHeight,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(7)),
              image: DecorationImage(
                  image: getImageDecoration(), fit: BoxFit.cover)),
          child: Visibility(
              visible: removedImageBackground.isNotEmpty ? true : false,
              child: Container(
                margin: const EdgeInsets.all(20),
                alignment: Alignment.center,
                width: MediaQuery.of(mContext).size.width,
                height: 220,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(7)),
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(removedImageBackground))),
              )),
        ),
        Visibility(
          visible: removedImageBackground.isNotEmpty ? true : false,
          child: Positioned(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(5),
                  child: CircleAvatar(
                    backgroundColor: iconColor,
                    radius: 18,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.download,
                        size: 18,
                      ),
                      color: Colors.white,
                      onPressed: () async {
                        progress = "0";
                        if (removedImageBackground.isNotEmpty) {
                          downloadFile(removedImageBackground,
                              removedImageBackgroundFileName);
                        }
                        setState(() {});
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: CircleAvatar(
                    backgroundColor: iconColor,
                    radius: 18,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.edit,
                        size: 18,
                      ),
                      color: Colors.white,
                      onPressed: () {
                        Logger().d(originalImage!.path);
                        setState(() {});
                        Get.toNamed(Routes.EDITOR,
                            arguments: {"image_url": removedImageBackground});
                      },
                    ),
                  ),
                ),
              ],
            ),
            bottom: 20,
            right: 15,
          ),
        )
      ]),
    );
  }

  initLanguage(callback) async {
    var lang = await AppLanguage.getTranslation();
    if (lang != null) {
      callback(lang);
    }
  }

  @override
  void initState() {
    initLanguage((lang) {
      Logger().d(lang);
      translation = lang;
    });
    translation = LanguageModel.data;
    homeController.initTestDevice();
    homeController.getCountUserReopenApp((prefs, value) async {
      Logger().d(value);

      if (value == null) {
        return prefs.setInt('opened', 1);
      }

      if (value < reviewShow) {
        return homeController.increaseUserReopenApp();
      }
      prefs.setInt('opened', 0);

      return homeController.showRatingDialog(context, () {
        homeController.openExternalBrowser(
            context,
            Uri.parse(
                "https://play.google.com/store/apps/details?id=${packageName}"),
            true);
      });
    });
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    mContext = context;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Padding(
                padding: EdgeInsets.only(top: 20, bottom: 10),
                child: CircleAvatar(
                  backgroundColor: iconColor,
                  radius: 18,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.dashboard,
                      size: 18,
                    ),
                    color: Colors.white,
                    onPressed: () {
                      // Get.offAndToNamed(Routes.DASHBOARD);
                    },
                  ),
                )),
            const Padding(
              padding: EdgeInsets.only(left: 10, top: 20, bottom: 10),
              child: const Text(
                'Dashboard',
                style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontFamily: 'RobotoCondensedRegular'),
              ),
            )
          ],
        ),
      ),
      body: DoubleBackToCloseApp(
        snackBar: SnackBar(
          content: Text(translation["exit_app"]),
        ),
        child: Column(
          children: [
            getImageContainer(),
            Expanded(
              // wrap in Expanded
              child: getDescriptionHome(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: secondaryColor,
        selectedItemColor: primaryColor,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.dashboard,
            ),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'Edit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.support),
            label: 'Support',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Future<void> downloadFile(uri, fileName) async {
    setState(() {
      downloading = true;
    });

    String savePath = await getFilePath(fileName);

    Dio dio = Dio();

    dio.download(
      uri,
      savePath,
      onReceiveProgress: (rcv, total) {
        setState(() {
          progress = ((rcv / total) * 100).toStringAsFixed(0);
        });

        if (progress == '100') {
          setState(() {
            isDownloaded = true;
          });
          if (isDownloaded && !isDialogDownloadedShow) {
            isDialogDownloadedShow = true;
            return showDownloadDialog(context);
          }
        } else if (double.parse(progress) < 100) {}
      },
      deleteOnError: true,
    ).then((_) async {
      MediaScanner.loadMedia(path: await getFilePath(fileName));

      setState(() {
        if (progress == '100') {
          isDownloaded = true;
        }

        downloading = false;
      });
    }).catchError((onError) {
      homeController.showWarningDialog(
          context, "Failed to save imgage $onError");
    });
  }

  getFilePath(uniqueFileName) async {
    String path = '';
    if (await homeController.requestPermission(Permission.storage)) {
      var directory = await getExternalStorageDirectory();
      String newPath = "";
      print(directory);
      List<String> paths = directory!.path.split("/");
      for (int x = 1; x < paths.length; x++) {
        String folder = paths[x];
        if (folder != "Android") {
          newPath += "/" + folder;
        } else {
          break;
        }
      }
      directory = Directory(newPath);
      // return '${directory.path}/$uniqueFileName';
      return '/storage/emulated/0/DCIM/HapusBackground/$uniqueFileName';
    }

    // path = '${dir.path}/$uniqueFileName.pdf';
    // Logger().d(dir.path);
    // return path;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
