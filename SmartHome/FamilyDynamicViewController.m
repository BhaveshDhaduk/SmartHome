//
//  FamilyDynamicViewController.m
//  SmartHome
//
//  Created by KobeBryant on 2017/4/26.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "FamilyDynamicViewController.h"

@interface FamilyDynamicViewController ()

@end

@implementation FamilyDynamicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDataSource];
    [self initUI];
}

- (void)initUI {
    NSInteger n = _cameraIDArray.count;
    CGFloat gap = 10.0f;
    CGFloat itemHeight = 260.0f;
    _cameraList.contentSize = CGSizeMake(UI_SCREEN_WIDTH, (itemHeight+gap)*n);
    
    for (NSInteger i = 0; i < n ; i++) {
        NSString *cameraURL = [SQLManager getCameraUrlByDeviceID:[_cameraIDArray[i] intValue]];
        NSInteger rID = [SQLManager getRoomIDByDeviceID:[_cameraIDArray[i] intValue]];
        NSString *roomName = [SQLManager getRoomNameByRoomID:(int)rID];
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Family" bundle:nil];
        MonitorViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"MonitorVC"];
        vc.delegate = self;
        vc.adjustBtn.tag = i;
        vc.cameraURL = cameraURL;
        vc.roomName = roomName;
        vc.deviceID = [_cameraIDArray[i] stringValue];
        vc.view.frame = CGRectMake(0, gap*(i+1) + i*itemHeight, UI_SCREEN_WIDTH, itemHeight);
        [self.cameraList addSubview:vc.view];
        [self addChildViewController:vc];
        
    }
    [self setNaviBarTitle:@"家庭动态"];
}

- (void)initDataSource {
    _cameraIDArray = [NSMutableArray array];
    NSArray *cameraIDs = [SQLManager getDeviceIDsByHtypeID:@"45"];
    if (cameraIDs.count >0) {
        [_cameraIDArray addObjectsFromArray:cameraIDs];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onAdjustBtnClicked:(UIButton *)sender {
    NSInteger index = sender.tag;
    NSString *cameraURL = [SQLManager getCameraUrlByDeviceID:[_cameraIDArray[index] intValue]];
    NSInteger rID = [SQLManager getRoomIDByDeviceID:[_cameraIDArray[index] intValue]];
    NSString *roomName = [SQLManager getRoomNameByRoomID:(int)rID];
    
    UIStoryboard *familyStoryBoard = [UIStoryboard storyboardWithName:@"Family" bundle:nil];
    FamilyDynamicDeviceAdjustViewController *vc = [familyStoryBoard instantiateViewControllerWithIdentifier:@"FamilyDynamicDeviceAdjustVC"];
    vc.roomID = rID;
    vc.roomName = roomName;
    vc.cameraURL = cameraURL;
    vc.deviceID = [_cameraIDArray[index] stringValue];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
