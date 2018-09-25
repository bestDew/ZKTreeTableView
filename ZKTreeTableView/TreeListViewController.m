//
//  ViewController.m
//  ZKTreeTableView
//
//  Created by bestdew on 2018/8/29.
//  Copyright © 2018年 bestdew. All rights reserved.
//

#import "TreeListViewController.h"
#import "CommentsCell.h"
#import "CommentsModel.h"
#import "YYFPSLabel.h"
#import <MJRefresh.h>
#import "ZKTreeListView.h"
#import "YYFPSLabel.h"
#import "RequestHepler.h"
#import "ZKToolBar.h"
#import "ZKInputView.h"

#define IPHONE_X ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
#define BOTTOM_MARGIN (IPHONE_X ? 34.f : 0.f)

@interface TreeListViewController () <ZKTreeListViewDelegate, ZKToolBarDelegate, ZKInputViewDelagete>

@property (nonatomic, strong) ZKTreeListView *listView;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, strong) ZKToolBar *toolBar;
@property (nonatomic, strong) ZKInputView *input_view;

@property (nonatomic, weak) ZKTreeNode *targetNode;

@end

static NSString *identifier = @"CommentsCell";

@implementation TreeListViewController

#pragma mark -- Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pageIndex = 1;
    
    UIBarButtonItem *expandAllItem = [[UIBarButtonItem alloc] initWithTitle:@"全部展开" style:UIBarButtonItemStylePlain target:self action:@selector(expandAllNodes)];
    self.navigationItem.rightBarButtonItem = expandAllItem;
    
    [self.view addSubview:self.listView];
    [self.view addSubview:self.toolBar];
    
    YYFPSLabel *fpsLabel = [[YYFPSLabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 150, 100, 60, 30)];
    [fpsLabel sizeToFit];
    [self.view addSubview:fpsLabel];
    
    [self.listView.tableView.mj_header beginRefreshing];
}

#pragma mark -- Action
- (void)requestNodesData
{
    // 模拟请求数据
    NSDictionary *params = @{@"pageIndex":@(self.pageIndex)};
    [RequestHepler mockRequestNodesDataWithParams:params success:^(id response) {
        NSArray *dataArray = (NSArray *)response;
        NSMutableArray *nodes = [NSMutableArray arrayWithCapacity:dataArray.count];
        for (NSDictionary *dataDict in dataArray) {
            ZKTreeNode *node = [self nodeForDictionary:dataDict];
            [nodes addObject:node];
        }
        // 4.加载数据
        if (self.pageIndex == 1) {
            [_listView loadNodes:nodes];
            [_listView.tableView.mj_header endRefreshing];
        } else {
            [_listView appendRootNodes:nodes];
            [_listView.tableView.mj_footer endRefreshing];
        }
    } failure:^(NSError *error) {
        NSLog(@"请求出错：%@", error);
    }];
}

- (void)requestChildNodesDataWithNode:(ZKTreeNode *)node cell:(ZKTailCell *)cell
{
    NSDictionary *params = @{@"pid":node.parentID,
                             @"level":@(node.level),
                             @"order":@(node.parentNode.childNodes.count)};
    [RequestHepler mackRequestMoreChildNodeDataWithParams:params success:^(id response) {
        ZKTreeNode *addNode = [self nodeForDictionary:response];
        [_listView addChildNodes:@[addNode] forNode:node.parentNode placedAtTop:NO];
        cell.loading = NO;
    } failure:^(NSError *error) {
        NSLog(@"请求出错：%@", error);
    }];
}

- (void)expandAllNodes
{
    static NSInteger expandLevel = NSIntegerMax;
    [_listView expandAllNodesWithLevel:expandLevel];
    expandLevel = (expandLevel == 0) ? NSIntegerMax : 0;
}

- (void)submitComments:(NSString *)content withNode:(ZKTreeNode *)node
{
    NSInteger level = node.level;
    if (node) level ++;
    NSInteger order = node ? node.childNodes.count : _listView.allNodes.count;
    id ID = node ? node.ID : [NSNull null];
    NSDictionary *params = @{@"pid":ID,
                             @"level":@(level),
                             @"order":@(order),
                             @"content":content};
    [RequestHepler submitCommentsWithParams:params success:^(id response) {
        [_input_view hide];
        node.childNodesCount ++; // 父节点子节点总数加一
        _toolBar.brigeCount ++;  // 评论总数加一
        ZKTreeNode *addNode = [self nodeForDictionary:response];
        [_listView addChildNodes:@[addNode] forNode:node placedAtTop:YES];
    } failure:^(NSError *error) {
        NSLog(@"请求出错：%@", error);
    }];
}

#pragma mark -- ZKTreeListView Delgate
- (void)treeListView:(ZKTreeListView *)listView didSelectNode:(ZKTreeNode *)node atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"节点ID = %@", node.ID);
    if (node.isTail) {
        ZKTailCell *cell = [listView cellForRowAtIndexPath:indexPath];
        if (cell.isLoading) return;
        // 模拟子节点加载更多
        cell.loading = YES;
        node.pageIndex ++;
        [self requestChildNodesDataWithNode:node cell:cell];
    } else {
        _targetNode = node;
        CommentsModel *model = (CommentsModel *)node.data;
        NSString *placeholder = [NSString stringWithFormat:@"回复  %@", model.nick_name];
        [self showInputViewWithPlaceholder:placeholder];
    }
}

//- (CGFloat)treeListView:(ZKTreeListView *)listView rowHeightForNode:(ZKTreeNode *)node atIndexPath:(NSIndexPath *)indexPath
//{
//    NSString *content = ((CommentsModel *)node.data).content;
//    CGFloat rowHeight = [self nodeHeightWithLevel:node.level content:content];
//    return rowHeight;
//}

- (ZKTreeListViewCell *)treeListView:(ZKTreeListView *)listView cellForNode:(ZKTreeNode *)node atIndexPath:(NSIndexPath *)indexPath
{
    __weak typeof(self) weakSelf = self;
    CommentsCell *cell = [listView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.block = ^(ZKTreeNode *node) {
        [weakSelf.listView expandNodes:@[node] withExpand:!node.isExpand];
    };
    return cell;
}

#pragma mark -- ZKToolBar Delgate
- (void)toolBar:(ZKToolBar *)toolBar didCilckAtIndex:(NSInteger)index
{
    switch (index) {
        case 0: { // 发表评论
            _targetNode = nil;
            [self showInputViewWithPlaceholder:@"我来说两句"];
            break;
        }
        case 1: { // 查看评论
            [_listView.tableView.mj_header beginRefreshing];
            break;
        }
        case 2: { // 分享
            NSLog(@"分享！");
            break;
        }
    }
}

#pragma mark -- ZKInputView Delgate
- (void)inputView:(ZKInputView *)inputView didSendText:(NSString *)text
{
    [self submitComments:text withNode:_targetNode];
}

#pragma mark -- Other
- (CGFloat)nodeHeightWithLevel:(NSInteger)level content:(NSString *)text
{
    CGFloat imgSize = (level == 0) ? 40.f : 30.f;
    CGFloat cellWidth = _listView.frame.size.width - [_listView indentationWidthWithLevel:level];
    CGFloat maxWidth = cellWidth - imgSize - 15.f;
    
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.alignment = NSTextAlignmentLeft;
    paraStyle.firstLineHeadIndent = 10.f;
    paraStyle.headIndent = 10.f;
    //paraStyle.lineSpacing = 2.f;
    paraStyle.tailIndent = -5.f;
    paraStyle.minimumLineHeight = 24.f;
    
    UIFont *font = [UIFont systemFontOfSize:17.f];
    NSDictionary *attributes = @{NSFontAttributeName:font,
                                 NSParagraphStyleAttributeName:paraStyle};
    CGFloat itemHeight = [self textSizeWithText:text maxSize:CGSizeMake(maxWidth, MAXFLOAT) attributes:attributes].height;
    
    return itemHeight + 60.f;
}

- (CGSize)textSizeWithText:(NSString *)text maxSize:(CGSize)maxSize attributes:(NSDictionary<NSAttributedStringKey, id> *)attributes;
{
    return [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
}

- (ZKTreeNode *)nodeForDictionary:(NSDictionary *)dict
{
    // 1.字典转模型
    CommentsModel *model = [CommentsModel modelWithDict:dict];
    // 2.计算 cell 行高
    NSInteger level = [model.level integerValue];
    CGFloat rowHeight = [self nodeHeightWithLevel:level content:model.content];
    // 3.创建 node
    NSInteger sortOrder = [model.order_no integerValue];
    ZKTreeNode *node = [ZKTreeNode nodeWithID:model.ID
                                     parentID:model.pid
                                    sortOrder:sortOrder
                                         data:model];
    // 后台未返回 level时，以下两项可不设置，level 内部自动计算，rowHeight可通过代理方法设置
    node.level = level;
    node.rowHeight = rowHeight;
    // 如需子节点分页，可设置此项，需后台返回每个节点的子节点总数
    node.childNodesCount = [model.childs_count integerValue];
    
    return node;
}

- (void)showInputViewWithPlaceholder:(NSString *)placeholder
{
    self.input_view.placeholder = placeholder;
    [self.input_view show];
}

#pragma mark -- Lazy Load
- (ZKTreeListView *)listView
{
    if (_listView == nil) {
        _listView = [[ZKTreeListView alloc] initWithFrame:self.view.bounds style:ZKTreeListViewStyleStructureLine];
        _listView.delegate = self;
        _listView.autoExpand = NO;
        _listView.showAnimation = NO;
        _listView.defaultExpandLevel = 2;
        _listView.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 16.f)];
        [_listView registerClass:[CommentsCell class] forCellReuseIdentifier:identifier];
        
        __weak typeof(self) weakSelf = self;
        _listView.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            weakSelf.pageIndex = 1;
            [weakSelf requestNodesData];
        }];
        _listView.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            weakSelf.pageIndex ++;
            [weakSelf requestNodesData];
        }];
    }
    return _listView;
}

- (ZKToolBar *)toolBar
{
    if (_toolBar == nil) {
        
        _toolBar = [[ZKToolBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 48.f - BOTTOM_MARGIN, self.view.frame.size.width, 48.f + BOTTOM_MARGIN)];
        _toolBar.delegate = self;
        _toolBar.brigeCount = 666;
        _toolBar.backgroundColor = [UIColor whiteColor];
    }
    return _toolBar;
}

- (ZKInputView *)input_view
{
    if (_input_view == nil) {
        
        _input_view = [[ZKInputView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 48.f)];
        _input_view.backgroundColor = [UIColor whiteColor];
        _input_view.maxLine = 3;
        _input_view.maxCount = 200;
        _input_view.delegate = self;
        _input_view.font = [UIFont systemFontOfSize:16.f];
    }
    return _input_view;
}

@end
