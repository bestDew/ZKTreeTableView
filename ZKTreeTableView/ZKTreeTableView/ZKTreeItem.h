//
//  ZKTreeItem.h
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

@import CoreGraphics.CGBase;

@interface ZKTreeItem : NSObject

@property (nonatomic, readonly, copy) NSString *ID;         // 唯一标识
@property (nonatomic, readonly, copy) NSString *parentID;   // 父级节点唯一标识
@property (nonatomic, readonly, copy) NSString *orderNo;    // 序号

@property (nonatomic, readonly, assign) CGFloat itemHeight; // cell的行高
@property (nonatomic, readonly, strong) id data;            // 完整数据，可以是数据模型

@property (nonatomic, assign) NSInteger level;              // 层级
@property (nonatomic, assign) BOOL isExpand;                // 是否为展开状态
@property (nonatomic, weak)   ZKTreeItem *parentItem;
@property (nonatomic, strong) NSMutableArray<ZKTreeItem *> *childItems;

/**
 初始化方法

 @param ID 唯一标识
 @param pID 父级节点唯一标识
 @param orderNo 序号
 @param level 层级
 @param height cell的行高
 @param data 完整数据，可以是数据模型
 @return item实例
 */
- (instancetype)initWithID:(NSString *)ID
                  parentID:(NSString *)pID
                   orderNo:(NSString *)orderNo
                     level:(NSInteger)level
                itemHeight:(CGFloat)height
                      data:(id)data;

/** 后台数据未返回 level 时，可使用此初始化方法 */
- (instancetype)initWithID:(NSString *)ID
                  parentID:(NSString *)pID
                   orderNo:(NSString *)orderNo
                      data:(id)data;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end
