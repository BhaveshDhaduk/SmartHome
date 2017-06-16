//
//  IPadDevicesView.m
//  SmartHome
//
//  Created by Brustar on 2017/6/9.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "IPadDevicesView.h"
#import "SQLManager.h"
#import "LeftMenuCell.h"
#import "NewColourCell.h"
#import "FMTableViewCell.h"
#import "CurtainTableViewCell.h"
#import "ScreenCurtainCell.h"
#import "OtherTableViewCell.h"
#import "BjMusicTableViewCell.h"
#import "AddDeviceCell.h"
#import "IphoneNewAddSceneVC.h"
#import "IpadDVDTableViewCell.h"
#import "NewLightCell.h"
#import "IpadTVCell.h"
#import "AireTableViewCell.h"
#import "SocketManager.h"
#import "PackManager.h"
#import "PowerLightCell.h"

static NSString *const leftMenuCell = @"leftMenuCell";
@implementation IPadDevicesView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.height/2+10);
    }
    return self;
}

-(void)initData
{
    self.menus = [SQLManager allTypeinRoom:self.roomID];
    
    self.devices = [SQLManager deviceOfRoom:self.roomID];
    self.temp = [self.devices copy];
    
    self.menu.dataSource = self.content.dataSource = self;
    self.menu.delegate = self.content.delegate = self;
    
    
    [self.menu setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ipad-frm_left_nol"]]];
    self.menu.separatorStyle = self.content.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UINib *cellNib = [UINib nibWithNibName:@"LeftMenuCell" bundle:nil];
    [self.menu registerNib:cellNib forCellReuseIdentifier:leftMenuCell];
    
    self.content.allowsSelection = NO;
    [self.content registerNib:[UINib nibWithNibName:@"IpadAireTableViewCell" bundle:nil] forCellReuseIdentifier:@"IpadAireTableViewCell"];//空调
    [self.content registerNib:[UINib nibWithNibName:@"CurtainTableViewCell" bundle:nil] forCellReuseIdentifier:@"CurtainTableViewCell"];//窗帘
    [self.content registerNib:[UINib nibWithNibName:@"IpadTVCell" bundle:nil] forCellReuseIdentifier:@"IpadTVCell"];//网络电视
    [self.content registerNib:[UINib nibWithNibName:@"NewColourCell" bundle:nil] forCellReuseIdentifier:@"NewColourCell"];//调色灯
    [self.content registerNib:[UINib nibWithNibName:@"OtherTableViewCell" bundle:nil] forCellReuseIdentifier:@"OtherTableViewCell"];//其他
    [self.content registerNib:[UINib nibWithNibName:@"ScreenTableViewCell" bundle:nil] forCellReuseIdentifier:@"ScreenTableViewCell"];//幕布ScreenCurtainCell
    [self.content registerNib:[UINib nibWithNibName:@"ScreenCurtainCell" bundle:nil] forCellReuseIdentifier:@"ScreenCurtainCell"];//幕布ScreenCurtainCell
    [self.content registerNib:[UINib nibWithNibName:@"IpadDVDTableViewCell" bundle:nil] forCellReuseIdentifier:@"IpadDVDTableViewCell"];//DVD
    [self.content registerNib:[UINib nibWithNibName:@"BjMusicTableViewCell" bundle:nil] forCellReuseIdentifier:@"BjMusicTableViewCell"];//背景音乐
    [self.content registerNib:[UINib nibWithNibName:@"AddDeviceCell" bundle:nil] forCellReuseIdentifier:@"AddDeviceCell"];//添加设备的cell
    [self.content registerNib:[UINib nibWithNibName:@"NewLightCell" bundle:nil] forCellReuseIdentifier:@"NewLightCell"];//调光灯
    [self.content registerNib:[UINib nibWithNibName:@"FMTableViewCell" bundle:nil] forCellReuseIdentifier:@"FMTableViewCell"];//FM
    
    [self.content registerNib:[UINib nibWithNibName:@"PowerLightCell" bundle:nil] forCellReuseIdentifier:@"PowerLightCell"];//开关灯
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 1) {
        Device *device = [self.devices objectAtIndex:indexPath.row];
        NSInteger type = device.hTypeId;
        if (type == 21 || type== air || type == 2 || type == 3 || type == bgmusic || type == screen) {
            return 150;
        }
        if (type == DVDtype || type == TVtype || type == FM) {
            return 210;
        }
        
        return 80;
    }
    return 64;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 1) {
        return self.devices.count;
    }
    return self.menus.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 1)
    {
        Device *device = [self.devices objectAtIndex:indexPath.row];

        switch (device.hTypeId)
        {
            case 2:
            {//调灯光
                NewLightCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewLightCell" forIndexPath:indexPath];
                cell.backgroundColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.AddLightBtn.hidden = YES;
                cell.LightConstraint.constant = 5;
                
                cell.NewLightNameLabel.text = device.name;
                cell.NewLightSlider.continuous = NO;
                cell.NewLightSlider.hidden = NO;
                //cell.deviceid = [NSString stringWithFormat:@"%d", device.eID];
                cell.NewLightPowerBtn.selected = device.power;//开关状态
                cell.NewLightSlider.value = (float)device.bright/100.0f;//亮度状态
                //cell.tag = device.eID;
                [cell query:[NSString stringWithFormat:@"%d", device.eID]];
                return cell;
            }
            case 3:
            {//调色灯
                NewColourCell * newColourCell = [tableView dequeueReusableCellWithIdentifier:@"NewColourCell" forIndexPath:indexPath];
                newColourCell.AddColourLightBtn.hidden = YES;
                newColourCell.ColourLightConstraint.constant = 10;
                newColourCell.backgroundColor =[UIColor clearColor];
                
                newColourCell.colourNameLabel.text = device.name;
                newColourCell.tag = device.eID;
                return newColourCell;
            }
            case 1:
            {
                PowerLightCell * newColourCell = [tableView dequeueReusableCellWithIdentifier:@"PowerLightCell" forIndexPath:indexPath];
                newColourCell.addPowerLightBtn.hidden = YES;
                newColourCell.powerBtnConstraint.constant = 10;
                newColourCell.backgroundColor =[UIColor clearColor];
                newColourCell.tag = device.eID;
                newColourCell.powerLightNameLabel.text = device.name;
                
                return newColourCell;
            }
            case air:
            {
                AireTableViewCell * aireCell = [tableView dequeueReusableCellWithIdentifier:@"IpadAireTableViewCell" forIndexPath:indexPath];
                aireCell.AddAireBtn.hidden = YES;
                aireCell.AireConstraint.constant = 10;
                aireCell.backgroundColor =[UIColor clearColor];
                aireCell.roomID = self.roomID;
                aireCell.AireNameLabel.text = device.name;
                aireCell.deviceid = [NSString stringWithFormat:@"%d", device.eID];
                aireCell.tag = device.eID;
                return aireCell;
            }
            case 21://curtain:
            {
                CurtainTableViewCell * aireCell = [tableView dequeueReusableCellWithIdentifier:@"CurtainTableViewCell" forIndexPath:indexPath];
                aireCell.backgroundColor = [UIColor clearColor];
                aireCell.AddcurtainBtn.hidden = YES;
                aireCell.curtainContraint.constant = 10;
                aireCell.roomID = self.roomID;
                
                aireCell.label.text = device.name;
                aireCell.deviceid = [NSString stringWithFormat:@"%d", device.eID];
                aireCell.tag = device.eID;
                return aireCell;
            }
            case TVtype:
            {
                IpadTVCell * TVCell = [tableView dequeueReusableCellWithIdentifier:@"IpadTVCell" forIndexPath:indexPath];
                TVCell.TVConstraint.constant = 10;
                TVCell.AddTvDeviceBtn.hidden = YES;
                TVCell.backgroundColor =[UIColor clearColor];
                
                TVCell.TVNameLabel.text = device.name;
                TVCell.tag = device.eID;
                return TVCell;
            }
            case DVDtype:
            {
                IpadDVDTableViewCell * DVDCell = [tableView dequeueReusableCellWithIdentifier:@"IpadDVDTableViewCell" forIndexPath:indexPath];
                DVDCell.AddDvdBtn.hidden = YES;
                DVDCell.DVDConstraint.constant = 10;
                DVDCell.backgroundColor =[UIColor clearColor];
                DVDCell.tag = device.eID;
                DVDCell.DVDNameLabel.text = device.name;
                return DVDCell;
            }
            case FM:
            {
                FMTableViewCell * FMCell = [tableView dequeueReusableCellWithIdentifier:@"FMTableViewCell" forIndexPath:indexPath];
                FMCell.backgroundColor =[UIColor clearColor];
                FMCell.FMNameLabel.text = device.name;
                FMCell.deviceid = [NSString stringWithFormat:@"%d", device.eID];
                FMCell.AddFmBtn.hidden = YES;
                FMCell.FMLayouConstraint.constant = 10;
                FMCell.tag = device.eID;
                return FMCell;
            }
            case screen:
            {
                ScreenCurtainCell * ScreenCell = [tableView dequeueReusableCellWithIdentifier:@"ScreenCurtainCell" forIndexPath:indexPath];
                ScreenCell.AddScreenCurtainBtn.hidden = YES;
                ScreenCell.ScreenCurtainConstraint.constant = 10;
                ScreenCell.backgroundColor =[UIColor clearColor];
                
                ScreenCell.ScreenCurtainLabel.text = device.name;
                ScreenCell.deviceid = [NSString stringWithFormat:@"%d", device.eID];
                ScreenCell.tag = device.eID;
                return ScreenCell;
            }
            case bgmusic:
            {
                BjMusicTableViewCell * BjMusicCell = [tableView dequeueReusableCellWithIdentifier:@"BjMusicTableViewCell" forIndexPath:indexPath];
                BjMusicCell.backgroundColor = [UIColor clearColor];
                BjMusicCell.AddBjmusicBtn.hidden = YES;
                BjMusicCell.BJmusicConstraint.constant = 10;
                BjMusicCell.tag = device.eID;
                BjMusicCell.BjMusicNameLb.text = device.name;
                BjMusicCell.deviceid = [NSString stringWithFormat:@"%d", device.eID];
                
                return BjMusicCell;
            }
            default:
            {
                OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
                otherCell.AddOtherBtn.hidden = YES;
                otherCell.OtherConstraint.constant = 10;
                otherCell.backgroundColor = [UIColor clearColor];
                otherCell.deviceid = [NSString stringWithFormat:@"%d", device.eID];
                if (device.name == nil) {
                    otherCell.NameLabel.text = @"";
                }else{
                    otherCell.NameLabel.text = device.name;
                }
                otherCell.tag = device.eID;
                return otherCell;
            }
        }
    }else{
        LeftMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:leftMenuCell forIndexPath:indexPath];

        Device *device = [self.menus objectAtIndex:indexPath.row];
        cell.lbl.text = device.subTypeName;
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 1) {
        
    }else{
        Device *device = [self.menus objectAtIndex:indexPath.row];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"subTypeId==%ld", device.subTypeId];
        self.devices = [self.temp filteredArrayUsingPredicate:pred];
        [self.content reloadData];
    }
}

@end
