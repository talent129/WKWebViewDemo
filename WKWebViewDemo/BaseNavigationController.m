//
//  BaseNavigationController.m
//  WKWebViewDemo
//
//  Created by luckyCoderCai on 2018/6/5.
//  Copyright © 2018年 Curtis. All rights reserved.
//

#import "BaseNavigationController.h"

@interface BaseNavigationController ()<UIGestureRecognizerDelegate, UINavigationControllerDelegate>

@end

@implementation BaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationBar.barTintColor = [UIColor orangeColor];
    self.navigationBar.translucent = NO;
    
    [self popGesture];
}

#pragma mark -右滑返回手势
- (void)popGesture
{
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.interactivePopGestureRecognizer.enabled  = YES;
        self.interactivePopGestureRecognizer.delegate = self;
        self.delegate = self;
    }
}

//重写系统push方法
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.viewControllers.count >= 1) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    
    [super pushViewController:viewController animated:animated];
    
    ///add by hgc 2018年03月06日 解决IPhoneX 模拟器下 push tabBar向上跳动
    CGRect frame = self.tabBarController.tabBar.frame;
    frame.origin.y = [UIScreen mainScreen].bounds.size.height - frame.size.height;
    self.tabBarController.tabBar.frame = frame;
}

#pragma mark -UINavigationControllerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.interactivePopGestureRecognizer)
    {
        if (self.viewControllers.count == 1)
        {
            return NO;
        }
    }
    return YES;
}

- (void)dealloc
{
    NSLog(@"--dealloc: %@", NSStringFromClass([self class]));
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.interactivePopGestureRecognizer.delegate = nil;
        self.delegate = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
