//
//  ZKTreeManager.h
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

#import <Foundation/Foundation.h>

@class ZKTreeItem;

@interface ZKTreeManager : NSObject

/** 获取可见的节点 */
@property (nonatomic, readonly, strong) NSMutableArray<ZKTreeItem *> *showItems;

/**
 唯一初始化方法

 @param items 原始数据包装成 treeItems 数组
 @param level 折叠/展开等级，为 0 全部折叠，为 1 展开一级，以此类推，为 NSIntegerMax 全部展开
 @return treeManager 实例对象
 */
- (instancetype)initWithItems:(NSArray<ZKTreeItem *> *)items andExpandLevel:(NSInteger)level;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/** 展开/收起 Item，返回所改变的 Item 的个数 */
- (NSInteger)expandItem:(ZKTreeItem *)item;
- (NSInteger)expandItem:(ZKTreeItem *)item isExpand:(BOOL)isExpand;
/** 展开/折叠到多少层级 */
- (void)expandItemWithLevel:(NSInteger)expandLevel completed:(void(^)(NSArray *noExpandArray))noExpandCompleted andCompleted:(void(^)(NSArray *expandArray))expandCompleted;

/** 根据 id 获取 item */
- (ZKTreeItem *)getItemWithItemId:(NSNumber *)itemId;
/** 获取所有 items */
- (NSArray *)getAllItems;

@end
