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
@end

@implementation ZKTreeManager

- (instancetype)initWithNodes:(NSArray<ZKTreeNode *> *)nodes andExpandLevel:(NSInteger)level
{
    if (self = [super init]) {
        
        // 1. 建立 MAP
        [self setupNodesMapByNodes:nodes];
        
        // 2. 建立父子关系，并得到顶级节点
        [self setupTopNodes];
        
        // 3. 设置等级（如需）
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
    self.allNodes = nodes.mutableCopy;
    
    NSMutableDictionary *nodesMap = @{}.mutableCopy;
    for (ZKTreeNode *node in nodes) {
        [nodesMap setObject:node forKey:node.ID];
        if (node.level != -1) _flag = NO;
    }
    self.nodesMap = nodesMap.mutableCopy;
}

// 建立父子关系，并得到顶级节点
- (void)setupTopNodes
{
    // 建立父子关系
    NSMutableArray *topNodes = @[].mutableCopy;
    self.minLevel = (self.allNodes.count > 0) ? self.allNodes[0].level : 0;
    
    for (ZKTreeNode *node in self.allNodes) {
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
        if (!_flag) {
            self.minLevel = MIN(node.level, self.minLevel);
            self.maxLevel = MAX(node.level, self.maxLevel);
        }
    }
    // 排序
    self.topNodes = [topNodes sortedArrayUsingComparator:^NSComparisonResult(ZKTreeNode *node1, ZKTreeNode *node2) {
        NSNumber *num1 = [NSNumber numberWithInteger:[node1.orderNo integerValue]];
        NSNumber *num2 = [NSNumber numberWithInteger:[node2.orderNo integerValue]];
        return [num1 compare:num2];
    }].mutableCopy;
}

// 设置等级
- (void)setupNodesLevel
{
    if (!_flag) return;
    
    for (ZKTreeNode *node in self.allNodes) {
        NSInteger tempLevel = 0;
        ZKTreeNode *parentNode = node.parentNode;
        while (parentNode) {
            tempLevel ++;
            parentNode = parentNode.parentNode;
        }
        node.level = tempLevel;
        self.minLevel = MIN(self.minLevel, tempLevel);
        self.maxLevel = MAX(self.maxLevel, tempLevel);
    }
}

// 根据展开等级设置 showNodes
- (void)setupShowNodesWithShowLevel:(NSInteger)level
{
    self.showLevel = MAX(level, 0);
    self.showLevel = MIN(level, self.maxLevel);
    
    NSMutableArray *showNodes = @[].mutableCopy;
    for (ZKTreeNode *node in self.topNodes) {
        [self addNode:node toShowNodes:showNodes andAllowShowLevel:self.showLevel];
    }
    self.showNodes = showNodes;
}

- (void)addNode:(ZKTreeNode *)node toShowNodes:(NSMutableArray *)showNodes andAllowShowLevel:(NSInteger)level
{
    if (node.level > level) return;
    
    [showNodes addObject:node];
    
    node.expand = (node.level != level);
    node.childNodes = [node.childNodes sortedArrayUsingComparator:^NSComparisonResult(ZKTreeNode *node1, ZKTreeNode *node2) {
        NSNumber *num1 = [NSNumber numberWithInteger:[node1.orderNo integerValue]];
        NSNumber *num2 = [NSNumber numberWithInteger:[node2.orderNo integerValue]];
        return [num1 compare:num2];
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
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange([self.showNodes indexOfObject:node] + 1, tempMutArray.count)];
        [self.showNodes insertObjects:tempMutArray atIndexes:indexSet];
    } else { // 折叠
        for (ZKTreeNode *tempNode in self.showNodes) {
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
        [self.showNodes removeObjectsInArray:tempMutArray];
    }
    
    return tempMutArray.count;
}

- (void)addNode:(ZKTreeNode *)node toTmpNodes:(NSMutableArray *)tmpNodes
{
    [tmpNodes addObject:node];
    
    node.childNodes = [node.childNodes sortedArrayUsingComparator:^NSComparisonResult(ZKTreeNode *node1, ZKTreeNode *node2) {
        NSNumber *num1 = [NSNumber numberWithInteger:[node1.orderNo integerValue]];
        NSNumber *num2 = [NSNumber numberWithInteger:[node2.orderNo integerValue]];
        return [num1 compare:num2];
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
        for (NSInteger i = 0; i < self.showNodes.count; i++) {
            ZKTreeNode *node = self.showNodes[i];
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
        for (NSInteger i = 0; i < self.showNodes.count; i++) {
            ZKTreeNode *node = self.showNodes[i];
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

- (void)insertNodes:(NSArray<ZKTreeNode *> *)nodes atIndex:(NSInteger)index
{
    // 1.查找目标位置节点
    ZKTreeNode *node = self.showNodes[index];
    // 2.构建一个临时管理者
    ZKTreeManager *tempManager = [[ZKTreeManager alloc] initWithNodes:nodes andExpandLevel:NSIntegerMax];
    // 3.校验插入层级合法性
    if ((node.level + 1 < tempManager.minLevel) || ((node.level == tempManager.minLevel) && node.isExpand && (node.childNodes.count != 0)) || (tempManager.minLevel < node.level)) {
        NSAssert(0, @"插入层级错误");
    }
    // 4.建立父子关系
    NSInteger tempTopCount = tempManager.topNodes.count;
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index + 1, tempManager.showNodes.count)];
    if (tempManager.minLevel == 0) {
        // 重置序号
        NSInteger index = [self.topNodes indexOfObject:node];
        for (NSInteger i = index + 1; i < self.topNodes.count; i++) {
            ZKTreeNode *tempNode = self.topNodes[i];
            [self node:tempNode resetOrderNo:(i + tempTopCount)];
        }
        for (NSInteger i = 0; i < tempTopCount; i++) {
            ZKTreeNode *tempNode = tempManager.topNodes[i];
            [self node:tempNode resetOrderNo:(i + index + 1)];
        }
        // 插入数据
        [self.topNodes insertObjects:tempManager.topNodes atIndexes:indexSet];
    } else {
        if (node.level < tempManager.minLevel) {
            node.expand = YES;
            for (NSInteger i = 0; i < tempTopCount; i++) {
                ZKTreeNode *tempNode = tempManager.topNodes[i];
                tempNode.parentNode = node;
                [self node:tempNode resetOrderNo:i];
            }
            for (NSInteger i = 0; i < node.childNodes.count; i++) {
                ZKTreeNode *tempNode = node.childNodes[i];
                [self node:tempNode resetOrderNo:(i + tempTopCount)];
            }
            NSIndexSet *tempIndexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, tempManager.topNodes.count)];
            [node.childNodes insertObjects:tempManager.topNodes atIndexes:tempIndexSet];
        } else {
            NSInteger index = [node.parentNode.childNodes indexOfObject:node];
            for (NSInteger i = index + 1; i < node.parentNode.childNodes.count; i++) {
                ZKTreeNode *tempNode = node.parentNode.childNodes[i];
                [self node:tempNode resetOrderNo:(i + tempTopCount)];
            }
            for (NSInteger i = 0; i < tempTopCount; i++) {
                ZKTreeNode *tempNode = tempManager.topNodes[i];
                tempNode.parentNode = node.parentNode;
                [self node:tempNode resetOrderNo:(i + index + 1)];
            }
            NSIndexSet *tempIndexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index + 1, tempManager.topNodes.count)];
            [node.parentNode.childNodes insertObjects:tempManager.topNodes atIndexes:tempIndexSet];
        }
    }
    // 5.重置最大最小值
    self.minLevel = MIN(self.minLevel, tempManager.minLevel);
    self.maxLevel = MAX(self.maxLevel, tempManager.maxLevel);
    self.showLevel = MAX(self.showLevel, tempManager.showLevel);
    // 6.数据合并
    self.nodesMap = [self dictionaryByMerging:self.nodesMap with:tempManager.nodesMap];
    [self.allNodes addObjectsFromArray:tempManager.allNodes];
    [self.showNodes insertObjects:tempManager.showNodes atIndexes:indexSet];
}

- (void)node:(ZKTreeNode *)node resetOrderNo:(NSInteger)orderNo
{
    NSString *orderNoStr = [NSString stringWithFormat:@"%zd", orderNo];
    [node setValue:orderNoStr forKey:@"orderNo"];
}

// 合并两个字典
- (NSMutableDictionary *)dictionaryByMerging:(NSDictionary *)dict1 with:(NSDictionary *)dict2
{
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:dict1];
    NSMutableDictionary *resultTemp = [NSMutableDictionary dictionaryWithDictionary:dict1];
    [resultTemp addEntriesFromDictionary:dict2];
    [resultTemp enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
        if ([dict1 objectForKey:key]) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                NSDictionary *newVal = [self dictionaryByMerging:[dict1 objectForKey:key] with:(NSDictionary *)obj];
                [result setObject:newVal forKey:key];
            } else {
                [result setObject:obj forKey:key];
            }
        } else if([dict2 objectForKey:key]) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                NSDictionary *newVal = [self dictionaryByMerging:[dict2 objectForKey:key] with:(NSDictionary *)obj];
                [result setObject:newVal forKey:key];
            } else {
                [result setObject:obj forKey:key];
            }
        }
    }];
    return [result mutableCopy];
}

// 根据 ID 获取 node
- (ZKTreeNode *)getNodeWithNodeID:(NSString *)ID
{
    return (ID ? self.nodesMap[ID] : nil);
}

@end
