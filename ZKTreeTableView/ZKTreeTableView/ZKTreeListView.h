//
//  ZKTreeListView.h
//  ZKTreeTableView
//
//  Created by bestdew on 2018/8/29.
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

@class ZKTreeListView;

typedef NS_ENUM(NSInteger, ZKTreeListViewStyle) {
    ZKTreeListViewStyleNone,          // 默认
    ZKTreeListViewStyleStructureLine, // 带有结构线
};

@protocol ZKTreeListViewDelegate <NSObject>

@optional;
/** 点击回调 */
- (void)treeListView:(ZKTreeListView *)listView didSelectRowAtIndexPath:(NSIndexPath *)indexPath withItem:(ZKTreeItem *)item;
/** 若实现此代理方法，则 cell 的高度根据代理方法返回的高度而定；若未实现，则默认读取 treeItem.itemHeight */
- (CGFloat)treeListView:(ZKTreeListView *)listView heightForItem:(ZKTreeItem *)item;

@end

@interface ZKTreeListView : UIView
/** 默认展开级数 */
@property (nonatomic, assign) NSInteger defaultExpandLevel;
/** 数据源 */
@property (nonatomic, strong) NSArray<ZKTreeItem *> *items;
/** 代理 */
@property (nonatomic, weak) id<ZKTreeListViewDelegate> delegate;
/** 风格 */
@property (nonatomic, assign) ZKTreeListViewStyle style;
/** 头视图 */
@property (nonatomic, strong) UIView *headerView;
/** 尾视图 */
@property (nonatomic, strong) UIView *footerView;
/** 当点击 cell 的时候是否自动展开/折叠（默认为YES） */
@property (nonatomic, assign, getter=isAutoExpand) BOOL autoExpand;
/** 是否展示折叠动画（默认为YES） */
@property (nonatomic, assign, getter=isShowExpandAnimation) BOOL showExpandAnimation;

/** 初始化 */
- (instancetype)initWithFrame:(CGRect)frame style:(ZKTreeListViewStyle)style NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

/** 注册自定义cell，必须继承自<ZKTreeTableViewCell> */
- (void)registerClass:(nullable Class)cellClass forCellReuseIdentifier:(NSString *)identifier;

/** 重新加载 */
- (void)reloadData;

/** 全部展开/全部折叠 */
- (void)expandAllItems:(BOOL)isExpand;

/** 展开/折叠到多少层级 */
- (void)expandItemWithLevel:(NSInteger)expandLevel;

/** 展开/折叠一组 item */
- (void)expandItems:(NSArray<ZKTreeItem *> *)items isExpand:(BOOL)isExpand;

/** 获取当前显示的 items */
- (NSArray<ZKTreeItem *> *)getShowItems;

/** 获取所有的 Items */
- (NSArray<ZKTreeItem *> *)getAllItems;

/** 根据 level 返回相应的 containerView 宽度 */
- (CGFloat)containerViewWidthWithLevel:(NSInteger)level;

/** 获取 cell 在屏幕中的坐标值 */
- (CGRect)rectInScreenForRowAtIndexPath:(NSIndexPath *)indexPath;

/** 根据 cell 获取 indexPath */
- (nullable NSIndexPath *)indexPathForCell:(ZKTreeListViewCell *)cell;

/** 根据 indexPath 获取 cell */
- (nullable __kindof ZKTreeListViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;

/** 滚动到指定位置 */
- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;

@end
