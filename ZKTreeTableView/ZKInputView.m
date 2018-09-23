//
//  ZKInputView.m
//  ZKTreeTableView
//
//  Created by bestdew on 2018/9/23.
//  Copyright © 2018年 bestdew. All rights reserved.
//

#import "ZKInputView.h"

#define ZK_SCREEN_W [UIScreen mainScreen].bounds.size.width
#define ZK_SCREEN_H [UIScreen mainScreen].bounds.size.height

@interface ZKInputView () <UITextViewDelegate, UIGestureRecognizerDelegate>
{
    CGFloat _lineHeight;
}
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) UIButton *sendButton;
@property (nonatomic, weak) UITextView *textView;
@property (nonatomic, weak) UILabel *placeholderLabel;

@end

@implementation ZKInputView

- (instancetype)init
{
    if (self = [super init]) {
        
        _maxLine = 3;
        _maxCount = 200;
        
        [self addSubviews];
        [self addGestureRecognizer];
        [self registerNotification];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        _maxLine = 3;
        _maxCount = 200;
        
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        
        [self addSubviews];
        [self addGestureRecognizer];
        [self registerNotification];
    }
    return self;
}

- (void)clearText
{
    _textView.text = nil;
    [_textView.delegate textViewDidChange:_textView];
}

- (void)tapAction:(UIGestureRecognizer *)gesture
{
    [self hide];
}

- (void)keyboardNotification:(NSNotification *)notification
{
    if (!_textView.isFirstResponder) return;
    
    NSValue *frameValue = [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGFloat keyboardHeight = frameValue.CGRectValue.size.height; // 键盘高度
    CGFloat duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]; // 获取键盘动画持续时间
    NSUInteger curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue]; // 获取动画曲线
    CGFloat contentY = 0.f;
    
    if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) { // 键盘显示
        contentY = ZK_SCREEN_H - keyboardHeight - _contentView.frame.size.height;
    } else if ([notification.name isEqualToString:UIKeyboardWillHideNotification]){ // 键盘隐藏
        contentY = ZK_SCREEN_H;
    }
    
    [UIView animateWithDuration:duration delay:0.f options:curve animations:^{
        _contentView.frame = CGRectMake(0, contentY, ZK_SCREEN_W, 48.f);
    } completion:^(BOOL finished) {
        if ([notification.name isEqualToString:UIKeyboardWillHideNotification]) {
            [self removeFromSuperview];
        }
    }];
}

- (void)show
{
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    [window addSubview:self];
    
    if ([self.delegate respondsToSelector:@selector(inputViewWillShow:)]) {
        [self.delegate inputViewWillShow:self];
    }
    [self clearText];
    [_textView becomeFirstResponder];
}

- (void)hide
{
    if ([self.delegate respondsToSelector:@selector(inputViewWillHide:)]) {
        [self.delegate inputViewWillHide:self];
    }
    [self clearText];
    [_textView resignFirstResponder];
}

- (void)sendButtonAction:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(inputView:didSendText:)]) {
        [self.delegate inputView:self didSendText:self.inputText];
    }
}

#pragma mark -- UIGestureRecognizer Delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return ![touch.view isDescendantOfView:_contentView];
}

#pragma mark -- UITextView Delegate
- (void)textViewDidChange:(UITextView *)textView
{
    NSInteger textCount = textView.text.length;
    
    _placeholderLabel.hidden = (textCount != 0);
    _sendButton.enabled = (textCount != 0);
    
    if (textCount > _maxCount) {
        textView.text = [textView.text substringToIndex:_maxCount];
        return;
    }
    
    [UIView animateWithDuration:0.2f animations:^{
        
        CGFloat tempHeight = (textView.contentSize.height > 32.f) ? textView.contentSize.height : 32.f;
        CGFloat maxTextViewHeight = _lineHeight * _maxLine;
        CGFloat contentHeight = (tempHeight > maxTextViewHeight) ? maxTextViewHeight : tempHeight;
        CGRect textViewFrame = textView.frame;
        textViewFrame.size.height = contentHeight;
        textView.frame = textViewFrame;
        
        CGRect contentFrame = _contentView.frame;
        CGFloat height = contentHeight + 16.f;
        CGFloat changeHeight = height - contentFrame.size.height;
        contentFrame.origin.y -= changeHeight;
        contentFrame.size.height = height;
        _contentView.frame = contentFrame;
        
        CGRect sendButtonFrame = _sendButton.frame;
        sendButtonFrame.origin.y = (contentFrame.size.height - 32.f) / 2;
        _sendButton.frame = sendButtonFrame;
    } completion:^(BOOL finished) {
        
        [textView scrollRangeToVisible:NSMakeRange(textView.selectedRange.location, 1)];
    }];
}

#pragma mark -- Setter && Getter
- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    _placeholderLabel.text = placeholder;
}

- (void)setMaxLine:(NSInteger)maxLine
{
    _maxLine = (maxLine <= 0) ? 3 : maxLine;
}

- (void)setMaxCount:(NSInteger)maxCount
{
    _maxCount = (maxCount <= 0) ? 200 : maxCount;
}

- (void)setFont:(UIFont *)font
{
    _font = font;
    _textView.font = font;
    _placeholderLabel.font = font;
    
    _lineHeight = font.lineHeight;
    CGFloat leading = (_textView.frame.size.height - _lineHeight) / 2;
    _textView.textContainerInset = UIEdgeInsetsMake(leading, 8.f, leading, 0);
}

- (void)setInputText:(NSString *)inputText
{
    _textView.text = inputText;
    [_textView.delegate textViewDidChange:_textView];
}

- (NSString *)inputText
{
    return _textView.text;
}

- (void)setFrame:(CGRect)frame
{
    CGRect rect = UIScreen.mainScreen.bounds;
    [super setFrame:rect];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    UIColor *clearColor = [UIColor clearColor];
    [super setBackgroundColor:clearColor];
}

#pragma mark -- Other
- (void)addGestureRecognizer
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
}

- (void)registerNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardNotification:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)addSubviews
{
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, ZK_SCREEN_H, ZK_SCREEN_W, 48.f)];
    contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:contentView];
    _contentView = contentView;
    
    CALayer *lineLayer = [CALayer layer];
    lineLayer.frame = CGRectMake(0, 0, self.frame.size.width, 1.f);
    lineLayer.backgroundColor = [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.00].CGColor;
    [contentView.layer addSublayer:lineLayer];
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(16.f, 7.f, self.frame.size.width - 85.f, 32.f)];
    textView.delegate = self;
    textView.scrollsToTop = NO;
    textView.textContainer.lineFragmentPadding = 0;
    textView.enablesReturnKeyAutomatically = YES;
    textView.layoutManager.allowsNonContiguousLayout = NO;
    textView.layer.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00].CGColor;
    textView.layer.masksToBounds = YES;
    textView.layer.cornerRadius = 8.f;
    [contentView addSubview:textView];
    _textView = textView;
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendButton.frame = CGRectMake(CGRectGetMaxX(textView.frame), 7.f, 69.f, 32.f);
    sendButton.titleLabel.font = [UIFont systemFontOfSize:18.f];
    sendButton.enabled = NO;
    [sendButton setTitle:@"发表" forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor colorWithRed:0.86 green:0.39 blue:0.32 alpha:1.00] forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor colorWithRed:0.53 green:0.54 blue:0.55 alpha:1.00] forState:UIControlStateDisabled];
    [sendButton addTarget:self action:@selector(sendButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:sendButton];
    _sendButton = sendButton;
    
    UILabel *placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(24.f, 12.f, textView.frame.size.width - 16.f, 22.f)];
    placeholderLabel.font = [UIFont systemFontOfSize:16.f];
    placeholderLabel.textColor = [UIColor colorWithRed:0.72 green:0.73 blue:0.75 alpha:1.00];
    [contentView addSubview:placeholderLabel];
    _placeholderLabel = placeholderLabel;
    
    [self setFont:[UIFont systemFontOfSize:17.f]];
}

- (void)dealloc
{
    NSLog(@"ZKInputView->销毁！");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
