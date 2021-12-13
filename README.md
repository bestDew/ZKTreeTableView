# ⚠️已停止维护，使用需谨慎⚠️



# ZKTreeListView

## 树状结构列表

 ![](https://github.com/bestDew/ZKTreeTableView/raw/master/ZKTreeTableView/Untitled.gif)
 
## 重要事项

 构建一个树结构，需要一些必要的参数：<br/>ID：当前节点唯一标识<br/>parentID：即为父节点的ID<br/>sortOrder：层级内子节点序号，用于排序
 
## 框架结构

 本框架主要包含四大类：
 
 * ZKTreeNode：节点数据模型。用于将原始数据转化为节点数据模型
   
 * ZKTreeManager：数据模型管理类。核心类，用于构建树结构，提供对节点数据的增、删、改、查功能（非线程安全）
 
 * ZKTreeListViewCell：cell视图类。自定义cell时需继承此类
 
 * ZKTreeListView：主视图类。用于将数据操作可视化
 
 ## 代码示例

 ```ObjectiveC
 
 // ...初始化ZKTreeListView，并设置其代理
 // ...实现其代理方法：- (ZKTreeListViewCell *)treeListView:(ZKTreeListView *)listView cellForNode:(ZKTreeNode *)node    atIndexPath:(NSIndexPath *)indexPath;
 // ...网络请求拿到原始数据：dataArray
 
 NSMutableArray *nodes = @[].mutableCopy;
 for (NSDictionary *data in dataArray) {
     // 1.字典转模型（你自己的数据模型）
     Model *model = [Model modelWithDict:data];
     // 2.构建节点数据模型
     ZKTreeNode *node = [ZKTreeNode nodeWithID:ID parentID:pID sortOrder:sortOrder data:model];
     // 后台未返回level时，可不设置，内部会自动计算
     node.level = level;
     /**
     框架目前暂不支持自适应行高，建议提前计算好行高，有助于提升性能
     注意：行高的计算依赖于level，若后台未返回level，此项可不设置，通过以下代理方法返回行高（此时level已内部自动设置）:
     - (CGFloat)treeListView:(ZKTreeListView *)listView rowHeightForNode:(ZKTreeNode *)node atIndexPath:(NSIndexPath *)indexPath
     此代理方法会在每次返回时为node.rowHeight赋值，避免重复计算带来的性能消耗
     */
     node.rowHeight = rowHeight;
     // 如需子节点分页显示，可设置此项，需后台返回每个节点的子节点总数
     node.childNodesCount = [model.childs_count integerValue];
     
     [nodes addObject:node];
 }
 // 3.加载数据
 /**
 若首次加载数据，使用：[_listView loadNodes:nodes];
 若在根节点追加数据，比如上拉加载更多可以使用：[_listView appendNodes:nodes]; 或 [_listView appendChildNodes:nodes node:nil];两种方式
 两种方法的区别是：-appendNodes：分组，而 -appendChildNodes:node:不会；在根节点追加数据时推荐使用前者，在子节点追加数据时只能使用后者
 */
 
 ```
 
 详细使用参见Demo，注释写得很清楚。
 
## 不足

 由于树状结构列表使用范围较窄，并且与业务耦合严重，所以框架目前的可定制化程度不高。如果本框架不能满足项目需求，可将 ZKTreeNode 和 ZKTreeManager 单独抽离使用，自己去实现视图类。
 
## 感谢

如果对你有帮助，烦劳给颗星，谢谢😘
