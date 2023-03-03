import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../widgets/no_splash_factory.dart';

///@Description TODO
///@Author jd

class RecommendTagsWidget extends StatefulWidget {
  const RecommendTagsWidget({
    Key? key,
    this.onClick,
  }) : super(key: key);
  final ValueChanged? onClick;

  @override
  State<RecommendTagsWidget> createState() => _RecommendTagsWidgetState();
}

class _RecommendTagsWidgetState extends State<RecommendTagsWidget> {
  bool showMore = true;

  final List<String> _tags = [
    '手机耳机',
    '冬季连衣裙',
    '毛线半身裙',
    '充电宝',
    '文艺青年专属装备',
    '面包',
    '方便面',
    '面包',
    '文艺青年专属装备',
    '面包',
    '方便面',
    '面包',
    '文艺青年专属装备',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                '最近搜索',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                Icons.delete,
                size: 18,
              ),
            ],
          ),
          Expanded(
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(top: 10),
              child: FlowWidget(
                spacing: 10,
                showMore: showMore,
                moreWidget: Container(
                  width: 40,
                  color: Colors.transparent,
                  child: _buildCustomButton(
                      onPressed: () {
                        setState(() {
                          showMore = !showMore;
                        });
                      },
                      child: Icon(
                        showMore
                            ? Icons.keyboard_arrow_down_rounded
                            : Icons.keyboard_arrow_up_rounded,
                        color: const Color(0xff686E7E),
                      )),
                ),
                children: _tags
                    .map(
                      (e) => _flowMenuItem(e),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //生成Popmenu数据
  Widget _flowMenuItem(String text) {
    return _buildCustomButton(
      onPressed: () {
        widget.onClick?.call(text);
      },
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black,
        ),
      ),
      style: TextButton.styleFrom(
        backgroundColor: const Color(0xffEDEEF2),
      ),
    );
  }

  Widget _buildCustomButton(
      {required Widget child, VoidCallback? onPressed, ButtonStyle? style}) {
    return SizedBox(
      height: 40,
      child: TextButton(
        onPressed: () {
          onPressed?.call();
        },
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xffEDEEF2),
          splashFactory: NoSplashFactory(),
        ),
        child: child,
      ),
    );
  }
}

class SearchTagList extends StatelessWidget {
  const SearchTagList({
    Key? key,
    this.query,
    this.tags,
  }) : super(key: key);

  final String? query;
  final List<String>? tags;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView.builder(
        itemBuilder: (context, idx) {
          return ListTile(
            title: RichText(
              text: TextSpan(
                  children: _getTextSpanList(
                'index:$idx',
                searchText: query ?? '',
              )),
            ),
          );
        },
        itemCount: 10,
      ),
    );
  }

  List<TextSpan> _getTextSpanList(
    String text, {
    String searchText = '',
    double fontSize = 14.0,
    Color fontColor = Colors.black,
    Color selectedColor = const Color(0xff2457F2),
  }) {
    List<TextSpan> textSpanList = [];
    final TextStyle normalTextStyle =
        TextStyle(fontSize: fontSize, color: fontColor);
    final TextStyle showTextStyle =
        TextStyle(fontSize: fontSize, color: selectedColor);

    if (searchText != null &&
        searchText.isNotEmpty &&
        text.contains(searchText)) {
      List<String> strList = [];
      bool _isContains = true;
      String targetText = text;
      while (_isContains) {
        int startIndex = targetText.indexOf(searchText);
        if (startIndex > 0) {
          String normalStr = targetText.substring(0, startIndex);
          textSpanList.add(TextSpan(
            text: normalStr,
            style: normalTextStyle,
          ));

          String showStr =
              targetText.substring(startIndex, startIndex + searchText.length);

          textSpanList.add(TextSpan(
            text: showStr,
            style: showTextStyle,
          ));
          targetText = targetText.substring(
              startIndex + searchText.length, targetText.length);
        } else {
          _isContains = false;
          textSpanList.add(TextSpan(
            text: targetText,
            style: normalTextStyle,
          ));
        }
      }
    } else {
      textSpanList.add(TextSpan(
        text: text,
        style: normalTextStyle,
      ));
    }
    return textSpanList;
  }
}

class FlowWidget extends StatelessWidget {
  const FlowWidget({
    Key? key,
    required this.children,
    this.spacing = 0,
    this.showMore = true,
    this.moreWidget,
  }) : super(key: key);
  final List<Widget> children;
  final double spacing;
  final bool showMore;
  final Widget? moreWidget;
  @override
  Widget build(BuildContext context) {
    if (moreWidget != null) children.add(moreWidget!);
    return Flow(
      delegate: MyFlowDelegate(
          spacing: spacing,
          showMore: showMore,
          hasMoreWidget: moreWidget != null),
      children: children,
    );
  }
}

class MyFlowDelegate extends FlowDelegate {
  MyFlowDelegate({
    this.spacing = 0,
    this.showMore = true,
    this.hasMoreWidget = false,
  });
  final double spacing;
  final bool showMore;
  final bool hasMoreWidget;
  @override
  void paintChildren(FlowPaintingContext context) {
    var screenWidth = context.size.width;
    double offsetX = 0; //x坐标
    double offsetY = 0; //Y坐标

    int currentRow = 0; //行数
    double maxHeight = 0;

    int totalCount = context.childCount;
    for (int i = 0; i < totalCount; i++) {
      Size size1 = context.getChildSize(i) ?? Size.zero;
      double childWidth = size1.width;
      var maxX = offsetX + childWidth + spacing;
      maxHeight = max(maxHeight, size1.height);
      if (maxX < screenWidth) {
        //不需要换行
        debugPrint('第$i,$offsetX , $offsetY');
        //是否显示更多按钮
        if (showMore && hasMoreWidget) {
          //显示更多时判断后面还有并且加上后面的超出父组件大小直接布局最后一个
          if (i < totalCount - 1) {
            Size nextSize = context.getChildSize(i + 1) ?? Size.zero;
            if ((maxX + nextSize.width) > screenWidth && offsetY > 0) {
              debugPrint('当前第$i,后面的要超出了请注意！');
              context.paintChild(totalCount - 1,
                  transform: Matrix4.translationValues(offsetX, offsetY, 0.0));
              break;
            }
          }
        }
        //行数大于2并且是最后一个 直接跳出不要再布局了
        if (hasMoreWidget) {
          if (currentRow < 2 && i == totalCount - 1) {
            break;
          }
        }
        context.paintChild(i,
            transform: Matrix4.translationValues(offsetX, offsetY, 0.0));
        offsetX = maxX;
      } else {
        currentRow++;
        //换行
        offsetY = offsetY + maxHeight + spacing;
        debugPrint('第$i,$offsetX , $offsetY');
        context.paintChild(i,
            transform: Matrix4.translationValues(0, offsetY, 0.0));
        offsetX = 0 + childWidth + spacing;
      }
    }
  }

  @override
  bool shouldRepaint(covariant FlowDelegate oldDelegate) {
    return oldDelegate != this;
  }

  @override
  Size getSize(BoxConstraints constraints) {
    return Size(double.infinity, constraints.maxHeight);
  }
}
