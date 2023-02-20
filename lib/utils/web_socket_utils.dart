import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'logger_util.dart';

class WebSocketUtils {
  //单例
  factory WebSocketUtils() => getInstance();
  static WebSocketUtils? _instance;
  static WebSocketUtils getInstance() {
    _instance ??= WebSocketUtils._();
    return _instance!;
  }

  final String url =
      'ws://127.0.0.1:48080/chat/conversation?tenant-id=3&Authorization=50ddd34cbb1f44e4a62bcb9f8f841230';

  WebSocketUtils._();

  WebSocketChannel? _channel;

  //连接状态
  bool isConnect = false;
  bool isConnecting = false;
  //心跳时间 30秒
  int heartbeat = 30;
  //心跳定时器
  Timer? _heartbeatTimer;
  // 重连定时器
  Timer? _reconnectTimer;
  // 重连次数，默认60次
  final num _reconnectCount = 60;
  // 重连计数器
  num _reconnectTimes = 0;

  //外边使用的流，因为这个外边页面没有销毁，所以不能重建
  final StreamController _streamController = StreamController.broadcast();
  late final Stream _outStream = _streamController.stream;
  late final StreamSink _outSink = _streamController.sink;

  ///连接
  void connect() {
    //重置重连计数器
    _reconnectTimes = 0;
    _initWebSocket();
    _initHeartBeat();
  }

  void _initWebSocket() {
    if (isConnect) {
      logger.i('已经连接');
      return;
    }
    if (isConnecting) {
      logger.i('正在连接');
      return;
    }
    logger.i('开始连接');
    _channel?.sink.close();
    try {
      final wsUrl = Uri.parse(url);
      _channel = WebSocketChannel.connect(wsUrl);
    } catch (e) {
      logger.i('连接异常');
    }
    isConnecting = true;
    _channel?.stream.listen((event) {
      debugPrint("收到消息：$event");
      isConnect = true;
      isConnecting = false;
      _outSink.add(event);
    }, onDone: () {
      isConnect = false;
      isConnecting = false;
      logger.i('连接关闭时响应');
      _outSink.addError('连接关闭');
      _autoReconnect();
    }, onError: (error) {
      logger.i('发生错误:$error');
      isConnect = false;
      isConnecting = false;
      _outSink.addError(error);
      _autoReconnect();
    }, cancelOnError: true);
  }

  ///获取流监听
  Stream? get stream => _outStream;

  ///发送
  void send(String message) {
    _channel?.sink.add(message);
  }

  ///关闭
  void close() {
    isConnect = false;
    isConnecting = false;
    _channel?.sink.close();
    _cancelReconnect();
    _destroyHeartBeat();
  }

  void _autoReconnect() {
    if (_reconnectTimes >= _reconnectCount) {
      logger.i('重连次数超过最大次数');
      _reconnectTimer?.cancel();
      _reconnectTimer = null;
      return;
    }
    debugPrint('重连次数:$_reconnectTimes');
    _reconnectTimes++;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: heartbeat), () {
      if (isConnect) {
        _cancelReconnect();
      } else if (isConnecting) {
        return;
      } else {
        _initWebSocket();
      }
    });
  }

  //取消重连
  void _cancelReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  /// 初始化心跳
  void _initHeartBeat() {
    _destroyHeartBeat();
    _heartbeatTimer =
        Timer.periodic(Duration(milliseconds: heartbeat), (timer) {
      send('{"module": "HEART_CHECK", "message": "请求心跳"}');
    });
  }

  void _destroyHeartBeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }
}
