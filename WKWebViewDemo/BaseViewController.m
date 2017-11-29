//
//  BaseViewController.m
//  WKWebViewDemo
//
//  Created by Curtis on 2017/11/29.
//  Copyright © 2017年 Curtis. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationController.navigationBar.barTintColor = [UIColor orangeColor];
    self.navigationController.navigationBar.translucent = NO;
    
    ///右滑返回
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    
    [self zjsLeftBarButtonItem];
    
}

#pragma mark -左侧返回按钮
- (void)zjsLeftBarButtonItem
{
    if (self.navigationController.viewControllers.count > 1) {
        UIButton *backButton= [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.frame = CGRectMake(0, 0, 64, 44);
        [backButton setImage:[UIImage imageNamed:@"navLeft"] forState:UIControlStateNormal];
        [backButton setImage:[UIImage imageNamed:@"navLeft"] forState:UIControlStateHighlighted];
        backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 50);
        [backButton addTarget:self action:@selector(zjsLeftBarButtonItemAction) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    }
}

- (void)zjsLeftBarButtonItemAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
