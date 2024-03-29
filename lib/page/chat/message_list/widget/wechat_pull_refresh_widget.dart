import 'package:flutter/material.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';

/// @author jd

///下拉刷新
Widget wechatBuildPulltoRefreshImage(
    BuildContext context, PullToRefreshScrollNotificationInfo info) {
  var offset = 0.0;
  if (info != null && info.dragOffset != null) {
    offset = info.dragOffset!;
  }
  Widget refreshWidget = Container();
  if (info != null && info.refreshWidget != null && offset > 100) {
    refreshWidget = info.refreshWidget!;
  }

  String mode = '下拉刷新';
  if (info != null && info.mode != null) {
    PullToRefreshIndicatorMode modeEnum = info.mode!;
    switch (modeEnum) {
      case PullToRefreshIndicatorMode.refresh:
        mode = '刷新中...';
        break;
      case PullToRefreshIndicatorMode.done:
        mode = '刷新成功';
        break;
      case PullToRefreshIndicatorMode.canceled:
        mode = '刷新取消';
        break;
      case PullToRefreshIndicatorMode.error:
        mode = '刷新错误';
        break;
    }
  }
  print('pull-offset:$offset');
  return SliverToBoxAdapter(
    child: Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: offset,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              refreshWidget,
              Container(
                padding: const EdgeInsets.only(left: 5.0),
                alignment: Alignment.center,
                child: Text(
                  mode,
                  style: const TextStyle(
                    fontSize: 12,
                    inherit: false,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
