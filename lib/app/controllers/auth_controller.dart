import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../flexus.dart';
import '../base/auth.dart';
import '../data/models/auth_user_model.dart';
import '../enums/login_type.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();
  FirebaseAuth auth = FirebaseAuth.instance;

  loginWithSocialAuth(LoginType loginType,
      {required OnAuthSuccess success,
      required OnAuthSuccessAndEmailToVerify emailToVerify,
      required OnAuthFailed failed}) async {
    Fx.instance.log.i("Login with ${loginType.toString()} clicked");
    switch (loginType) {
      case LoginType.facebook:
        // TODO: Handle this case.
        break;
      case LoginType.google:
        await _signInWithGoogle(loginType, success, failed);
        break;
      case LoginType.apple:
        // TODO: Handle this case.
        break;
      case LoginType.email:
        // TODO: Handle this case.
        break;
      case LoginType.auto:
        // TODO: Handle this case.
        break;
    }
  }

  signInWithEmail(String email, String password,
      {required OnAuthSuccess success,
      required OnAuthSuccessAndEmailToVerify emailToVerify,
      required OnAuthFailed failed}) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      User user = userCredential.user!;
      _onAuthSuccess(LoginType.email, success, emailToVerify, user);
    } on FirebaseAuthException catch (ex) {
      _onAuthFailed(LoginType.email, failed, ex);
    } catch (ex) {
      _onAuthFailed(LoginType.email, failed, ex);
    }
  }

  signUpWithEmail(String name, String email, String password,
      {required OnAuthSuccess success,
      required OnAuthSuccessAndEmailToVerify emailToVerify,
      required OnAuthFailed failed}) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      User user = userCredential.user!;
      await user.updateDisplayName(name);
      _onAuthSuccess(LoginType.email, success, emailToVerify, user);
    } on FirebaseAuthException catch (ex) {
      _onAuthFailed(LoginType.email, failed, ex);
    } catch (ex) {
      _onAuthFailed(LoginType.email, failed, ex);
    }
  }

  autoSignUserIn(
      {required OnAuthSuccess success,
      required OnAuthSuccessAndEmailToVerify emailToVerify,
      required OnAuthFailed failed}) async {
    await FirebaseAuth.instance.currentUser?.reload();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _onAuthSuccess(LoginType.auto, success, emailToVerify, user);
    } else {
      _onAuthFailed(LoginType.auto, failed, Exception("User not found"));
    }
  }

  Future<bool> isEmailVerified() async {
    FirebaseAuth.instance.currentUser?.reload();
    User? user = FirebaseAuth.instance.currentUser;
    if (user?.emailVerified ?? false) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> resetPassword(String email,
      {required Function resetSuccess, required Function resetFailed}) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      resetSuccess();
    } on FirebaseAuthException catch (exception) {
      Fx.instance.log.w(exception.toString());
      Fx.instance.errorUtil.handleFirebaseErrors(exception);
      resetFailed();
    }
  }

  _signInWithGoogle(LoginType loginType, OnAuthSuccess onAuthSuccess,
      OnAuthFailed onAuthFailed) async {
    try {
      UserCredential userCredential;
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      var credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;
      _onAuthSuccess(loginType, onAuthSuccess, null, user!);
    } catch (ex) {
      _onAuthFailed(loginType, onAuthFailed, ex);
    }
  }

  void signOutFromAll(OnSignOut onSignOut) {
    FirebaseAuth.instance.signOut().then((it) {
      Auth.instance.authUser = null;
      onSignOut();
    });
    Fx.instance.log.i("User sign out success");
  }

  AuthUser _getAuthUser(User user) {
    return AuthUser(
        name: user.providerData.first.displayName,
        email: user.email,
        emailVerified: user.emailVerified,
        photoURL: user.providerData.first.photoURL);
  }

  _onAuthSuccess(LoginType loginType, OnAuthSuccess onAuthSuccess,
      OnAuthSuccessAndEmailToVerify? emailToVerify, User user) async {
    AuthUser authUser = _getAuthUser(user);
    Fx.instance.log.i("Login with ${loginType.toString()} successful");
    Fx.instance.log.d(
        "User Data = Name: ${authUser.name}, Email: ${authUser.email}, Email Verified: ${authUser.emailVerified}");
    Auth.instance.authUser = authUser;

    if (emailToVerify != null) {
      if (user.emailVerified) {
        onAuthSuccess(authUser);
      } else {
        Fx.instance.log.i("Sending verification email");
        user.sendEmailVerification();
        emailToVerify(authUser);
      }
    } else {
      onAuthSuccess(authUser);
    }
  }

  _onAuthFailed(
      LoginType loginType, OnAuthFailed onAuthFailed, Object exception) {
    Auth.instance.authUser = null;
    Fx.instance.log.w("Login with ${loginType.toString()} failed");
    Fx.instance.log.w(exception.toString());
    if (exception is FirebaseAuthException) {
      Fx.instance.errorUtil.handleFirebaseErrors(exception);
    } else {
      Fx.instance.errorUtil.handleGenericAuthError(exception);
    }
    onAuthFailed(exception);
  }
}

typedef OnAuthSuccess = Function(AuthUser user);
typedef OnAuthSuccessAndEmailToVerify = Function(AuthUser user);
typedef OnAuthFailed = Function(Object exception);
typedef OnSignOut = Function();