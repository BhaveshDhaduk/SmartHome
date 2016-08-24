//
//  Device.h
//  SmartHome
//
//  Created by 逸云科技 on 16/8/5.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Device : NSObject

@property (nonatomic,assign) int eID;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *sn;
@property (nonatomic,strong) NSString *birth;
@property (nonatomic,strong) NSString *guarantee;
@property (nonatomic,strong) NSString *model;
@property (nonatomic,assign) double price;
@property (nonatomic,strong) NSString *purchase;
@property (nonatomic,strong) NSString *producer;
@property (nonatomic,strong) NSString *gua_tel;
@property (nonatomic,assign) NSInteger power;
@property (nonatomic,assign) double current;
@property (nonatomic,assign) NSInteger voltage;
@property (nonatomic,strong) NSString *protocol;
@property (nonatomic,assign) NSInteger rID;
@property (nonatomic,assign) NSInteger eNumber;
@property (nonatomic,assign) NSInteger hTypeId;
@property (nonatomic,assign) NSInteger subTypeId;
@property (nonatomic,strong) NSString *typeName;
@property (nonatomic,strong) NSString *subTypeName;

+ (instancetype)deviceWithDict:(NSDictionary *)dict;
@end