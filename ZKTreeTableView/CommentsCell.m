//
//  CommentCell.m
//  ZKTreeTableView
//
//  Created by bestdew on 2018/8/30.
//  Copyright © 2018年 bestdew. All rights reserved.
//

#import "CommentsCell.h"
#import "CommentsModel.h"

@interface CommentsCell ()

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *nickNameLabel;
@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation CommentsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self.containerView addSubview:self.imgView];
        [self.containerView addSubview:self.nickNameLabel];
        [self.containerView addSubview:self.contentLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat imgSize = (self.node.level == 0) ? 40.f : 24.f;
    
    _imgView.frame = CGRectMake(0.f, 16.f, imgSize, imgSize);
    _imgView.layer.cornerRadius = imgSize / 2;
    _nickNameLabel.frame = CGRectMake(imgSize + 12.f, 20.f, self.containerView.frame.size.width - imgSize - 28.f, 20.f);
    _contentLabel.frame = CGRectMake(imgSize + 4.f, CGRectGetMaxY(_nickNameLabel.frame) + 4.f, self.containerView.frame.size.width - CGRectGetMaxX(_imgView.frame) - 20.f, self.containerView.frame.size.height - CGRectGetMaxY(_nickNameLabel.frame) - 4.f);
    _contentLabel.layer.cornerRadius = 8.f;
}

- (void)setNode:(ZKTreeNode *)node
{
    [super setNode:node]; // 必须调用父类方法
    
    CommentsModel *model = (CommentsModel *)node.data;
    
    self.nickNameLabel.text = model.nick_name;
    self.imgView.image = [UIImage imageNamed:model.image_name];
    self.contentLabel.attributedText = [self attributedTextWithString:model.content];
}

- (NSAttributedString *)attributedTextWithString:(NSString *)string
{
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.alignment = NSTextAlignmentLeft;
    paraStyle.firstLineHeadIndent = 10.f;
    paraStyle.headIndent = 10.f;
    //paraStyle.lineSpacing = 2.f;
    paraStyle.tailIndent = -5.f;
    paraStyle.minimumLineHeight = 24.f;
    
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:17.f],
                          NSParagraphStyleAttributeName:paraStyle};
    NSAttributedString *attributeText = [[NSAttributedString alloc] initWithString:string attributes:dic];
    
    return attributeText;
}

- (UILabel *)nickNameLabel
{
    if (_nickNameLabel == nil) {

        _nickNameLabel = [[UILabel alloc] init];
        _nickNameLabel.font = [UIFont systemFontOfSize:14.f];
    }
    return _nickNameLabel;
}

- (UIImageView *)imgView
{
    if (_imgView == nil) {
        
        _imgView = [[UIImageView alloc] init];
    }
    return _imgView;
}

- (UILabel *)contentLabel
{
    if (_contentLabel == nil) {
        
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.layer.backgroundColor = [UIColor colorWithRed:0.94 green:0.95 blue:0.95 alpha:1.00].CGColor;
        _contentLabel.numberOfLines = 0;
    }
    return _contentLabel;
}

@end
