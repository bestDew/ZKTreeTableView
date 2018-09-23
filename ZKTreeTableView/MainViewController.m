//
//  MainViewController.m
//  ZKTreeTableView
//
//  Created by bestdew on 2018/9/4.
//  Copyright © 2018年 bestdew. All rights reserved.
//

#import "MainViewController.h"
#import "CheckViewController.h"
#import "TreeListViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"ZKTreeListViewDemo";
    
    CGFloat screenWidth  = UIScreen.mainScreen.bounds.size.width;
    CGFloat screenHeight = UIScreen.mainScreen.bounds.size.height;
    
    UIButton *firstButton = [UIButton buttonWithType:UIButtonTypeCustom];
    firstButton.frame = CGRectMake(60.f, (screenHeight - 100.f) / 2, screenWidth - 120.f, 40.f);
    firstButton.layer.backgroundColor = [UIColor colorWithRed:0.35 green:0.58 blue:0.91 alpha:1.00].CGColor;
    firstButton.layer.masksToBounds = YES;
    firstButton.layer.cornerRadius = 20.f;
    firstButton.tag = 10;
    [firstButton setTitle:@"NoneStyle" forState:UIControlStateNormal];
    [firstButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:firstButton];
    
    UIButton *secondButton = [UIButton buttonWithType:UIButtonTypeCustom];
    secondButton.frame = CGRectMake(60.f, CGRectGetMaxY(firstButton.frame) + 20.f, firstButton.frame.size.width, 40.f);
    secondButton.layer.backgroundColor = [UIColor colorWithRed:0.35 green:0.58 blue:0.91 alpha:1.00].CGColor;
    secondButton.layer.masksToBounds = YES;
    secondButton.layer.cornerRadius = 20.f;
    secondButton.tag = 11;
    [secondButton setTitle:@"StructureLineStyle" forState:UIControlStateNormal];
    [secondButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:secondButton];
}

- (void)buttonAction:(UIButton *)button
{
    switch (button.tag) {
        case 10: {
            CheckViewController *checkVC = [[CheckViewController alloc] init];
            [self.navigationController pushViewController:checkVC animated:YES];
            break;
        }
        case 11: {
            TreeListViewController *treeListVC = [[TreeListViewController alloc] init];
            [self.navigationController pushViewController:treeListVC animated:YES];
            break;
        }
    }
}

@end
