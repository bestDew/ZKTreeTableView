//
//  ZKTreeNode.m
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

#import "ZKTreeNode.h"

@implementation ZKTreeNode

- (instancetype)initWithID:(NSString *)ID parentID:(NSString *)pID sortOrder:(NSInteger)order data:(id)data
{
    if (self = [super init]) {
        
        _ID = ID;
        _parentID = pID;
        _order = order;
        _data = data;
        _level = -1;
        _expand = NO;
        _rowHeight = -1.f;
        _pageIndex = 1;
        _childNodesCount = -1;
        _parentNode = nil;
        _childNodes = @[].mutableCopy;
    }
    return self;
}

+ (instancetype)nodeWithID:(NSString *)ID parentID:(NSString *)pID sortOrder:(NSInteger)order data:(id)data
{
    return [[self alloc] initWithID:ID parentID:pID sortOrder:order data:data];
}

- (BOOL)isEqualToNode:(ZKTreeNode *)node
{
    if (!node) return NO;
    
    return [self.ID isEqualToString:node.ID];
}

- (BOOL)isEqual:(id)object
{
    if (self == object) return YES;
    if (![object isKindOfClass:[ZKTreeNode class]]) {
        return NO;
    }
    return [self isEqualToNode:(ZKTreeNode *)object];
}

- (BOOL)isTail
{
    return [self.ID hasPrefix:@"node_tail_"];
}

- (void)setLevel:(NSInteger)level
{
    _level = MAX(level, 0);
}

- (void)setRowHeight:(CGFloat)rowHeight
{
    _rowHeight = MAX(rowHeight, 0);
}

- (void)setChildNodesCount:(NSInteger)childNodesCount
{
    _childNodesCount = MAX(childNodesCount, 0);
}

@end
