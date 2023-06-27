import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_wechat/widgets/direction_button.dart';
import 'package:get/get.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../message_list/vm/audio_payer.dart';
import '../../message_list/vm/audio_record.dart';
import '../controller/chat_controller.dart';

/// @author jd

enum ChatInputMessageStatus {
  text,
  voice,
}

class ChatInputMessageController extends ChangeNotifier {
  bool _hiddenKeyboard = false;

  void hiddenKeyboard() {
    _hiddenKeyboard = true;
    notifyListeners();
  }
}

class ChatInputMessageWidget extends StatefulWidget {
  const ChatInputMessageWidget({required this.controller, Key? key})
      : super(key: key);
  final ChatInputMessageController controller;

  @override
  State createState() => _ChatInputMessageWidgetState();
}

class _ChatInputMessageWidgetState extends State<ChatInputMessageWidget>
    with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  late Animation _animation;
  late AnimationController _animationController;
  final TextEditingController _textEditingController = TextEditingController();
  final ChatController _controller = Get.find<ChatController>();
  ChatInputMessageStatus _status = ChatInputMessageStatus.text;
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;
  bool _isRecording = false;
  final List<String> _list = [
    '照片',
    '拍摄',
    '视频通话',
    '位置',
    '红包',
    '转账',
    '语音输入',
    '收藏',
    '个人名片',
    '文件',
    '卡券',
  ];

  AudioRecord? audioRecord;

  @override
  void initState() {
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _animationController.reverse(from: 0);
      }
    });

    _animationController = AnimationController(
        duration: const Duration(
          milliseconds: 250,
        ),
        vsync: this);
    _animation = Tween(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.addListener(() {});
    _animationController.reverse();

    widget.controller.addListener(() {
      if (widget.controller._hiddenKeyboard) {
        //收起键盘
        // FocusScope.of(context).requestFocus(FocusNode());
        _focusNode.unfocus();
        _animationController.reverse();
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.only(top: 10),
        alignment: Alignment.topCenter,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.keyboard_voice),
                  onPressed: () {
                    // FocusScope.of(context).requestFocus(FocusNode());
                    _focusNode.unfocus();
                    _animationController.reverse(from: 0);
                    setState(() {
                      if (_status == ChatInputMessageStatus.text) {
                        _status = ChatInputMessageStatus.voice;
                      } else if (_status == ChatInputMessageStatus.voice) {
                        _status = ChatInputMessageStatus.text;
                      }
                    });
                  },
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: _status == ChatInputMessageStatus.voice
                        ? _voiceWidget()
                        : _input(),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                IconButton(
                  icon: const Icon(Icons.face),
                  onPressed: () {
                    // FocusScope.of(context).requestFocus(FocusNode());
                    _focusNode.unfocus();
                    _animationController.forward();
                    if (_status == ChatInputMessageStatus.voice) {
                      setState(() {
                        _status = ChatInputMessageStatus.text;
                      });
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    // FocusScope.of(context).requestFocus(FocusNode());
                    _focusNode.unfocus();
                    _animationController.forward();
                    if (_status == ChatInputMessageStatus.voice) {
                      setState(() {
                        _status = ChatInputMessageStatus.text;
                      });
                    }
                  },
                ),
              ],
            ),
            _menu(),
          ],
        ),
      ),
    );
  }

  Widget _input() {
    return Container(
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xffeeeeee),
        ),
      ),
      child: TextField(
        keyboardType: TextInputType.text,
        maxLines: 5,
        minLines: 1,
        textInputAction: TextInputAction.send,
        onSubmitted: (value) {
          _textEditingController.text = '';
          Get.find<ChatController>().sendMessage(message: value);
        },
        focusNode: _focusNode,
        controller: _textEditingController,
        decoration: const InputDecoration(
          hintText: 'input message',
          filled: true,
          fillColor: Colors.white,
          border: InputBorder.none,
          isCollapsed: true, //相当于高度包裹的意思，必须为true，不然有默认的最小高度
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          // isDense: true,
        ),
      ),
    );
  }

  Widget _input2() {
    return TextField(
      keyboardType: TextInputType.multiline,
      maxLines: 5,
      minLines: 1,
      focusNode: _focusNode,
      decoration: const InputDecoration(
        hintText: 'input message',
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        isDense: true,
        border: OutlineInputBorder(
          gapPadding: 0,
          borderRadius: BorderRadius.all(Radius.circular(4)),
          borderSide: BorderSide(
            width: 1,
            style: BorderStyle.none,
          ),
        ),
      ),
    );
  }

  Widget _voiceWidget() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPressStart: (LongPressStartDetails details) {
        audioRecord = AudioRecord();
        audioRecord?.start();
        setState(() {
          _isRecording = true;
        });
      },
      onLongPressEnd: (LongPressEndDetails details) {
        audioRecord?.stop().then((value) {
          File file = File.fromUri(Uri.parse(value!));
          _controller.sendFile(file: file);
        });
        setState(() {
          _isRecording = false;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(5),
        ),
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        child: Center(
          child: _isRecording ? const Text('松手停止') : const Text('按住 说话'),
        ),
      ),
    );
  }

  Widget _menu() {
    double itemWidth = 80;
    //一行数量
    int crossAxisCount = MediaQuery.of(context).size.width ~/ itemWidth;
    int maxMenuCountOfPage = crossAxisCount * 2;
    int pageCount = _list.length ~/ maxMenuCountOfPage;
    if (_list.length % maxMenuCountOfPage > 0) {
      pageCount++;
    }
    List<Widget> pageChildren = [];

    for (int i = 0; i < pageCount; i++) {
      int startIndex = i * maxMenuCountOfPage;
      int endIndex = (i + 1) * maxMenuCountOfPage;
      if (endIndex > _list.length) {
        endIndex = _list.length;
      }

      List<Widget> gridChildren = [];
      for (int j = startIndex; j < endIndex; j++) {
        String title = _list[j];
        gridChildren.add(
          DirectionButton(
            text: Text(title),
            icon: const Icon(Icons.camera),
            imageDirection: AxisDirection.up,
            middlePadding: 10,
            action: () {
              if (title == '照片') {
                _pickImage();
              } else if (title == '拍摄') {
                _pickCamera();
              }
            },
          ),
        );
      }
      pageChildren.add(GridView.count(
        crossAxisCount: crossAxisCount,
        children: gridChildren,
      ));
    }
    return SizeTransition(
      sizeFactor: _animation as Animation<double>,
      child: Container(
        height: 260,
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                children: pageChildren,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPageIndex = page;
                  });
                },
              ),
            ),
            SizedBox(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pageChildren.length,
                  (int index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPageIndex == index
                            ? Colors.blue
                            : Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickImage() async {
    final List<AssetEntity>? result = await AssetPicker.pickAssets(
      context,
      pickerConfig: const AssetPickerConfig(
        requestType: RequestType.image,
        maxAssets: 1,
        // specialPickerType: SpecialPickerType.noPreview,
      ),
    );
    File? file = await result?.first.file;
    _controller.sendFile(file: file!);
  }

  void _pickCamera() async {}
}
