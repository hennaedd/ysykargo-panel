import 'dart:developer';

import 'package:flutter/foundation.dart';

void cPrint(String? object) {
  try {
    if (kDebugMode) {
      log(object ?? 'Logger detected null value.', name: 'KARGO APP LOGGER');
    }
  } catch (e) {
    if (kDebugMode) {
      log(e.toString());
    }
  }
}