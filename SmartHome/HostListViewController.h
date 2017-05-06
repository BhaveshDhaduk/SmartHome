//
//  HostListViewController.h
//  SmartHome
//
//  Created by KobeBryant on 2017/5/3.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "CustomViewController.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
#import "HostListCell.h"
#import "SQLManager.h"
#import "AFNetworking.h"

@interface HostListViewController : CustomViewController<HttpDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *hostArray;
@property (nonatomic, strong) NSMutableArray *homeNameArray;
@property (nonatomic, strong) NSString *selectedHost;
@property (weak, nonatomic) IBOutlet UITableView *hostTableView;
@property (nonatomic,strong) NSMutableArray *home_room_infoArr;

- (IBAction)OkBtnClicked:(id)sender;

@end
