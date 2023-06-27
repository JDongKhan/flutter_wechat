import 'package:audio_session/audio_session.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:flutter_wechat/utils/toast_utils.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class AudioPlayer {
  //语音类型
  final AudioSource _theSource = AudioSource.microphone;
  //存储录音编码格式
  Codec _codec = Codec.aacMP4;

  //录制权限
  bool _voiceRecorderIsInitialized = false;

  //语音录制工具
  final FlutterSoundRecorder _voiceRecorder =
      FlutterSoundRecorder(logLevel: Level.error);

  //存储文件后缀
  String _voiceFilePathSuffix = 'temp_file.mp4';

  //唯一标识
  String? _path;

  void init() {
    //初始化录音
    initVoiceRecorder().then((value) {
      _voiceRecorderIsInitialized = true;
    });
  }

  void dispose() {
    //关闭语音录制
    _voiceRecorder.closeRecorder();
  }

  ///录音及语音方法定义begin
  ///初始录音
  ///todo 用户禁止语音权限提示
  Future<bool> initVoiceRecorder() async {
    if (!kIsWeb) {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('Microphone permission not granted');
      }
    }
    await _voiceRecorder.openRecorder();
    if (!await _voiceRecorder.isEncoderSupported(_codec) && kIsWeb) {
      _codec = Codec.opusWebM;
      _voiceFilePathSuffix = 'tau_file.webm';
      if (!await _voiceRecorder.isEncoderSupported(_codec) && kIsWeb) {
        _voiceRecorderIsInitialized = true;
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
    _voiceRecorderIsInitialized = true;
    return true;
  }

  ///开始录音并返回录音文件前缀
  void start() {
    if (!_voiceRecorderIsInitialized) {
      ToastUtils.toast("没有录音权限");
      throw Exception("没有录音权限");
    }
    _path = const Uuid().v4() + _voiceFilePathSuffix;
    _voiceRecorder.startRecorder(
      codec: _codec,
      toFile: _path!,
      audioSource: _theSource,
    );
  }

  ///停止录音 并将消息存储
  Future<String?> stop() async {
    if (_path == null) {
      return null;
    }
    return _voiceRecorder.stopRecorder().then((value) {
      String path = _path!;
      return path;
    });
  }
}
