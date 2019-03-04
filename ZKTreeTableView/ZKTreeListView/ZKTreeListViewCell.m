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

@property (nonatomic, strong) CALayer *horizontalLine;
@property (nonatomic, strong) CALayer *verticalLine;

@end

@implementation ZKTreeListViewCell

CG_INLINE CGFloat CGFloatFromPixel(CGFloat value) {
    return value / UIScreen.mainScreen.scale;
}

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
    
    CGFloat x = 0.f, horLineWidth = 0.f, verLineX = 36.f, verLineY = 36.f;
    
    // 禁用隐式动画
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    if (self.showStructureLine) {
        if (_node.level == 0) {
            verLineY = 58.f;
        } else if (_node.level == 1) {
            x = 36.f;
            horLineWidth = 12.f;
            verLineX = 24.f;
        } else {
            x = 60.f + (_node.level - 2) * 20.f;
            horLineWidth = 8.f;
            verLineX = 20.f;
        }
        CGFloat horizontalLineY = 24.f - _node.isTail * 2.f;
        _horizontalLine.frame = CGRectMake(0, horizontalLineY, horLineWidth, CGFloatFromPixel(1.f));
        
        CGFloat verLineWidth = (_node.childNodes.count > 0 && _node.isExpand) ? CGFloatFromPixel(1.f) : 0.f;
        _verticalLine.frame = CGRectMake(verLineX, verLineY, verLineWidth, maxHeight - verLineY);
    } else {
        x = 30.f * _node.level;
    }
    
    _view.frame = CGRectMake(x, 0.f, maxWidth - x, maxHeight);
    
    [CATransaction commit];
}

- (void)addStructureLine
{
    // 移除之前的结构线
    [self removeAllLineLayers];
    
    if (!self.showStructureLine) return;
    
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
            lineHeight = 24.f - _node.isTail * 2.f;
        }
        // 绘制结构线
        ZKLayer *otherLine = [ZKLayer layer];
        otherLine.frame = CGRectMake(lineX, 0.f, CGFloatFromPixel(1.f), lineHeight);
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

@interface ZKTreeTailCell ()

@property (nonatomic, strong) UIView *baseView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, copy) NSString *idleStateText;
@property (nonatomic, copy) NSString *loadingStateText;
@property (nonatomic, copy) NSString *loadErrorStateText;

@end

@implementation ZKTreeTailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _idleStateText = @"点击加载更多";
        _loadingStateText = @"加载中...";
        _loadErrorStateText = @"加载失败，点击重试";
        
        [self.view addSubview:self.baseView];
        [self.baseView addSubview:self.titleLabel];
        [self.baseView addSubview:self.indicatorView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat baseViewX = (self.node.level == 1) ? 12.f : 8.f;
    CGFloat baseViewY = (self.showStructureLine) ? 12.f : 5.f;
    CGFloat baseViewW = self.view.frame.size.width - baseViewX - 16.f;
    _baseView.frame = CGRectMake(baseViewX, baseViewY, baseViewW, 24.f);
    
    CGFloat titleLabelW = [_titleLabel sizeThatFits:CGSizeMake(baseViewW - 40.f, 24.f)].width;
    CGFloat indicatorViewX = (baseViewW - titleLabelW - 24.f) * 0.5;
    _indicatorView.frame = CGRectMake(indicatorViewX, 4.f, 16.f, 16.f);
    
    CGFloat titleLabelX = indicatorViewX + 24.f;
    _titleLabel.frame = CGRectMake(titleLabelX, 0, titleLabelW, 24.f);
}

- (void)setState:(ZKTreeTailCellState)state
{
    if (state == _state) return;
    
    _state = state;
    
    switch (state) {
        case ZKTreeTailCellStateIdle:
            _titleLabel.text = _idleStateText;
            [_indicatorView stopAnimating];
            break;
        case ZKTreeTailCellStateLoading:
            _titleLabel.text = _loadingStateText;
            [_indicatorView startAnimating];
            break;
        case ZKTreeTailCellStateLoadError:
            _titleLabel.text = _loadErrorStateText;
            [_indicatorView stopAnimating];
            break;
    }
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setText:(NSString *)text forState:(ZKTreeTailCellState)state
{
    switch (state) {
        case ZKTreeTailCellStateIdle:
            _idleStateText = text;
            break;
        case ZKTreeTailCellStateLoading:
            _loadingStateText = text;
            break;
        case ZKTreeTailCellStateLoadError:
            _loadErrorStateText = text;
            break;
    }
    if (_state == state) _titleLabel.text = text;
}

- (UIView *)baseView
{
    if (_baseView == nil) {
        
        _baseView = [[UIView alloc] init];
        _baseView.backgroundColor = [UIColor colorWithRed:0.94 green:0.95 blue:0.95 alpha:1.00];
        _baseView.layer.masksToBounds = YES;
        _baseView.layer.cornerRadius = 8.f;
    }
    return _baseView;
}

- (UILabel *)titleLabel
{
    if (_titleLabel == nil) {
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:12.f];
        _titleLabel.textColor = [UIColor colorWithRed:0.53 green:0.54 blue:0.55 alpha:1.00];
        _titleLabel.text = _idleStateText;
    }
    return _titleLabel;
}

- (UIActivityIndicatorView *)indicatorView
{
    if (_indicatorView == nil) {
        
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.hidesWhenStopped = YES;
        _indicatorView.transform = CGAffineTransformMakeScale(0.8, 0.8);
    }
    return _indicatorView;
}

@end
