//
//  TableController.m
//  Demo
//
//  Created by Jiangmingz on 2016/6/30.
//  Copyright © 2016年 Jiangmingz. All rights reserved.
//

#import "TableController.h"
#import "AndroidRefresh.h"

static NSString *identiferCell = @"identiferCell";

@interface TableController () {
    AndroidRefresh *_androidRefresh;
}

@property(nonatomic, assign) NSInteger count;

@end

@implementation TableController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.count = 0;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"手动刷新"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(startRefreshing)];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:identiferCell];
    self.tableView.tableFooterView = [UIView new];
    self.view.backgroundColor = [UIColor grayColor];
    [self refreshDemo1];
}

- (void)refreshDemo1 {
    _androidRefresh = [[AndroidRefresh alloc] initWithPanView:self.tableView];
    [self.view addSubview:_androidRefresh];

    [_androidRefresh setColors:@[
            [UIColor redColor],
            [UIColor greenColor],
            [UIColor blueColor],
    ]];

    [_androidRefresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
}

- (void)startRefreshing {
    [_androidRefresh startRefresh];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identiferCell forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"Cell %zd", indexPath.row + self.count];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (void)refresh:(id)sender {
    NSLog(@"begin _androidRefresh");

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self endRefreshing];
    });
}

- (void)endRefreshing {
    [_androidRefresh endRefresh];

    NSLog(@"end _androidRefresh");
    self.count = self.count + 200;
    [self.tableView reloadData];
}

@end
