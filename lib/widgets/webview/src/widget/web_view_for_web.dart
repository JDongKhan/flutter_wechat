import 'dart:html';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class WebViewForWeb extends StatelessWidget {
  final String url;
  final String? title;
  final bool? hideAppBar;
  const WebViewForWeb({
    Key? key,
    required this.url,
    this.title,
    this.hideAppBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String newUrl = url;
    if (!url.startsWith('http') && !kDebugMode) {
      newUrl = "assets/$url";
    }
    final IFrameElement iframeElement = IFrameElement();
    iframeElement.src = newUrl;
    iframeElement.style.border = 'none';
// ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'iframeElement',
      (int viewId) => iframeElement,
    );
    Widget? leftWidget;
    if (Navigator.canPop(context)) {
      leftWidget = _buildAppBarLeft(context);
    }
    return Column(
      children: [
        if (hideAppBar != true)
          _commonAppBar(
            title: title ?? '',
            leftWidget: leftWidget,
          ),
        Expanded(
          child: HtmlElementView(
            key: UniqueKey(),
            viewType: 'iframeElement',
          ),
        ),
      ],
    );
  }

  ///通用APP bar 统一后退键
  Widget _buildAppBarLeft(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Container(
        // color: Colors.red,
        padding: const EdgeInsets.only(left: 20, right: 0),
        alignment: Alignment.centerLeft,
        child: const Icon(
          Icons.arrow_back_ios,
        ),
      ),
    );
  }

  Widget _commonAppBar({
    Widget? leftWidget,
    String? title,
    List<Widget>? rightWidget,
    Color bgColor = Colors.white,
  }) {
    return Container(
      color: bgColor,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 44,
          // color: Colors.blue,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              leftWidget ?? Container(),
              Expanded(
                child: Text(
                  '$title',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              if (rightWidget != null) ...rightWidget,
            ],
          ),
        ),
      ),
    );
  }
}
