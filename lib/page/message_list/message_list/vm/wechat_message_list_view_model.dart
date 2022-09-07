import 'package:flutter_wechat/base/base_list_controller.dart';

import '../../../../network/network_utils.dart';

/// @author jd

class WechatMessageListViewModel extends BaseListController {
  @override
  Future<List> loadData() async {
    NetworkResponse response =
        await Network.get('http://baidu.com/message_list.do', mock: true);
    List list = response.data;
    return list;
  }
}
