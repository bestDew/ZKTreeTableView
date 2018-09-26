//
//  ZKTreeListView.m
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

#import "ZKTreeListView.h"
#import "ZKTreeManager.h"

@interface ZKTreeListView () <UITableViewDelegate, UITableViewDataSource>
{
    dispatch_semaphore_t _lock;
}
@property (nonatomic, strong) NSMutableArray<ZKTreeManager *> *managers;

@end

@implementation ZKTreeListView

#pragma mark -- Init
- (instancetype)init
{
    return [self initWithFrame:CGRectZero style:ZKTreeListViewStyleNone];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame style:ZKTreeListViewStyleNone];
}

- (instancetype)initWithFrame:(CGRect)frame style:(ZKTreeListViewStyle)style
{
    if (self = [super initWithFrame:frame]) {
        
        _style = style;
        _autoExpand = YES;
        _showAnimation = YES;
        _defaultExpandLevel = 0;
        _lock = dispatch_semaphore_create(1);
        
        [self addTableView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [super initWithCoder:aDecoder];
}

#pragma mark -- Layout
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _tableView.frame = self.bounds;
}

#pragma -- Load Data
- (void)loadNodes:(NSArray<ZKTreeNode *> *)nodes
{
    // 1.先清空原始数据
    [self.managers removeAllObjects];
    // 2.再重新加载
    [self appendRootNodes:nodes];
}

- (void)appendRootNodes:(NSArray<ZKTreeNode *> *)nodes
{
    if (nodes == nil) return;
    
    // 1.数据去重
    NSMutableArray *mutNodes = nodes.mutableCopy;
    for (ZKTreeManager *tempManager in self.managers) {
        for (ZKTreeNode *tempNode in tempManager.allNodes) {
            if ([nodes containsObject:tempNode]) {
                [mutNodes removeObject:tempNode];
            }
        }
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
        // 2.构建管理者
        ZKTreeManager *manager = [[ZKTreeManager alloc] initWithNodes:mutNodes minLevel:0 expandLevel:_defaultExpandLevel];
        // 3.拼接节点
        [self.managers addObject:manager];
        dispatch_semaphore_signal(_lock);
        // 4.刷新界面
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
        });
    });
}

- (void)reloadNodes:(NSArray<ZKTreeNode *> *)nodes
{
    if (nodes.count <= 0) return;
    
    for (ZKTreeManager *manager in self.managers) {
        NSMutableArray<NSIndexPath *> *tempMutArray = @[].mutableCopy;
        for (ZKTreeNode *node in nodes) {
            if (![manager.showNodes containsObject:node]) continue;
            NSInteger index = [manager.showNodes indexOfObject:node];
            NSInteger section = [self.managers indexOfObject:manager];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:section];
            [tempMutArray addObject:indexPath];
        }
        if (tempMutArray.count <= 0) continue;
        [_tableView reloadRowsAtIndexPaths:tempMutArray withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)addChildNodes:(NSArray<ZKTreeNode *> *)nodes forNode:(nullable ZKTreeNode *)node placedAtTop:(BOOL)isTop
{
    if (nodes.count <= 0) return;
    
    __block NSMutableArray *mutNodes = nodes.mutableCopy;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
        // 0.查找当前 section 下的 管理者
        ZKTreeManager *manager = nil;
        if (node == nil) { // 在根节点插入
            manager = isTop ? [self.managers firstObject] : [self.managers lastObject];
        } else {
            for (ZKTreeManager *tempManager in self.managers) {
                if ([tempManager getNodeByID:node.ID]) {
                    manager = tempManager;
                    break;
                }
            }
            NSAssert(manager, @"当前树结构中未找到目标node");
        }
        // 1.数据去重
        for (ZKTreeNode *tempNode in node.childNodes) {
            if ([nodes containsObject:tempNode]) {
                [mutNodes removeObject:tempNode];
            }
        }
        // 2.插入数据
        [manager addChildNodes:mutNodes forNode:node placedAtTop:isTop];
        // 3.刷新界面
        NSInteger section = [self.managers indexOfObject:manager];
        dispatch_semaphore_signal(_lock);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadSection:section];
        });
    });
}

- (void)deleteNode:(ZKTreeNode *)node
{
    if (node == nil) return;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
        // 1.查找当前 section 下的 管理者
        ZKTreeManager *manager = nil;
        for (ZKTreeManager *tempManager in self.managers) {
            if ([tempManager getNodeByID:node.ID]) {
                manager = tempManager;
                break;
            }
        }
        NSAssert(manager, @"当前树结构中未找到目标node");
        // 2.删除节点
        [manager deleteNode:node];
        // 3.刷新界面
        NSInteger section = [self.managers indexOfObject:manager];
        dispatch_semaphore_signal(_lock);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadSection:section];
        });
    });
}

#pragma mark -- Expand
- (void)expandAllNodesWithLevel:(NSInteger)expandLevel
{
    __weak typeof(self) weakSelf = self;
    for (ZKTreeManager *manager in self.managers) {
        NSInteger section = [self.managers indexOfObject:manager];
        [manager expandAllNodesWithLevel:expandLevel noExpandCompleted:^(NSArray<ZKTreeNode *> * _Nonnull noExpandArray) {
            [weakSelf tableView:weakSelf.tableView didSelectNodes:noExpandArray withSection:section expand:NO];
        } expandCompleted:^(NSArray<ZKTreeNode *> * _Nonnull expandArray) {
            [weakSelf tableView:weakSelf.tableView didSelectNodes:expandArray withSection:section expand:YES];
        }];
    }
}

- (void)expandNodes:(NSArray<ZKTreeNode *> *)nodes withExpand:(BOOL)isExpand
{
    for (ZKTreeManager *manager in self.managers) {
        NSMutableArray *tempMutArray = @[].mutableCopy;
        for (ZKTreeNode *node in nodes) {
            if (![manager.showNodes containsObject:node]) continue;
            [tempMutArray addObject:node];
        }
        if (tempMutArray.count <= 0) continue;
        NSInteger section = [self.managers indexOfObject:manager];
        [self tableView:_tableView didSelectNodes:tempMutArray withSection:section expand:isExpand];
    }
}

#pragma mark -- Other
- (void)registerClass:(nullable Class)cellClass forCellReuseIdentifier:(NSString *)identifier
{
    BOOL flag = [cellClass isSubclassOfClass:[ZKTreeListViewCell class]];
    NSAssert(flag, @"cellClass必须继承自<ZKTreeListViewCell>");
    
    [_tableView registerClass:cellClass forCellReuseIdentifier:identifier];
}

- (__kindof ZKTreeListViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath
{
    return [_tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
}

- (__kindof ZKTreeListViewCell *)cellForNode:(ZKTreeNode *)node
{
    if (node == nil) return nil;
    
    for (ZKTreeManager *manager in self.managers) {
        if (![manager.showNodes containsObject:node]) continue;
        
        NSInteger section = [self.managers indexOfObject:manager];
        NSInteger row = [manager.showNodes indexOfObject:node];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        
        return [_tableView cellForRowAtIndexPath:indexPath];
    }
    
    return nil;
}

- (__kindof ZKTreeListViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_tableView cellForRowAtIndexPath:indexPath];
}

- (CGFloat)indentationWidthWithLevel:(NSInteger)level
{
    CGFloat indentationWith = 0.f;
    if (level <= 0) {
        indentationWith = 0.f;
    } else if (level == 1) {
        indentationWith = 36.f;
    } else {
        indentationWith = 60.f + (level - 2) * 20.f;
    }
    return indentationWith;
}

#pragma mark -- Private Method
- (void)tableView:(UITableView *)tableView didSelectNodes:(NSArray<ZKTreeNode *> *)nodes withSection:(NSInteger)section expand:(BOOL)isExpand
{
    NSMutableArray *updateIndexPaths = @[].mutableCopy;
    NSMutableArray *tempMutArray = isExpand ? self.managers[section].showNodes : self.managers[section].showNodes.mutableCopy;
    
    for (ZKTreeNode *node in nodes) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[tempMutArray indexOfObject:node] inSection:section];
        NSInteger updateNum = [self.managers[section] expandNode:node expand:isExpand];
        NSArray *tmpArray = [self getUpdateIndexPathsWithCurrentIndexPath:indexPath andUpdateNum:updateNum];
        [updateIndexPaths addObjectsFromArray:tmpArray];
    }
    
    if (self.isShowAnimation) {
        if (isExpand) {
            [tableView insertRowsAtIndexPaths:updateIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            [tableView deleteRowsAtIndexPaths:updateIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    } else {
        [tableView reloadData];
    }
}

- (NSArray<NSIndexPath *> *)getUpdateIndexPathsWithCurrentIndexPath:(NSIndexPath *)indexPath andUpdateNum:(NSInteger)updateNum
{
    NSMutableArray *tmpIndexPaths = [NSMutableArray arrayWithCapacity:updateNum];
    for (NSInteger i = 0; i < updateNum; i++) {
        NSIndexPath *tmpIndexPath = [NSIndexPath indexPathForRow:(indexPath.row + 1 + i) inSection:indexPath.section];
        [tmpIndexPaths addObject:tmpIndexPath];
    }
    return tmpIndexPaths;
}

- (void)reloadSection:(NSInteger)section
{
    [UIView setAnimationsEnabled:NO];
    NSIndexSet *secIndexSet = [[NSIndexSet alloc] initWithIndex:section];
    [_tableView reloadSections:secIndexSet withRowAnimation:UITableViewRowAnimationNone];
    [UIView setAnimationsEnabled:YES];
}

- (void)addTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    if (_style == ZKTreeListViewStyleNone) {
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    } else {
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    [_tableView registerClass:[ZKTailCell class] forCellReuseIdentifier:@"ZKTailCell"];
    
    [self addSubview:_tableView];
}

- (void)dealloc
{
    NSLog(@"ZKTreeListView->销毁");
}

#pragma mark -- UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZKTreeNode *node = self.managers[indexPath.section].showNodes[indexPath.row];
    if (node.rowHeight >= 0.f) return node.rowHeight;
    if ([self.delegate respondsToSelector:@selector(treeListView:rowHeightForNode:atIndexPath:)]) {
        CGFloat rowHeight = [self.delegate treeListView:self rowHeightForNode:node atIndexPath:indexPath];
        node.rowHeight = rowHeight;
        return rowHeight;
    }
    return 0.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZKTreeNode *node = self.managers[indexPath.section].showNodes[indexPath.row];
    if (self.isAutoExpand && node.childNodes.count > 0) {
        [self tableView:tableView didSelectNodes:@[node] withSection:indexPath.section expand:!node.isExpand];
    }
    
    if ([self.delegate respondsToSelector:@selector(treeListView:didSelectNode:atIndexPath:)]) {
        [self.delegate treeListView:self didSelectNode:node atIndexPath:indexPath];
    }
}

#pragma mark -- UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.managers.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.managers[section].showNodes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZKTreeNode *node = self.managers[indexPath.section].showNodes[indexPath.row];
    if (node.isTail) {
        ZKTailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZKTailCell" forIndexPath:indexPath];
        cell.node = node;
        [cell setValue:@(_style) forKey:@"showStructureLine"];
        
        return cell;
    } else {
        ZKTreeListViewCell *cell = [self.delegate treeListView:self cellForNode:node atIndexPath:indexPath];
        cell.node = node;
        [cell setValue:@(_style) forKey:@"showStructureLine"];
        
        return cell;
    }
}

#pragma mark -- UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(treeListView:didScroll:)]) {
        [self.delegate treeListView:self didScroll:scrollView.contentOffset];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(treeListView:willBeginDragging:)]) {
        [self.delegate treeListView:self willBeginDragging:scrollView.contentOffset];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([self.delegate respondsToSelector:@selector(treeListView:didEndDragging:willDecelerate:)]) {
        [self.delegate treeListView:self didEndDragging:scrollView.contentOffset willDecelerate:decelerate];
    }
}

#pragma mark -- Setter && Getter
- (NSMutableArray<ZKTreeManager *> *)managers
{
    if (_managers == nil) {
        
        _managers = [NSMutableArray array];
    }
    return _managers;
}

- (NSSet<ZKTreeNode *> *)allNodes
{
    NSMutableSet *tempMutSet = [NSMutableSet set];
    for (ZKTreeManager *manager in self.managers) {
        [tempMutSet unionSet:manager.allNodes];
    }
    return tempMutSet;
}

- (NSArray<ZKTreeNode *> *)showNodes
{
    NSMutableArray *resultMutArray = [NSMutableArray array];
    for (ZKTreeManager *manager in self.managers) {
        [resultMutArray addObjectsFromArray:manager.showNodes];
    }
    return resultMutArray;
}

@end
