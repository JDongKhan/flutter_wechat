import 'dart:io';

/// @author jd

class Message {
  const Message({
    this.time,
    this.message,
    this.isMe = false,
    this.name,
    this.image,
    this.file,
  });
  final String? time;
  final String? message;
  final bool isMe;
  final String? name;
  final String? image;
  final File? file;

  bool isVideo() {
    if (file == null) {
      return false;
    }
    return file!.path.contains("mp4");
  }
}
