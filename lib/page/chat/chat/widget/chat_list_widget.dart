import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import '../controller/chat_controller.dart';

class ChartListWidget extends StatefulWidget {
  const ChartListWidget({
    Key? key,
    required this.itemBuilder,
    required this.itemCount,
    this.scrollController,
  }) : super(key: key);
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final ScrollController? scrollController;
  @override
  State<ChartListWidget> createState() => _ChartListWidgetState();
}

class _ChartListWidgetState extends State<ChartListWidget> {
  late ListObserverController observerController;
  late ChatScrollObserver chatObserver;
  late ScrollController _scrollController;
  final ChatController _controller = Get.find<ChatController>();
  @override
  void initState() {
    _scrollController = widget.scrollController ?? ScrollController();
    observerController = ListObserverController(controller: _scrollController)
      ..cacheJumpIndexOffset = false;

    chatObserver = ChatScrollObserver(observerController)
      ..fixedPositionOffset = 5
      ..toRebuildScrollViewCallback = () {
        setState(() {});
      }
      ..onHandlePositionCallback = (type) {};

    _controller.chatObserver = chatObserver;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildListView();
  }

  Widget _buildListView() {
    Widget resultWidget = ListView.builder(
      physics: ChatObserverBouncingScrollPhysics(observer: chatObserver),
      padding: const EdgeInsets.only(left: 10, right: 10, top: 15, bottom: 15),
      shrinkWrap: chatObserver.isShrinkWrap,
      reverse: true,
      controller: _scrollController,
      itemBuilder: (c, idx) {
        return widget.itemBuilder(c, idx);
      },
      itemCount: widget.itemCount,
    );
    resultWidget = CustomRefreshIndicator(
      builder: MaterialIndicatorDelegate(
        builder: (context, controller) {
          return const CupertinoActivityIndicator();
        },
      ),
      trigger: IndicatorTrigger.trailingEdge,
      onRefresh: _controller.onLoad,
      child: resultWidget,
    );

    resultWidget = ListViewObserver(
      controller: observerController,
      child: resultWidget,
    );
    resultWidget = Align(
      alignment: Alignment.topCenter,
      child: resultWidget,
    );
    return resultWidget;
  }
}
