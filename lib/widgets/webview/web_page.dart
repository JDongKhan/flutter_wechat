import 'package:flutter/material.dart';

import 'src/web_view_adapter.dart';

/// @author jd

///web page
class WebPage extends StatelessWidget {
  const WebPage({
    super.key,
    required this.url,
    this.title,
    this.hideAppBar,
    this.hideAppBarExt,
  });
  final String? title;
  final String url;
  final bool? hideAppBar;
  //true 默认设置高度为1
  final bool? hideAppBarExt;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: webViewPlatformAdapter.createWebView(
        url,
        title: title,
        hideAppBar: hideAppBar,
        hideAppBarExt:hideAppBarExt,
      ),
    );
  }
}
