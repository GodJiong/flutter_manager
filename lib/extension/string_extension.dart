/// FileName string_extension
///
/// @Author wangjiong
/// @Date 2023/7/17
///
/// @Description: String扩展函数

extension StringExtension on String? {
  bool get isBlank => this?.trim().length == 0;

  bool get isNotBlank => !this.isBlank;

  bool get isNullOrEmpty => this == null || this?.isEmpty == true;

  bool get isNullOrBlank => this == null || this.isBlank;
}
