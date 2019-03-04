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
#import "ZKTreeNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZKTreeManager : NSObject

/** 所有可见节点 */
@property (nonatomic, readonly, strong) NSMutableArray<ZKTreeNode *> *showNodes;
/** 所有节点 */
@property (nonatomic, readonly, strong) NSMutableSet<ZKTreeNode *> *allNodes;
/** 最小等级 */
@property (nonatomic, readonly, assign) NSInteger minLevel;
/** 最大等级 */
@property (nonatomic, readonly, assign) NSInteger maxLevel;
/** 当前展示的最大等级（默认为 minLevel） */
@property (nonatomic, readonly, assign) NSInteger showLevel;

/**
 初始化方法
 
 @param nodes 节点数组
 @param minLevel 节点最小等级
 @param expandLevel 默认展开的等级
 @return manager 实例
 */
- (instancetype)initWithNodes:(NSArray<ZKTreeNode *> *)nodes
                     minLevel:(NSInteger)minLevel
                  expandLevel:(NSInteger)expandLevel;

+ (instancetype)managerWithNodes:(NSArray<ZKTreeNode *> *)nodes
                        minLevel:(NSInteger)minLevel
                     expandLevel:(NSInteger)expandLevel;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 给父节点增加一组子节点
 
 @param nodes 子节点数组
 @param node 父节点（若 node 为空，则追加在根节点）
 @param isTop 是否置顶（若为 YES：追加在头部，为 NO 则追加在末尾）
 */
- (void)addChildNodes:(NSArray<ZKTreeNode *> *)nodes
              forNode:(nullable ZKTreeNode *)node
          placedAtTop:(BOOL)isTop;
/** 删除一个节点（包含子节点） */
- (void)deleteNode:(ZKTreeNode *)node;

/** 展开/收起 node，返回所改变的 node 的个数 */
- (NSInteger)expandNode:(ZKTreeNode *)node expand:(BOOL)isExpand;
/**
 展开/折叠到多少层级
 
 @param expandLevel 等级
 @param noExpandCompleted 返回折叠所改变的所有节点
 @param expandCompleted 返回展开所改变的所有节点
 */
- (void)expandAllNodesWithLevel:(NSInteger)expandLevel
              noExpandCompleted:(void(^)(NSArray<ZKTreeNode *> *noExpandArray))noExpandCompleted
                expandCompleted:(void(^)(NSArray<ZKTreeNode *> *expandArray))expandCompleted;

/** 向上查找相差 grades 个等级 的 node 的父节点 */
- (nullable ZKTreeNode *)parentNodeWithNode:(ZKTreeNode *)node grades:(NSInteger)grades;
/** 获取 node 所有的子节点，包含子节点的子节点 */
- (NSArray<ZKTreeNode *> *)childNodesForNode:(ZKTreeNode *)node;
/** 根据节点 ID 获取 节点 */
- (nullable ZKTreeNode *)nodeForID:(NSString *)ID;

@end

NS_ASSUME_NONNULL_END
