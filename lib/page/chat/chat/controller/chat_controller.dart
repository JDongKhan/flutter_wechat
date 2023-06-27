import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wechat/utils/date_util.dart';
import 'package:flutter_wechat/utils/web_socket_utils.dart';
import 'package:get/get.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import '../model/wechat_message.dart';

const int pageSize = 20;

class ChatController extends GetxController {
  ChatController({this.scrollController});
  var data = <Message>[].obs;
  int currentPage = 0;
  ScrollController? scrollController;
  var isConnected = false.obs;

  StreamSubscription? _streamSubscription;

  bool get hasMore => data.length >= pageSize;

  var unReadCount = 0.obs;
  //显示未读标识
  var showUnReadTip = false.obs;

  ChatScrollObserver? chatObserver;

  @override
  void onInit() {
    WebSocketUtils.getInstance().connect();
    _streamSubscription = WebSocketUtils.getInstance().stream?.listen((event) {
      isConnected.value = true;
    }, onDone: () {
      isConnected.value = false;
    }, onError: (error) {
      isConnected.value = false;
    });
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    _firstLoad();
  }

  void _firstLoad() async {
    List<Message> list = await loadData();
    data.addAll(list);
    update();
  }

  @override
  void onClose() {
    _streamSubscription?.cancel();
    super.onClose();
  }

  @override
  Future<List<Message>> loadData() async {
    return Future.delayed(const Duration(seconds: 1), () {
      return List.generate(
        20,
        (int index) => Message(
          time: '2021-01-01 0$currentPage:$index',
          message:
              ' this is $index message  this is $index message  this is $index message  this is $index message  this is $index message  this is $index message  this is $index message  this is $index message  this is $index message  this is $index message  this is $index message',
          isMe: (index % 10) == 0,
        ),
      );
    });
  }

  void clearUnRead() {
    unReadCount.value = 0;
    showUnReadTip.value = false;
  }

  ///接受消息
  void receiveMessage(String message) {
    if (showUnReadTip.value) {
      unReadCount.value++;
    }
    chatObserver?.standby();
    Message m = Message(
      time: DateUtil.formatDate(DateTime.now(), format: "yyyy-MM-dd HH:mm:ss"),
      message: message,
      isMe: false,
    );
    data.insert(0, m);
    update();
  }

  //发送消息
  void sendMessage({required String message}) {
    Message m = Message(
      time: DateUtil.formatDate(DateTime.now(), format: "yyyy-MM-dd HH:mm:ss"),
      message: message,
      isMe: true,
    );
    data.insert(0, m);
    update();
    jumpToBottom();
  }

  //发送消息
  void sendFile({required File file}) {
    Message m = Message(
      time: DateUtil.formatDate(DateTime.now(), format: "yyyy-MM-dd HH:mm:ss"),
      file: file,
      isMe: true,
    );
    data.insert(0, m);
    update();
    jumpToBottom();
  }

  void removeMessage(Message message) {
    update();
    jumpToBottom();
  }

  void jumpToBottom() {}

  ///加载更多
  Future onLoad() async {
    currentPage++;
    debugPrint('上拉刷新开始...');
    List<Message>? list = await loadData();
    debugPrint('加载数据完成...');
    if (list != null) {
      data.addAll(list);
    }
    debugPrint('上拉刷新结束...');
    update();
    return list;
  }
}
