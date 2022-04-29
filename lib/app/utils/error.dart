import 'package:firebase_auth/firebase_auth.dart';
import 'package:flexus_core/flexus.dart';
import 'package:get/get.dart';

import '../../configs/gen/locales.g.dart';

class FxErrorUtil {
  final String _title;
  FxErrorUtil(this._title);

  void handleFirebaseException(FirebaseException ex) {
    late String message;
    switch (ex.code) {
      case "user-not-found":
        message = LocaleKeys.auth_errors_no_user_found.tr;
        break;
      case "wrong-password":
        message = LocaleKeys.auth_errors_wrong_password.tr;
        break;
      case "weak-password":
        message = LocaleKeys.auth_errors_weak_password.tr;
        break;
      case "email-already-in-use":
        message = LocaleKeys.auth_already_have_an_account.tr;
        break;
      case "account-exists-with-different-credential":
        message = LocaleKeys.auth_errors_account_exist_with_same_email.tr;
        break;
      case "too-many-requests":
        message = LocaleKeys.auth_errors_too_many_requests.tr;
        break;
      case "unauthorized":
        message = LocaleKeys.auth_errors_unauthorized.tr;
        break;
      default:
        message = LocaleKeys.auth_errors_sign_in_failure.tr;
    }
    Fc.instance.dialog.showOKDialog(message: message, title: _title.tr);
  }

  void handleGenericException(Object exception) {
    Fc.instance.dialog.showOKDialog(
        message: LocaleKeys.auth_errors_sign_in_failure.tr, title: _title.tr);
  }
}
