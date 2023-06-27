import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:logger/logger.dart';

class AudioPlayer {
  //播放器权限
  bool _voicePlayerIsInitialized = false;

  //语音播放工具
  final FlutterSoundPlayer _voicePlayer =
      FlutterSoundPlayer(logLevel: Level.error);

  void init() {
    //初始化播放器
    _voicePlayer.openPlayer().then((value) {
      _voicePlayerIsInitialized = true;
    });
  }

  void dispose() {
    //关闭语音播放
    _voicePlayer.closePlayer();
  }

  ///开始播放录音
  void play(String messageVoiceFilePath, {Function? playFinished}) {
    assert(_voicePlayerIsInitialized && _voicePlayer.isStopped);
    _voicePlayer.startPlayer(
      fromURI: messageVoiceFilePath,
      //codec: kIsWeb ? Codec.opusWebM : Codec.aacADTS,
      //语音播放完后的动作->停止播放
      whenFinished: () {
        print("播放完的动作");
        playFinished?.call();
      },
    );
  }

  ///停止播放声音
  Future<void> stop() {
    return _voicePlayer.stopPlayer();
  }
}
