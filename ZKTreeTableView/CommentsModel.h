//
//  CommentsModel.h
//  ZKTreeTableView
//
//  Created by bestdew on 2018/8/29.
//  Copyright © 2018年 bestdew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentsModel : NSObject

@property (nonatomic, readonly, copy)   NSString *image_name; // 头像
@property (nonatomic, readonly, copy)   NSString *nick_name;  // 昵称
@property (nonatomic, readonly, copy)   NSString *location;   // 地理位置
@property (nonatomic, readonly, copy)   NSString *phoneBrand; // 手机品牌
@property (nonatomic, readonly, copy)   NSString *content;    // 评论内容
@property (nonatomic, readonly, strong) NSNumber *likeCount;  // 点赞数
@property (nonatomic, readonly, copy)   NSString *time;       // 评论时间
@property (nonatomic, readonly, strong) NSNumber *level;      // 层级

+ (instancetype)modelWithDict:(NSDictionary *)dict;

@end
