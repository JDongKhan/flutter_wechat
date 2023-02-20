import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_wechat/extension/extension_function.dart';
import 'package:flutter_wechat/page/message_list/message_detail/widget/bubble_widget.dart';
import 'package:flutter_wechat/page/picture_overview/picture_overview.dart';
import 'package:flutter_wechat/utils/asset_bundle_utils.dart';
import 'package:get/get.dart';
import '../controller/chat_controller.dart';
import '../model/wechat_message.dart';
import 'chat_list_widget.dart';
import 'chat_unread_tip_view.dart';

/// @author jd

class DoctorMessageListWidget extends StatefulWidget {
  const DoctorMessageListWidget({super.key, required this.scrollController});
  final ScrollController scrollController;
  @override
  State createState() => _DoctorMessageListWidgetState();
}

class _DoctorMessageListWidgetState extends State<DoctorMessageListWidget> {
  final ChatController _controller = Get.find<ChatController>();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: (notification) {
        if (notification is ScrollNotification) {
          if (notification.metrics is PageMetrics) {
            return false;
          }
          if (notification.metrics is FixedScrollMetrics) {
            if (notification.metrics.axisDirection == AxisDirection.left ||
                notification.metrics.axisDirection == AxisDirection.right) {
              return false;
            }
          }

          ///取到这个值
          double extentAfter = notification.metrics.extentAfter;
          double offset = notification.metrics.pixels;
          bool showTips = offset > 0;
          bool loadMore = extentAfter <= 20;
          // if (loadMore) {
          //   _controller.onLoad.throttleWithTimeout(timeout: 2000).call();
          // }
          if (offset < 10) {
            _controller.clearUnRead.debounce().call();
          }
          debugPrint('showTips:$showTips');
          if (showTips != _controller.showUnReadTip.value) {
            _controller.showUnReadTip.value = showTips;
          }
        }
        return false;
      },
      child: Stack(
        children: [
          Positioned.fill(child: _buildScrollWidget()),
          Positioned(
            bottom: 0,
            right: 0,
            child: Obx(() {
              if (_controller.showUnReadTip.value) {
                return ChatUnreadTipView(
                  onTap: () {
                    widget.scrollController.jumpTo(
                        widget.scrollController.position.maxScrollExtent);
                  },
                  unreadMsgCount: _controller.unReadCount.value,
                );
              }
              return Container();
            }),
          )
        ],
      ),
    );
  }

  Widget _buildScrollWidget() {
    return GetBuilder<ChatController>(
      builder: (c) {
        return _buildListWidget(c);
      },
    );
  }

  Widget _buildListWidget(ChatController controller) {
    return ChartListWidget(
      scrollController: widget.scrollController,
      itemBuilder: (c, index) {
        Message m = controller.data[index];
        return Container(
          padding:
              const EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
          child: m.isMe ? _myMessage(m) : _otherMessage(m),
        );
      },
      itemCount: controller.data.length,
    );
  }

  Widget _otherMessage(Message m) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: AssetImage(
                AssetBundleUtils.getImgPath('user_head_1'),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 10, right: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('xiao ming'),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(m.time ?? ''),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                BubbleWidget(
                  child: _buildItemWidget(m),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _myMessage(Message m) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.only(left: 50, right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(m.time ?? ''),
                BubbleWidget(
                  direction: BubbleDirection.right,
                  child: _buildItemWidget(m),
                ),
              ],
            ),
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: AssetImage(
                AssetBundleUtils.getImgPath('user_head_0'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemWidget(Message m) {
    if (m.image != null) {
      return Image.asset(
        AssetBundleUtils.getImgPath('shop_0.png'),
        width: 200,
      );
    }
    if (m.file != null) {
      return GestureDetector(
        onTap: () {
          _preview(ImagePreviewModel.file(m.file));
        },
        child: Image.file(
          m.file!,
          width: 200,
        ),
      );
    }
    return Text(m.message ?? '');
  }

  void _preview(ImagePreviewModel image) {
    PictureOverview.preview(context: context, imageItems: [image]);
  }
}
