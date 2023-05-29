/// FileName module_tree_structure
///
/// @Author wangjiong
/// @Date 2023/5/23
///
/// @Description: 组件树结构化模型

/// 树结构
class ModuleTreeNode {
  /// 模块名
  final String name;

  /// 当前结点的所有子节点
  final List<ModuleTreeNode> children;

  ModuleTreeNode(this.name, [this.children = const []]);
}

/// 找到某个节点到根节点的所有路径
/// 递归进行深度优先搜索，将找到的路径添加到paths列表中
List<List<String>> findNodePathsToRoot(ModuleTreeNode root, String targetNodeName) {
  List<List<String>> paths = [];

  void traverse(ModuleTreeNode node, List<String> currentPath) {
    currentPath.add(node.name);

    if (node.name == targetNodeName) {
      paths.add(List.from(currentPath.reversed));
    }

    for (var child in node.children) {
      traverse(child, currentPath);
    }

    currentPath.removeLast();
  }

  traverse(root, []);

  return paths;
}
