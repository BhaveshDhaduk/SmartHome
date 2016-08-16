//
//  Scene.h
//  SmartHome
//
//  Created by Brustar on 16/5/6.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SCENE_FILE_NAME @"ecloud_scene"

@interface Scene : NSObject
//场景id
@property (nonatomic,assign) int sceneID;
//场景名称
@property (nonatomic,strong) NSString *sceneName;
//房间id
@property (nonatomic) int roomID;
//房间名称
@property (nonatomic,strong)NSString *roomName;
//场景图片id
@property (nonatomic) int picID;
//场景开始时间
@property(nonatomic,strong)NSString *startTime;
//天文时间
@property(nonatomic,strong)NSString *astronomicalTime;
//每周运行时间
@property(nonatomic,strong)NSString *weekValue;
//是否每周重复（1 重复，2 不重复）
@property(nonatomic,assign) NSInteger weekRepeat;
//是否为收藏场景
@property(nonatomic,assign) BOOL isFavorite;
//设备ID
@property(nonatomic,assign) int eID;
//户型id
@property (nonatomic) int houseID;
//是否系统场景
@property (nonatomic) bool readonly;
//设备列表
@property (strong,nonatomic) NSArray *devices;

@end
