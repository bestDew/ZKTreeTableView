//
//  CustomCell.m
//  ZKTreeTableView
//
//  Created by bestdew on 2018/9/4.
//  Copyright © 2018年 bestdew. All rights reserved.
//

#import "CustomCell.h"
#import "CommentsModel.h"

@interface CustomCell ()

@property (nonatomic, weak) UIImageView *arrowImgView;
@property (nonatomic, weak) UILabel *titleLabel;

@end

@implementation CustomCell

#pragma mark -- Init
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self addSubViews];
    }
    return self;
}

#pragma mark -- Other
- (void)addSubViews
{
    UIImageView *arrowImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow"]];
    [self.containerView addSubview:arrowImgView];
    _arrowImgView = arrowImgView;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    [self.containerView addSubview:titleLabel];
    _titleLabel = titleLabel;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _arrowImgView.frame = CGRectMake(0.f, 12.f, 20.f, 20.f);
    
    CGFloat titleX = (_arrowImgView.isHidden) ? 0.f : 30.f;
    _titleLabel.frame = CGRectMake(titleX, 0, self.containerView.frame.size.width - 15.f - titleX, 44.f);
}

- (void)refreshArrowDirection:(CGFloat)angle animated:(BOOL)animated
{
    if (CGAffineTransformEqualToTransform(_arrowImgView.transform, CGAffineTransformMakeRotation(angle))) return;
    
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            _arrowImgView.transform = CGAffineTransformMakeRotation(angle);
        }];
    } else {
        _arrowImgView.transform = CGAffineTransformMakeRotation(angle);
    }
}

#pragma mark -- Setter && Getter
- (void)setNode:(ZKTreeNode *)node
{
    [super setNode:node];
    
    CommentsModel *model = (CommentsModel *)node.data;
    _titleLabel.text = model.nick_name;
    
    _arrowImgView.hidden = (node.childNodes.count <= 0);
    
    CGFloat angle = (node.isExpand) ? M_PI_2 : 0.f;
    [self refreshArrowDirection:angle animated:NO];
}

@end
