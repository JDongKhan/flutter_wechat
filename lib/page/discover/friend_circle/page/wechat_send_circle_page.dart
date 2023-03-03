import 'package:flutter/material.dart';

class WeChatSendCirclePage extends StatefulWidget {
  const WeChatSendCirclePage({Key? key}) : super(key: key);

  @override
  State<WeChatSendCirclePage> createState() => _WeChatSendCirclePageState();
}

class _WeChatSendCirclePageState extends State<WeChatSendCirclePage> {
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> _imageList = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTextField(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: Colors.black,
      child: SafeArea(
        child: Row(
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                '取消',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return Container(
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xffeeeeee),
        ),
      ),
      child: TextField(
        keyboardType: TextInputType.text,
        maxLines: 5,
        minLines: 1,
        textInputAction: TextInputAction.send,
        onSubmitted: (value) {
          _textEditingController.text = '';
        },
        focusNode: _focusNode,
        controller: _textEditingController,
        decoration: const InputDecoration(
          hintText: '这一刻的想法',
          filled: true,
          fillColor: Colors.white,
          border: InputBorder.none,
          isCollapsed: true, //相当于高度包裹的意思，必须为true，不然有默认的最小高度
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          // isDense: true,
        ),
      ),
    );
  }

  // Widget _buildNineGrid() {
  //   return DragSortView(
  //     _imageList,
  //     space: 5,
  //     margin: const EdgeInsets.all(20),
  //     padding: const EdgeInsets.all(0),
  //     itemBuilder: (BuildContext context, int index) {},
  //     initBuilder: (BuildContext context) {},
  //     onDragListener: (MotionEvent event, double itemWidth) {
  //       /// Judge to drag to the specified position to delete
  //       /// return true;
  //       if (event.globalY > 600) {
  //         return true;
  //       }
  //       return false;
  //     },
  //   );
  // }
}
