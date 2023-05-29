import 'package:test/test.dart';

import '../bin/commands/mvm/module_tree_structure.dart';

/// FileName test
///
/// @Author wangjiong
/// @Date 2023/2/28
///

void main() async {
  test('从某个子节点到根节点的所有路径中相邻子父节点对', () {
    // 构造一个树结构
    ModuleTreeNode nodeG = ModuleTreeNode('G');
    ModuleTreeNode nodeD = ModuleTreeNode('D', [nodeG]);
    ModuleTreeNode nodeE = ModuleTreeNode('E', [nodeG]);
    ModuleTreeNode nodeF = ModuleTreeNode('F', [nodeG]);
    ModuleTreeNode nodeC = ModuleTreeNode('C', [nodeF]);
    ModuleTreeNode nodeB = ModuleTreeNode('B', [nodeD, nodeE, nodeF]);
    ModuleTreeNode nodeA = ModuleTreeNode('A', [nodeB, nodeC]);

    // 查找从节点 'F' 到根节点的所有路径中相邻子父节点对
    List<List<String>> result = findNodePathsToRoot(nodeA, 'G');

    // 输出结果
    for (var path in result) {
      for (var i = 0; i < path.length - 1; i++) {
        print('${path[i + 1]} -> ${path[i]}');
      }
      print('---------');
    }
  });

  test("根据map的value分组", () {
    Map<String, List<String>> groupByValue(Map<String, String> inputMap) {
      Map<String, List<String>> groupedMap = {};

      inputMap.forEach((key, value) {
        groupedMap.putIfAbsent(value, () => []).add(key);
      });

      return groupedMap;
    }

    Map<String, String> inputMap = {
      'A': '1',
      'B': '2',
      'C': '1',
      'D': '3',
    };

    Map<String, List<String>> groupedMap = groupByValue(inputMap);
    expect(groupedMap['1'], ["A", "C"]);
    expect(groupedMap['2'], ["B"]);
    expect(groupedMap['3'], ["D"]);
  });
}
