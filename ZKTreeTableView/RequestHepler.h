//
//  RequestHepler.h
//  ZKTreeTableView
//
//  Created by bestdew on 2018/9/23.
//  Copyright © 2018年 bestdew. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 请求成功回调
 
 @param response 成功后返回的数据
 */
typedef void (^ResponseSuccess)(id response);

/**
 请求失败回调
 
 @param error 错误信息
 */
typedef void (^ResponseFailure)(NSError *error);

@interface RequestHepler : NSObject

/** 模拟请求数据 */
+ (void)mockRequestNodesDataWithParams:(id)params success:(ResponseSuccess)success failure:(ResponseFailure)failure;
+ (void)mackRequestMoreChildNodeDataWithParams:(id)params success:(ResponseSuccess)success failure:(ResponseFailure)failure;
+ (void)submitCommentsWithParams:(id)params success:(ResponseSuccess)success failure:(ResponseFailure)failure;

@end
