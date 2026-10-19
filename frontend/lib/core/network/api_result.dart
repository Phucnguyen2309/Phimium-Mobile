import 'package:dio/dio.dart';

/// Sealed class for handling API results
sealed class ApiResult<T> {
  const ApiResult();
}

class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  const ApiSuccess(this.data);
}

class ApiError<T> extends ApiResult<T> {
  final String message;
  final int? statusCode;
  const ApiError(this.message, {this.statusCode});
}

/// Extension to convert DioException to ApiError
extension DioExceptionHandler on DioException {
  String get errorMessage {
    switch (type) {
      case DioExceptionType.connectionTimeout:
        return 'Kết nối hết thời gian. Vui lòng thử lại.';
      case DioExceptionType.sendTimeout:
        return 'Gửi yêu cầu hết thời gian. Vui lòng thử lại.';
      case DioExceptionType.receiveTimeout:
        return 'Nhận phản hồi hết thời gian. Vui lòng thử lại.';
      case DioExceptionType.badResponse:
        return _handleBadResponse(response?.statusCode);
      case DioExceptionType.cancel:
        return 'Yêu cầu đã bị hủy.';
      case DioExceptionType.connectionError:
        return 'Không có kết nối mạng. Vui lòng kiểm tra lại.';
      default:
        return 'Đã xảy ra lỗi. Vui lòng thử lại.';
    }
  }

  String _handleBadResponse(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Yêu cầu không hợp lệ.';
      case 401:
        return 'Phiên đăng nhập đã hết. Vui lòng đăng nhập lại.';
      case 403:
        return 'Bạn không có quyền truy cập.';
      case 404:
        return 'Không tìm thấy dữ liệu.';
      case 409:
        return 'Dữ liệu đã tồn tại.';
      case 422:
        return 'Dữ liệu không hợp lệ.';
      case 500:
        return 'Lỗi máy chủ. Vui lòng thử lại sau.';
      default:
        return 'Đã xảy ra lỗi ($statusCode).';
    }
  }
}
