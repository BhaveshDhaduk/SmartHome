//
//  DeviceManager.m
//  SmartHome
//
//  Created by 逸云科技 on 16/8/5.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "DeviceManager.h"
#import "Device.h"
#import "FMDatabase.h"
#import "DeviceType.h"
@implementation DeviceManager

//从数据中获取所有设备信息
+(NSArray *)getAllDevicesInfo{
    
    
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    NSMutableArray *deviceModels = [NSMutableArray array];
    if([db open])
    {
        FMResultSet *resultSet = [db executeQuery:@"select * from Devices"];
        
        while ([resultSet next]){
            
            
            [deviceModels addObject:[self deviceMdoelByFMResultSet:resultSet]];
            
        }
        
        
    }
    [db close];
    return [deviceModels copy];
}

+(NSString *)deviceNameByDeviceID:(int)eId
{
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    NSString *eName;
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT NAME FROM Devices where ID = %d",eId];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            eName = [resultSet stringForColumn:@"NAME"];
        }
    }
    return eName;
}

+(NSInteger)deviceIDByDeviceName:(NSString *)deviceName
{
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    NSInteger eId;
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT ID FROM Devices NAME = '%@'",deviceName];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            eId = [resultSet intForColumn:@"ID"];
        }
    }
    return eId;

}

+(NSString *)deviceTypeNameByDeviceID:(int)eId
{
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    NSString *typeName;
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT typeName FROM Devices where ID = %d",eId];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            typeName = [resultSet stringForColumn:@"typeName"];
        }
    }
    return typeName;
}


+(Device*)deviceMdoelByFMResultSet:(FMResultSet *)resultSet
{
    Device *device = [Device new];
    device.eID = [resultSet intForColumn:@"ID"];
    device.name = [resultSet stringForColumn:@"NAME"];
    device.sn = [resultSet stringForColumn:@"sn"];
    device.birth = [resultSet stringForColumn:@"birth"];
    device.guarantee = [resultSet stringForColumn:@"guarantee"];
    device.model = [resultSet stringForColumn:@""];
    device.price = [resultSet doubleForColumn:@"price"];
    device.purchase = [resultSet stringForColumn:@"purchase"];
    device.producer = [resultSet stringForColumn:@"producer"];
    device.gua_tel = [resultSet stringForColumn:@"gua_tel"];
    device.power = [resultSet intForColumn:@"power"];
    device.current = [resultSet doubleForColumn:@"current"];
    device.voltage = [resultSet intForColumn:@"voltage"];
    device.protocol = [resultSet stringForColumn:@"protocol"];
    device.rID = [resultSet intForColumn:@"rID"];
    device.eNumber = [resultSet intForColumn:@"eNumber"];
    device.hTypeId = [resultSet intForColumn:@"hTypeId"];
    device.subTypeId = [resultSet intForColumn:@"subTypeId"];
    device.typeName = [resultSet stringForColumn:@"typeName"];
    device.subTypeName = [resultSet stringForColumn:@"subTypeName"];
    return device;
}

+(NSArray *)devicesByRoomId:(NSInteger)roomId
{
    
    NSArray *devices = [self getAllDevicesInfo];
    NSMutableArray *arr = [NSMutableArray array];
    for(Device *device in devices )
    {
        if(device.rID == roomId)
        {
            [arr addObject:device];
        }
    }
    
    return [arr copy];
}

+(NSArray *)deviceSubTypeByRoomId:(NSInteger)roomID
{
    NSMutableArray *subTypes = [NSMutableArray array];
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT distinct typeName FROM Devices where rID = %ld",roomID];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            NSString *typeName = [resultSet stringForColumn:@"typeName"];
            
            if ([typeName isEqualToString:@"开关"]||[typeName isEqualToString:@"调色"]||[typeName isEqualToString:@"调光"]) {
                typeName = @"灯光";
            }
            else if ([typeName isEqualToString:@"开合帘"] || [typeName isEqualToString:@"卷帘"]) {
                typeName = @"窗帘";
            }
            
            BOOL isEqual = false;
            for (NSString *tempTypeName in subTypes) {
                if ([tempTypeName isEqualToString:typeName]) {
                    isEqual = true;
                    break;
                }
            }
            if (!isEqual) {
                [subTypes addObject:typeName];
            }
        }
    }
    
    return [subTypes copy];
}



+ (NSArray *)getLightTypeNameWithRoomID:(NSInteger)roomID
{
    NSMutableArray *lightNames = [NSMutableArray array];
    
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT distinct typeName FROM Devices where rID = %ld and typeName in (\"开关\",\"调色\",\"调光\")",roomID];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            NSString *light = [resultSet stringForColumn:@"typeName"];
            [lightNames addObject:light];
        }
    }
    
    if (lightNames.count < 1) {
        return nil;
    }
    
    return [lightNames copy];
}


+ (NSArray *)getLightWithTypeName:(NSString *)typeName roomID:(NSInteger)roomID
{
    NSMutableArray *lights = [NSMutableArray array];
    
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT ID FROM Devices where rID = %ld and typeName = \"%@\"",roomID, typeName];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            int lightID = [resultSet intForColumn:@"ID"];
            [lights addObject:[NSNumber numberWithInt:lightID]];
        }
    }
    
    if (lights.count < 1) {
        return nil;
    }
    
    return [lights copy];
}



+ (NSArray *)getCurtainTypeNameWithRoomID:(NSInteger)roomID
{
    NSMutableArray *curtainNames = [NSMutableArray array];
    
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT distinct typeName FROM Devices where rID = %ld and typeName in (\"开合帘\",\"卷帘\")",roomID];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            NSString *light = [resultSet stringForColumn:@"typeName"];
            [curtainNames addObject:light];
        }
    }
    
    if (curtainNames.count < 1) {
        return nil;
    }
    
    return [curtainNames copy];
}


+ (NSArray *)getCurtainWithTypeName:(NSString *)typeName roomID:(NSInteger)roomID
{
    NSMutableArray *curtains = [NSMutableArray array];
    
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT ID FROM Devices where rID = %ld and typeName = \"%@\"",roomID, typeName];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            int lightID = [resultSet intForColumn:@"ID"];
            [curtains addObject:[NSNumber numberWithInt:lightID]];
        }
    }
    
    if (curtains.count < 1) {
        return nil;
    }
    
    return [curtains copy];
}



+ (NSString *)deviceIDWithRoomID:(NSInteger)roomID withType:(NSString *)type
{
    NSString *deviceID = nil;
    
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT ID FROM Devices where rID = %ld and typeName = \'%@\'",roomID,type];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            int tvID = [resultSet intForColumn:@"ID"];
            deviceID = [NSString stringWithFormat:@"%d", tvID];
        }
    }
    [db close];
    return deviceID;
}


+(NSArray *)getDeviceByTypeName:(NSString  *)typeName andRoomID:(NSInteger)roomID
{
    NSMutableArray *array = [NSMutableArray array];
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT ID FROM Devices where rID = %ld and typeName = \'%@\'",roomID,typeName];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            int eId = [resultSet intForColumn:@"ID"];
            [array addObject:[NSNumber numberWithInt:eId]];
        }
        
        
    }
    [db close];
    return [array copy];
}

+(NSString *)getEType:(NSInteger)eID
{
    NSString * htypeID=nil;
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT htypeID FROM Devices where ID = %ld",eID];
        FMResultSet *resultSet = [db executeQuery:sql];
        if ([resultSet next])
        {
            htypeID = [resultSet stringForColumn:@"htypeID"];
        }
    }
    [db close];
    return htypeID;
}

+(NSString *)getENumber:(NSInteger)eID
{
    NSString * enumber=nil;
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT enumber FROM Devices where ID = %ld",eID];
        FMResultSet *resultSet = [db executeQuery:sql];
        if ([resultSet next])
        {
            enumber = [resultSet stringForColumn:@"enumber"];
        }
    }
    [db close];
    return enumber;
}

+(NSString *)getDeviceIDByENumber:(NSInteger)eID masterID:(NSInteger)mID
{
    NSString *deviceID=nil;
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT ID FROM Devices where enumber = %ld and masterID=%ld",eID,mID];
        FMResultSet *resultSet = [db executeQuery:sql];
        if ([resultSet next])
        {
            deviceID = [resultSet stringForColumn:@"ID"];
        }
    }
    [db close];
    return deviceID;
}


+(int)saveMaxSceneId:(NSString *)name
{
    int sceneID=1;
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"select max(id) as id from scenes"];
        FMResultSet *resultSet = [db executeQuery:sql];
        if ([resultSet next])
        {
            sceneID = [resultSet intForColumn:@"ID"]+1;
        }
        
        sql=[NSString stringWithFormat:@"insert into Scenes values(%d,'%@',null,null,null,null,null,null,null,null,null)",sceneID,name];
        [db executeUpdate:sql];
    }
    [db close];
    return sceneID;
}

+ (NSArray *)getDeviceSubTypeNameWithRoomID:(int)roomID sceneID:(int)sceneID
{
    NSMutableArray *subTypeNames = [NSMutableArray array];
    
    NSArray *deviceIDs = [self getDeviceIDWithRoomID:roomID sceneID:sceneID];
    
    for (NSString *deviceID in deviceIDs) {
        NSString *subTypeName = [self getDeviceSubTypeNameWithID:[deviceID intValue]];
        
        BOOL isSame = false;
        for (NSString *tempSubTypeName in subTypeNames) {
            if ([tempSubTypeName isEqualToString:subTypeName]) {
                isSame = true;
                break;
            }
        }
        if (isSame) {
            continue;
        }
        
        [subTypeNames addObject:subTypeName];
    }
    
    if (subTypeNames.count < 1) {
        return nil;
    }
    
    return [subTypeNames copy];
}

+(NSArray *)getAllDeviceSubTypes
{
    NSMutableArray *subTypeNames = [NSMutableArray array];
    NSArray *deviceIDs = [self getAllDevicesIds];
    for(NSString *deviceID in deviceIDs)
    {
        NSString *subTypeName = [self getDeviceSubTypeNameWithID:[deviceID intValue]];
        BOOL isSame = false;
        for (NSString *tempSubTypeName in subTypeNames) {
            if ([tempSubTypeName isEqualToString:subTypeName]) {
                isSame = true;
                break;
            }
        }
        if (isSame) {
            continue;
        }
        
        [subTypeNames addObject:subTypeName];
        
    }
    if(subTypeNames.count < 1)
    {
        return  nil;
    }
    
    return subTypeNames;
}
+(NSArray *)getAllDevicesIds
{
    NSMutableArray *deviceIDs = [NSMutableArray array];
    
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    if([db open])
    {
        NSString *sql = @"SELECT eId FROM Scenes";
        
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            NSString *deviceID = [resultSet stringForColumn:@"eId"];
            
            [deviceIDs addObject:deviceID];
        }
    }
    
    if (deviceIDs.count < 1) {
        return nil;
    }
    
    return [deviceIDs copy];

}
+ (NSString *)getDeviceSubTypeNameWithID:(int)ID
{
    NSString *subTypeName = nil;
    
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT subTypeName FROM Devices where ID = %d",ID];
        
        FMResultSet *resultSet = [db executeQuery:sql];
        if ([resultSet next])
        {
            subTypeName = [resultSet stringForColumn:@"subTypeName"];
        }
    }
    
    return subTypeName;
}

+ (NSArray *)getDeviceIDWithRoomID:(int)roomID sceneID:(int)sceneID
{
    NSMutableArray *deviceIDs = [NSMutableArray array];
    
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT eId FROM Scenes where rId = %d and ID = %d",roomID, sceneID];
        
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            NSString *deviceID = [resultSet stringForColumn:@"eId"];
            
            [deviceIDs addObject:deviceID];
        }
    }
    
    if (deviceIDs.count < 1) {
        return nil;
    }
    
    return [deviceIDs copy];
}
+ (Device *)getDeviceWithDeviceID:(int) deviceID
{
    Device *device = nil;
    
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM Devices where ID = %d",deviceID];
        FMResultSet *resultSet = [db executeQuery:sql];
        if ([resultSet next])
        {
            device = [self deviceMdoelByFMResultSet:resultSet];
        }
    }
    
    return device;
}


+ (NSArray *)getDeviceWithRoomID:(int)roomID sceneID:(int)sceneID
{
    NSMutableArray *devices = [NSMutableArray array];
    
    NSArray *deviceIDs = [self getDeviceIDWithRoomID:roomID sceneID:sceneID];
    
    for (NSString *deviceID in deviceIDs) {
        Device *device = [self getDeviceWithDeviceID:[deviceID intValue]];
        
        [devices addObject:device];
    }
    
    if (devices.count < 1) {
        return nil;
    }
    
    return [devices copy];
}


+ (NSArray *)getDeviceTypeNameWithRoomID:(int)roomID sceneID:(int)sceneID subTypeName:(NSString *)subTypeName
{
    NSMutableArray *typeNames = [NSMutableArray array];
    
    NSArray *deviceIDs = [self getDeviceIDWithRoomID:roomID sceneID:sceneID];
    
    for (NSString *deviceID in deviceIDs) {
        NSString *typeName = [self getDeviceTypeNameWithID:deviceID];
        
        if ([typeName isEqualToString:@"开关"] || [typeName isEqualToString:@"调色"] || [typeName isEqualToString:@"调光"]) {
            typeName = @"灯光";
        } else if ([typeName isEqualToString:@"开合帘"] || [typeName isEqualToString:@"卷帘"]) {
            typeName = @"窗帘";
        }
        
        BOOL isSame = false;
        for (NSString *tempTypeName in typeNames) {
            if ([tempTypeName isEqualToString:typeName]) {
                isSame = true;
                break;
            }
        }
        if (isSame) {
            continue;
        }
        
        [typeNames addObject:typeName];
    }
    
    if (typeNames.count < 1) {
        return nil;
    }
    
    return [typeNames copy];
}

+(NSArray *)getAllDeviceNameBysubType:(NSString *)subTypeName
{
    NSMutableArray *typeNames = [NSMutableArray array];
    NSArray *deviceIDs = [self getAllDevicesIds];
    for (NSString *deviceID in deviceIDs) {
        NSString *typeName = [self getDeviceTypeNameWithID:deviceID];
        BOOL isSame = false;
        for (NSString *tempTypeName in typeNames) {
            if ([tempTypeName isEqualToString:typeName]) {
                isSame = true;
                break;
            }
        }
        if (isSame) {
            continue;
        }
        
        [typeNames addObject:typeName];
    }
    
    if (typeNames.count < 1) {
        return nil;
    }
    
    return [typeNames copy];
}

+ (NSString *)getDeviceTypeNameWithID:(NSString *)ID
{
    NSString *typeName = nil;
    
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT typeName FROM Devices where ID = %@",ID];
        
        FMResultSet *resultSet = [db executeQuery:sql];
        if ([resultSet next])
        {
            typeName = [resultSet stringForColumn:@"typeName"];
        }
    }
    
    return typeName;
}


@end