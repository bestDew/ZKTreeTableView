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

@property (nonatomic, assign) BOOL showStructureLine;
@property (nonatomic, strong) CALayer *horizontalLine;
@property (nonatomic, strong) CALayer *verticalLine;

@end

@implementation ZKTreeListViewCell

#pragma mark -- 初始化
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.showStructureLine = NO;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _view = [[UIView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_view];
    }
    return self;
}

#pragma mark -- Other
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat maxWidth  = self.contentView.frame.size.width;
    CGFloat maxHeight = self.contentView.frame.size.height;
    
    CGFloat x = 0.f, horLineWidth = 0.f, verLineX = 36.f, verLineY = 40.f;
    
    // 禁用隐式动画
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    if (_node.level == 0) {
        verLineY = 56.f;
    } else if (_node.level == 1) {
        x = 36.f;
        horLineWidth = 12.f;
        verLineX = 24.f;
    } else {
        x = 60.f + (_node.level - 2) * 20.f;
        horLineWidth = 8.f;
        verLineX = 20.f;
    }
    
    _view.frame = CGRectMake(x, 0.f, maxWidth - x, maxHeight);
    
    CGFloat horizontalLineY = 28.f - _node.isTail * 6.f;
    _horizontalLine.frame = CGRectMake(0, horizontalLineY, horLineWidth, 1.f);
    
    CGFloat verLineWidth = (_node.childNodes.count > 0 && _node.isExpand) ? 1.f : 0.f;
    _verticalLine.frame = CGRectMake(verLineX, verLineY, verLineWidth, maxHeight - verLineY);
    
    [CATransaction commit];
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
            lineX = 36.f;
        } else if (i == 1) {
            lineX = 60.f;
        } else {
            lineX = 60.f + (i - 1) * 20.f;
        }
        // 判断 node 是否为叶节点
        NSArray<ZKTreeNode *> *nodes = _node.parentNode.childNodes;
        if ((nodes.lastObject == _node) && i == _node.level - 1) {
            lineHeight = 28.f - _node.isTail * 6.f;
        }
        // 绘制结构线
        ZKLayer *otherLine = [ZKLayer layer];
        otherLine.frame = CGRectMake(lineX, 0.f, 1.0, lineHeight);
        [self.contentView.layer addSublayer:otherLine];
    }
}

- (void)parentNode:(ZKTreeNode *)pNode mutArray:(NSMutableArray<NSNumber *> *)mutArray
{
    if (pNode.level == 0) return;
    
    if (pNode.parentNode.childNodes.lastObject == pNode) {
        [mutArray addObject:@(pNode.level - 1)];
    }
    [self parentNode:pNode.parentNode mutArray:mutArray];
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

// 限制 cell 事件响应区域
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    CGPoint pt = [self convertPoint:point toView:_view];
    if ([_view pointInside:pt withEvent:event]) {
        return [super hitTest:point withEvent:event];
    }
    return nil;
}

#pragma mark -- Setter && Getter
- (void)setShowStructureLine:(BOOL)showStructureLine
{
    _showStructureLine = showStructureLine;
    
    if (showStructureLine) {
        [_view.layer addSublayer:self.horizontalLine];
        [_view.layer addSublayer:self.verticalLine];
    } else {
        [_horizontalLine removeFromSuperlayer];
        [_verticalLine removeFromSuperlayer];
        _horizontalLine = nil;
        _verticalLine = nil;
    }
    [self addStructureLine];
}

- (void)setNode:(ZKTreeNode *)node
{
    _node = node;
    
    [self addStructureLine];
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

@end

@interface ZKTailCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation ZKTailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self.view addSubview:self.titleLabel];
        [self.view addSubview:self.indicatorView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat titleLabelX = (self.node.level == 1) ? 12.f : 8.f;
    CGFloat titleLabelY = (self.showStructureLine) ? 12.f : 5.f;
    _titleLabel.frame = CGRectMake(titleLabelX, titleLabelY, self.view.frame.size.width - titleLabelX - 16.f, 24.f);
    _indicatorView.center = _titleLabel.center;
}

- (UILabel *)titleLabel
{
    if (_titleLabel == nil) {
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:12.f];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor colorWithRed:0.53 green:0.54 blue:0.55 alpha:1.00];
        _titleLabel.layer.backgroundColor = [UIColor colorWithRed:0.94 green:0.95 blue:0.95 alpha:1.00].CGColor;
        _titleLabel.text = @"点击加载更多";
        _titleLabel.layer.masksToBounds = YES;
        _titleLabel.layer.cornerRadius = 8.f;
    }
    return _titleLabel;
}

- (UIActivityIndicatorView *)indicatorView
{
    if (_indicatorView == nil) {
        
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.hidesWhenStopped = YES;
    }
    return _indicatorView;
}

- (void)setLoading:(BOOL)loading
{
    _loading = loading;
    
    if (loading) {
        _titleLabel.text = nil;
        [_indicatorView startAnimating];
    } else {
        _titleLabel.text = @"点击加载更多";
        [_indicatorView stopAnimating];
    }
}

@end
