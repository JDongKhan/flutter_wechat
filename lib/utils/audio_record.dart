import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:flutter_wechat/utils/path_utils.dart';
import 'package:flutter_wechat/utils/toast_utils.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class AudioRecord {
  //语音类型
  final AudioSource _theSource = AudioSource.microphone;
  //存储录音编码格式
  Codec _codec = Codec.aacMP4;

  //语音录制工具
  final FlutterSoundRecorder _voiceRecorder =
      FlutterSoundRecorder(logLevel: Level.info);

  //存储文件后缀
  String _voiceFilePathSuffix = 'temp_file.mp4';

  //唯一标识
  String? _path;

  ///录音及语音方法定义begin
  ///初始录音
  Future<bool> initVoiceRecorder() async {
    if (!kIsWeb) {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        ToastUtils.toast("没有录音权限");
        return false;
      }
    }
    await _voiceRecorder.openRecorder();
    if (!await _voiceRecorder.isEncoderSupported(_codec) && kIsWeb) {
      _codec = Codec.opusWebM;
      _voiceFilePathSuffix = 'tau_file.webm';
      if (!await _voiceRecorder.isEncoderSupported(_codec) && kIsWeb) {
        return false;
      }
    }
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
    return true;
  }

  ///开始录音并返回录音文件前缀
  void start() async {
    //初始化录音
    bool voiceRecorderIsInitialized = await initVoiceRecorder();
    if (!voiceRecorderIsInitialized) {
      return;
    }
    Directory? dir = await PathUtils.getAppTemporaryDirectory();
    String fileName = const Uuid().v4() + _voiceFilePathSuffix;
    if (dir != null) {
      _path = dir.path;
    }
    if (_path != null) {
      _path = "${_path!}/$fileName";
    } else {
      _path = fileName;
    }
    print("开始录制:$_path");
    _voiceRecorder.startRecorder(
      codec: _codec,
      toFile: _path!,
      audioSource: _theSource,
    );
  }

  Future<void> cancel() async {
    if (_path == null) {
      return;
    }
    print("取消录制");
    await _voiceRecorder.stopRecorder();
    await _voiceRecorder.deleteRecord(fileName: _path!);
    await _voiceRecorder.closeRecorder();
  }

  ///停止录音 并将消息存储
  Future<String?> stop() async {
    if (_path == null) {
      return null;
    }
    return _voiceRecorder.stopRecorder().then((value) {
      String path = _path!;
      print('录制成功$path');
      //关闭语音录制
      _voiceRecorder.closeRecorder();
      return path;
    });
  }
}
