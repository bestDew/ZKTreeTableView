//
//  ZKTreeManager.m
//  ZKTreeListViewDemo
//
//  Created by bestdew on 2018/9/5.
//  Copyright © 2018年 bestdew. All rights reserved.
//
//                      d*##$.
// zP"""""$e.           $"    $o
//4$       '$          $"      $
//'$        '$        J$       $F
// 'b        $k       $>       $
//  $k        $r     J$       d$
//  '$         $     $"       $~
//   '$        "$   '$E       $
//    $         $L   $"      $F ...
//     $.       4B   $      $$$*"""*b
//     '$        $.  $$     $$      $F
//      "$       R$  $F     $"      $
//       $k      ?$ u*     dF      .$
//       ^$.      $$"     z$      u$$$$e
//        #$b             $E.dW@e$"    ?$
//         #$           .o$$# d$$$$c    ?F
//          $      .d$$#" . zo$>   #$r .uF
//          $L .u$*"      $&$$$k   .$$d$$F
//           $$"            ""^"$$$P"$P9$
//          JP              .o$$$$u:$P $$
//          $          ..ue$"      ""  $"
//         d$          $F              $
//         $$     ....udE             4B
//          #$    """"` $r            @$
//           ^$L        '$            $F
//             RN        4N           $
//              *$b                  d$
//               $$k                 $F
//               $$b                $F
//                 $""               $F
//                 '$                $
//                  $L               $
//                  '$               $
//                   $               $

#import "ZKTreeManager.h"
#import "ZKTreeNode.h"

@interface ZKTreeManager ()
{
    BOOL _flag; // 判断是否需要计算等级的标识
}
@property (nonatomic, strong) NSDictionary *nodesMap;
@property (nonatomic, strong) NSMutableArray<ZKTreeNode *> *topNodesMutArray;  // 根节点数组
@property (nonatomic, strong) NSMutableArray<ZKTreeNode *> *allNodesMutArray;  // 全部节点数组
@property (nonatomic, strong) NSMutableArray<ZKTreeNode *> *showNodesMutArray; // 已展示的节点数组
@property (nonatomic, assign) NSInteger maxLevel;   // 最大等级
@property (nonatomic, assign) NSInteger showLevel;  // 展开的最大等级

@end

@implementation ZKTreeManager

#pragma mark -- 初始化
- (instancetype)initWithNodes:(NSArray<ZKTreeNode *> *)nodes andExpandLevel:(NSInteger)level
{
    if (self = [super init]) {
        
        // 1. 建立 MAP
        [self setupNodesMapByNodes:nodes];
        
        // 2. 建立父子关系，并得到顶级节点
        [self setupTopNodes];
        
        // 3. 设置等级
        [self setupNodesLevel];
        
        // 4. 根据展开等级设置 showNodes
        [self setupShowNodesWithShowLevel:level];
    }
    return self;
}

// 建立 MAP
- (void)setupNodesMapByNodes:(NSArray *)nodes
{
    _flag = YES;
    NSMutableDictionary *nodesMap = @{}.mutableCopy;
    for (ZKTreeNode *node in nodes) {
        [nodesMap setObject:node forKey:node.ID];
        if (node.level != -1) _flag = NO;
    }
    self.nodesMap = nodesMap.copy;
}

// 建立父子关系，并得到顶级节点
- (void)setupTopNodes
{
    self.allNodesMutArray = self.nodesMap.allValues.mutableCopy;
    
    // 建立父子关系
    NSMutableArray *topNodes = @[].mutableCopy;
    for (ZKTreeNode *node in self.allNodesMutArray) {
        node.expand = NO;
        if ([node.parentID isKindOfClass:[NSString class]]) {
            ZKTreeNode *parentNode = self.nodesMap[node.parentID];
            if (parentNode) {
                node.parentNode = parentNode;
                if (![parentNode.childNodes containsObject:node]) {
                    [parentNode.childNodes addObject:node];
                }
            }
        }
        if (!node.parentNode) [topNodes addObject:node];
        if (!_flag) self.maxLevel = MAX(node.level, self.maxLevel);
    }
    // 排序
    self.topNodesMutArray = [topNodes sortedArrayUsingComparator:^NSComparisonResult(ZKTreeNode *node1, ZKTreeNode *node2) {
        return [node1.orderNo compare:node2.orderNo];
    }].mutableCopy;
}

// 设置等级
- (void)setupNodesLevel
{
    if (!_flag) return;
    
    for (ZKTreeNode *node in self.allNodesMutArray) {
        NSInteger tempLevel = 0;
        ZKTreeNode *parentNode = node.parentNode;
        while (parentNode) {
            tempLevel ++;
            parentNode = parentNode.parentNode;
        }
        node.level = tempLevel;
        self.maxLevel = MAX(self.maxLevel, tempLevel);
    }
}

// 根据展开等级设置 showNodes
- (void)setupShowNodesWithShowLevel:(NSInteger)level
{
    self.showLevel = MAX(level, 0);
    self.showLevel = MIN(level, self.maxLevel);
    
    NSMutableArray *showNodes = @[].mutableCopy;
    for (ZKTreeNode *node in self.topNodesMutArray) {
        [self addNode:node toShowNodes:showNodes andAllowShowLevel:self.showLevel];
    }
    self.showNodesMutArray = showNodes;
}

- (void)addNode:(ZKTreeNode *)node toShowNodes:(NSMutableArray *)showNodes andAllowShowLevel:(NSInteger)level
{
    if (node.level > level) return;
    
    [showNodes addObject:node];
    
    node.expand = (node.level != level);
    node.childNodes = [node.childNodes sortedArrayUsingComparator:^NSComparisonResult(ZKTreeNode *node1, ZKTreeNode *node2) {
        return [node1.orderNo compare:node2.orderNo];
    }].mutableCopy;
    
    for (ZKTreeNode *childNode in node.childNodes) {
        [self addNode:childNode toShowNodes:showNodes andAllowShowLevel:level];
    }
}

#pragma mark -- Expand Node
// 展开/收起 node，返回所改变的 node 的个数
- (NSInteger)expandNode:(ZKTreeNode *)node
{
    return [self expandNode:node expand:!node.isExpand];
}

- (NSInteger)expandNode:(ZKTreeNode *)node expand:(BOOL)isExpand
{
    if (node.isExpand == isExpand) return 0;
    
    node.expand = isExpand;
    NSMutableArray *tempMutArray = @[].mutableCopy;
    
    if (isExpand) { // 展开
        for (ZKTreeNode *tempNode in node.childNodes) {
            [self addNode:tempNode toTmpNodes:tempMutArray];
        }
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange([self.showNodesMutArray indexOfObject:node] + 1, tempMutArray.count)];
        [self.showNodesMutArray insertObjects:tempMutArray atIndexes:indexSet];
    } else { // 折叠
        for (ZKTreeNode *tempNode in self.showNodesMutArray) {
            BOOL isParent = NO;
            ZKTreeNode *parentNode = tempNode.parentNode;
            while (parentNode) {
                if (parentNode == node) {
                    isParent = YES;
                    break;
                }
                parentNode = parentNode.parentNode;
            }
            if (isParent) [tempMutArray addObject:tempNode];
        }
        [self.showNodesMutArray removeObjectsInArray:tempMutArray];
    }
    
    return tempMutArray.count;
}

- (void)addNode:(ZKTreeNode *)node toTmpNodes:(NSMutableArray *)tmpNodes
{
    [tmpNodes addObject:node];
    
    node.childNodes = [node.childNodes sortedArrayUsingComparator:^NSComparisonResult(ZKTreeNode *node1, ZKTreeNode *node2) {
        return [node1.orderNo compare:node2.orderNo];
    }].mutableCopy;
    
    if (!node.isExpand) return;
    
    for (ZKTreeNode *tmpNode in node.childNodes) {
        [self addNode:tmpNode toTmpNodes:tmpNodes];
    }
}

// 展开/折叠到多少层级
- (void)expandNodesWithLevel:(NSInteger)expandLevel completed:(void (^)(NSArray *))noExpandCompleted andCompleted:(void (^)(NSArray *))expandCompleted
{
    expandLevel = MAX(expandLevel, 0);
    expandLevel = MIN(expandLevel, self.maxLevel);
    
    // 先一级一级折叠
    for (NSInteger level = self.maxLevel; level >= expandLevel; level--) {
        NSMutableArray *nodesArray = @[].mutableCopy;
        for (NSInteger i = 0; i < self.showNodesMutArray.count; i++) {
            ZKTreeNode *node = self.showNodesMutArray[i];
            if (node.isExpand && node.level == level) {
                [nodesArray addObject:node];
            }
        }
        if (nodesArray.count) {
            if (noExpandCompleted) {
                noExpandCompleted(nodesArray);
            }
        }
    }
    
    // 再一级一级展开
    for (NSInteger level = 0; level < expandLevel; level++) {
        NSMutableArray *nodesArray = @[].mutableCopy;
        for (NSInteger i = 0; i < self.showNodesMutArray.count; i++) {
            ZKTreeNode *node = self.showNodesMutArray[i];
            if (!node.isExpand && node.level == level) {
                [nodesArray addObject:node];
            }
        }
        if (nodesArray.count) {
            if (expandCompleted) {
                expandCompleted(nodesArray);
            }
        }
    }
}

// 根据 ID 获取 node
- (ZKTreeNode *)getNodeWithNodeID:(NSString *)ID
{
    return (ID ? self.nodesMap[ID] : nil);
}

- (NSArray<ZKTreeNode *> *)showNodes
{
    return self.showNodesMutArray;
}

- (NSArray<ZKTreeNode *> *)allNodes
{
    return self.allNodesMutArray;
}

@end
