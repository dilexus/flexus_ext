library flexus_ext;

import 'app/base/bindings.dart';
import 'flexus.dart';

class FlexusExt {
  FlexusExt._privateConstructor();
  static final FlexusExt _instance = FlexusExt._privateConstructor();
  static FlexusExt get instance => _instance;
  Fx load() {
    Bindings().dependencies();
    return Fx.instance;
  }
}
