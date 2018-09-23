//
//  CustomCell.h
//  ZKTreeTableView
//
//  Created by bestdew on 2018/9/4.
//  Copyright © 2018年 bestdew. All rights reserved.
//

#import "ZKTreeListViewCell.h"

typedef void (^CheckBlock)(ZKTreeNode *node, BOOL isCheck);

@interface CheckCell : ZKTreeListViewCell

@property (nonatomic, copy) CheckBlock block;

- (void)refreshArrowDirection:(CGFloat)angle animated:(BOOL)animated;

@end
