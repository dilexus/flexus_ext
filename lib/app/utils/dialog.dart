import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../configs/gen/locales.g.dart';

class FxDialogUtil {
  showOKDialog(
      {required String message,
      required String title,
      String? textOK,
      VoidCallback? onOKPressed,
      Widget? content,
      bool barrierDismissible = false}) {
    Get.defaultDialog(
        title: title,
        middleText: message,
        barrierDismissible: barrierDismissible,
        backgroundColor: Get.theme.colorScheme.background,
        content: content,
        confirm: _getDialogBoxButton(textOK ?? LocaleKeys.generic_ok.tr,
            onOKPressed ?? () => Get.back()),
        radius: 8);
  }

  showYesNoDialog(
      {required String message,
      required String title,
      String? textYes,
      String? textNo,
      VoidCallback? onYesPressed,
      VoidCallback? onNoPressed,
      Widget? content,
      bool barrierDismissible = false}) {
    Get.defaultDialog(
        title: title,
        middleText: message,
        content: content,
        backgroundColor: Get.theme.colorScheme.background,
        barrierDismissible: barrierDismissible,
        confirm: _getDialogBoxButton(textYes ?? LocaleKeys.generic_yes.tr,
            onYesPressed ?? () => Get.back()),
        cancel: _getDialogBoxButton(textNo ?? LocaleKeys.generic_no.tr,
            onNoPressed ?? () => Get.back()),
        radius: 8);
  }

  showYesNoCustomDialog(
      {required String message,
      required String title,
      String? textYes,
      String? textNo,
      String? textCustom,
      VoidCallback? onYesPressed,
      VoidCallback? onNoPressed,
      VoidCallback? onCustomPressed,
      Widget? content,
      bool barrierDismissible = false}) {
    Get.defaultDialog(
        title: title,
        middleText: message,
        content: content,
        barrierDismissible: barrierDismissible,
        confirm: _getDialogBoxButton(textYes ?? LocaleKeys.generic_yes.tr,
            onYesPressed ?? () => Get.back()),
        cancel: _getDialogBoxButton(textNo ?? LocaleKeys.generic_no.tr,
            onNoPressed ?? () => Get.back()),
        custom: _getDialogBoxButton(textCustom ?? LocaleKeys.generic_ok.tr,
            onCustomPressed ?? () => Get.back()),
        radius: 8);
  }

  _getDialogBoxButton(String text, VoidCallback? onPressed) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 48,
        minWidth: 100,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          primary: Get.theme.colorScheme.primary,
          elevation: 0,
        ),
        child: Text(
          text,
        ),
      ),
    );
  }
}
