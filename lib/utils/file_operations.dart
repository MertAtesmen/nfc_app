import 'dart:io';

List<FileSystemEntity> listFiles({required String directoryPath}) {
  Directory dir = Directory(directoryPath);
  return dir.listSync();
}

List<String> getTags({required File file}) {
  String content = file.readAsStringSync();
  if (content == "") {
    return [];
  }
  return content.split("\n");
}

void addListofTags({required List<String> tags, required File file}) {
  file.writeAsString(tags.join("\n"));
}

void addTag({required File file, required String tag}) {
  if (file.lengthSync() != 0) {
    file.writeAsStringSync("\n", mode: FileMode.append);
  }
  file.writeAsString(tag, mode: FileMode.append);
}

List<String> deleteATag({required File file, required String tag}) {
  List<String> tags = getTags(file: file);
  tags.remove(tag);
  addListofTags(tags: tags, file: file);
  return tags;
}
