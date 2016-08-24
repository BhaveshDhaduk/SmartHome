//
//  EditSceneController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/8/3.
//  Copyright © 2016年 Brustar. All rights reserved.
//
#define backGroudColour [UIColor colorWithRed:55/255.0 green:73/255.0 blue:91/255.0 alpha:1]

#import "EditSceneController.h"
#import "EditSceneCell.h"
#import "LightController.h"
#import "CurtainController.h"
#import "TVController.h"
#import "DVDController.h"
#import "NetvController.h"
#import "FMController.h"
#import "DeviceManager.h"
#import "Device.h"
#import "SceneManager.h"
#import "DeviceListController.h"
#import "AirController.h"
#import "HttpManager.h"
@interface EditSceneController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITableView *subDeviceTableView;

@property (weak, nonatomic) IBOutlet UIView *footerView;
//设备种类
@property(nonatomic,strong) NSArray *devicesTypes;

@property (weak, nonatomic) IBOutlet UIButton *realObjBtn;
@property (weak, nonatomic) IBOutlet UIButton *graphicBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;
@property (weak, nonatomic) IBOutlet UIButton *addDeviceBtn;
@property (nonatomic,assign) NSInteger selectedRow;
@property (nonatomic,strong) NSArray *subTypeArr;

@property (weak, nonatomic) IBOutlet UIView *devicelView;
@property (nonatomic,strong) LightController *ligthVC;

//当前房间当前场景的所有设备
@property (nonatomic,strong) NSArray *devices;
//当前房间当前场景的所有设备类别的子类
@property (nonatomic,strong) NSArray *typeArray;
@end

@implementation EditSceneController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.tableFooterView = self.footerView;
    self.tableView.backgroundColor = backGroudColour;
    self.subDeviceTableView.backgroundColor = backGroudColour;
    self.view.backgroundColor = backGroudColour;
    
    [self setupData];
    }


- (void)setupData
{
    self.devices = [DeviceManager getDeviceWithRoomID:self.roomID sceneID:self.sceneID];
    
    self.devicesTypes = [DeviceManager getDeviceSubTypeNameWithRoomID:self.roomID sceneID:self.sceneID];
    
    self.subTypeArr = [DeviceManager getDeviceTypeNameWithRoomID:self.roomID sceneID:self.sceneID subTypeName:self.devicesTypes[0]];
    
    [self.tableView reloadData];
    [self.subDeviceTableView reloadData];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //右边的根据左边选中的设备大类的设备子类数量
    if (tableView == self.tableView) {
        return self.devicesTypes.count;
    }
    else {
        return self.subTypeArr.count;
    }

   
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EditSceneCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EditSceneCell" forIndexPath:indexPath];
    if(tableView == self.tableView)
    {
        cell.label.text = self.devicesTypes[indexPath.row];
        [cell.button setBackgroundImage:[UIImage imageNamed:@"store"] forState:UIControlStateNormal];
    }else {
        //根据设备子类数据
        cell.label.text = self.subTypeArr[indexPath.row];
        [cell.button setBackgroundImage:[UIImage imageNamed:@"store"] forState:UIControlStateNormal];
    }
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(tableView == self.subDeviceTableView)
        
    {
       self.subTypeArr =  [DeviceManager getDeviceTypeNameWithRoomID:self.roomID sceneID:self.sceneID subTypeName:self.devicesTypes[indexPath.row]];
        NSString *typeName = self.subTypeArr[indexPath.row];
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        if([typeName isEqualToString:@"电视"])
        {
            TVController *tVC = [storyBoard instantiateViewControllerWithIdentifier:@"TVController"];
            tVC.sceneid =[NSString stringWithFormat:@"%d",self.sceneID];
            
            [self addViewAndVC:tVC];
            
        }else if([typeName isEqualToString:@"灯光"])
        {
            LightController *ligthVC = [storyBoard instantiateViewControllerWithIdentifier:@"LightController"];
            ligthVC.roomID = self.roomID;
            ligthVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
            [self addViewAndVC:ligthVC];

        }else if([typeName isEqualToString:@"窗帘"])
        {
            CurtainController *curtainVC = [storyBoard instantiateViewControllerWithIdentifier:@"CurtainController"];
            curtainVC.roomID = self.roomID;
            curtainVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
            [self addViewAndVC:curtainVC];

            
        }else if([typeName isEqualToString:@"DVD"])
        {
            
            DVDController *dvdVC = [storyBoard instantiateViewControllerWithIdentifier:@"DVDController"];
            dvdVC.roomID = self.roomID;
            dvdVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
            [self addViewAndVC:dvdVC];

        }else if([typeName isEqualToString:@"FM"])
        {
             FMController *fmVC = [storyBoard instantiateViewControllerWithIdentifier:@"FMController"];
            fmVC.roomID = self.roomID;
            fmVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
            [self addViewAndVC:fmVC];

        }else if([typeName isEqualToString:@"空调"])
        {
            AirController *airVC = [storyBoard instantiateViewControllerWithIdentifier:@"AirController"];
            airVC.roomID = self.roomID;
            airVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
        }else{
            NetvController *netVC = [storyBoard instantiateViewControllerWithIdentifier:@"NetvController"];
            netVC.roomID = self.roomID;
            netVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
            [self addViewAndVC:netVC];

        }
    }
}

-(void )addViewAndVC:(UIViewController *)vc
{
    vc.view.frame = self.devicelView.frame;
    [self.view addSubview:vc.view];
    [self addChildViewController:vc];
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
     cell.backgroundColor = backGroudColour;
    
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"deviceListSegue"])
    {
        id theSegue = segue.destinationViewController;
        [theSegue setValue:[NSNumber numberWithInt:self.roomID] forKey:@"roomid"];
    }
       
}

- (IBAction)saveScene:(UIBarButtonItem *)sender {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"请选择" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:saveAction];
    UIAlertAction *saveNewAction = [UIAlertAction actionWithTitle:@"另存为新场景" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //另存为场景
        
        
    }];
    [alertVC addAction:saveNewAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertVC dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertVC addAction:cancelAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



@end
