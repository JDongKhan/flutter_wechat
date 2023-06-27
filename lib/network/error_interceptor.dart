import 'package:dio/dio.dart';

import 'app_exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    if (err is AppException) {
      handler.next(err);
      return;
    }
    final AppException appException = AppException.create(err);
    handler.next(appException);
  }
}
