import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../controller/chat_controller.dart';
import '../widget/doctor_input_message_widget.dart';
import '../widget/doctor_message_list_widget.dart';

/// @author jd

class DoctorChatPage extends StatefulWidget {
  const DoctorChatPage({super.key});

  @override
  State createState() => _DoctorChatPageState();
}

class _DoctorChatPageState extends State<DoctorChatPage> {
  final DoctorInputMessageController _inputMessageController =
      DoctorInputMessageController();

  final ScrollController _scrollController = ScrollController();
  late ChatController _controller;

  @override
  void initState() {
    _controller = Get.put(ChatController(scrollController: _scrollController));
    super.initState();
  }

  @override
  void dispose() {
    GetInstance().delete<ChatController>();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;
    return Scaffold(
      body: Column(
        children: [
          Obx(
            () {
              double bottomHeight = 0;
              PreferredSizeWidget? bottom;
              if (!Get.find<ChatController>().isConnected.value) {
                bottomHeight = 10;
                bottom = PreferredSize(
                  preferredSize: Size(100, bottomHeight),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      '未连接',
                      style: Theme.of(context).appBarTheme.toolbarTextStyle,
                    ),
                  ),
                );
              }
              double appBarMaxHeight =
                  kToolbarHeight + bottomHeight + topPadding;
              return Container(
                constraints: BoxConstraints(maxHeight: appBarMaxHeight),
                child: AppBar(
                  primary: true,
                  title: const Text(
                    '图文问诊',
                  ),
                  bottom: bottom,
                  actions: [
                    TextButton(
                      onPressed: () {
                        _controller.receiveMessage('测试');
                      },
                      child: Text(
                        '模拟添加数据',
                        style: Theme.of(context).appBarTheme.toolbarTextStyle,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  _inputMessageController.hiddenKeyboard();
                },
                child: DoctorMessageListWidget(
                  scrollController: _scrollController,
                ),
              ),
            ),
          ),
          DoctorInputMessageWidget(
            controller: _inputMessageController,
          ),
        ],
      ),
    );
  }

  ///自定义的目的是最小化的刷新appbar，如果使用Scaffold的appbar无法支持obx
  Widget _buildAppBar({
    bool primary = false,
    required Widget title,
    Widget? bottom,
    List<Widget> actions = const [],
  }) {
    ThemeData theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 0),
      color: theme.appBarTheme.backgroundColor,
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Container(
              width: 150,
              alignment: Alignment.centerLeft,
              child: BackButton(
                color: theme.appBarTheme.titleTextStyle?.color,
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    title,
                    bottom ?? const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
            Container(
              width: 150,
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: actions,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
