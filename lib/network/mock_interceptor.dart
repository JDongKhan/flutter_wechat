import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;

import '../utils/asset_bundle_utils.dart';
import '../utils/logger_util.dart';

/// @author jd

class NetworkMockInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['mock'] == true) {
      final String jsonPath =
          'assets/jsons/${path.basenameWithoutExtension(options.path)}.json';
      final String jsonString = await AssetBundleUtils.loadString(jsonPath);
      if (jsonString.isEmpty) {
        handler.next(options);
        return;
      }
      dynamic json = jsonDecode(jsonString);
      await Future<dynamic>.delayed(const Duration(milliseconds: 1000));
      logger.i('本次模拟的数据来源:$jsonPath\n$json');
      handler.resolve(
        Response<dynamic>(
          requestOptions: options,
          data: json,
          headers: Headers(),
          extra: options.extra,
          statusCode: 200,
        ),
      );
    } else {
      handler.next(options);
    }
  }
}
