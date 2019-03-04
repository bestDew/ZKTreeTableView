//
//  CommentCell.h
//  ZKTreeTableView
//
//  Created by bestdew on 2018/8/30.
//  Copyright © 2018年 bestdew. All rights reserved.
//

#import "ZKTreeListViewCell.h"

typedef void (^ExpandBlock)(ZKTreeNode *node);

@interface CommentCell : ZKTreeListViewCell

@property (nonatomic, copy) ExpandBlock block;

@end
