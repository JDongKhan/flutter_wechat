import 'package:flutter_wechat/base/base_list_controller.dart';

import '../../../../network/network_utils.dart';

/// @author jd

class WechatFriendCircleViewModel extends BaseListController {
  @override
  Future<List> loadData() async {
    NetworkResponse response =
        await Network.get('http://baidu.com/friend_circle.do', mock: true);
    return response.data;
  }
}
