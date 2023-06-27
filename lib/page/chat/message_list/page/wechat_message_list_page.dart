import 'package:badges/badges.dart' as badge;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_wechat/utils/asset_bundle_utils.dart';
import 'package:flutter_wechat/widgets/search_bar.dart' as SM;
import 'package:get/get.dart';
import 'package:nine_grid_view/nine_grid_view.dart';

import '../../../../utils/logger_util.dart';
import '../../../../widgets/common_search.dart';
import '../../../../widgets/direction_button.dart';
import '../../../../widgets/pop/pop_widget.dart';
import '../../../scan/scan_page.dart';
import '../../../wechat_main_page.dart';
import '../../chat/page/chat_page.dart';
import '../vm/custom_bouncing_scroll_physics.dart';
import '../vm/wechat_message_list_view_model.dart';
import '../widget/recommend_tags_widget.dart';
import '../widget/wechat_draggable_scrollable_sheet.dart';
import '../widget/wechat_message_list_bottom_menu.dart';

/// @author jd

class WechatMessageListPage extends StatefulWidget {
  @override
  _WechatMessageListPageState createState() => _WechatMessageListPageState();
}

class _WechatMessageListPageState extends State<WechatMessageListPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  late SlidableController _slidableController;
  // final ScrollController _scrollController = ScrollController();
  WechatMessageListViewModel model = Get.put(WechatMessageListViewModel());
  bool _hasSubTitle = true;

  bool _showBackMenu = false;

  Object _groupId = "1";

  final WeChatMessageListBottomMenuController _bottomMenuController =
      WeChatMessageListBottomMenuController(initOpacity: 0);

  late AnimationController _animationController;

  @override
  void initState() {
    _slidableController = SlidableController(this);
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    super.initState();
  }

  //显示主页面
  void _showMainPage() {
    if (!_showBackMenu) {
      return;
    }
    setState(() {
      _animationController.animateTo(1);
      hiddenBottomBar(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ///底部的菜单
        WeChatMessageListBottomMenu(
          controller: _bottomMenuController,
          onChange: (double value) {},
          onBack: () {
            _showMainPage();
          },
        ),

        GetBuilder<WechatMessageListViewModel>(
            assignId: true,
            builder: (vm) {
              return NotificationListener<DraggableScrollableNotification>(
                onNotification: (DraggableScrollableNotification notification) {
                  _bottomMenuController.opacity = 1 - notification.extent;
                  if (notification.extent < 0.1) {
                    hiddenBottomBar(true);
                  } else {
                    hiddenBottomBar(false);
                  }
                  return true;
                },
                child: WechatDraggableScrollableSheet(
                  animationController: _animationController,
                  expand: true,
                  minChildSize: 0.0,
                  maxChildSize: 1,
                  initialChildSize: 1,
                  builder: (
                    BuildContext context,
                    ScrollController scrollController,
                  ) {
                    return _topWidget(scrollController);
                  },
                ),
              );
            }),

        ///上层的列表
      ],
    );
  }

  Widget _topWidget(ScrollController scrollController) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: () {
            _showMainPage();
          },
          child: const Text('微信'),
        ),
        actions: [
          Builder(
            builder: (BuildContext context) => IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {
                _showMenu(context);
              },
            ),
          ),
        ],
      ),
      body: SlidableAutoCloseBehavior(
        child: CustomScrollView(
          controller: scrollController,
          physics: const CustomBouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: SM.SearchBar(
                onTap: () {
                  _showSearch(context);
                },
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  Map item = model.data[index];
                  return _buildListItem(model, item);
                },
                childCount: model.data.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onLoading() {
    print('onLoading');
  }

  void hiddenBottomBar(bool hidden) {
    if (_showBackMenu != hidden) {
      _showBackMenu = hidden;
      WechatMainPage.of(context)?.hiddenBottomNavigationBar(hidden);
    }
  }

  void _showSearch(BuildContext context) {
    showCustomSearch(
      context: context,
      builder: (context, constraints, query) {
        logger.i('开始查询数据:$query');
        if (query.isBlank!) {
          return RecommendTagsWidget(
            onClick: (title) {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return Container();
              }));
            },
          );
        }
        return SearchTagList(
          query: query,
        );
      },
    );
  }

  ///cell布局
  Widget _buildListItem(WechatMessageListViewModel model, Map item) {
    return Slidable(
      key: ObjectKey(item['msg_name']),
      groupTag: _groupId,
      // The start action pane is the one at the left or the top side.
      startActionPane: ActionPane(
        // A motion is a widget used to control how the pane animates.
        motion: const ScrollMotion(),
        // A pane can dismiss the Slidable.
        dismissible: DismissiblePane(onDismissed: () {}),
        // All actions are defined in the children parameter.
        children: [
          // A SlidableAction can have an icon and/or a label.
          SlidableAction(
            onPressed: (c) {},
            backgroundColor: const Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
          SlidableAction(
            onPressed: (c) {},
            backgroundColor: const Color(0xFF21B7CA),
            foregroundColor: Colors.white,
            icon: Icons.share,
            label: 'Share',
          ),
        ],
      ),

      // The end action pane is the one at the right or the bottom side.
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            // An action can be bigger than the others.
            flex: 2,
            onPressed: (c) {},
            backgroundColor: const Color(0xFF7BC043),
            foregroundColor: Colors.white,
            icon: Icons.archive,
            label: 'Archive',
          ),
          SlidableAction(
            onPressed: (c) {},
            backgroundColor: const Color(0xFF0392CF),
            foregroundColor: Colors.white,
            icon: Icons.save,
            label: 'Save',
          ),
        ],
      ),
      child: ListTile(
        onTap: () {
          _clickAtIndex(context, item);
        },
        title: Text(item['msg_name']),
        leading: badge.Badge(
          toAnimate: false,
          showBadge: int.parse(item['msg_count']) > 0,
          badgeContent: Text(
            item['msg_count'],
            style: const TextStyle(color: Colors.white),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: _buildHeadIcon(item),
          ),
        ),
        subtitle: Text(
          item['msg_content'],
        ),
      ),
    );
  }

  Widget _buildHeadIcon(Map item) {
    dynamic icon = item['icon'];
    if (icon is String) {
      return Image.asset(
        AssetBundleUtils.getImgPath(icon),
      );
    } else if (icon is List) {
      List list = icon;
      return NineGridView(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.all(5),
        space: 2,
        type:
            NineGridType.qqGp, //NineGridType.weChatGp, NineGridType.dingTalkGp
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index) {
          return Image.asset(
            AssetBundleUtils.getImgPath(list[index]),
          );
        },
      );
    }

    return Container();
  }

  ///cell布局
  Widget _buildListItem2(WechatMessageListViewModel model, Map item) {
    return Slidable(
      key: ObjectKey(item['msg_name']),
      groupTag: _groupId,
      startActionPane: ActionPane(
        // A motion is a widget used to control how the pane animates.
        motion: const ScrollMotion(),
        // A pane can dismiss the Slidable.
        dismissible: DismissiblePane(onDismissed: () {}),
        // All actions are defined in the children parameter.
        children: [
          // A SlidableAction can have an icon and/or a label.
          SlidableAction(
            onPressed: (c) {},
            backgroundColor: const Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
          SlidableAction(
            onPressed: (c) {},
            backgroundColor: const Color(0xFF21B7CA),
            foregroundColor: Colors.white,
            icon: Icons.share,
            label: 'Share',
          ),
        ],
      ),

      // The end action pane is the one at the right or the bottom side.
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            // An action can be bigger than the others.
            flex: 2,
            onPressed: (c) {},
            backgroundColor: const Color(0xFF7BC043),
            foregroundColor: Colors.white,
            icon: Icons.archive,
            label: 'Archive',
          ),
          SlidableAction(
            onPressed: (c) {},
            backgroundColor: const Color(0xFF0392CF),
            foregroundColor: Colors.white,
            icon: Icons.save,
            label: 'Save',
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
        child: Row(
          children: [
            badge.Badge(
              toAnimate: false,
              showBadge: int.parse(item['msg_count']) > 0,
              badgeContent: Text(
                item['msg_count'],
                style: const TextStyle(color: Colors.white),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.asset(
                  AssetBundleUtils.getImgPath(
                    item['icon'],
                  ),
                  width: 50,
                  height: 50,
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['msg_name'],
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  if (_hasSubTitle)
                    Text(
                      item['msg_content'],
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    )
                  else
                    Container(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///行点击事件
  void _clickAtIndex(BuildContext context, Map map) {
    Navigator.of(context).push(
      CupertinoPageRoute<ChatPage>(
        builder: (BuildContext context) => ChatPage(),
      ),
    );
  }

  ///下拉菜单
  void _showMenu(BuildContext context) {
    showPop(
      right: 10,
      clickCallback: (int index) {
        print(index);
      },
      backgroundColor: const Color(0xffaaaaff),
      barrierColor: const Color(0x00000000),
      width: 110,
      context: context,
      items: [
        DirectionButton(
          imageDirection: AxisDirection.left,
          padding: const EdgeInsets.all(0),
          middlePadding: 10,
          icon: const Icon(
            Icons.comment,
            color: Colors.white,
          ),
          text: const Text(
            '发起群聊',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          action: () {
            setState(() {
              _hasSubTitle = !_hasSubTitle;
            });
          },
        ),
        const DirectionButton(
          imageDirection: AxisDirection.left,
          padding: EdgeInsets.all(0),
          middlePadding: 10,
          icon: Icon(
            Icons.add,
            color: Colors.white,
          ),
          text: Text(
            '添加朋友',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        DirectionButton(
          imageDirection: AxisDirection.left,
          padding: EdgeInsets.all(0),
          middlePadding: 10,
          action: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ScanPage(),
              ),
            );
          },
          icon: const Icon(
            Icons.scanner_rounded,
            color: Colors.white,
          ),
          text: const Text(
            '扫一扫',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        const DirectionButton(
          imageDirection: AxisDirection.left,
          padding: EdgeInsets.all(0),
          middlePadding: 10,
          icon: Icon(
            Icons.payment,
            color: Colors.white,
          ),
          text: Text(
            '收付款',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
