//
//  ZKTreeItem.m
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

#import "ZKTreeItem.h"

@implementation ZKTreeItem

- (instancetype)initWithID:(NSString *)ID
                  parentID:(NSString *)pID
                   orderNo:(NSString *)orderNo
                      data:(id)data
{
    return [self initWithID:ID
                   parentID:pID
                    orderNo:orderNo
                      level:-1
                 itemHeight:0.f
                       data:data];
}

- (instancetype)initWithID:(NSString *)ID
                  parentID:(NSString *)pID
                   orderNo:(NSString *)orderNo
                     level:(NSInteger)level
                itemHeight:(CGFloat)height
                      data:(id)data
{
    if (self = [super init]) {
        // 赋值
        _ID = ID;
        _parentID = pID;
        _orderNo = orderNo;
        _level = level;
        _itemHeight = (height <= 0.f) ? 44.f : height;
        _data = data;
        // 默认值
        _isExpand = NO;
        _childItems = @[].mutableCopy;
    }
    return self;
}

@end
