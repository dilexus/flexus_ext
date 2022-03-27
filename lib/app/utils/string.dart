class FxStringUtil {
  String getInitials({required String string, required int limitTo}) {
    var buffer = StringBuffer();
    var split = string.split(' ');
    if (limitTo > split.length) {
      limitTo = split.length;
    }
    for (var i = 0; i < limitTo; i++) {
      buffer.write(split[i][0]);
    }

    return buffer.toString();
  }
}
