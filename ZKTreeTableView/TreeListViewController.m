//
//  ViewController.m
//  ZKTreeTableView
//
//  Created by bestdew on 2018/8/29.
//  Copyright © 2018年 bestdew. All rights reserved.
//

#import "TreeListViewController.h"
#import "CommentsCell.h"
#import "CustomCell.h"
#import "CommentsModel.h"
#import "YYFPSLabel.h"
#import <MJRefresh.h>

@interface TreeListViewController () <ZKTreeListViewDelegate>

@property (nonatomic, strong) ZKTreeListView *listView;
@property (nonatomic, assign) NSInteger pageIndex;

@end

@implementation TreeListViewController

#pragma mark -- Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pageIndex = 1;
    
    UIBarButtonItem *expandAllItem = [[UIBarButtonItem alloc] initWithTitle:@"全部展开" style:UIBarButtonItemStylePlain target:self action:@selector(expandAllNodes)];
    self.navigationItem.rightBarButtonItem = expandAllItem;
    
    [self.view addSubview:self.listView];
    [self.listView.tableView.mj_header beginRefreshing];
    
    YYFPSLabel *fpsLabel = [[YYFPSLabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 70, 84, 60, 30)];
    [fpsLabel sizeToFit];
    [self.view addSubview:fpsLabel];
}

#pragma mark -- Action
- (void)requestData
{
    // 模拟请求数据
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 获取数据并创建树形结构
        NSError *error = nil;
        NSData *JSONData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Resource" ofType:@"json"]];
        NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingAllowFragments error:&error];
        NSMutableArray *nodes = @[].mutableCopy;
        if (error) NSLog(@"解析出错：%@", error);
        
        for (NSDictionary *data in dataArray) {
            // 1.字典转模型
            CommentsModel *model = [CommentsModel modelWithDict:data];
            // 2.计算 cell 行高
            NSInteger level = [model.level integerValue];
            CGFloat rowHeight = (_style == ZKTreeListViewStyleNone) ? 44.f : [self nodeHeightWithLevel:level content:model.content];
            // 3.创建 node
            NSString *ID  = [NSString stringWithFormat:@"%@_%zd", model.ID, self.pageIndex];
            NSString *pID = [NSString stringWithFormat:@"%@_%zd", model.pid, self.pageIndex];
            NSInteger sortOrder = [model.order_no integerValue];
            ZKTreeNode *node = [ZKTreeNode nodeWithID:ID
                                             parentID:pID
                                            sortOrder:sortOrder
                                                 data:model];
            // 后台未返回 level时，以下两项可不设置，level 内部自动计算，rowHeight可通过代理方法设置
            node.level = level;
            node.rowHeight = rowHeight;
            // 如需子节点分页，可设置此项，需后台返回每个节点的子节点总数
            if (_style != ZKTreeListViewStyleNone) node.childNodesCount = [model.childs_count integerValue];
            
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
    });
}

- (void)expandAllNodes
{
    static BOOL isExpandAll = YES;
    _listView.expandLevel = isExpandAll ? NSIntegerMax : 0;
    isExpandAll = !isExpandAll;
    
    if (_style == ZKTreeListViewStyleStructureLine) return;
    
    for (ZKTreeNode *node in _listView.showNodes) {
        CustomCell *cell = [_listView cellForNode:node];
        CGFloat angle = (node.isExpand && node.childNodes.count > 0) ? M_PI_2 : 0.f;
        [cell refreshArrowDirection:angle animated:YES];
    }
}

#pragma mark -- ZKTreeListView Delgate
- (void)treeListView:(ZKTreeListView *)listView didSelectNode:(ZKTreeNode *)node atIndexPath:(NSIndexPath *)indexPath
{
    //[listView expandNodes:@[node] withExpand:!node.isExpand];
    NSLog(@"节点ID = %@", node.ID);
    if (node.isTail) { // 模拟子节点加载更多
        ZKTailCell *cell = [listView cellForRowAtIndexPath:indexPath];
        if (!cell.isLoading) {
            cell.loading = YES;
            node.pageIndex ++;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                ZKTreeNode *addNode = [self loadChildNodeFor:node.parentNode];
                [listView appendChildNodes:@[addNode] forNode:node.parentNode];
                cell.loading = NO;
            });
        }
    }
    
    if (_style == ZKTreeListViewStyleStructureLine) return;
    
    CGFloat angle = (node.isExpand && node.childNodes.count > 0) ? M_PI_2 : 0.f;
    CustomCell *cell = [listView cellForRowAtIndexPath:indexPath];
    [cell refreshArrowDirection:angle animated:YES];
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
    if (_style == ZKTreeListViewStyleNone) {
        CustomCell *cell = [listView dequeueReusableCellWithIdentifier:@"CustomCell" forIndexPath:indexPath];
        return cell;
    } else {
        CommentsCell *cell = [listView dequeueReusableCellWithIdentifier:@"CommentCell" forIndexPath:indexPath];
        return cell;
    }
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
        _listView = [[ZKTreeListView alloc] initWithFrame:self.view.bounds style:_style];
        _listView.delegate = self;
        _listView.autoExpand = YES;
        _listView.showAnimation = !_style;
        _listView.backgroundColor = [UIColor blackColor];
        _listView.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 16.f)];
        if (_style == ZKTreeListViewStyleNone) {
            [_listView registerClass:[CustomCell class] forCellReuseIdentifier:@"CustomCell"];
        } else {
            [_listView registerClass:[CommentsCell class] forCellReuseIdentifier:@"CommentCell"];
        }
        
        __weak typeof(self) weakSelf = self;
        _listView.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            weakSelf.pageIndex = 1;
            [weakSelf requestData];
        }];
        _listView.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            weakSelf.pageIndex ++;
            [weakSelf requestData];
        }];
    }
    return _listView;
}

- (ZKTreeNode *)loadChildNodeFor:(ZKTreeNode *)pNode
{
    static NSInteger count = 30;
    NSInteger level = pNode.level;
    NSInteger order = pNode.childNodes.count - 1;
    order ++;
    level ++;
    count ++;
    NSArray *tempArray = [pNode.ID componentsSeparatedByString:@"_"];
    NSInteger pid = [[tempArray firstObject] integerValue];
    NSDictionary *dict = @{@"id":@(count),
                           @"level":@(level),
                           @"image_name":@"touxiang_nan",
                           @"nick_name":@"自是不复欲--见汝",
                           @"content":@"每条评论都要认真的写，因为你不会知道在某个夜深人静的时候，有人会认真的逐条翻阅，他可能不会评论甚至也不会点赞，他只是在你熟睡的时候把你的悲欢喜乐都当成自己的，就像一只松鼠，在月光下的雪地里小心翼翼地捡起，散落在树下的一枚枚松子。",
                           @"order_no":@(order),
                           @"childs_count":@(0),
                           @"pid":@(pid)};
    CommentsModel *model = [CommentsModel modelWithDict:dict];
    NSString *ID = [NSString stringWithFormat:@"%@_%@", model.ID, [tempArray lastObject]];
    ZKTreeNode *node = [ZKTreeNode nodeWithID:ID
                                     parentID:pNode.ID
                                    sortOrder:order
                                         data:model];
    node.level = [model.level integerValue];
    node.rowHeight = 252.f;
    node.childNodesCount = [model.childs_count integerValue];
    
    return node;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
