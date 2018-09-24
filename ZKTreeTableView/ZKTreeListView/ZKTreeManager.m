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

static NSString * const kTailIDPrefix = @"node_tail_";

@interface ZKTreeManager ()
{
    BOOL _flag; // 判断是否需要计算等级的标识
    NSInteger _defaultExpandLevel; // 默认展开的等级
}
/** key 为节点 ID，value为对应的 node */
@property (nonatomic, strong) NSMutableDictionary<NSString *, ZKTreeNode *> *nodesMap;
/** 所有根节点 */
@property (nonatomic, strong) NSMutableArray<ZKTreeNode *> *rootNodes;

@end

@implementation ZKTreeManager

#pragma mark -- Init
+ (instancetype)managerWithNodes:(NSArray<ZKTreeNode *> *)nodes minLevel:(NSInteger)minLevel expandLevel:(NSInteger)expandLevel
{
    return [[self alloc] initWithNodes:nodes minLevel:minLevel expandLevel:expandLevel];
}

- (instancetype)initWithNodes:(NSArray<ZKTreeNode *> *)nodes minLevel:(NSInteger)minLevel expandLevel:(NSInteger)expandLevel
{
    if (self = [super init]) {
        
        _minLevel = minLevel;
        _maxLevel = minLevel;
        _allNodes = [NSMutableSet setWithArray:nodes];
        _flag = ([nodes firstObject].level == -1);
        
        // 1.建立映射
        [self bulidMap];
        // 2.建立父子关系
        [self bulidRelationship];
        // 3.设置等级
        [self setupLevel];
        // 4.子节点排序
        [self sortChildNodes];
        // 5. 根据展开等级设置 showNodes
        [self setupShowNodesWithExpandLevel:expandLevel];
    }
    return self;
}

- (void)bulidMap
{
    _nodesMap = [NSMutableDictionary dictionaryWithCapacity:_allNodes.count];
    for (ZKTreeNode *node in _allNodes) {
        [_nodesMap setObject:node forKey:node.ID];
        if (!_flag) _maxLevel = MAX(_maxLevel, node.level);
    }
}

- (void)bulidRelationship
{
    NSMutableArray *tempMutArray = [NSMutableArray array];
    for (ZKTreeNode *node in _allNodes) {
        if (node.parentID) {
            ZKTreeNode *parentNode = _nodesMap[node.parentID];
            if (parentNode) {
                node.parentNode = parentNode;
                if (![parentNode.childNodes containsObject:node]) {
                    [parentNode.childNodes addObject:node];
                }
            }
        }
        if (!node.parentNode) [tempMutArray addObject:node];
    }
    // 根节点排序
    _rootNodes = [self sortedNodes:tempMutArray];
}

- (void)setupLevel
{
    if (!_flag) return;
    
    for (ZKTreeNode *node in _allNodes) {
        NSInteger level = _minLevel;
        ZKTreeNode *parentNode = node.parentNode;
        while (parentNode) {
            level ++;
            parentNode = parentNode.parentNode;
        }
        node.level = level;
        _maxLevel = MAX(_maxLevel, level);
    }
}

- (void)sortChildNodes
{
    NSSet *tempSet = _allNodes.copy;
    for (ZKTreeNode *node in tempSet) {
        node.childNodes = [self sortedNodes:node.childNodes];
        if (node.childNodesCount > node.childNodes.count) {
            [self addTailForNode:node];
        }
    }
}

- (void)addTailForNode:(ZKTreeNode *)node
{
    // 没有子节点时不添加
    if (node.childNodesCount <= 0) return;
    
    // 已存在不添加
    ZKTreeNode *lastNode = [node.childNodes lastObject];
    if ([lastNode.ID hasPrefix:kTailIDPrefix]) return;
    // 添加尾巴
    ZKTreeNode *tail = [self tailForNode:node];
    [node.childNodes addObject:tail];
    [_nodesMap setObject:tail forKey:tail.ID];
    [_allNodes addObject:tail];
    node.childNodesCount ++;
}

- (ZKTreeNode *)tailForNode:(ZKTreeNode *)node
{
    NSInteger order = node.order;
    NSString *ID = [NSString stringWithFormat:@"%@%@", kTailIDPrefix, node.ID];
    ZKTreeNode *tail = [[ZKTreeNode alloc] initWithID:ID
                                             parentID:node.ID
                                            sortOrder:(order ++)
                                                 data:nil];
    tail.level = node.level + 1;
    tail.rowHeight = 34.f;
    tail.parentNode = node;
    
    return tail;
}

- (void)setupShowNodesWithExpandLevel:(NSInteger)level
{
    level = MAX(level, _minLevel);
    level = MIN(level, _maxLevel);
    _showLevel = level;
    _defaultExpandLevel = level;
    
    NSMutableArray *showNodes = [NSMutableArray array];
    for (ZKTreeNode *node in _rootNodes) {
        [self addShowNode:node toShowNodes:showNodes andShowLevel:level];
    }
    _showNodes = showNodes;
}

#pragma mark -- Public Methods
- (void)addChildNodes:(NSArray<ZKTreeNode *> *)nodes forNode:(ZKTreeNode *)node placedAtTop:(BOOL)isTop
{
    if (nodes.count <= 0) return;
    
    // 1.构建一个临时管理者
    NSInteger minLevel = node ? (node.level + 1) : _minLevel;
    ZKTreeManager *tempManager = [ZKTreeManager managerWithNodes:nodes minLevel:minLevel expandLevel:_defaultExpandLevel];
    // 2.建立父子关系
    NSInteger tempRootNodesCount = tempManager.rootNodes.count;
    if (isTop) { // 追加在头部
        NSInteger tempMaxOrder = [tempManager.rootNodes lastObject].order;
        if (node == nil) { // 根节点
            // 重置序号
            for (ZKTreeNode *tempNode in _rootNodes) {
                NSInteger index = [_rootNodes indexOfObject:tempNode];
                [tempNode setValue:@(tempMaxOrder + index + 1) forKey:@"order"];
            }
            // 插入数据
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, tempRootNodesCount)];
            [_rootNodes insertObjects:tempManager.rootNodes atIndexes:indexSet];
            [_showNodes insertObjects:tempManager.showNodes atIndexes:indexSet];
        } else { // 子节点
            // 1.重置序号并建立父子关系
            for (ZKTreeNode *tempNode in node.childNodes) {
                NSInteger index = [node.childNodes indexOfObject:tempNode];
                [tempNode setValue:@(tempMaxOrder + index + 1) forKey:@"order"];
            }
            for (ZKTreeNode *tempNode in tempManager.rootNodes) {
                tempNode.parentNode = node;
            }
            // 2.插入数据
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, tempRootNodesCount)];
            [node.childNodes insertObjects:tempManager.rootNodes atIndexes:indexSet];
            // 3.判断子节点是否全部加载完
            ZKTreeNode *lastChildnode = [node.childNodes lastObject];
            if (node.childNodesCount <= node.childNodes.count) {
                if ([lastChildnode.ID hasPrefix:kTailIDPrefix]) {
                    [self deleteNode:lastChildnode];
                }
            }
            // 4.重新设置 showNodes
            if (node.isExpand) {
                NSInteger location = [_showNodes indexOfObject:node] + 1;
                NSIndexSet *showIndexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(location, tempManager.showNodes.count)];
                [self.showNodes insertObjects:tempManager.showNodes atIndexes:showIndexSet];
            }
        }
    } else { // 追加在末尾
        if (node == nil) { // 根节点
            // 重置序号
            NSInteger location = [_rootNodes lastObject].order + 1;
            for (ZKTreeNode *tempNode in tempManager.rootNodes) {
                NSInteger i = [tempManager.rootNodes indexOfObject:tempNode];
                [tempNode setValue:@(location + i) forKey:@"order"];
            }
            // 插入数据
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(location, tempRootNodesCount)];
            [_rootNodes insertObjects:tempManager.rootNodes atIndexes:indexSet];
            [_showNodes addObjectsFromArray:tempManager.showNodes];
        } else { // 子节点
            // 1.增加/删除尾巴
            ZKTreeNode *lastChildnode = [node.childNodes lastObject];
            if ([lastChildnode.ID hasPrefix:kTailIDPrefix]) {
                [self deleteNode:lastChildnode];
                node.childNodesCount --;
            }
            if (node.childNodesCount > (node.childNodes.count + tempRootNodesCount)) {
                ZKTreeNode *tail = [self tailForNode:node];
                [tempManager.nodesMap setObject:tail forKey:tail.ID];
                [tempManager.allNodes addObject:tail];
                [tempManager.showNodes insertObject:tail atIndex:tempRootNodesCount];
                [tempManager.rootNodes addObject:tail];
                tempRootNodesCount ++;
                node.childNodesCount ++;
            }
            // 2.重置序号并建立父子关系
            NSArray<ZKTreeNode *> *childNodeArray = node.childNodes.copy;
            NSInteger location = [childNodeArray lastObject].order + 1;
            for (ZKTreeNode *tempNode in tempManager.rootNodes) {
                NSInteger i = [tempManager.rootNodes indexOfObject:tempNode];
                tempNode.parentNode = node;
                [tempNode setValue:@(location + i) forKey:@"order"];
            }
            // 3.插入数据
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(childNodeArray.count, tempRootNodesCount)];
            [node.childNodes insertObjects:tempManager.rootNodes atIndexes:indexSet];
            
            if (node.isExpand) {
                NSMutableArray *tempMutArray = [NSMutableArray array];
                for (ZKTreeNode *tempNode in childNodeArray) {
                    [self addNode:tempNode toMutableArray:tempMutArray flag:YES];
                }
                NSInteger location = [_showNodes indexOfObject:node] + tempMutArray.count + 1;
                NSIndexSet *showIndexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(location, tempManager.showNodes.count)];
                [self.showNodes insertObjects:tempManager.showNodes atIndexes:showIndexSet];
            }
        }
    }
    // 4.重置最大等级
    _maxLevel = MAX(_maxLevel, tempManager.maxLevel);
    
    // 5.数据合并
    [_allNodes unionSet:tempManager.allNodes];
    [_nodesMap addEntriesFromDictionary:tempManager.nodesMap];
}

- (void)deleteNode:(ZKTreeNode *)node
{
    if (![_allNodes containsObject:node]) return;
    
    // 1.解除父子关系
    if (node.parentNode) [node.parentNode.childNodes removeObject:node];
    // 2.从数据源中删除节点及其子节点
    [self removeNode:node];
    // 3.设置当前展示的最大 level
    NSInteger level = [self maxLevelWithNodes:_showNodes];
    _showLevel = MIN(_showLevel, level);
}

- (NSInteger)expandNode:(ZKTreeNode *)node expand:(BOOL)isExpand
{
    if (node.isExpand == isExpand) return 0;
    
    node.expand = isExpand;
    NSMutableArray<ZKTreeNode *> *tempMutArray = [NSMutableArray array];
    
    if (isExpand) { // 展开
        for (ZKTreeNode *tempNode in node.childNodes) {
            [self addNode:tempNode toMutableArray:tempMutArray flag:YES];
        }
        NSInteger location = [_showNodes indexOfObject:node] + 1;
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(location, tempMutArray.count)];
        [_showNodes insertObjects:tempMutArray atIndexes:indexSet];
        _showLevel = MAX(_showLevel, [tempMutArray lastObject].level);
    } else { // 折叠
        for (ZKTreeNode *tempNode in _showNodes) {
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
        [_showNodes removeObjectsInArray:tempMutArray];
        
        NSInteger level = [self maxLevelWithNodes:_showNodes];
        _showLevel = MIN(_showLevel, level);
    }
    
    return tempMutArray.count;
}

- (void)expandAllNodesWithLevel:(NSInteger)expandLevel noExpandCompleted:(void (^)(NSArray<ZKTreeNode *> *))noExpandCompleted expandCompleted:(void (^)(NSArray<ZKTreeNode *> *))expandCompleted
{
    expandLevel = MAX(expandLevel, _minLevel);
    expandLevel = MIN(expandLevel, _maxLevel);
    
    _showLevel = expandLevel;
    
    // 先一级一级折叠
    for (NSInteger level = _maxLevel; level >= expandLevel; level--) {
        NSMutableArray *nodesArray = [NSMutableArray array];
        for (ZKTreeNode *node in _showNodes) {
            if (node.isExpand && node.level == level) {
                [nodesArray addObject:node];
            }
        }
        if (nodesArray.count <= 0) continue;
        if (noExpandCompleted) noExpandCompleted(nodesArray);
    }
    // 再一级一级展开
    for (NSInteger level = 0; level < expandLevel; level++) {
        NSMutableArray *nodesArray = [NSMutableArray array];
        for (ZKTreeNode *node in _showNodes) {
            if (!node.isExpand && node.level == level) {
                [nodesArray addObject:node];
            }
        }
        if (!nodesArray.count) continue;
        if (expandCompleted) expandCompleted(nodesArray);
    }
}

- (ZKTreeNode *)parentNodeWithNode:(ZKTreeNode *)node grades:(NSInteger)grades
{
    if (grades < 0) return nil;
    while (grades > 0) {
        node = node.parentNode;
        grades --;
    }
    return node;
}

- (NSArray<ZKTreeNode *> *)getAllChildNodesWithNode:(ZKTreeNode *)node
{
    NSMutableArray *mutArray = [NSMutableArray array];
    [self addNode:node toMutableArray:mutArray flag:NO];
    
    return mutArray;
}

- (ZKTreeNode *)getNodeByID:(NSString *)ID
{
    return [_nodesMap objectForKey:ID];
}

#pragma mark -- Private Methods
- (NSMutableArray *)sortedNodes:(NSArray<ZKTreeNode *> *)nodes
{
    return [nodes sortedArrayUsingComparator:^NSComparisonResult(ZKTreeNode * _Nonnull node1, ZKTreeNode * _Nonnull node2) {
        NSNumber *num1 = [NSNumber numberWithInteger:node1.order];
        NSNumber *num2 = [NSNumber numberWithInteger:node2.order];
        return [num1 compare:num2];
    }].mutableCopy;
}

- (NSInteger)maxLevelWithNodes:(NSArray<ZKTreeNode *> *)nodes
{
    NSInteger level = _minLevel;
    for (ZKTreeNode *node in nodes) {
        level = MAX(level, node.level);
    }
    return level;
}

- (void)removeNode:(ZKTreeNode *)node
{
    [_rootNodes removeObject:node];
    [_showNodes removeObject:node];
    [_allNodes removeObject:node];
    [_nodesMap removeObjectForKey:node.ID];
    
    if (node.childNodes.count <= 0) return;
    // 删除子节点
    NSArray *childNodes = node.childNodes.copy;
    for (ZKTreeNode *childNode in childNodes) {
        [self removeNode:childNode];
    }
}

- (void)addShowNode:(ZKTreeNode *)node toShowNodes:(NSMutableArray *)showNodes andShowLevel:(NSInteger)level
{
    if (node.level > level) return;
    
    [showNodes addObject:node];
    
    node.expand = (node.level != level);
    for (ZKTreeNode *childNode in node.childNodes) {
        [self addShowNode:childNode toShowNodes:showNodes andShowLevel:level];
    }
}

- (void)addNode:(ZKTreeNode *)node toMutableArray:(NSMutableArray *)mutArray flag:(BOOL)flag
{
    [mutArray addObject:node];
    
    if (flag && !node.isExpand) return;
    
    for (ZKTreeNode *tempNode in node.childNodes) {
        [self addNode:tempNode toMutableArray:mutArray flag:flag];
    }
}

@end
