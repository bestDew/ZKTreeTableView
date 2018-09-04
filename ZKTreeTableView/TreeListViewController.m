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

@interface TreeListViewController () <ZKTreeListViewDelegate>

@property (nonatomic, strong) ZKTreeListView *listView;

@end

@implementation TreeListViewController

#pragma mark -- Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *allExpandItem = [[UIBarButtonItem alloc] initWithTitle:@"全部展开" style:UIBarButtonItemStylePlain target:self action:@selector(allExpandItemClick)];
    self.navigationItem.rightBarButtonItem = allExpandItem;
    
    [self.view addSubview:self.listView];
    [self requestTreeData];
    
    YYFPSLabel *fpsLabel = [[YYFPSLabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 70, 84, 60, 30)];
    [fpsLabel sizeToFit];
    [self.view addSubview:fpsLabel];
    
    // 监听屏幕旋转
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDeviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

#pragma mark -- Action
- (void)handleDeviceOrientationDidChange:(UIInterfaceOrientation)interfaceOrientation
{
    _listView.frame = self.view.bounds;
    
    if (_treeStyle == ZKTreeListViewStyleNone) return;
    
    for (ZKTreeItem *item in _listView.items) {
        
        CommentsModel *model = (CommentsModel *)item.data;
        CGFloat itemHeight = [self itemHeightWithLevel:[model.level integerValue] content:model.content];
        [item setValue:@(itemHeight) forKey:@"itemHeight"];
    }
    [_listView reloadData];
}

- (void)requestTreeData
{
    // 获取数据并创建树形结构
    NSError *error = nil;
    NSData *JSONData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Resource" ofType:@"json"]];
    NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingAllowFragments error:&error];
    NSMutableArray *items = @[].mutableCopy;
    if (error) NSLog(@"%@", error);
    
    for (NSDictionary *data in dataArray) {
        // 1.字典转模型
        CommentsModel *model = [CommentsModel modelWithDict:data];
        // 2.计算 cell 行高
        NSInteger level = [model.level integerValue];
        CGFloat itemHeight = (_treeStyle == 0) ? 44.f : [self itemHeightWithLevel:level content:model.content];
        // 3.创建 treeItem
        ZKTreeItem *item = [[ZKTreeItem alloc] initWithID:[NSString stringWithFormat:@"%@", data[@"id"]]
                                                 parentID:[NSString stringWithFormat:@"%@", data[@"pid"]]
                                                  orderNo:[NSString stringWithFormat:@"%@", data[@"order_no"]]
                                                    level:level
                                               itemHeight:itemHeight
                                                     data:model];
        [items addObject:item];
    }
    _listView.items = items;
    [_listView reloadData];
}

- (void)allExpandItemClick
{
    static BOOL isExpand = YES;
    [self.listView expandAllItems:isExpand];
    isExpand = !isExpand;
    
    if (_treeStyle == ZKTreeListViewStyleStructureLine) return;
    
    NSArray *items = [_listView getShowItems];
    for (NSInteger i = 0; i < items.count; i++) {
        @autoreleasepool {
            ZKTreeItem *item = items[i];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            CustomCell *cell = [_listView cellForRowAtIndexPath:indexPath];
            CGFloat angle = (item.isExpand && item.childItems.count > 0) ? M_PI_2 : 0.f;
            [cell refreshArrowDirection:angle animated:YES];
        }
    }
}

#pragma mark -- ZKTreeListView Delgate
- (void)treeListView:(ZKTreeListView *)listView didSelectRowAtIndexPath:(NSIndexPath *)indexPath withItem:(ZKTreeItem *)item
{
    [listView expandItems:@[item] isExpand:!item.isExpand];
    
    if (_treeStyle == ZKTreeListViewStyleStructureLine) return;
    
    CGFloat angle = (item.isExpand && item.childItems.count > 0) ? M_PI_2 : 0.f;
    CustomCell *cell = [listView cellForRowAtIndexPath:indexPath];
    [cell refreshArrowDirection:angle animated:YES];
}

#pragma mark -- Other
- (CGFloat)itemHeightWithLevel:(NSInteger)level content:(NSString *)text
{
    CGFloat imgSize = (level == 0) ? 40.f : 30.f;
    CGFloat cellWidth = [_listView containerViewWidthWithLevel:level];
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
        _listView = [[ZKTreeListView alloc] initWithFrame:self.view.bounds style:_treeStyle];
        _listView.delegate = self;
        _listView.autoExpand = NO;
        _listView.showExpandAnimation = !_treeStyle;
        //_listView.defaultExpandLevel = 2;
        _listView.footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 16.f)];
        if (_treeStyle == ZKTreeListViewStyleNone) {
            [_listView registerClass:[CustomCell class] forCellReuseIdentifier:@"CustomCell"];
        } else {
            [_listView registerClass:[CommentsCell class] forCellReuseIdentifier:@"CommentCell"];
        }
    }
    return _listView;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
