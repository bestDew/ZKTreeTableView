//
//  CustomCell.m
//  ZKTreeTableView
//
//  Created by bestdew on 2018/9/4.
//  Copyright © 2018年 bestdew. All rights reserved.
//

#import "CheckCell.h"
#import "CommentsModel.h"

@interface CheckCell ()

@property (nonatomic, weak) UIImageView *arrowImgView;
@property (nonatomic, weak) UILabel *titleLabel;

@end

@implementation CheckCell

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
    [self.view addSubview:arrowImgView];
    _arrowImgView = arrowImgView;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    [self.view addSubview:titleLabel];
    _titleLabel = titleLabel;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat arrowX = (self.node.level == 0) ? 16.f : 10.f;
    _arrowImgView.frame = CGRectMake(arrowX, 12.f, 20.f, 20.f);
    
    CGFloat titleX = (_arrowImgView.isHidden) ? 16.f : 46.f;
    _titleLabel.frame = CGRectMake(titleX, 0, self.view.frame.size.width - titleX - 16.f, 44.f);
}

- (void)refreshArrowDirection:(CGFloat)angle animated:(BOOL)animated
{
    if (CGAffineTransformEqualToTransform(_arrowImgView.transform, CGAffineTransformMakeRotation(angle))) return;
    
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
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
