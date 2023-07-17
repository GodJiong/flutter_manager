import '../constant/constant_export.dart';

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

/// 输出红色提示
printRed(String msg) {
  print("$console_red$msg$console_default");
}

/// 输出绿色提示
printGreen(String msg) {
  print("$console_green$msg$console_default");
}

/// 输出黄色提示
printYellow(String msg) {
  print("$console_yellow$msg$console_default");
}
