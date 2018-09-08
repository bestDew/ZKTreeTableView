//
//  ZKTreeListViewCell.m
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

#import "ZKTreeListViewCell.h"

@interface ZKLayer : CALayer
@end

@implementation ZKLayer

- (instancetype)init
{
    if (self = [super init]) {
        self.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.00].CGColor;
    }
    return self;
}

@end

@interface ZKTreeListViewCell ()

@property (nonatomic, assign) CGFloat indenWidth; // 缩进宽度，默认为8.f
@property (nonatomic, strong) CALayer *horizontalLine;
@property (nonatomic, strong) CALayer *verticalLine;
@property (nonatomic, strong) CALayer *separator;
@property (nonatomic, assign) BOOL showStructureLine; // 用于标记是否显示结构线

@end


@implementation ZKTreeListViewCell

#pragma mark -- 初始化
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.indenWidth = 8.f;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.containerView];;
    }
    return self;
}

#pragma mark -- Other
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat x = 0.f;
    CGFloat maxWidth  = self.contentView.frame.size.width;
    CGFloat maxHeight = self.contentView.frame.size.height;
    
    // 禁用隐式动画
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    if (_node.level == 0) {
        x = 16.f;
        _horizontalLine.frame = CGRectZero;
    } else if (_node.level == 1) {
        x = 48.f;
        _horizontalLine.frame = CGRectMake(x - 12.f, 27.5f, 12.f, 1.f);
    } else {
        x = 68.f + (_node.level - 2) * (self.indenWidth + 12.f);
        _horizontalLine.frame = CGRectMake(x - self.indenWidth, 27.5f, self.indenWidth, 1.f);
    }
    
    CGFloat radius = (_node.level == 0) ? 20.f : 12.f;
    CGFloat verticalLineY = 16.f + radius * 2;
    CGFloat verticalLineWidth = (_node.childNodes.count == 0 || !_node.isExpand) ? 0.f : 1.0f;
    
    _verticalLine.frame = CGRectMake(x + radius - 0.5, verticalLineY, verticalLineWidth, maxHeight - verticalLineY);
    
    CGFloat containerHeight = (_showStructureLine) ? maxHeight : (maxHeight - 0.5f);
    _containerView.frame = CGRectMake(x, 0.f, maxWidth - x, containerHeight);
    _separator.frame = CGRectMake(x, containerHeight, maxWidth - x, 0.5f);
    
    [CATransaction commit];
}

- (void)removeAllLineLayers
{
    NSArray<CALayer *> *subLayers = self.contentView.layer.sublayers;
    NSArray<CALayer *> *removedLayers = [subLayers filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [evaluatedObject isMemberOfClass:[ZKLayer class]];
    }]];
    [removedLayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperlayer];
    }];
}

- (void)parentNode:(ZKTreeNode *)pNode mutArray:(NSMutableArray<NSNumber *> *)mutArray
{
    if (pNode.level == 0) return;
    
    if (pNode.parentNode.childNodes.lastObject == pNode) {
        [mutArray addObject:@(pNode.level - 1)];
    }
    [self parentNode:pNode.parentNode mutArray:mutArray];
}

- (void)addStructureLine
{
    // 移除之前的结构线
    [self removeAllLineLayers];
    
    if (!_showStructureLine) return;
    
    // 由 node 的父节点递归到根节点，寻找当前等级下的叶节点并保存
    NSMutableArray<NSNumber *> *mutArray = @[].mutableCopy;
    [self parentNode:_node.parentNode mutArray:mutArray];
    
    CGFloat lineHeight = self.contentView.frame.size.height;
    
    for (NSInteger i = 0; i < _node.level; i++) {
        // 若 node 父节点为叶节点，则该 level 下不绘制结构线
        if ([mutArray containsObject:@(i)]) continue;
        
        CGFloat lineX = 0.f;
        
        if (i == 0) {
            lineX = 35.5f;
        } else if (i == 1) {
            lineX = 59.5f;
        } else {
            lineX = 59.5f + (i - 1) * (self.indenWidth + 12.f);
        }
        // 判断 node 是否为叶节点
        NSArray<ZKTreeNode *> *nodes = _node.parentNode.childNodes;
        if ((nodes.lastObject == _node) && i == _node.level - 1) {
            lineHeight = 28.f;
        }
        // 绘制结构线
        ZKLayer *otherLine = [ZKLayer layer];
        otherLine.frame = CGRectMake(lineX, 0.f, 1.0, lineHeight);
        [self.contentView.layer addSublayer:otherLine];
    }
}

// 限制 cell 事件响应区域
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    CGPoint pt = [self.contentView convertPoint:point toView:self.containerView];
    if ([self.containerView pointInside:pt withEvent:event]) {
        return [super hitTest:point withEvent:event];
    }
    return nil;
}

#pragma mark -- Setter && Getter
- (void)setShowStructureLine:(BOOL)showStructureLine
{
    _showStructureLine = showStructureLine;
    
    if (showStructureLine) {
        [_separator removeFromSuperlayer];
        _separator = nil;
        [self.contentView.layer addSublayer:self.horizontalLine];
        [self.contentView.layer addSublayer:self.verticalLine];
    } else {
        [_horizontalLine removeFromSuperlayer];
        [_verticalLine removeFromSuperlayer];
        _horizontalLine = nil;
        _verticalLine = nil;
        [self.contentView.layer addSublayer:self.separator];
    }
    [self addStructureLine];
}

- (void)setNode:(ZKTreeNode *)node
{
    _node = node;
    
    [self addStructureLine];
}

- (UIView *)containerView
{
    if (_containerView == nil) {
        
        _containerView = [[UIView alloc] initWithFrame:CGRectZero];
        _containerView.backgroundColor = [UIColor whiteColor];
    }
    return _containerView;
}

- (CALayer *)horizontalLine
{
    if (_horizontalLine == nil) {
        
        _horizontalLine = [CALayer layer];
        _horizontalLine.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.00].CGColor;
    }
    return _horizontalLine;
}

- (CALayer *)verticalLine
{
    if (_verticalLine == nil) {
        
        _verticalLine = [CALayer layer];
        _verticalLine.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.00].CGColor;
    }
    return _verticalLine;
}

- (CALayer *)separator
{
    if (_separator == nil) {
        
        _separator = [CALayer layer];
        _separator.backgroundColor = [UIColor lightGrayColor].CGColor;
    }
    return _separator;
}

@end
