//
//  RequestHepler.m
//  ZKTreeTableView
//
//  Created by bestdew on 2018/9/23.
//  Copyright © 2018年 bestdew. All rights reserved.
//

#import "RequestHepler.h"

@implementation RequestHepler

+ (void)mockRequestNodesDataWithParams:(id)params success:(ResponseSuccess)success failure:(ResponseFailure)failure
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSError *error = nil;
        NSData *JSONData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Resource" ofType:@"json"]];
        NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingAllowFragments error:&error];
        if (!error) {
            NSMutableArray *mutArray = [NSMutableArray arrayWithCapacity:dataArray.count];
            for (NSDictionary *dict in dataArray) {
                NSMutableDictionary *mutDict = dict.mutableCopy;
                NSString *ID = [NSString stringWithFormat:@"%@_%@", mutDict[@"id"], params[@"pageIndex"]];
                NSString *pID = [NSString stringWithFormat:@"%@_%@", mutDict[@"pid"], params[@"pageIndex"]];
                [mutDict setObject:ID forKey:@"id"];
                [mutDict setObject:pID forKey:@"pid"];
                
                [mutArray addObject:mutDict];
            }
            success(mutArray);
        } else {
            failure(error);
        }
    });
}

+ (void)mackRequestMoreChildNodeDataWithParams:(id)params success:(ResponseSuccess)success failure:(ResponseFailure)failure;
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSDictionary *tempDict = (NSDictionary *)params;
        NSError *error = [NSError errorWithDomain:@"com.ParamsError.Domain" code:429 userInfo:@{NSLocalizedDescriptionKey:@"传参错误"}];
        if ((tempDict[@"level"] == nil) || (tempDict[@"order"] == nil) || (tempDict[@"pid"] == nil)) {
            if (failure) failure(error);
            return;
        }
        
        static NSInteger count = 30; count ++;
        NSArray *tempArray = [params[@"pid"] componentsSeparatedByString:@"_"];
        if (tempArray.count != 2) {
            if (failure) failure(error);
            return;
        }
        NSString *ID = [NSString stringWithFormat:@"%zd_%@", count, [tempArray lastObject]];
        NSDictionary *dict = @{@"id":ID,
                               @"level":params[@"level"],
                               @"image_name":@"touxiang_nan",
                               @"nick_name":@"自是不复欲--见汝",
                               @"content":@"每条评论都要认真的写，因为你不会知道在某个夜深人静的时候，有人会认真的逐条翻阅，他可能不会评论甚至也不会点赞，他只是在你熟睡的时候把你的悲欢喜乐都当成自己的，就像一只松鼠，在月光下的雪地里小心翼翼地捡起，散落在树下的一枚枚松子。",
                               @"order_no":params[@"order"],
                               @"childs_count":@(0),
                               @"pid":params[@"pid"]};
        
        if (success) success(dict);
    });
}

@end
