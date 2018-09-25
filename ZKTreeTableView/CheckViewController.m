//
//  CheckViewController.m
//  ZKTreeTableView
//
//  Created by bestdew on 2018/9/23.
//  Copyright © 2018年 bestdew. All rights reserved.
//

#import "CheckViewController.h"
#import "CheckCell.h"
#import "CommentsModel.h"
#import "ZKTreeListView.h"
#import "YYFPSLabel.h"
#import "RequestHepler.h"
#import "CheckNode.h"

@interface CheckViewController () <ZKTreeListViewDelegate>

@property (nonatomic, strong) ZKTreeListView *listView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

static NSString *identifier = @"CheckCell";

@implementation CheckViewController

#pragma mark -- Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *expandAllItem = [[UIBarButtonItem alloc] initWithTitle:@"全部展开" style:UIBarButtonItemStylePlain target:self action:@selector(expandAllNodes)];
    UIBarButtonItem *checkAllItem = [[UIBarButtonItem alloc] initWithTitle:@"全部勾选" style:UIBarButtonItemStylePlain target:self action:@selector(checkAllNodes)];
    self.navigationItem.rightBarButtonItems = @[expandAllItem, checkAllItem];
    
    [self.view addSubview:self.listView];
    [self.view addSubview:self.indicatorView];
    
    YYFPSLabel *fpsLabel = [[YYFPSLabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 150, 100, 60, 30)];
    [fpsLabel sizeToFit];
    [self.view addSubview:fpsLabel];
    
    [self requestData];
}

#pragma mark -- Action
- (void)requestData
{
    // 模拟请求数据
    [RequestHepler mockRequestNodesDataWithParams:@{@"pageIndex":@"1"} success:^(id response) {
        NSArray *dataArray = (NSArray *)response;
        NSMutableArray *nodes = [NSMutableArray arrayWithCapacity:dataArray.count];
        for (NSDictionary *dataDict in dataArray) {
            // 1.字典转模型
            CommentsModel *model = [CommentsModel modelWithDict:dataDict];
            // 2.创建 node
            NSInteger sortOrder = [model.order_no integerValue];
            CheckNode *node = [CheckNode nodeWithID:model.ID
                                           parentID:model.pid
                                          sortOrder:sortOrder
                                               data:model];
            node.checked = NO;
            node.rowHeight = 44.f;
            
            [nodes addObject:node];
        }
        // 4.加载数据
        [_indicatorView stopAnimating];
        [_listView loadNodes:nodes];
    } failure:^(NSError *error) {
        NSLog(@"请求失败：%@", error);
    }];
}

- (void)expandAllNodes
{
    static NSInteger expandLevel = NSIntegerMax;
    [_listView expandAllNodesWithLevel:expandLevel];
    expandLevel = (expandLevel == 0) ? NSIntegerMax : 0;
    
    for (CheckNode *node in _listView.showNodes) {
        CheckCell *cell = [_listView cellForNode:node];
        CGFloat angle = (node.isExpand && node.childNodes.count > 0) ? M_PI_2 : 0.f;
        [cell refreshArrowDirection:angle animated:YES];
    }
}

- (void)checkAllNodes
{
    for (CheckNode *node in _listView.allNodes) {
        node.checked = !node.isChecked;
    }
    [_listView reloadNodes:_listView.allNodes.allObjects];
}

- (void)checkNode:(CheckNode *)node withCheck:(BOOL)isCheck mutableArray:(NSMutableArray<CheckNode *> *)mutArray
{
    if ((node == nil) || (mutArray == nil) || (node.isChecked == isCheck)) return;
    
    node.checked = isCheck;
    [mutArray addObject:node];
    
    CheckNode *pNode = (CheckNode *)(node.parentNode);
    NSArray<CheckNode *> *nodes = (NSArray<CheckNode *> *)(node.childNodes);
    
    [self checkParentNode:pNode withCheck:isCheck mutableArray:mutArray];
    [self checkChildNodes:nodes withCheck:isCheck mutableArray:mutArray];
}

// 向上寻找叶节点并勾选或取消勾选
- (void)checkParentNode:(CheckNode *)pNode withCheck:(BOOL)isCheck mutableArray:(NSMutableArray<CheckNode *> *)mutArray
{
    if (pNode.childNodes.count != 1) return;
    
    pNode.checked = isCheck;
    [mutArray addObject:pNode];
    pNode = (CheckNode *)(pNode.parentNode);
    [self checkParentNode:pNode withCheck:isCheck mutableArray:mutArray];
}

// 向下寻找子节点并勾选或取消勾选
- (void)checkChildNodes:(NSArray<CheckNode *> *)nodes withCheck:(BOOL)isCheck mutableArray:(NSMutableArray<CheckNode *> *)mutArray
{
    if (nodes.count == 0) return;
    
    for (CheckNode *node in nodes) {
        node.checked = isCheck;
        [mutArray addObject:node];
        NSArray<CheckNode *> *childNodes = (NSArray<CheckNode *> *)(node.childNodes);
        [self checkChildNodes:childNodes withCheck:isCheck mutableArray:mutArray];
    }
}

#pragma mark -- ZKTreeListView Delgate
- (void)treeListView:(ZKTreeListView *)listView didSelectNode:(ZKTreeNode *)node atIndexPath:(NSIndexPath *)indexPath
{
    CGFloat angle = (node.isExpand && node.childNodes.count > 0) ? M_PI_2 : 0.f;
    CheckCell *cell = [listView cellForRowAtIndexPath:indexPath];
    [cell refreshArrowDirection:angle animated:YES];
}

- (ZKTreeListViewCell *)treeListView:(ZKTreeListView *)listView cellForNode:(ZKTreeNode *)node atIndexPath:(NSIndexPath *)indexPath
{
    __weak typeof(self) weakSelf = self;
    CheckCell *cell = [listView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.block = ^(ZKTreeNode *node, BOOL isCheck) {
        NSMutableArray<CheckNode *> *mutArray = [NSMutableArray array];
        [weakSelf checkNode:(CheckNode *)node withCheck:isCheck mutableArray:mutArray];
        [weakSelf.listView reloadNodes:mutArray];
    };
    return cell;
}

#pragma mark -- Lazy Load
- (ZKTreeListView *)listView
{
    if (_listView == nil) {
        _listView = [[ZKTreeListView alloc] initWithFrame:self.view.bounds style:ZKTreeListViewStyleNone];
        _listView.delegate = self;
        _listView.tableView.tableFooterView = [UIView new];
        [_listView registerClass:[CheckCell class] forCellReuseIdentifier:identifier];
    }
    return _listView;
}

- (UIActivityIndicatorView *)indicatorView
{
    if (_indicatorView == nil) {
        
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicatorView.color = [UIColor grayColor];
        _indicatorView.center = self.view.center;
        _indicatorView.hidesWhenStopped = YES;
        [_indicatorView startAnimating];
    }
    return _indicatorView;
}

@end
