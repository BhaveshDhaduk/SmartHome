//
//  RegisterPhoneNumController.h
//  SmartHome
//
//  Created by 逸云科技 on 16/7/4.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterPhoneNumController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *UserTypeLb;
@property (weak, nonatomic) IBOutlet UILabel *MasterIDLb;




@property (nonatomic,strong) NSString *suerTypeStr;
@property (nonatomic,strong) NSString *masterStr;

@end