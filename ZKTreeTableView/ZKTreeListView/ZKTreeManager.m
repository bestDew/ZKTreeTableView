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
}
/** key 为节点 ID，value为对应的 node */
@property (nonatomic, strong) NSMutableDictionary<NSString *, ZKTreeNode *> *nodesMap;
/** 所有根节点 */
@property (nonatomic, strong) NSMutableArray<ZKTreeNode *> *rootNodes;

@end

@implementation ZKTreeManager

#pragma mark -- Init
+ (instancetype)managerWithNodes:(NSArray<ZKTreeNode *> *)nodes minLevel:(NSInteger)minLevel
{
    return [[self alloc] initWithNodes:nodes minLevel:minLevel];
}

- (instancetype)initWithNodes:(NSArray<ZKTreeNode *> *)nodes minLevel:(NSInteger)minLevel
{
    if (self = [super init]) {
        
        _minLevel = minLevel;
        _maxLevel = minLevel;
        _showLevel = minLevel;
        _allNodes = nodes.mutableCopy;
        _flag = ([nodes firstObject].level == -1);
        
        // 1.建立映射
        [self bulidMap];
        // 2.建立父子关系
        [self bulidRelationship];
        // 3.设置等级
        [self setupLevel];
        // 4.子节点排序
        [self sortChildNodes];
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
    // 默认展示根节点
    _showNodes = [NSMutableArray arrayWithArray:_rootNodes];
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
    NSArray *tempArray = _allNodes.copy;
    for (ZKTreeNode *node in tempArray) {
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

- (void)addNode:(ZKTreeNode *)node toMutableArray:(NSMutableArray *)mutArray
{
    [mutArray addObject:node];
    
    if (!node.isExpand) return;
    
    for (ZKTreeNode *tempNode in node.childNodes) {
        [self addNode:tempNode toMutableArray:mutArray];
    }
}

#pragma mark -- Public Methods
- (void)appendChildNodes:(NSArray<ZKTreeNode *> *)nodes forNode:(ZKTreeNode *)node
{
    if (nodes.count <= 0) return;
    
    // 1.构建一个临时管理者
    NSInteger minLevel = node ? (node.level + 1) : _minLevel;
    ZKTreeManager *tempManager = [ZKTreeManager managerWithNodes:nodes minLevel:minLevel];
    // 2.建立父子关系
    NSInteger tempRootNodesCount = tempManager.rootNodes.count;
    if (node == nil) { // 根节点
        // 重置序号
        NSInteger location = [_rootNodes lastObject].order + 1;
        for (NSInteger i = 0; i < tempRootNodesCount; i++) {
            ZKTreeNode *tempNode = tempManager.rootNodes[i];
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
        if (node.childNodesCount > (node.childNodes.count + tempManager.rootNodes.count)) {
            ZKTreeNode *tail = [self tailForNode:node];
            [tempManager.nodesMap setObject:tail forKey:tail.ID];
            [tempManager.allNodes addObject:tail];
            [tempManager.showNodes addObject:tail];
            [tempManager.rootNodes addObject:tail];
            tempRootNodesCount ++;
            node.childNodesCount ++;
        }
        // 2.重置序号并建立父子关系
        NSArray<ZKTreeNode *> *childNodeArray = node.childNodes.copy;
        NSInteger location = [childNodeArray lastObject].order + 1;
        for (NSInteger i = 0; i < tempRootNodesCount; i++) {
            ZKTreeNode *tempNode = tempManager.rootNodes[i];
            tempNode.parentNode = node;
            [tempNode setValue:@(location + i) forKey:@"order"];
        }
        // 3.插入数据
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(childNodeArray.count, tempRootNodesCount)];
        [node.childNodes insertObjects:tempManager.rootNodes atIndexes:indexSet];
        
        if (node.isExpand) {
            NSMutableArray *tempMutArray = [NSMutableArray array];
            for (ZKTreeNode *tempNode in childNodeArray) {
                [self addNode:tempNode toMutableArray:tempMutArray];
            }
            NSInteger location = [_showNodes indexOfObject:node] + tempMutArray.count + 1;
            NSIndexSet *showIndexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(location, tempManager.showNodes.count)];
            [self.showNodes insertObjects:tempManager.showNodes atIndexes:showIndexSet];
        }
    }
    // 4.重置最大等级
    _maxLevel = MAX(_maxLevel, tempManager.maxLevel);
    
    // 5.数据合并
    [_allNodes addObjectsFromArray:tempManager.allNodes];
    [_nodesMap addEntriesFromDictionary:tempManager.nodesMap];
}

- (void)deleteNode:(ZKTreeNode *)node
{
    if (![self.allNodes containsObject:node]) return;
    
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
            [self addNode:tempNode toMutableArray:tempMutArray];
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
        for (NSInteger i = 0; i < _showNodes.count; i++) {
            ZKTreeNode *node = _showNodes[i];
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
        for (NSInteger i = 0; i < _showNodes.count; i++) {
            ZKTreeNode *node = _showNodes[i];
            if (!node.isExpand && node.level == level) {
                [nodesArray addObject:node];
            }
        }
        if (!nodesArray.count) continue;
        if (expandCompleted) expandCompleted(nodesArray);
    }
}

- (ZKTreeNode *)superNodeWithNode:(ZKTreeNode *)node grades:(NSInteger)grades
{
    if (grades < 0) return nil;
    while (grades > 0) {
        node = node.parentNode;
        grades --;
    }
    return node;
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
    [self.rootNodes removeObject:node];
    [self.showNodes removeObject:node];
    [self.allNodes removeObject:node];
    [self.nodesMap removeObjectForKey:node.ID];
    
    if (node.childNodes.count <= 0) return;
    // 删除子节点
    NSArray *childNodes = node.childNodes.copy;
    for (ZKTreeNode *childNode in childNodes) {
        [self removeNode:childNode];
    }
}

@end
