//
//  NewWindController.m
//  SmartHome
//
//  Created by KobeBryant on 2017/9/13.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "NewWindController.h"

@interface NewWindController ()

@end

@implementation NewWindController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.roomID = (int)[DeviceInfo defaultManager].roomID;
    NSString *roomName = [SQLManager getRoomNameByRoomID:self.roomID];
    self.title = [NSString stringWithFormat:@"%@ - 新风",roomName];
    [self setNaviBarTitle:self.title];
    Device *device = [SQLManager getDeviceWithDeviceHtypeID:newWind roomID:self.roomID];
    self.deviceID = [NSString stringWithFormat:@"%d", device.eID];
    
    //查询新风的开关状态，温度
    NSData *data = [[DeviceInfo defaultManager] query:self.deviceID];
    SocketManager *sock = [SocketManager defaultManager];
    sock.delegate = self;
    [sock.socket writeData:data withTimeout:1 tag:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)powerBtnClicked:(id)sender {
     UIButton *btn = (UIButton *)sender;
     btn.selected = !btn.selected;
    if (btn.selected) {
        //发开指令  
        NSData *data = [[DeviceInfo defaultManager] toogleFreshAir:0x01 deviceID:self.deviceID deviceType:0x30];
        SocketManager *sock = [SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
        
        //发送风指令
        data = [[DeviceInfo defaultManager] changeMode:0x41 deviceID:self.deviceID deviceType:0x30];
        [sock.socket writeData:data withTimeout:1 tag:1];
        
    }else {
        //发关指令
        NSData *data = [[DeviceInfo defaultManager] toogleFreshAir:0x00 deviceID:self.deviceID deviceType:0x30];
        SocketManager *sock = [SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
    }
}

- (IBAction)highSpeedBtnClicked:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (btn.selected) {
        return;
    }else {
        btn.selected = !btn.selected;
        if (btn.selected) {
            self.middleSpeedBtn.selected = NO;
            self.lowSpeedBtn.selected = NO;
            // 发高速指令
            NSData *data = [[DeviceInfo defaultManager] changeSpeed:0x35 deviceID:self.deviceID deviceType:0x30];
            SocketManager *sock = [SocketManager defaultManager];
            [sock.socket writeData:data withTimeout:1 tag:1];
            
        }
    }
}

- (IBAction)middleSpeedBtnClicked:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (btn.selected) {
        return;
    }else {
        btn.selected = !btn.selected;
        if (btn.selected) {
            self.highSpeedBtn.selected = NO;
            self.lowSpeedBtn.selected = NO;
            // 发中速指令
            NSData *data = [[DeviceInfo defaultManager] changeSpeed:0x36 deviceID:self.deviceID deviceType:0x30];
            SocketManager *sock = [SocketManager defaultManager];
            [sock.socket writeData:data withTimeout:1 tag:1];
        }
    }
}

- (IBAction)lowSpeedBtnClicked:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (btn.selected) {
        return;
    }else {
        btn.selected = !btn.selected;
        if (btn.selected) {
            self.middleSpeedBtn.selected = NO;
            self.highSpeedBtn.selected = NO;
            // 发低速指令
            NSData *data = [[DeviceInfo defaultManager] changeSpeed:0x37 deviceID:self.deviceID deviceType:0x30];
            SocketManager *sock = [SocketManager defaultManager];
            [sock.socket writeData:data withTimeout:1 tag:1];
        }
    }
}

#pragma mark - TCP recv delegate
-(void)recv:(NSData *)data withTag:(long)tag
{
    Proto proto = protocolFromData(data); 
    
    if (CFSwapInt16BigToHost(proto.masterID) != [[DeviceInfo defaultManager] masterID]) {
        return;
    }
    
    if (proto.cmd == 0x01) {
        
        if (proto.action.state == 0x6A) { //温度
            self.tempLabel.text = [NSString stringWithFormat:@"%d°C",proto.action.RValue];
        }
        
        NSString *devID = [SQLManager getDeviceIDByENumber:CFSwapInt16BigToHost(proto.deviceID)];
        if ([devID intValue] == [self.deviceID intValue]) {
            if (proto.action.state == PROTOCOL_OFF || proto.action.state == PROTOCOL_ON) {  //开关
                self.powerBtn.selected = proto.action.state;
            }
        }
    }
}

@end
