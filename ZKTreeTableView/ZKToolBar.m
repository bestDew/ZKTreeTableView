//
//  ZKToolBar.m
//  ZKTreeTableView
//
//  Created by bestdew on 2018/9/23.
//  Copyright © 2018年 bestdew. All rights reserved.
//

#import "ZKToolBar.h"

@interface ZKToolBar ()

@property (nonatomic, weak) UILabel *brigeLabel;

@end

@implementation ZKToolBar

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self addSubviews];
    }
    return self;
}

- (void)buttonAction:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(toolBar:didCilckAtIndex:)]) {
        NSInteger index = button.tag - 200;
        [self.delegate toolBar:self didCilckAtIndex:index];
    }
}

- (void)setBrigeCount:(NSInteger)brigeCount
{
    _brigeCount = brigeCount;
    
    if (brigeCount == 0) {
        _brigeLabel.text = nil;
    } else if (brigeCount > 1000) {
        _brigeLabel.text = @"1k+";
    } else {
        _brigeLabel.text = @(brigeCount).stringValue;
    }
    _brigeLabel.hidden = (brigeCount == 0);
    CGSize textSize = [_brigeLabel sizeThatFits:CGSizeMake(MAXFLOAT, 15.f)];
    CGRect rect = _brigeLabel.frame;
    rect.size.width = (textSize.width < 15.f) ? 15.f : (textSize.width + 4.f);
    _brigeLabel.frame = rect;
}

- (void)addSubviews
{
    CALayer *lineLayer = [CALayer layer];
    lineLayer.frame = CGRectMake(0, 0, self.frame.size.width, 1.f);
    lineLayer.backgroundColor = [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.00].CGColor;
    [self.layer addSublayer:lineLayer];
    
    UIButton *inputButton = [UIButton buttonWithType:UIButtonTypeCustom];
    inputButton.frame = CGRectMake(16.f, 7.f, self.frame.size.width - 128.f, 32.f);
    inputButton.tag = 200;
    inputButton.layer.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00].CGColor;
    inputButton.layer.masksToBounds = YES;
    inputButton.layer.cornerRadius = 8.f;
    inputButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    inputButton.titleEdgeInsets = UIEdgeInsetsMake(5.f, 8.f, 5.f, 0);
    inputButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
    [inputButton setTitle:@"我来说两句" forState:UIControlStateNormal];
    [inputButton setTitleColor:[UIColor colorWithRed:0.72 green:0.73 blue:0.75 alpha:1.00] forState:UIControlStateNormal];
    [inputButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:inputButton];
    
    UIButton *viewcButton = [UIButton buttonWithType:UIButtonTypeCustom];
    viewcButton.frame = CGRectMake(CGRectGetMaxX(inputButton.frame) + 20.f, 13.f, 24.f, 21.f);
    viewcButton.tag = 201;
    [viewcButton setImage:[UIImage imageNamed:@"ic_comment_new"] forState:UIControlStateNormal];
    [viewcButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:viewcButton];
    
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    shareButton.frame = CGRectMake(CGRectGetMaxX(viewcButton.frame) + 25.f, 10.f, 25.f, 25.f);
    shareButton.tag = 202;
    [shareButton setImage:[UIImage imageNamed:@"share_normal"] forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:shareButton];
    
    UILabel *brigeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(viewcButton.frame) - 10.f, viewcButton.frame.origin.y - 4.f, 15.f, 13.f)];
    brigeLabel.font = [UIFont systemFontOfSize:9.f];
    brigeLabel.textColor = [UIColor whiteColor];
    brigeLabel.hidden = YES;
    brigeLabel.textAlignment = NSTextAlignmentCenter;
    brigeLabel.layer.backgroundColor = [UIColor redColor].CGColor;
    brigeLabel.layer.masksToBounds = YES;
    brigeLabel.layer.cornerRadius = 2.f;
    [self addSubview:brigeLabel];
    _brigeLabel = brigeLabel;
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
}

@end
