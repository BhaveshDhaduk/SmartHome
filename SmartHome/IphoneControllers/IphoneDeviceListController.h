//
//  IphoneDeviceListController.h
//  SmartHome
//
//  Created by 逸云科技 on 16/9/19.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IphoneDeviceListController : UIViewController

-(void)goDeviceByRoomID:(int)roomID typeName:(NSString *)typeName;
@property (nonatomic,strong) Scene *scene;

@end
