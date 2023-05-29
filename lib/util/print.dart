/// FileName print
///
/// @Author wangjiong
/// @Date 2023/5/29
///
/// @Description: 统一管理日志

/// 日志控制
bool GLOBAL_PRINT_ENABLE = true;

/// 打印日志
dPrint(Object? object) {
  if (!GLOBAL_PRINT_ENABLE) {
    return;
  }
  print(object);
}
