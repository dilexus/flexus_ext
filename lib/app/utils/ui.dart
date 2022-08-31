import 'dart:io';

import 'package:flexus_core/flexus.dart';
import 'package:flexus_ext/app/enums/login_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:network_to_file_image/network_to_file_image.dart';

import '../../configs/gen/locales.g.dart';

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
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Get.theme.colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Get.theme.colorScheme.error),
      ),
    );
  }

  Widget getAuthButton(String text, VoidCallback onPressed,
      {required Key key}) {
    return SizedBox(
      width: double.infinity,
      height: 48.0,
      child: ElevatedButton(
          key: key,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Get.theme.colorScheme.primary,
          ),
          onPressed: onPressed,
          child: Text(text)),
    );
  }

  Widget getAuthSocialAuthButton(LoginType loginType, Function onPressed,
      {required Key key}) {
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
            key: key,
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.background,
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                    width: 1.0, color: Get.theme.colorScheme.primary),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onPressed: () => onPressed(loginType),
            child: Icon(iconData, color: Get.theme.colorScheme.primary)));
  }

  Widget getTextDropDown(BuildContext context,
      {required String name,
      required String label,
      required Icon icon,
      required List<String> items,
      required String? Function(String?) validators,
      required Key key,
      bool enabled = true,
      bool allowClear = false,
      String initialValue = '',
      EdgeInsets padding = const EdgeInsets.only(top: 12.0, bottom: 12.0)}) {
    return Padding(
      padding: padding,
      child: FormBuilderDropdown(
        name: name,
        key: key,
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Get.theme.colorScheme.secondary),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Get.theme.colorScheme.onBackground),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Get.theme.colorScheme.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Get.theme.colorScheme.error),
          ),
          border: const OutlineInputBorder(borderSide: BorderSide()),
          contentPadding: const EdgeInsets.all(4.0),
          prefixIcon: icon,
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
      required Key key,
      required InputDecoration decoration,
      required String? Function(String?) validators,
      String? initialValue = '',
      bool obscureText = false,
      EdgeInsets padding = const EdgeInsets.only(top: 12.0, bottom: 12.0)}) {
    return Padding(
      padding: padding,
      child: FormBuilderTextField(
          initialValue: initialValue,
          name: name,
          key: key,
          decoration: decoration,
          obscureText: obscureText,
          validator: validators),
    );
  }

  Widget getProfileCircularAvatar(
      String? profilePicture, String? name, BuildContext? context,
      {required Key key, File? imageFile}) {
    if (imageFile != null && imageFile.path != '') {
      return CircleAvatar(
          key: key,
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
          key: key,
          radius: 51,
          backgroundColor: Get.theme.colorScheme.onBackground,
          child: CircleAvatar(
            backgroundImage: NetworkToFileImage(url: profilePicture),
            radius: 50,
            backgroundColor: Colors.white,
          ));
    } else {
      return CircleAvatar(
        key: key,
        radius: 51,
        backgroundColor: Get.theme.colorScheme.onBackground,
        child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Text(
              Fc.instance.stringUtil
                  .getInitials(string: name ?? '-', limitTo: 2),
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
    CroppedFile? croppedFile = await (ImageCropper().cropImage(
        sourcePath: pickedFile!.path,
        maxWidth: 512,
        maxHeight: 512,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: LocaleKeys.dialogs_crop_image.tr,
              toolbarColor: Colors.black,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true),
          IOSUiSettings(
            minimumAspectRatio: 1.0,
          )
        ]));
    return File(croppedFile!.path);
  }
}
