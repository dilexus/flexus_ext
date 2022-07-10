import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flexus_core/flexus.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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
    Fc.instance.log.i('Login with ${loginType.toString()} clicked');
    switch (loginType) {
      case LoginType.facebook:
        await _signInWithFacebook(loginType, success, failed);
        break;
      case LoginType.google:
        await _signInWithGoogle(loginType, success, failed);
        break;
      case LoginType.apple:
        await _signInWithApple(loginType, success, failed);
        break;
      default:
        Fc.instance.log.w('Invalid social login type');
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
    try {
      await FirebaseAuth.instance.currentUser?.reload();
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _onAuthSuccess(LoginType.auto, success, emailToVerify, user);
      } else {
        _onAuthFailed(LoginType.auto, failed, Exception('User not found'));
      }
    } catch (ex) {
      _onAuthFailed(LoginType.email, failed, ex);
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
      Fc.instance.log.w(exception.toString());
      Fx.instance.errorUtil.handleFirebaseException(exception);
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

  _signInWithFacebook(LoginType loginType, OnAuthSuccess onAuthSuccess,
      OnAuthFailed onAuthFailed) async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      UserCredential userCredential;
      switch (result.status) {
        case LoginStatus.success:
          AuthCredential credential =
              FacebookAuthProvider.credential(result.accessToken!.token);
          userCredential =
              await FirebaseAuth.instance.signInWithCredential(credential);
          final user = userCredential.user;
          _onAuthSuccess(loginType, onAuthSuccess, null, user!);
          break;
        case LoginStatus.cancelled:
          Fc.instance.log.w(result.message);
          _onAuthFailed(loginType, onAuthFailed,
              Exception('Facebook login is cancelled'));
          break;
        case LoginStatus.failed:
          Fc.instance.log.e(result.message);
          _onAuthFailed(
              loginType, onAuthFailed, Exception('Facebook login is failed'));
          break;
        default:
      }
    } catch (ex) {
      _onAuthFailed(loginType, onAuthFailed, ex);
    }
  }

  _signInWithApple(LoginType loginType, OnAuthSuccess onAuthSuccess,
      OnAuthFailed onAuthFailed) async {
    try {
      final nonce = Fc.instance.commonUtil.createNonce(32);
      final nativeAppleCred = Platform.isIOS
          ? await SignInWithApple.getAppleIDCredential(
              scopes: [
                AppleIDAuthorizationScopes.email,
                AppleIDAuthorizationScopes.fullName,
                AppleIDAuthorizationScopes.values.first,
                AppleIDAuthorizationScopes.values.last,
              ],
              nonce: sha256.convert(utf8.encode(nonce)).toString(),
            )
          : await SignInWithApple.getAppleIDCredential(
              scopes: [
                AppleIDAuthorizationScopes.email,
                AppleIDAuthorizationScopes.fullName,
                AppleIDAuthorizationScopes.values.first,
                AppleIDAuthorizationScopes.values.last,
              ],
              webAuthenticationOptions: WebAuthenticationOptions(
                redirectUri:
                    Uri.parse(Fx.instance.context.appleRedirectURL ?? ''),
                clientId: Fx.instance.context.appleBundleId ?? '',
              ),
              nonce: sha256.convert(utf8.encode(nonce)).toString(),
            );

      var credentialsApple = OAuthCredential(
        providerId: 'apple.com',
        signInMethod: 'oauth',
        accessToken: nativeAppleCred.identityToken,
        idToken: nativeAppleCred.identityToken,
        rawNonce: nonce,
      );
      User? user =
          (await FirebaseAuth.instance.signInWithCredential(credentialsApple))
              .user;
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
    Fc.instance.log.i('User sign out success');
  }

  Future<void> updateUserInfo(LoginType loginType,
      {required OnUserProfileUpdateSuccess success,
      required OnUserProfileUpdateFailed failed,
      String? name,
      String? password,
      File? photo}) async {
    try {
      Fc.instance.log.i('Updating user info');

      User user = FirebaseAuth.instance.currentUser!..reload();

      if (password != null && password.isNotEmpty) {
        await user.updatePassword(password);
        Fc.instance.log.i('Password saved successful');
      }

      if (photo != null && photo.path != '') {
        String photoUrl = await Fx.instance.firebaseUtil
            .addImageToStorage('user/profile/${user.uid}.jpg', photo);
        await user.updatePhotoURL(photoUrl);
        Fc.instance.log.i('Photo saved successful');
      }

      if (name != null && name.isNotEmpty) {
        await user.updateDisplayName(name);
        Fc.instance.log.i('Name saved successful');
      }
      user = FirebaseAuth.instance.currentUser!
        ..reload().then((value) async {
          AuthUser authUser = await _getAuthUser(loginType, user);
          Auth.instance.authUser = authUser;
          success(authUser);
        });
    } on FirebaseException catch (ex) {
      Fc.instance.log.w(ex);
      Fx.instance.errorUtil.handleFirebaseException(ex);
      failed(ex);
    } catch (ex) {
      Fc.instance.log.w(ex);
      Fx.instance.errorUtil.handleGenericException(ex);
      failed(ex);
    }
  }

  Future<AuthUser> _getAuthUser(LoginType loginType, User user) async {
    late LoginType type;
    switch (user.providerData[0].providerId) {
      case 'google.com':
        type = LoginType.google;
        break;
      case 'facebook.com':
        type = LoginType.facebook;
        break;
      case 'apple.com':
        type = LoginType.apple;
        break;
      default:
        type = LoginType.email;
    }
    String idToken = await user.getIdToken();
    return AuthUser(
        id: user.uid,
        name: user.providerData.first.displayName,
        email: user.email,
        emailVerified: user.emailVerified,
        photoURL: user.providerData.first.photoURL,
        idToken: idToken,
        loginType: type);
  }

  _onAuthSuccess(LoginType loginType, OnAuthSuccess onAuthSuccess,
      OnAuthSuccessAndEmailToVerify? emailToVerify, User user) async {
    AuthUser authUser = await _getAuthUser(loginType, user);
    Fc.instance.log.i('Login with ${loginType.toString()} successful');
    Fc.instance.log.d(
        'User Data = Name: ${authUser.name}, Email: ${authUser.email}, Email Verified: ${authUser.emailVerified}');
    Auth.instance.authUser = authUser;

    if (emailToVerify != null) {
      if (user.emailVerified) {
        onAuthSuccess(authUser);
      } else {
        Fc.instance.log.i('Sending verification email');
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
    Fc.instance.log.w('Login with ${loginType.toString()} failed');

    if (exception is FirebaseException) {
      Fc.instance.log.w(exception.toString());
      Fx.instance.errorUtil.handleFirebaseException(exception);
    } else {
      Fc.instance.log.w(exception.toString());
      Fx.instance.errorUtil.handleGenericException(exception);
    }
    onAuthFailed(exception);
  }
}

typedef OnAuthSuccess = Function(AuthUser user);
typedef OnUserProfileUpdateSuccess = Function(AuthUser user);
typedef OnUserProfileUpdateFailed = Function(Object exception);
typedef OnAuthSuccessAndEmailToVerify = Function(AuthUser user);
typedef OnAuthFailed = Function(Object exception);
typedef OnSignOut = Function();
