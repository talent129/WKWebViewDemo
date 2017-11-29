//
//  WebViewController.m
//  WKWebViewDemo
//
//  Created by Curtis on 2017/11/29.
//  Copyright © 2017年 Curtis. All rights reserved.
//

#import "WebViewController.h"
#import <WebKit/WebKit.h>

#define Screen_Bounds [UIScreen mainScreen].bounds

@interface WebViewController ()<WKUIDelegate, WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation WebViewController

#pragma mark -lazy load
- (WKWebView *)webView
{
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:Screen_Bounds];
        _webView.backgroundColor = [UIColor whiteColor];
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        _webView.allowsBackForwardNavigationGestures = YES;//允许右滑手势返回上一页面(网页)
    }
    return _webView;
}

- (UIProgressView *)progressView
{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] init];
        _progressView.backgroundColor = [UIColor clearColor];//背景色-若trackTintColor为clearColor,则显示背景颜色
        _progressView.progressTintColor = [UIColor blueColor];//进度条颜色
        _progressView.trackTintColor = [UIColor clearColor];//进度条还未到达的线条颜色
        
        _progressView.hidden = YES;//初始隐藏
    }
    return _progressView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"WKWebView";
    
    [self testWKWebView];
    
}

#pragma mark -父类方法
- (void)zjsLeftBarButtonItemAction
{
    NSLog(@"--父类返回按钮响应事件");
    if ([self.webView canGoBack]) {
        [self canGoBackWebViewPage];
        [self rewriteLeftBarButton:YES];
    } else {
        [self popToLastViewController];
    }
}

#pragma mark -跳转网页
- (void)canGoBackWebViewPage
{
    [self.webView goBack];
}

#pragma mark -重写左侧返回按钮 是否添加关闭按钮
- (void)rewriteLeftBarButton:(BOOL)add
{
    UIButton *backButton= [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 64, 44);
    [backButton setImage:[UIImage imageNamed:@"navLeft"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"navLeft"] forState:UIControlStateHighlighted];
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 50);
    [backButton addTarget:self action:@selector(zjsLeftBarButtonItemAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    if (add) {
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake(0, 0, 44, 44);
        closeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(popToLastViewController) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *closeItem = [[UIBarButtonItem alloc]initWithCustomView:closeButton];
        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        //正: 向右 负: 向左
        space.width = -10;
        
        NSArray *array = [NSArray arrayWithObjects:backItem, space, closeItem, nil];
        self.navigationItem.leftBarButtonItems = array;
    } else {
        self.navigationItem.leftBarButtonItem = backItem;
    }
}

#pragma mark -pop
- (void)popToLastViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -WKWebView
- (void)testWKWebView
{
    [self.view addSubview:self.webView];
    
    NSString *url = @"https://www.baidu.com";
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self.webView loadRequest:request];
    
    [self.view addSubview:self.progressView];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.and.trailing.equalTo(@0);
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        make.height.equalTo(@2);
    }];
    
    ///KVO-title
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    
    ///KVO-estimatedProgress
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
}

/**
 KVO获取网页title
 
 @param keyPath 路径
 @param object 对象
 @param change 改变
 @param context 上下文
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"title"]) {
        if ([object isEqual:self.webView]) {
            if (self.navigationController) {
                self.title = self.webView.title;
            }
        }
    } else if ([keyPath isEqualToString:@"estimatedProgress"]) {
        if ([object isEqual:self.webView]) {
            NSLog(@"-change: %@ ---estimatedProgress: %f", change, self.webView.estimatedProgress);
            [self.progressView setProgress:self.webView.estimatedProgress animated:YES];

            if (self.webView.estimatedProgress > 0 && self.webView.estimatedProgress < 1) {
                _progressView.hidden = NO;
            } else if (self.webView.estimatedProgress == 1) {

                __weak typeof(self) weakSelf = self;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    weakSelf.progressView.hidden = YES;
                    [weakSelf.progressView setProgress:0 animated:NO];
                });
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark -WKNavigationDelegate
///发送请求之前 决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSLog(@"--发送请求之前 决定是否跳转-decidePolicyForNavigationAction");
    NSLog(@"%@",navigationAction.request.URL.absoluteString);
    
    //允许跳转
    decisionHandler(WKNavigationActionPolicyAllow);
    //不允许跳转
    //decisionHandler(WKNavigationActionPolicyCancel);
}

///页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    NSLog(@"--页面开始加载调用-didStartProvisionalNavigation");
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    NSLog(@"--接收到响应后，决定是否跳转--decidePolicyForNavigationResponse");
    NSLog(@"%@",navigationResponse.response.URL.absoluteString);
    
    //比如遇到某些字段 返回 -百度 南京天气预报
    NSString *backUrl = @"mipcache.bdstatic.com";
    if ([navigationResponse.response.URL.absoluteString rangeOfString:backUrl].location != NSNotFound) {
        NSLog(@"--这个字符串中包含: %@", backUrl);
        //回调的URL中如果含有backUrl，就直接返回，也就是关闭了webView界面
        [self.navigationController  popViewControllerAnimated:YES];
    }
    
    
    //允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
    //不允许跳转
    //decisionHandler(WKNavigationResponsePolicyCancel);
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    NSLog(@"--当内容开始返回时调用-didCommitNavigation");
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    NSLog(@"--页面加载完成之后调用-didFinishNavigation");
    
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
{
    NSLog(@"--接收到服务器跳转请求之后-didReceiveServerRedirectForProvisionalNavigation");
    
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"--页面加载失败调用-didFailProvisionalNavigation");

}

#pragma mark -WKUIDelegate
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    NSLog(@"--创建一个新的webView-createWebViewWithConfiguration");
    return [[WKWebView alloc] init];
}

// 输入框
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler
{
    NSLog(@"%@---%@",prompt, defaultText);
    completionHandler(@"http");
    
}
// 确认框
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler
{
    NSLog(@"%@",message);
    completionHandler(YES);
    
}
// 警告框
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    NSLog(@"%@",message);
    completionHandler();
}

- (void)dealloc
{
    [self.webView removeObserver:self forKeyPath:@"title"];
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
