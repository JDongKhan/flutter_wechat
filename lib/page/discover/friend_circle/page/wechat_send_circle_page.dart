import 'package:flutter/material.dart';

import '../widget/drag_sort_widget.dart';

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
      backgroundColor: Colors.black87,
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTextField(),
                  DragSortWidget(),
                  _buildOtherItem(
                      icon: Icons.location_on_outlined, title: '所在位置'),
                  _buildOtherItem(
                      icon: Icons.people_alt_outlined, title: '提醒谁看'),
                  _buildOtherItem(
                      icon: Icons.location_on_outlined, title: '谁可以看'),
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(backgroundColor: Colors.green),
              child: const Text(
                '发表',
                style: TextStyle(color: Colors.white),
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
      child: TextField(
        keyboardType: TextInputType.text,
        maxLines: 5,
        minLines: 1,
        textInputAction: TextInputAction.send,
        onSubmitted: (value) {
          _textEditingController.text = '';
        },
        style: const TextStyle(color: Colors.white),
        focusNode: _focusNode,
        controller: _textEditingController,
        decoration: const InputDecoration(
          hintText: '这一刻的想法',
          filled: true,
          border: InputBorder.none,
          isCollapsed: true, //相当于高度包裹的意思，必须为true，不然有默认的最小高度
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          // isDense: true,
        ),
      ),
    );
  }

  Widget _buildOtherItem({IconData? icon, String? title}) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            title ?? '',
            style: TextStyle(color: Colors.white),
          ),
          const Spacer(),
          const Icon(
            Icons.arrow_forward_ios_outlined,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
