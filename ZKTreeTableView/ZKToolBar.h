//
//  ZKToolBar.h
//  ZKTreeTableView
//
//  Created by bestdew on 2018/9/23.
//  Copyright © 2018年 bestdew. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZKToolBar;

@protocol ZKToolBarDelegate <NSObject>

@optional
- (void)toolBar:(ZKToolBar *)toolBar didCilckAtIndex:(NSInteger)index;

@end

@interface ZKToolBar : UIView

@property (nonatomic, weak) id<ZKToolBarDelegate> delegate;
@property (nonatomic, assign) NSInteger brigeCount;

@end
