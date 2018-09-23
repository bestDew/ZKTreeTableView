//
//  CheckNode.h
//  ZKTreeTableView
//
//  Created by bestdew on 2018/9/24.
//  Copyright © 2018年 bestdew. All rights reserved.
//

#import "ZKTreeNode.h"

@interface CheckNode : ZKTreeNode

@property (nonatomic, assign, getter=isChecked) BOOL checked;

@end
