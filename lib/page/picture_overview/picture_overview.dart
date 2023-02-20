import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_wechat/style/push_animation_style.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImagePreviewModel {
  final File? file;
  final String? url;
  late ImageProvider image;
  ImagePreviewModel({this.file, this.url});
  ImagePreviewModel.file(this.file)
      : url = null,
        image = FileImage(file!);
  ImagePreviewModel.url(this.url)
      : file = null,
        image = NetworkImage(url!);
}

class PictureOverview extends StatefulWidget {
  final List<ImagePreviewModel> imageItems; //图片列表
  final int defaultIndex; //默认第几张
  final Axis direction; //图片查看方向
  final BoxDecoration? decoration; //背景设计

  const PictureOverview({
    super.key,
    required this.imageItems,
    this.defaultIndex = 0,
    this.direction = Axis.horizontal,
    this.decoration,
  });

  static void preview({
    required BuildContext context,
    required List<ImagePreviewModel> imageItems,
  }) {
    Navigator.of(context).push(
      ScaleRouter(
        child: PictureOverview(
          imageItems: imageItems,
        ),
      ),
    );
  }

  @override
  State<PictureOverview> createState() => _PictureOverviewState();
}

class _PictureOverviewState extends State<PictureOverview> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.defaultIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: widget.imageItems[index].image,
              );
            },
            scrollDirection: widget.direction,
            itemCount: widget.imageItems.length,
            backgroundDecoration:
                widget.decoration ?? const BoxDecoration(color: Colors.black),
            pageController: PageController(initialPage: widget.defaultIndex),
            onPageChanged: (index) => setState(
              () {
                currentIndex = index;
              },
            ),
          ),
          Positioned(
            bottom: 20,
            child: Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                child: Text("${currentIndex + 1}/${widget.imageItems.length}",
                    style: const TextStyle(
                      decoration: TextDecoration.none,
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      shadows: [
                        Shadow(color: Colors.black, offset: Offset(1, 1)),
                      ],
                    ))),
          ),
          Positioned(
            //右上角关闭
            top: 40,
            right: 40,
            child: Container(
              alignment: Alignment.centerLeft,
              width: 20,
              child: GestureDetector(
                onTap: () {
                  //隐藏预览
                  Navigator.pop(context);
                },
                child: const Icon(Icons.close_rounded, color: Colors.white),
              ),
            ),
          ),
          Positioned(
            //数量显示
            right: 20,
            top: 20,
            child: Text(
              '${currentIndex + 1}/${widget.imageItems.length}',
              style: const TextStyle(color: Colors.black),
            ),
          )
        ],
      ),
    );
  }
}
