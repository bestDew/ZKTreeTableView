//
//  ZKTreeManager.h
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

@class ZKTreeNode;

@interface ZKTreeManager : NSObject

/** 获取当前 manager 的可见节点 */
@property (nonatomic, readonly, strong) NSArray<ZKTreeNode *> *showNodes;
/** 获取当前 manager 的所有节点 */
@property (nonatomic, readonly, strong) NSArray<ZKTreeNode *> *allNodes;

/**
 唯一初始化方法
 
 @param nodes 原始数据包装成 treeNodes 数组
 @param level 折叠/展开等级，为 0 全部折叠，为 1 展开一级，以此类推，为 NSIntegerMax 全部展开
 @return treeManager 实例对象
 */
- (instancetype)initWithNodes:(NSArray<ZKTreeNode *> *)nodes andExpandLevel:(NSInteger)level;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/** 展开/收起 node，返回所改变的 node 的个数 */
- (NSInteger)expandNode:(ZKTreeNode *)node;
- (NSInteger)expandNode:(ZKTreeNode *)node expand:(BOOL)isExpand;
/** 展开/折叠到多少层级 */
- (void)expandNodesWithLevel:(NSInteger)expandLevel completed:(void(^)(NSArray *noExpandArray))noExpandCompleted andCompleted:(void(^)(NSArray *expandArray))expandCompleted;

/** 根据 ID 获取 node */
- (ZKTreeNode *)getNodeWithNodeID:(NSString *)ID;

@end
