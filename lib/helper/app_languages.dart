import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

class AppLanguage {
  static getCode() {
    return Platform.localeName;
  }

  static getTranslation() async {
    var langCode = getCode();
    var language = await rootBundle.loadString('assets/languages/en_US.json');
    if (langCode == "id_ID") {
      language = await rootBundle.loadString('assets/languages/id_ID.json');
      return await json.decode(language);
    }

    if (langCode == "en_US") {
      language = await rootBundle.loadString('assets/languages/en_US.json');
      return await json.decode(language);
    }

    return await json.decode(language);
  }
}
