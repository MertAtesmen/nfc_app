import 'dart:math';

String getRandomTag() {
  var rand = Random();
  StringBuffer string = StringBuffer();
  for (int i = 0; i < 16; ++i) {
    string.write(rand.nextInt(16).toRadixString(16).toUpperCase());
  }
  return string.toString();
}

String getLabelTag(String tag) {
  if (tag.length != 16) return "Length is not correct";
  List<String> list = [];
  for (int i = 0; i < 6; ++i) {
    int index = tag.length - (i * 2) - 5;
    list.add(tag[index - 1]);
    list.add(tag[index]);
  }
  return list.join();
}

bool isAtag(String tag) {
  for (int i = 0; i < tag.length; i++) {
    if (!tag[i].contains(RegExp(r"[0-9]|[A-Z]"))) {
      return false;
    }
  }
  return true;
}
