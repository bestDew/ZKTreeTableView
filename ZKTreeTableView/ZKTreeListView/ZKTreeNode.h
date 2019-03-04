//
//  ZKTreeNode.h
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

#import <Foundation/Foundation.h>

@import CoreGraphics.CGBase;

NS_ASSUME_NONNULL_BEGIN

@interface ZKTreeNode : NSObject

@property (nonatomic, readonly, copy) NSString *ID;        // 节点唯一标识
@property (nonatomic, readonly, copy) NSString *parentID;  // 父节点唯一标识
@property (nonatomic, readonly, assign) NSInteger order;   // 节点在其父节点的子节点数组中的排序依据
@property (nonatomic, readonly, strong) id data;           // 节点完整数据，可以是数据模型

@property (nonatomic, assign) NSInteger level;              // 节点所处层级（0，1，2...）
@property (nonatomic, assign) CGFloat rowHeight;            // 行高
@property (nonatomic, assign, getter=isExpand) BOOL expand; // 节点展开状态（YES：展开，NO：折叠）

@property (nonatomic, assign) NSInteger childNodesCount;    // 子节点总数（用于分页）
@property (nonatomic, assign) NSInteger pageIndex;          // 分页页码（默认为1）

@property (nullable, nonatomic, weak)   ZKTreeNode *parentNode; // 父节点
@property (nullable, nonatomic, strong) NSMutableArray<ZKTreeNode *> *childNodes; // 子节点数组

/** 快捷初始化 */
- (instancetype)initWithID:(NSString *)ID
                  parentID:(NSString *)pID
                 sortOrder:(NSInteger)order
                      data:(nullable id)data;

+ (instancetype)nodeWithID:(NSString *)ID
                  parentID:(NSString *)pID
                 sortOrder:(NSInteger)order
                      data:(nullable id)data;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/** 判断两个节点是否相同（⚠️仅比较节点 ID ）*/
- (BOOL)isEqualToNode:(ZKTreeNode *)node;
- (BOOL)isTail;

@end

FOUNDATION_EXTERN NSString * const kTailIDPrefix;

NS_ASSUME_NONNULL_END
