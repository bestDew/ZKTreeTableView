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

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, strong) UITableView *tableView;
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
    return [self initWithFrame:frame style:ZKTreeListViewStyleNone];;
}

- (instancetype)initWithFrame:(CGRect)frame style:(ZKTreeListViewStyle)style
{
    if (self = [super initWithFrame:frame]) {
        self.frame = frame;
        self.autoExpand = YES;
        self.showExpandAnimation = YES;
        self.defaultExpandLevel = 0;
        self.style = style ? style : ZKTreeListViewStyleNone;
        [self addSubview:self.tableView];
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
    
    self.tableView.frame = self.bounds;
}

#pragma mark -- Public Method
- (void)reloadData:(NSArray<ZKTreeNode *> *)nodes
{
    [self.managers removeAllObjects];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        ZKTreeManager *manager = [[ZKTreeManager alloc] initWithNodes:nodes andExpandLevel:_defaultExpandLevel];
        [self.managers addObject:manager];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

- (void)appendData:(NSArray<ZKTreeNode *> *)nodes
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        ZKTreeManager *manager = [[ZKTreeManager alloc] initWithNodes:nodes andExpandLevel:_defaultExpandLevel];
        [self.managers addObject:manager];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

- (void)registerClass:(nullable Class)cellClass forCellReuseIdentifier:(NSString *)identifier
{
    if (cellClass) {
        NSAssert(![cellClass isKindOfClass:[ZKTreeListViewCell class]],
                 @"<cellClass>必须是<ZKTreeListViewCell>的子类");
    }
    
    self.identifier = identifier;
    [self.tableView registerClass:cellClass forCellReuseIdentifier:identifier];
}

- (void)expandAllNodes:(BOOL)isExpand
{
    [self expandNodesWithLevel:(isExpand ? NSIntegerMax : 0)];
}

- (void)expandNodesWithLevel:(NSInteger)expandLevel
{
    __weak typeof(self) weakSelf = self;
    for (ZKTreeManager *manager in self.managers) {
        NSInteger section = [self.managers indexOfObject:manager];
        [manager expandNodesWithLevel:expandLevel completed:^(NSArray *noExpandArray) {
            [weakSelf tableView:weakSelf.tableView didSelectNodes:noExpandArray withSection:section expand:NO];
        } andCompleted:^(NSArray *expandArray) {
            [weakSelf tableView:weakSelf.tableView didSelectNodes:expandArray withSection:section expand:YES];
        }];
    }
}

- (void)expandNodes:(NSArray<ZKTreeNode *> *)nodes expand:(BOOL)isExpand
{
    for (ZKTreeNode *node in nodes) {
        for (ZKTreeManager *manager in self.managers) {
            if (![manager.showNodes containsObject:node]) continue;
            NSInteger section = [self.managers indexOfObject:manager];
            [self tableView:_tableView didSelectNodes:@[node] withSection:section expand:isExpand];
        }
    }
}

- (CGFloat)containerViewWidthWithLevel:(NSInteger)level
{
    CGFloat indentationWith = 0.f;
    if (level <= 0) {
        indentationWith = 16.f;
    } else if (level == 1) {
        indentationWith = 48.f;
    } else {
        indentationWith = 68.f + (level - 2) * 20.f;
    }
    return self.bounds.size.width - indentationWith;
}

- (CGRect)rectInScreenForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    CGRect rectInTableView = [_tableView rectForRowAtIndexPath:indexPath];
    CGRect rectInScreen = [self convertRect:rectInTableView toView:keyWindow];
    
    return rectInScreen;
}

- (NSIndexPath *)indexPathForCell:(ZKTreeListViewCell *)cell
{
    return [_tableView indexPathForCell:cell];
}

- (__kindof ZKTreeListViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_tableView cellForRowAtIndexPath:indexPath];
}

- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated
{
    [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
}

#pragma mark -- Private Method
- (void)tableView:(UITableView *)tableView didSelectNodes:(NSArray<ZKTreeNode *> *)nodes withSection:(NSInteger)section expand:(BOOL)isExpand
{
    NSMutableArray *updateIndexPaths = @[].mutableCopy;
    NSMutableArray *tempMutArray = isExpand ? self.managers[section].showNodes : self.managers[section].showNodes.mutableCopy;
    
    for (ZKTreeNode *node in nodes) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[tempMutArray indexOfObject:node] inSection:section];
        NSInteger updateNum = [self.managers[section] expandNode:node];
        NSArray *tmpArray = [self getUpdateIndexPathsWithCurrentIndexPath:indexPath andUpdateNum:updateNum];
        [updateIndexPaths addObjectsFromArray:tmpArray];
    }
    
    if (self.isShowExpandAnimation) {
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

#pragma mark -- UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZKTreeNode *node = self.managers[indexPath.section].showNodes[indexPath.row];
    if (self.isAutoExpand && node.childNodes.count != 0) {
        [self tableView:tableView didSelectNodes:@[node] withSection:indexPath.section expand:!node.isExpand];
    }

    if ([self.delegate respondsToSelector:@selector(treeListView:didSelectRowAtIndexPath:withNode:)]) {
        [self.delegate treeListView:self didSelectRowAtIndexPath:indexPath withNode:node];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(treeListView:heightForNode:)]) {
        ZKTreeNode *node = self.managers[indexPath.section].showNodes[indexPath.row];
        return [self.delegate treeListView:self heightForNode:node];
    }
    return self.managers[indexPath.section].showNodes[indexPath.row].nodeHeight;
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
    if (indexPath.row >= self.managers[indexPath.section].showNodes.count) {
        return nil;
    }
    
    ZKTreeNode *node = self.managers[indexPath.section].showNodes[indexPath.row];
    ZKTreeListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.identifier forIndexPath:indexPath];
    cell.node = node;
    // 私有属性，这里通过KVC赋值
    [cell setValue:@(_style) forKey:@"showStructureLine"];
    
    return cell;
}

#pragma mark -- Setter && Getter
- (void)setHeaderView:(UIView *)headerView
{
    _headerView = headerView;
    _tableView.tableHeaderView = headerView;
}

- (void)setFooterView:(UIView *)footerView
{
    _footerView = footerView;
    _tableView.tableFooterView = footerView;
}

- (UITableView *)tableView
{
    if (_tableView == nil) {
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (NSMutableArray<ZKTreeManager *> *)managers
{
    if (_managers == nil) {
        
        _managers = [NSMutableArray array];
    }
    return _managers;
}

- (NSArray<ZKTreeNode *> *)allNodes
{
    NSMutableArray *tempMutArray = @[].mutableCopy;
    for (ZKTreeManager *manager in self.managers) {
        [tempMutArray addObjectsFromArray:manager.allNodes];
    }
    return tempMutArray;
}

- (NSArray<ZKTreeNode *> *)showNodes
{
    NSMutableArray *tempMutArray = @[].mutableCopy;
    for (ZKTreeManager *manager in self.managers) {
        [tempMutArray addObjectsFromArray:manager.showNodes];
    }
    return tempMutArray;
}

#pragma mark -- Other
- (void)dealloc
{
    NSLog(@"ZKTreeListView->销毁");
}

@end
