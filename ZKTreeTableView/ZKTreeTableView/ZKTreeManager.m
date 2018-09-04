//
//  ZKTreeManager.m
//  ZKTreeTableView
//
//  Created by bestdew on 2018/8/29.
//  Copyright © 2018年 bestdew. All rights reserved.
//
//                      d*##$.
// zP"""""$e.           $"    $o
//4$       '$          $"      $
//'$        '$        J$       $F
// 'b        $k       $>       $
//  $k        $r     J$       d$
//  '$         $     $"       $~
//   '$        "$   '$E       $
//    $         $L   $"      $F ...
//     $.       4B   $      $$$*"""*b
//     '$        $.  $$     $$      $F
//      "$       R$  $F     $"      $
//       $k      ?$ u*     dF      .$
//       ^$.      $$"     z$      u$$$$e
//        #$b             $E.dW@e$"    ?$
//         #$           .o$$# d$$$$c    ?F
//          $      .d$$#" . zo$>   #$r .uF
//          $L .u$*"      $&$$$k   .$$d$$F
//           $$"            ""^"$$$P"$P9$
//          JP              .o$$$$u:$P $$
//          $          ..ue$"      ""  $"
//         d$          $F              $
//         $$     ....udE             4B
//          #$    """"` $r            @$
//           ^$L        '$            $F
//             RN        4N           $
//              *$b                  d$
//               $$k                 $F
//               $$b                $F
//                 $""               $F
//                 '$                $
//                  $L               $
//                  '$               $
//                   $               $

#import "ZKTreeManager.h"
#import "ZKTreeItem.h"

@interface ZKTreeManager ()
{
    BOOL _flag; // 判断是否需要计算等级的标识
}
@property (nonatomic, strong) NSDictionary *itemsMap;
@property (nonatomic, strong) NSMutableArray <ZKTreeItem *>*topItems;
@property (nonatomic, strong) NSMutableArray <ZKTreeItem *>*tmpItems;
@property (nonatomic, assign) NSInteger maxLevel;   // 最大等级
@property (nonatomic, assign) NSInteger showLevel;  // 展开的最大等级

@end

@implementation ZKTreeManager

#pragma mark -- 初始化
- (instancetype)initWithItems:(NSArray<ZKTreeItem *> *)items andExpandLevel:(NSInteger)level
{
    if (self = [super init]) {
        
        // 1. 建立 MAP
        [self setupItemsMapByItems:items];
        
        // 2. 建立父子关系，并得到顶级节点
        [self setupTopItems];
        
        // 3. 设置等级
        [self setupItemsLevel];
        
        // 4. 根据展开等级设置 showItems
        [self setupShowItemsWithShowLevel:level];
    }
    return self;
}

// 建立 MAP
- (void)setupItemsMapByItems:(NSArray *)items
{
    _flag = YES;
    NSMutableDictionary *itemsMap = @{}.mutableCopy;
    for (ZKTreeItem *item in items) {
        [itemsMap setObject:item forKey:item.ID];
        if (item.level != -1) _flag = NO;
    }
    self.itemsMap = itemsMap.copy;
}

// 建立父子关系，并得到顶级节点
- (void)setupTopItems
{
    self.tmpItems = self.itemsMap.allValues.mutableCopy;
    
    // 建立父子关系
    NSMutableArray *topItems = @[].mutableCopy;
    for (ZKTreeItem *item in self.tmpItems) {
        item.isExpand = NO;
        if ([item.parentID isKindOfClass:[NSString class]]) {
            ZKTreeItem *parent = self.itemsMap[item.parentID];
            if (parent) {
                item.parentItem = parent;
                if (![parent.childItems containsObject:item]) {
                    [parent.childItems addObject:item];
                }
            }
        }
        if (!item.parentItem) [topItems addObject:item];
        if (!_flag) self.maxLevel = MAX(item.level, self.maxLevel);
    }
    // 排序
    self.topItems = [topItems sortedArrayUsingComparator:^NSComparisonResult(ZKTreeItem *item1, ZKTreeItem *item2) {
        return [item1.orderNo compare:item2.orderNo];
    }].mutableCopy;
}

// 设置等级
- (void)setupItemsLevel
{
    if (!_flag) return;
    
    for (ZKTreeItem *item in self.tmpItems) {
        NSInteger tempLevel = 0;
        ZKTreeItem *parent = item.parentItem;
        while (parent) {
            tempLevel ++;
            parent = parent.parentItem;
        }
        item.level = tempLevel;
        self.maxLevel = MAX(self.maxLevel, tempLevel);
    }
}

// 根据展开等级设置 showItems
- (void)setupShowItemsWithShowLevel:(NSInteger)level
{
    self.showLevel = MAX(level, 0);
    self.showLevel = MIN(level, self.maxLevel);
    
    NSMutableArray *showItems = @[].mutableCopy;
    for (ZKTreeItem *item in self.topItems) {
        [self addItem:item toShowItems:showItems andAllowShowLevel:self.showLevel];
    }
    _showItems = showItems;
}

- (void)addItem:(ZKTreeItem *)item toShowItems:(NSMutableArray *)showItems andAllowShowLevel:(NSInteger)level
{
    if (item.level > level) return;
    
    [showItems addObject:item];
    
    item.isExpand = (item.level != level);
    item.childItems = [item.childItems sortedArrayUsingComparator:^NSComparisonResult(ZKTreeItem *item1, ZKTreeItem *item2) {
        return [item1.orderNo compare:item2.orderNo];
    }].mutableCopy;
    
    for (ZKTreeItem *childItem in item.childItems) {
        [self addItem:childItem toShowItems:showItems andAllowShowLevel:level];
    }
}

#pragma mark -- Expand Item
// 展开/收起 Item，返回所改变的 Item 的个数
- (NSInteger)expandItem:(ZKTreeItem *)item
{
    return [self expandItem:item isExpand:!item.isExpand];
}

- (NSInteger)expandItem:(ZKTreeItem *)item isExpand:(BOOL)isExpand
{
    if (item.isExpand == isExpand) return 0;
    
    item.isExpand = isExpand;
    NSMutableArray *tempMutArray = @[].mutableCopy;
    
    if (isExpand) { // 展开
        for (ZKTreeItem *tempItem in item.childItems) {
            [self addItem:tempItem toTmpItems:tempMutArray];
        }
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange([self.showItems indexOfObject:item] + 1, tempMutArray.count)];
        [self.showItems insertObjects:tempMutArray atIndexes:indexSet];
    } else { // 折叠
        for (ZKTreeItem *tempItem in self.showItems) {
            BOOL isParent = NO;
            ZKTreeItem *parentItem = tempItem.parentItem;
            while (parentItem) {
                if (parentItem == item) {
                    isParent = YES;
                    break;
                }
                parentItem = parentItem.parentItem;
            }
            if (isParent) [tempMutArray addObject:tempItem];
        }
        [self.showItems removeObjectsInArray:tempMutArray];
    }

    return tempMutArray.count;
}

- (void)addItem:(ZKTreeItem *)item toTmpItems:(NSMutableArray *)tmpItems
{
    [tmpItems addObject:item];
    
    item.childItems = [item.childItems sortedArrayUsingComparator:^NSComparisonResult(ZKTreeItem *item1, ZKTreeItem *item2) {
        return [item1.orderNo compare:item2.orderNo];
    }].mutableCopy;
    
    if (!item.isExpand) return;
    
    for (ZKTreeItem *tmpItem in item.childItems) {
        [self addItem:tmpItem toTmpItems:tmpItems];
    }
}

// 展开/折叠到多少层级
- (void)expandItemWithLevel:(NSInteger)expandLevel completed:(void(^)(NSArray *noExpandArray))noExpandCompleted andCompleted:(void(^)(NSArray *expandArray))expandCompleted
{
    expandLevel = MAX(expandLevel, 0);
    expandLevel = MIN(expandLevel, self.maxLevel);
    
    // 先一级一级折叠
    for (NSInteger level = self.maxLevel; level >= expandLevel; level--) {
        NSMutableArray *itemsArray = @[].mutableCopy;
        for (NSInteger i = 0; i < self.showItems.count; i++) {
            ZKTreeItem *item = self.showItems[i];
            if (item.isExpand && item.level == level) {
                [itemsArray addObject:item];
            }
        }
        if (itemsArray.count) {
            if (noExpandCompleted) {
                noExpandCompleted(itemsArray);
            }
        }
    }
    
    // 再一级一级展开
    for (NSInteger level = 0; level < expandLevel; level++) {
        NSMutableArray *itemsArray = @[].mutableCopy;
        for (NSInteger i = 0; i < self.showItems.count; i++) {
            ZKTreeItem *item = self.showItems[i];
            if (!item.isExpand && item.level == level) {
                [itemsArray addObject:item];
            }
        }
        if (itemsArray.count) {
            if (expandCompleted) {
                expandCompleted(itemsArray);
            }
        }
    }
}

// 根据 id 获取 item
- (ZKTreeItem *)getItemWithItemId:(NSNumber *)itemId
{
    return (itemId ? self.itemsMap[itemId] : nil);
}

// 获取所有 items
- (NSArray *)getAllItems
{
    return [self.itemsMap allValues];
}

@end
