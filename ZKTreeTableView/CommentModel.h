//
//  CommentModel.h
//  ZKTreeTableView
//
//  Created by bestdew on 2018/8/29.
//  Copyright © 2018年 bestdew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentModel : NSObject

@property (nonatomic, readonly, copy)   NSString *ID;           // 节点ID
@property (nonatomic, readonly, copy)   NSString *pid;          // 父节点ID
@property (nonatomic, readonly, copy)   NSString *image_name;   // 头像
@property (nonatomic, readonly, copy)   NSString *nick_name;    // 昵称
@property (nonatomic, readonly, copy)   NSString *content;      // 评论内容
@property (nonatomic, readonly, strong) NSNumber *level;        // 层级
@property (nonatomic, readonly, strong) NSNumber *order_no;     // 序号
@property (nonatomic, readonly, strong) NSNumber *childs_count; // 子节点总数

+ (instancetype)modelWithDict:(NSDictionary *)dict;

@end
