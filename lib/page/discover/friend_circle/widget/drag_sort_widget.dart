import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nine_grid_view/nine_grid_view.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class DragSortWidget extends StatefulWidget {
  @override
  _DragSortWidgetState createState() => _DragSortWidgetState();
}

class _DragSortWidgetState extends State<DragSortWidget> {
  List<ImageBean> imageList = [];
  int moveAction = MotionEvent.actionUp;
  bool _canDelete = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    imageList = Utils.getTestData();
  }

  void _loadAssets(BuildContext context) {
    _pickImage();
  }

  @override
  Widget build(BuildContext context) {
    return DragSortView(
      imageList,
      space: 5,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(0),
      itemBuilder: (BuildContext context, int index) {
        ImageBean bean = imageList[index];
        // It is recommended to use a thumbnail picture
        return Utils.getWidget(bean);
      },
      initBuilder: (BuildContext context) {
        return InkWell(
          onTap: () {
            _loadAssets(context);
          },
          child: Container(
            color: const Color(0XFFCCCCCC),
            child: const Center(
              child: Icon(
                Icons.add,
              ),
            ),
          ),
        );
      },
      onDragListener: (MotionEvent event, double itemWidth) {
        switch (event.action) {
          case MotionEvent.actionDown:
            moveAction = event.action!;
            setState(() {});
            break;
          case MotionEvent.actionMove:
            double x = event.globalX! + itemWidth;
            double y = event.globalY! + itemWidth;
            double maxX = MediaQuery.of(context).size.width - 1 * 100;
            double maxY = MediaQuery.of(context).size.height - 1 * 100;
            print('Sky24n maxX: $maxX, maxY: $maxY, x: $x, y: $y');
            if (_canDelete && (x < maxX || y < maxY)) {
              setState(() {
                _canDelete = false;
              });
            } else if (!_canDelete && x > maxX && y > maxY) {
              setState(() {
                _canDelete = true;
              });
            }
            break;
          case MotionEvent.actionUp:
            moveAction = event.action!;
            if (_canDelete) {
              setState(() {
                _canDelete = false;
              });
              return true;
            } else {
              setState(() {});
            }
            break;
        }
        return false;
      },
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
    setState(() {
      imageList.add(ImageBean.file(file: file));
    });
  }
}

class ImageBean extends DragBean {
  final String? thumbPath;
  final String? originPath;
  final String? middlePath;
  final double? originalWidth;
  final double? originalHeight;
  final File? file;
  ImageBean.url({
    this.thumbPath,
    this.originPath,
    this.middlePath,
    this.originalWidth,
    this.originalHeight,
  }) : file = null;

  ImageBean.file({
    this.file,
    this.originalWidth,
    this.originalHeight,
  })  : thumbPath = null,
        originPath = null,
        middlePath = null;
}

class Utils {
  static String getImgPath(String name) {
    return 'assets/images/$name';
  }

  static Future<T?> pushPage<T extends Object>(
      BuildContext context, Widget page) {
    return Navigator.push(
      context,
      CupertinoPageRoute(builder: (ctx) => page),
    );
  }

  static void showSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static Widget getWidget(ImageBean imageBean) {
    if (imageBean.file != null) {
      return Image.file(imageBean.file!, fit: BoxFit.cover);
    } else if (imageBean.thumbPath?.startsWith('http') == true) {
      //return CachedNetworkImage(imageUrl: url, fit: BoxFit.cover);
      return Image.network(imageBean.thumbPath!, fit: BoxFit.cover);
    }
    //return Image.file(File(url), fit: BoxFit.cover);
    return Image.asset(getImgPath(imageBean.thumbPath!), fit: BoxFit.cover);
  }

  static Image? getBigImage(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http')) {
      //return Image(image: CachedNetworkImageProvider(url), fit: BoxFit.cover);
      return Image.network(url, fit: BoxFit.cover);
    }
    //return Image.file(File(url), fit: BoxFit.cover);
    return Image.asset(getImgPath(url), fit: BoxFit.cover);
  }

  static List<ImageBean> getTestData() {
    List<String> urlList = [
      'video_1.png',
      'video_2.png',
      'video_3.png',
      'video_4.png',
      'video_5.png',
      'video_6.png',
      'video_7.png',
    ];
    List<ImageBean> list = [];
    for (int i = 0; i < urlList.length; i++) {
      String url = urlList[i];
      list.add(ImageBean.url(
        originPath: url,
        middlePath: url,
        thumbPath: url,
        originalWidth: i == 0 ? 264 : null,
        originalHeight: i == 0 ? 258 : null,
      ));
    }
    return list;
  }
}
