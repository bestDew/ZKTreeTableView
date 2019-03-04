//
//  ZKTreeListViewCell.h
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
#import "ZKTreeNode.h"

@interface ZKTreeListViewCell : UITableViewCell

/** 内容视图，子类添加子控件需添加在内容容器上 */
@property (nonatomic, readonly, strong) UIView *view;
/** 子类中重写 -setNode: 方法，通过 node.data 进行赋值处理 */
@property (nonatomic, strong) ZKTreeNode *node;
/** 是否显示结构线 */
@property (nonatomic, assign) BOOL showStructureLine;

@end

typedef NS_ENUM(NSInteger, ZKTreeTailCellState) {
    ZKTreeTailCellStateIdle,     // 闲置状态
    ZKTreeTailCellStateLoading,  // 加载中...
    ZKTreeTailCellStateLoadError // 加载失败
};

@interface ZKTreeTailCell : ZKTreeListViewCell

/** 当前状态 */
@property (nonatomic, assign) ZKTreeTailCellState state;

/** 设置响应状态下的文字 */
- (void)setText:(NSString *)text forState:(ZKTreeTailCellState)state;

@end
