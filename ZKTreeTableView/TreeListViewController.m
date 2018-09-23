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

@interface TreeListViewController () <ZKTreeListViewDelegate>

@property (nonatomic, strong) ZKTreeListView *listView;
@property (nonatomic, assign) NSInteger pageIndex;

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
    
    YYFPSLabel *fpsLabel = [[YYFPSLabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 70, 84, 60, 30)];
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
            [_listView appendNodes:nodes];
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
        [_listView appendChildNodes:@[addNode] forNode:node.parentNode];
        cell.loading = NO;
    } failure:^(NSError *error) {
        NSLog(@"请求出错：%@", error);
    }];
}

- (void)expandAllNodes
{
    static BOOL isExpandAll = YES;
    _listView.expandLevel = isExpandAll ? NSIntegerMax : 0;
    isExpandAll = !isExpandAll;
}

#pragma mark -- ZKTreeListView Delgate
- (void)treeListView:(ZKTreeListView *)listView didSelectNode:(ZKTreeNode *)node atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"节点ID = %@", node.ID);
    ZKTailCell *cell = [listView cellForRowAtIndexPath:indexPath];
    if ((!node.isTail) || cell.isLoading) return;
    // 模拟子节点加载更多
    cell.loading = YES;
    node.pageIndex ++;
    [self requestChildNodesDataWithNode:node cell:cell];
}

//- (CGFloat)treeListView:(ZKTreeListView *)listView rowHeightForNode:(ZKTreeNode *)node atIndexPath:(NSIndexPath *)indexPath
//{
//    NSString *content = ((CommentsModel *)node.data).content;
//    CGFloat rowHeight = (_style == ZKTreeListViewStyleNone) ? 44.f : [self nodeHeightWithLevel:node.level content:content];
//
//    return rowHeight;
//}

- (ZKTreeListViewCell *)treeListView:(ZKTreeListView *)listView cellForNode:(ZKTreeNode *)node atIndexPath:(NSIndexPath *)indexPath
{
    CommentsCell *cell = [listView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    return cell;
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

- (ZKTreeListView *)listView
{
    if (_listView == nil) {
        _listView = [[ZKTreeListView alloc] initWithFrame:self.view.bounds style:ZKTreeListViewStyleStructureLine];
        _listView.delegate = self;
        _listView.showAnimation = NO;
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

@end
