//
//  RegisterDetailController.h
//  SmartHome
//
//  Created by 逸云科技 on 16/7/4.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterDetailController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *phoneNumber;
@property (nonatomic,strong) NSString *phoneStr;
@property (nonatomic,strong) NSString *userType;
@property (nonatomic,strong) NSString *MasterID;
@end