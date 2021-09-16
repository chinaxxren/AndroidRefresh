//
//  ViewController.m
//  Demo
//
//  Created by Jiangmingz on 2016/6/30.
//  Copyright © 2016年 Jiangmingz. All rights reserved.
//

#import "ViewController.h"
#import "AndroidRefresh.h"

static NSString *identiferCell = @"identiferCell";

@interface ViewController () {
    AndroidRefresh *refresh;
}

@property (nonatomic,assign) NSInteger count;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.count = 20;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:identiferCell];
    self.tableView.tableFooterView = [UIView new];
    
    refresh = [[AndroidRefresh alloc] initWithScrollView:self.tableView];
    [self.view addSubview:refresh];

    [refresh setColors:@[
            [UIColor redColor],
            [UIColor greenColor],
            [UIColor blueColor],
    ]];

    [refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identiferCell forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"Cell %zd",indexPath.row + self.count];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (void)refresh:(id)sender {
    NSLog(@"begin refresh");
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self endRefreshing];
    });
}

- (void)endRefreshing {
    [refresh endRefreshing];
    
    NSLog(@"end refresh");
    self.count = self.count + 20;
    [self.tableView reloadData];
}

@end
