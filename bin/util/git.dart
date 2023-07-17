import 'dart:io';

import 'package:flutter_manager/extension/extension_export.dart';
import 'package:flutter_manager/util/print.dart';

import '../commands/custom_command.dart';

/// FileName git
///
/// @Author wangjiong
/// @Date 2023/5/29
///
/// @Description: git相关操作
class Git {
  factory Git() => _instance;

  Git._internal();

  static late final Git _instance = Git._internal();

  /// git clone
  clone(String url, String path, String ref) async {
    final git = " git clone $url $path -b $ref";
    await CustomCommand().run(git);
  }

  /// git checkout
  checkout(String module, String url, String ref, String workingDirectory) async {
    if (workingDirectory.isNullOrBlank || url.isNullOrBlank || ref.isNullOrBlank) {
      return;
    }
    // 获取path路径下的分支
    String? currentBranch = await getBranch(workingDirectory);
    // 1. 本地和配置文件相同时不用切换
    if (currentBranch.isNullOrBlank || currentBranch == ref) {
      printGreen('$module：$currentBranch');
      return;
    }
    // 2. 检查远程仓库中是否存在该分支
    bool remoteBranchExists = await checkRemoteBranchExists(url, ref, workingDirectory);
    if (!remoteBranchExists) {
      printRed("$module:远程仓库中不存在分支：$ref");
      return;
    }

    // 3. 检查是否有本地该分支追踪远程分支
    bool localBranchTrackingRemote = await checkLocalBranchTracksRemote(ref, workingDirectory);

    // 4. 如果远程有本地没有则本地创建并切换，如果本地和远程都有则正常切换
    if (!localBranchTrackingRemote) {
      await createAndCheckoutLocalBranch(module, url, currentBranch, ref, workingDirectory);
    } else {
      await checkoutBranch(module, currentBranch, ref, workingDirectory);
    }
  }

  /// 检查远程仓库中是否存在该分支
  Future<bool> checkRemoteBranchExists(String url, String newBranch, String workingDirectory) async {
    String command = 'ls-remote --exit-code --heads $url $newBranch';
    ProcessResult? result = await _runCommand(command, workingDirectory);
    return result?.exitCode == 0;
  }

  /// 检查是否有本地该分支追踪远程分支
  Future<bool> checkLocalBranchTracksRemote(String newBranch, String workingDirectory) async {
    String command = 'rev-parse --abbrev-ref --symbolic-full-name ${newBranch}@{u}';
    ProcessResult? result = await _runCommand(command, workingDirectory);
    return result?.exitCode == 0;
  }

  /// 创建并切换本地分支
  Future<void> createAndCheckoutLocalBranch(String module, String url, String? currentBranch,
      String newBranch, String workingDirectory) async {
    String commandCreate = 'checkout -b $newBranch origin/$newBranch';
    ProcessResult? resultCreate = await _runCommand(commandCreate, workingDirectory);
    if (resultCreate?.exitCode == 0) {
      printYellow('$module:创建并切换到本地分支：$newBranch');
    } else {
      printRed('$module:创建本地分支失败：${resultCreate?.stderr}');
    }
  }

  /// 切换本地分支
  Future<void> checkoutBranch(
      String module, String? currentBranch, String newBranch, String workingDirectory) async {
    String command = 'checkout $newBranch';
    ProcessResult? result = await _runCommand(command, workingDirectory);
    if (result?.exitCode == 0) {
      printYellow('$module:本地分支$currentBranch切换到$newBranch');
    } else {
      printRed('$module:切换分支失败：${result?.stderr}');
    }
  }

  /// 获取当前分支
  Future<String?> getBranch(String workingDirectory) async {
    String command = 'rev-parse --abbrev-ref HEAD';
    ProcessResult? result = await _runCommand(command, workingDirectory);
    String? currentBranch = result?.stdout?.trim();
    return currentBranch;
  }

  /// 在某个路径下执行一个命令
  Future<ProcessResult?>? _runCommand(String command, String workingDirectory) {
    // 将 Git 命令字符串转换为列表形式
    List<String> commandArgs = command.split(' ');
    // 在指定路径下执行 Git 命令
    // await Process.run('flutter', ['pub', 'get'], workingDirectory: workingDirectory);
    return Process.run("git", commandArgs, workingDirectory: workingDirectory);
  }
}
