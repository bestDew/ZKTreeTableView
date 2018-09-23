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

@interface CheckViewController () <ZKTreeListViewDelegate>

@property (nonatomic, strong) ZKTreeListView *listView;

@end

static NSString *identifier = @"CheckCell";

@implementation CheckViewController

#pragma mark -- Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *expandAllItem = [[UIBarButtonItem alloc] initWithTitle:@"全部展开" style:UIBarButtonItemStylePlain target:self action:@selector(expandAllNodes)];
    self.navigationItem.rightBarButtonItem = expandAllItem;
    
    [self.view addSubview:self.listView];
    
    YYFPSLabel *fpsLabel = [[YYFPSLabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 70, 84, 60, 30)];
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
            ZKTreeNode *node = [ZKTreeNode nodeWithID:model.ID
                                             parentID:model.pid
                                            sortOrder:sortOrder
                                                 data:model];
            node.rowHeight = 44.f;
            
            [nodes addObject:node];
        }
        // 4.加载数据
        [_listView loadNodes:nodes];
    } failure:^(NSError *error) {
        NSLog(@"请求失败：%@", error);
    }];
}

- (void)expandAllNodes
{
    static BOOL isExpandAll = YES;
    _listView.expandLevel = isExpandAll ? NSIntegerMax : 0;
    isExpandAll = !isExpandAll;
    
    for (ZKTreeNode *node in _listView.showNodes) {
        CheckCell *cell = [_listView cellForNode:node];
        CGFloat angle = (node.isExpand && node.childNodes.count > 0) ? M_PI_2 : 0.f;
        [cell refreshArrowDirection:angle animated:YES];
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
    CheckCell *cell = [listView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
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

@end
