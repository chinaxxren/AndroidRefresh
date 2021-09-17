//
//  ViewController.m
//  Demo
//
//  Created by Jiangmingz on 2016/6/30.
//  Copyright © 2016年 Jiangmingz. All rights reserved.
//

#import "ViewController.h"
#import "AndroidRefresh.h"

@interface ViewController () {
    AndroidRefresh *_androidRefresh;
}

@property(nonatomic, assign) NSInteger count;
@property(nonatomic, strong) UILabel *redLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;

    UIView *panView = [[UIView alloc] initWithFrame:self.view.bounds];
    panView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:panView];

    self.count = 0;
    self.redLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - 100) * 0.5f, 150, 100, 100)];
    self.redLabel.textAlignment = NSTextAlignmentCenter;
    self.redLabel.textColor = [UIColor whiteColor];
    self.redLabel.backgroundColor = [UIColor redColor];
    self.redLabel.font = [UIFont boldSystemFontOfSize:20];
    self.redLabel.text = [NSString stringWithFormat:@"%zd", self.count];
    [panView addSubview:self.redLabel];

    _androidRefresh = [[AndroidRefresh alloc] initWithPanView:panView];
    [_androidRefresh setColors:@[[UIColor redColor], [UIColor greenColor], [UIColor blueColor],]];
    [_androidRefresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_androidRefresh];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"手动刷新"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(startRefreshing)];
    self.view.backgroundColor = [UIColor grayColor];
}

- (void)refresh:(id)sender {

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self endRefreshing];
    });
}

- (void)startRefreshing {
    [_androidRefresh startCenterRefresh];
}

- (void)endRefreshing {
    [_androidRefresh endRefresh];

    self.count = self.count + 2;
    self.redLabel.text = [NSString stringWithFormat:@"%zd", self.count];
}

@end
