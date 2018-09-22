//
//  ZKTreeListView.h
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

#import <UIKit/UIKit.h>
#import "ZKTreeListViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@class ZKTreeListView;

typedef NS_ENUM(NSInteger, ZKTreeListViewStyle) {
    ZKTreeListViewStyleNone,          // 默认
    ZKTreeListViewStyleStructureLine, // 带有结构线
};

@protocol ZKTreeListViewDelegate <NSObject>

/** 返回节点所在的 cell，必须实现 */
- (ZKTreeListViewCell *)treeListView:(ZKTreeListView *)listView cellForNode:(ZKTreeNode *)node atIndexPath:(NSIndexPath *)indexPath;

@optional
/** 点击回调 */
- (void)treeListView:(ZKTreeListView *)listView didSelectNode:(ZKTreeNode *)node atIndexPath:(NSIndexPath *)indexPath;
/**
 若设置了 node.rowHeight，优先读取 node.rowHeight；
 若未设置，则回调此代理方法，并赋值 node.rowHeight ，避免重复计算带来的性能消耗
 */
- (CGFloat)treeListView:(ZKTreeListView *)listView rowHeightForNode:(ZKTreeNode *)node atIndexPath:(NSIndexPath *)indexPath;

/** 滚动回调（实际上就是 scrollView 的部分代理方法） */
- (void)treeListView:(ZKTreeListView *)listView didScroll:(CGPoint)offset;
- (void)treeListView:(ZKTreeListView *)listView willBeginDragging:(CGPoint)offset;
- (void)treeListView:(ZKTreeListView *)listView didEndDragging:(CGPoint)offset willDecelerate:(BOOL)decelerate;

@end

@interface ZKTreeListView : UIView

/** 样式 */
@property (nonatomic, readonly, assign) ZKTreeListViewStyle style;
/** 全部数据，包含已展示的数据和未展示的数据 */
@property (nonatomic, readonly, strong) NSArray<ZKTreeNode *> *allNodes;
/** 已展示的数据 */
@property (nonatomic, readonly, strong) NSArray<ZKTreeNode *> *showNodes;
/** 展开的等级 */
@property (nonatomic, assign) NSInteger expandLevel;
/** 代理 */
@property (nonatomic, weak) id<ZKTreeListViewDelegate> delegate;
/** 当点击 cell 的时候是否自动展开/折叠（默认为YES） */
@property (nonatomic, assign, getter=isAutoExpand) BOOL autoExpand;
/** 是否显示折叠动画（默认为YES） */
@property (nonatomic, assign, getter=isShowAnimation) BOOL showAnimation;
/** 内部 tableView，请勿设置其代理 */
@property (nonatomic, readonly, strong) UITableView *tableView;

/** 初始化 */
- (instancetype)initWithFrame:(CGRect)frame style:(ZKTreeListViewStyle)style NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

/** 加载全部数据 */
- (void)loadNodes:(NSArray<ZKTreeNode *> *)nodes;
/** 重新加载一组节点 */
- (void)reloadNodes:(NSArray<ZKTreeNode *> *)nodes;
/** 在根节点末尾追加数据（会创建新的分组） */
- (void)appendNodes:(NSArray<ZKTreeNode *> *)nodes;
/** 在 node 子节点的末尾追加子节点（当 node == nil 时，在根节点末尾追加数据，与 -appendNodes: 的区别是：此方法不会创建新的分组） */
- (void)appendChildNodes:(NSArray<ZKTreeNode *> *)nodes forNode:(nullable ZKTreeNode *)node;
/** 删除一个节点（包含子节点） */
- (void)deleteNode:(ZKTreeNode *)node;

/** 全部展开/折叠到多少层级 */
- (void)expandAllNodesWithLevel:(NSInteger)expandLevel;
/** 展开/折叠一组 nodes */
- (void)expandNodes:(NSArray<ZKTreeNode *> *)nodes withExpand:(BOOL)isExpand;

/** 注册自定义cell，必须继承自<ZKTreeTableViewCell> */
- (void)registerClass:(nullable Class)cellClass forCellReuseIdentifier:(NSString *)identifier;
- (__kindof ZKTreeListViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath;
/** 根据 node 获取其所在的 cell */
- (nullable __kindof ZKTreeListViewCell *)cellForNode:(ZKTreeNode *)node;
- (nullable __kindof ZKTreeListViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;
/** 根据等级返回相应的缩进宽度 */
- (CGFloat)indentationWidthWithLevel:(NSInteger)level;

@end

NS_ASSUME_NONNULL_END
