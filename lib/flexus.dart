import 'package:flexus_ext/app/base/context.dart';
import 'package:flexus_ext/app/utils/dialog.dart';
import 'package:flexus_ext/app/utils/error.dart';
import 'package:flexus_ext/app/utils/string.dart';
import 'package:flexus_ext/app/utils/ui.dart';
import 'package:logger/logger.dart';

import 'app/utils/common.dart';

class Fx {
  Fx._privateConstructor();
  static final Fx _instance = Fx._privateConstructor();
  static Fx get instance => _instance;

  late FxDialogUtil dialogUtil;
  late FxErrorUtil errorUtil;
  late FxStringUtil stringUtil;
  late FxCommonUtil commonUtil;
  late FxUIUtil uiUtil;
  late Logger log;
  late FxContext context;

  int(FxDialogUtil dialogUtil, FxErrorUtil errorUtil, FxStringUtil stringUtil,
      FxCommonUtil commonUtil, FxUIUtil uiUtil, Logger log, FxContext context) {
    this.dialogUtil = dialogUtil;
    this.errorUtil = errorUtil;
    this.stringUtil = stringUtil;
    this.commonUtil = commonUtil;
    this.uiUtil = uiUtil;
    this.log = log;
    this.context = context;
  }
}
