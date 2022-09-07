import 'package:flutter/material.dart';

/// @author jd
///

typedef ClickCallBack = void Function(int selectIndex);

//支持自定义 pop 菜单

void showPop({
  required BuildContext context,
  required List<Widget> items,
  double? top,
  double? left,
  double? right,
  double width = 100,
  double cellHeight = 40,
  Color backgroundColor = Colors.white,
  Color dividerColor = const Color(0xFFE6E6E6),
  required Color barrierColor,
  bool hiddenArrow = false,
  bool barrierDismissible = true,
  ClickCallBack? clickCallback,
}) {
  Widget _buildMenuLineCell(dataArr) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView.separated(
        itemCount: dataArr.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
              onTap: () {
                Navigator.pop(context);
                if (clickCallback != null) {
                  clickCallback(index);
                }
              },
              child: Container(
                height: cellHeight,
                margin: EdgeInsets.only(
                  left: 10,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: dataArr[index],
                ),
              ));
        },
        separatorBuilder: (context, index) {
          return Divider(
            height: 0.1,
            color: dividerColor,
          );
        },
      ),
    );
  }

  showPopView(
    context: context,
    widget: _buildMenuLineCell(items),
    top: top,
    left: left,
    right: right,
    width: width,
    height: cellHeight * items.length,
    backgroundColor: backgroundColor,
    barrierColor: barrierColor,
    hiddenArrow: hiddenArrow,
    barrierDismissible: barrierDismissible,
  );
}

//
// static void showPopView({
//   @required BuildContext context,
//   Widget widget,
//   double top,
//   double left,
//   double right,
//   double width = 120,
//   double height,
//   Color backgroundColor = Colors.white,
//   bool hiddenArrow = false,
// }) {
//   _buildMenusView() {
//     return Positioned(
//       right: right,
//       left: left,
//       top: top,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: <Widget>[
//           if (!hiddenArrow)
//             Container(
//               padding: EdgeInsets.only(right: 10),
//               child: TriangleUpWidget(height: 10, width: 14),
//             ),
//           ClipRRect(
//               borderRadius: BorderRadius.circular(5),
//               child: Container(
//                 color: backgroundColor,
//                 width: width,
//                 height: height,
//                 child: widget,
//               ))
//         ],
//       ),
//     );
//   }
//   showDialog(
//       context: context,
//       barrierDismissible: false,
//       barrierColor: Colors.transparent,
//       builder: (context) {
//         return BasePopMenus(child: _buildMenusView());
//       });
// }

void showPopView({
  required BuildContext context,
  Widget? widget,
  double? top,
  double? left,
  double? right,
  double width = 100,
  double? height,
  Color backgroundColor = Colors.white,
  required Color barrierColor,
  bool hiddenArrow = false,
  bool barrierDismissible = true,
}) {
  RenderBox renderBox = context.findRenderObject() as RenderBox;
  Rect position = renderBox.localToGlobal(Offset.zero) & renderBox.size;
  if (top == null) {
    top = position.bottom;
  }
  if ((left == null && right == null)) {
    left = position.left - renderBox.size.width;
  }

  _buildMenusView() {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned(
            top: top,
            left: left,
            right: right,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                if (!hiddenArrow)
                  Container(
                    padding: EdgeInsets.only(right: 10),
                    child: TriangleUpWidget(height: 10, width: 14,color:backgroundColor),
                  ),
                ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Container(
                      color: backgroundColor,
                      width: width,
                      height: height,
                      child: widget,
                    ))
              ],
            ),
          ),
        ],
      ),
    );
  }

  int animalType = -1;

  showGeneralDialog(
    barrierDismissible: barrierDismissible,
    barrierLabel: 'menus',
    barrierColor: barrierColor,
    context: context,
    transitionDuration: Duration(milliseconds: 200),
    transitionBuilder: (BuildContext c, Animation<double> animation,
        Animation<double> secondaryAnimation, Widget child) {
      if (animalType == 0) {
        return FadeTransition(
          opacity: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.fastOutSlowIn,
          )),
          child: child,
        );
      } else if (animalType == 1) {
        return ScaleTransition(
          scale: Tween(
            begin: 0.0,
            end: 1.0,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
          ),
          child: child,
        );
      } else if (animalType == 2) {
        return RotationTransition(
          turns: Tween(
            begin: 0.0,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.fastOutSlowIn,
            ),
          ),
          child: child,
        );
      } else if (animalType == 3) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(-1.0, 0.0),
            end: Offset(0.0, 0.0),
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.fastOutSlowIn,
            ),
          ),
          child: child,
        );
      }
      return SizeTransition(
        sizeFactor: Tween<double>(begin: 0.1, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.linear,
          ),
        ),
        child: child,
      );
    },
    pageBuilder: (BuildContext c, Animation<double> animation,
        Animation<double> secondaryAnimation) {
      return _buildMenusView();
    },
  );
}

class BasePopMenus extends Dialog {
  BasePopMenus({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          GestureDetector(onTap: () => Navigator.pop(context)),
          child,
        ],
      ),
    );
  }
}

class TriangleUpPainter extends CustomPainter {
  Color? color; //填充颜色
  late Paint _paint; //画笔
  late Path _path; //绘制路径
  double? angle; //角度

  TriangleUpPainter(Color color) {
    _paint = Paint()
      ..strokeWidth = 1.0 //线宽
      ..color = color
      ..isAntiAlias = true;
    _path = Path();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final baseX = size.width;
    final baseY = size.height;
    //起点
    _path.moveTo(baseX * 0.5, 0);
    _path.lineTo(baseX, baseY);
    _path.lineTo(0, baseY);
    canvas.drawPath(_path, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class TriangleUpWidget extends StatefulWidget {
  double height;
  double width;
  Color color;

  TriangleUpWidget({
    Key? key,
    this.height = 14,
    this.width = 16,
    this.color = Colors.white,
  }) : super(key: key);

  @override
  CoreTriangleState createState() => CoreTriangleState();
}

class CoreTriangleState extends State<TriangleUpWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: widget.height,
        width: widget.width,
        child: CustomPaint(
          painter: TriangleUpPainter(widget.color),
        ));
  }
}
