import 'package:flexus_ext/app/utils/dialog.dart';
import 'package:flexus_ext/app/utils/error.dart';
import 'package:flexus_ext/app/utils/string.dart';
import 'package:flexus_ext/app/utils/ui.dart';
import 'package:logger/logger.dart';

class Fx {
  Fx._privateConstructor();
  static final Fx _instance = Fx._privateConstructor();
  static Fx get instance => _instance;

  late FxDialogUtil dialogUtil;
  late FxErrorUtil errorUtil;
  late FxStringUtil stringUtil;
  late FxUIUtil uiUtil;
  late Logger log;

  int(FxDialogUtil dialogUtil, FxErrorUtil errorUtil, FxStringUtil stringUtil,
      FxUIUtil uiUtil, Logger log) {
    this.dialogUtil = dialogUtil;
    this.errorUtil = errorUtil;
    this.stringUtil = stringUtil;
    this.uiUtil = uiUtil;
    this.log = log;
  }
}
