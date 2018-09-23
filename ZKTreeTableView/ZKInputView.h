//
//  ZKInputView.h
//  ZKTreeTableView
//
//  Created by bestdew on 2018/9/23.
//  Copyright © 2018年 bestdew. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZKInputView;

@protocol ZKInputViewDelagete <NSObject>

@optional
/** 将要显示的回调 */
- (void)inputViewWillShow:(ZKInputView *)inputView;
/** 将要隐藏的回调 */
- (void)inputViewWillHide:(ZKInputView *)inputView;
/** 点击了发送按钮的回调 */
- (void)inputView:(ZKInputView *)inputView didSendText:(NSString *)text;

@end

@interface ZKInputView : UIView

/** 输入框最大行数（默认：3） */
@property (nonatomic, assign) NSInteger maxLine;
/** 输入的最大字数（默认：200）*/
@property (nonatomic, assign) NSInteger maxCount;
/** 占位文字 */
@property (nonatomic, copy) NSString *placeholder;
/** 文字大小 */
@property (nonatomic, strong) UIFont *font;
/** 输入的文字 */
@property (nonatomic, copy) NSString *inputText;
/** 代理 */
@property (nonatomic, weak) id<ZKInputViewDelagete> delegate;

/** 展示 */
- (void)show;
/** 隐藏 */
- (void)hide;
/** 清理文字 */
- (void)clearText;

@end
