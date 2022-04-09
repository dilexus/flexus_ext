import 'dart:io';

import 'package:flexus_ext/app/enums/login_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:network_to_file_image/network_to_file_image.dart';

import '../../configs/gen/locales.g.dart';
import '../../flexus.dart';

class FxUIUtil {
  getAuthInputDecorator(String labelText,
      {Widget? icon, Widget? prefix, Widget? suffix, Color? prefixIconColor}) {
    return InputDecoration(
      labelText: labelText,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      prefixIcon: icon,
      prefixIconColor: prefixIconColor,
      prefix: prefix,
      suffix: suffix,
      contentPadding: const EdgeInsets.all(16),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Get.theme.colorScheme.primary),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Get.theme.colorScheme.onBackground),
      ),
    );
  }

  Widget getAuthButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 48.0,
      child: ElevatedButton(
          child: Text(text),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            primary: Get.theme.colorScheme.primary,
          ),
          onPressed: onPressed),
    );
  }

  Widget getAuthSocialAuthButton(LoginType loginType, Function onPressed) {
    IconData iconData;
    switch (loginType) {
      case LoginType.facebook:
        iconData = FontAwesomeIcons.facebook;
        break;
      case LoginType.google:
        iconData = FontAwesomeIcons.google;
        break;
      case LoginType.apple:
        iconData = FontAwesomeIcons.apple;
        break;
      case LoginType.email:
        iconData = FontAwesomeIcons.user;
        break;
      case LoginType.auto:
        iconData = FontAwesomeIcons.user;
        break;
    }
    return SizedBox(
        height: 48.0,
        child: ElevatedButton(
            child: Icon(iconData, color: Get.theme.colorScheme.secondary),
            style: ElevatedButton.styleFrom(
              primary: Get.theme.colorScheme.background,
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                    width: 1.0, color: Get.theme.colorScheme.secondary),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onPressed: () => onPressed(loginType)));
  }

  Widget getTextDropDown(BuildContext context,
      {required String name,
      required String label,
      required String hint,
      required Icon icon,
      required List<String> items,
      required String? Function(String?) validators,
      bool enabled = true,
      bool allowClear = false,
      String initialValue = "",
      EdgeInsets padding = const EdgeInsets.only(top: 12.0, bottom: 12.0)}) {
    return Padding(
      padding: padding,
      child: FormBuilderDropdown(
        name: name,
        initialValue: initialValue,
        decoration: InputDecoration(
          labelStyle: TextStyle(
            color: enabled
                ? Get.theme.colorScheme.onBackground
                : Get.theme.disabledColor,
          ),
          labelText: label,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Get.theme.colorScheme.secondary),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Get.theme.colorScheme.onBackground),
          ),
          border: const OutlineInputBorder(borderSide: BorderSide()),
          contentPadding: const EdgeInsets.all(12.0),
          prefixIcon: icon,
        ),
        allowClear: allowClear,
        hint: Text(
          hint,
          style: TextStyle(color: Get.theme.colorScheme.onBackground),
        ),
        style: TextStyle(
          color: Get.theme.colorScheme.onBackground,
        ),
        validator: validators,
        enabled: enabled,
        dropdownColor: Get.theme.colorScheme.background,
        items: items
            .map((val) => DropdownMenuItem(
                  value: val,
                  child: Text(val),
                ))
            .toList(),
      ),
    );
  }

  Widget getTextBox(BuildContext context,
      {required String name,
      required InputDecoration decoration,
      required String? Function(String?) validators,
      bool obscureText = false,
      EdgeInsets padding = const EdgeInsets.only(top: 12.0, bottom: 12.0)}) {
    return Padding(
      padding: padding,
      child: FormBuilderTextField(
          name: name,
          decoration: decoration,
          obscureText: obscureText,
          validator: validators),
    );
  }

  Widget getProfileCircularAvatar(
      String? profilePicture, String? name, BuildContext? context,
      {File? imageFile}) {
    if (imageFile != null && imageFile.path != "") {
      return CircleAvatar(
          radius: 51,
          foregroundColor: Get.theme.colorScheme.background,
          backgroundColor: Get.theme.colorScheme.onBackground,
          child: CircleAvatar(
            backgroundImage:
                NetworkToFileImage(url: profilePicture, file: imageFile),
            radius: 50,
            backgroundColor: Colors.white,
          ));
    } else if (profilePicture != null) {
      return CircleAvatar(
          radius: 51,
          backgroundColor: Get.theme.colorScheme.onBackground,
          child: CircleAvatar(
            backgroundImage: NetworkToFileImage(url: profilePicture),
            radius: 50,
            backgroundColor: Colors.white,
          ));
    } else {
      return CircleAvatar(
        radius: 51,
        backgroundColor: Get.theme.colorScheme.onBackground,
        child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Text(
              Fx.instance.stringUtil
                  .getInitials(string: name ?? "-", limitTo: 2),
              style: TextStyle(
                  fontSize: 30,
                  color: Theme.of(Get.context!).colorScheme.primary),
            )),
      );
    }
  }

  getProfileImage(ImageSource imageSource) async {
    Get.back();
    final pickedFile = await (ImagePicker().pickImage(source: imageSource));
    File? croppedFile = await (ImageCropper().cropImage(
        sourcePath: pickedFile!.path,
        maxWidth: 512,
        maxHeight: 512,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: LocaleKeys.dialogs_crop_image.tr,
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true),
        iosUiSettings: const IOSUiSettings(
          minimumAspectRatio: 1.0,
        )));
    return File(croppedFile!.path);
  }
}
