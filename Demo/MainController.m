//
//  TableController.m
//  Demo
//
//  Created by Jiangmingz on 2016/6/30.
//  Copyright © 2016年 Jiangmingz. All rights reserved.
//

#import "MainController.h"

#import "TableController.h"
#import "ViewController.h"

static NSString *IDENTIFER_CELL = @"IDENTIFER_CELL";

@interface MainController ()

@end

@implementation MainController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:IDENTIFER_CELL];
    self.tableView.tableFooterView = [UIView new];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFER_CELL forIndexPath:indexPath];
    if(indexPath.row == 0) {
        cell.textLabel.text = @"普通View";
    } else {
        cell.textLabel.text = @"TableView";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0) {
        [self.navigationController pushViewController:[ViewController new] animated:YES];
    } else {
        [self.navigationController pushViewController:[TableController new] animated:YES];
    }
}


@end
