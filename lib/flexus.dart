import 'package:flexus_ext/app/base/context.dart';
import 'package:flexus_ext/app/utils/error.dart';
import 'package:flexus_ext/app/utils/ui.dart';
import 'package:logger/logger.dart';

import 'app/utils/firebase.dart';

class Fx {
  Fx._privateConstructor();
  static final Fx _instance = Fx._privateConstructor();
  static Fx get instance => _instance;
  late FxErrorUtil errorUtil;
  late FxUIUtil uiUtil;
  late FxFirebaseUtil firebaseUtil;
  late FxContext context;

  init(FxErrorUtil errorUtil, FxUIUtil uiUtil, FxFirebaseUtil firebaseUtil,
      Logger log, FxContext context) {
    this.errorUtil = errorUtil;
    this.uiUtil = uiUtil;
    this.firebaseUtil = firebaseUtil;
    this.context = context;
  }
}
