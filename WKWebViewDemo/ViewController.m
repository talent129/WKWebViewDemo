//
//  ViewController.m
//  WKWebViewDemo
//
//  Created by Curtis on 2017/11/29.
//  Copyright © 2017年 Curtis. All rights reserved.
//

#import "ViewController.h"
#import "WebViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"Push-WebView";
    
}

- (IBAction)pushWebViewAction:(id)sender {
    
    WebViewController *vc = [[WebViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
