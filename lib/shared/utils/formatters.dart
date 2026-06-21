import '../../core/constants/app_constants.dart';

abstract final class Formatters {
  static String currency(num value) {
    return '${AppConstants.defaultCurrencyCode} ${value.toStringAsFixed(2)}';
  }
}
