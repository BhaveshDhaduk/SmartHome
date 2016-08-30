//
//  LoginController.m
//  SmartHome
//
//  Created by Brustar on 16/6/29.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "LoginController.h"
#import "CryptoManager.h"
#import "MBProgressHUD+NJ.h"
#import "WebManager.h"
#import "RegexKitLite.h"
#import "SocketManager.h"
#import "ScenseController.h"
#import "QRCodeReaderDelegate.h"
#import "QRCodeReader.h"
#import "QRCodeReaderViewController.h"
#import "RegisterPhoneNumController.h"
#import "MSGController.h"
#import "ProfieFaultsViewController.h"
#import "ServiceRecordViewController.h"
#import "RegisterDetailController.h"
#import "ECloudTabBarController.h"
#import "DeviceManager.h"
#import "RoomManager.h"
#import "FMDatabase.h"
#import "DeviceInfo.h"
#import "PackManager.h"

@interface LoginController ()<QRCodeReaderDelegate,UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITextField *user;
@property (weak, nonatomic) IBOutlet UITextField *pwd;
@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIView *registerView;

@property(nonatomic,assign) NSInteger userType;
@property(nonatomic,strong) NSString *masterId;
@property(nonatomic,strong) NSString *role;
@property(nonatomic,strong) NSMutableArray *hostIDS;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,assign) int vEquipmentsLast;
@property (nonatomic,assign) int vRoomLast;
@property (nonatomic,assign) int vSceneLast;
@property (nonatomic,assign) int vTVChannelLast;
@property (nonatomic,assign) int vFMChannellLast;
@property (nonatomic,assign) int vClientlLast;



@end

@implementation LoginController
-(NSMutableArray *)hostIDS
{
    if(!_hostIDS)
    {
        _hostIDS = [NSMutableArray array];
    }
    return _hostIDS;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [UIView new];
    self.user.text = [[NSUserDefaults  standardUserDefaults] objectForKey:@"Account"];
    self.userType = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Type"] intValue];
    self.pwd.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"Password"];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (IBAction)login:(id)sender
{
    if ([self.user.text isEqualToString:@""])
    {
        [MBProgressHUD showError:@"请输入用户名或手机号"];
        return;
    }
    
    if ([self.pwd.text isEqualToString:@""])
    {
        [MBProgressHUD showError:@"请输入密码"];
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@UserLogin.aspx",[IOManager httpAddr]];
    
    self.userType = 1;
    if([self isMobileNumber:self.user.text])
    {
        self.userType = 2;
    }

    
    NSDictionary *dict = @{@"Account":self.user.text,@"Type":[NSNumber numberWithInteger:self.userType],@"Password":[self.pwd.text md5]};
    [IOManager writeUserdefault:self.user.text forKey:@"Account"];
    [IOManager writeUserdefault:[NSNumber numberWithInteger:self.userType] forKey:@"Type"];
    [IOManager writeUserdefault:self.pwd.text forKey:@"Password"];
    HttpManager *http=[HttpManager defaultManager];
    http.delegate=self;
    http.tag = 1;
    [http sendPost:url param:dict];
    
}
//获取设备配置信息
- (void)sendRequestForGettingConfigInfos:(NSString *)str withTag:(int)tag;
{
    NSString *url = [NSString stringWithFormat:@"%@%@",[IOManager httpAddr],str];
    
    NSDictionary *dic = @{@"AuthorToken":[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"]};
    HttpManager *http = [HttpManager defaultManager];
    http.delegate = self;
    http.tag = tag;
    [http sendPost:url param:dic];
}


//判断版本号
-(void)judgeVersion:(NSDictionary *)responseObject tag:(int) tag
{
    if ( 4 == tag)
    {
        self.vEquipmentsLast = [responseObject[@"vEquipment"] intValue];
        self.vRoomLast = [responseObject[@"vRoom"] intValue];
        self.vSceneLast = [responseObject[@"vScene"] intValue];
        //self.vSceneLast = 5;
        self.vTVChannelLast = [responseObject[@"vTVChannel"] intValue];
        self.vFMChannellLast = [responseObject[@"vFMChannel"] intValue];
        self.vClientlLast = [responseObject[@"vClient"] intValue];
    }
    
    int vEquipment = [[[NSUserDefaults standardUserDefaults] objectForKey:@"vEquipment"] intValue] ;
    int vRoom = [[[NSUserDefaults standardUserDefaults] objectForKey:@"vRoom"] intValue];
    int vScene = [[[NSUserDefaults standardUserDefaults] objectForKey:@"vScene"] intValue];
    int vTVChannel = [[[NSUserDefaults standardUserDefaults] objectForKey:@"vTVChannel"] intValue];
    int vFMChannel = [[[NSUserDefaults standardUserDefaults] objectForKey:@"vFMChannel"] intValue];
    int vClient = [[[NSUserDefaults standardUserDefaults] objectForKey:@"vClient"] intValue];
    
    
    switch (tag) {
        case 4:
            if(self.vEquipmentsLast > vEquipment)
            {
                // 更新设备
                [IOManager writeUserdefault:[NSNumber numberWithInt:self.vEquipmentsLast] forKey:@"vEquipment"];
                [self sendRequestForGettingConfigInfos:@"GetEquipmentsInfo.aspx" withTag:5];
                return;
            }
        case 5:
            if(self.vRoomLast > vRoom)
            {
                //更新房间
                [self updateRoomInfo];
                return;
            }
        case 6:
            if(self.vSceneLast > vScene)
            {
                //更新场景
                [self updateSceneInfo];
                return;
            }
        case 7:
            if(self.vTVChannelLast > vTVChannel){
                [self updateTVChannelsInfo];
                return;
            }
        case 8:
            if(self.vFMChannellLast > vFMChannel){
                [self updateFMChannelsInfo];
                return;
            }
        default:
            [self goToViewController];
            break;
    }
    
    
}
//更新房间配置信息
-(void)updateRoomInfo{
    
    [IOManager writeUserdefault:[NSNumber numberWithInt:self.vRoomLast] forKey:@"vRoom"];
    [self sendRequestForGettingConfigInfos:@"GetRoomsConfig.aspx" withTag:6];
}
//更新场景配置信息
-(void)updateSceneInfo
{
    [IOManager writeUserdefault:[NSNumber numberWithInt:self.vSceneLast] forKey:@"vScene"];
    [self sendRequestForGettingConfigInfos:@"GetScenes.aspx" withTag:7];
}
//更新电视频道配置信息
-(void)updateTVChannelsInfo
{
    [IOManager writeUserdefault:[NSNumber numberWithInt:self.vTVChannelLast] forKey:@"vTVChannel"];
    [self sendRequestForGettingConfigInfos:@"GetTVChannels.aspx" withTag:8];
}
//更新FM频道配置信息
-(void)updateFMChannelsInfo
{
    [IOManager writeUserdefault:[NSNumber numberWithInt:self.vFMChannellLast] forKey:@"vFMChannel"];
    [self sendRequestForGettingConfigInfos:@"GetFMChannels.aspx" withTag:9];
}
//写设备配置信息到sql
-(void)writDevicesConfigDatesToSQL:(NSDictionary *)responseObject
{
    
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if([db open])
    {
        
        NSArray *messageInfo =  responseObject[@"messageInfo"];
        if(messageInfo.count ==0 || messageInfo == nil)
        {
            return;
        }
        for(NSDictionary *dic in messageInfo)
        {
            NSInteger rId = [dic[@"rId"] integerValue];
            NSArray *equipmentList = dic[@"equipmentList"];
            if(equipmentList.count ==0 || equipmentList == nil)
            {
                continue;
            }
            for(NSDictionary *equip in equipmentList)
            {
                NSString *sql = [NSString stringWithFormat:@"insert into Devices values(%d,'%@',%@,%@,%@,%@,%@,%@,%@,'%@',%@,%@,%@,%@,%ld,'%@','%@',%@,'%@','%@','%04lx','%@')",[equip[@"eId"] intValue],equip[@"eName"],NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,rId,equip[@"eNumber"],equip[@"hTypeId"],equip[@"subTypeId"],equip[@"typeName"],equip[@"subTypeName"],[[DeviceInfo defaultManager] masterID],equip[@"url"]];
                
                BOOL result = [db executeUpdate:sql];
                if(result)
                {
                    NSLog(@"insert 成功");
                }else{
                    NSLog(@"insert 失败");
                }
                
            }
            
        }
        
    }
    [db close];
    
}
//写房间配置信息到SQL
-(void)writeRoomsConfigDataToSQL:(NSDictionary *)responseObject
{
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if([db open])
    {
        NSDictionary *messageInfo = responseObject[@"messageInfo"];
        NSArray *roomList = messageInfo[@"roomList"];
        if(roomList.count == 0 || roomList == nil)
        {
            return;
        }
        for(NSDictionary *roomDic in roomList)
        {
            NSString *sql = [NSString stringWithFormat:@"insert into Rooms values(%d,'%@',%@,%@,%@,%@,%@,'%@')",[roomDic[@"rId"] intValue],roomDic[@"rName"],NULL,NULL,NULL,NULL,NULL,roomDic[@"imgUrl"]];
            BOOL result = [db executeUpdate:sql];
            if(result)
            {
                NSLog(@"insert 成功");
            }else{
                NSLog(@"insert 失败");
            }
        }
    }
    [db close];
    
}

//写场景配置信息到SQL
-(void)writeScensConfigDataToSQL:(NSDictionary *)responseObject
{
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if([db open])
    {
        NSArray *messageInfo = responseObject[@"messageInfo"];
        
        for(NSDictionary *messageDic in  messageInfo)
        {
            NSInteger rId = [messageDic[@"rId"] integerValue];
            NSString *rName = messageDic[@"rName"];
            NSArray *sceneList = messageDic[@"c_sceneInfoList"];
            for(NSDictionary *dic in sceneList)
            {
                NSString *sId = dic[@"sId"];
                NSString *sName = dic[@"sName"];
                int sType = [dic[@"sType"] intValue];
                
                NSString *urlImg = dic[@"urlImage"];
                NSString *startTime = dic[@"startTime"];
                NSString *astronomicalTime = dic[@"astronomicalTime"];
                NSString *weakValue = dic[@"weekValue"];
                NSInteger weekRepeat = [dic[@"weekRepeat"] integerValue];
                NSArray *deviceList = dic[@"scceqSubTypeList"];
               
                NSMutableString *strEid = [[NSMutableString alloc]init];

                for(NSDictionary *equDic in deviceList)
                {
                    NSArray *sceeqTypeList = equDic[@"sceeqTypeList"];
                                                           for(NSDictionary *typeList in sceeqTypeList)
                    {
                        NSArray *sceeqList = typeList[@"sceeqList"];
                                                for(NSDictionary *eList in sceeqList)
                        {
                            
                            NSInteger eId = [eList[@"eId"] integerValue];
                           [strEid appendString:[NSString stringWithFormat:@"%ld,",eId]];
                            
                        }
                       
                    }
                    
                }
                NSString *str = [strEid copy];
                NSString *strEids;
                if(str.length != 0)
                {
                   strEids = [str substringToIndex:[str length] - 1];
                   
                }else{
                   strEids = @"";
                }
                NSString *sql = [NSString stringWithFormat:@"insert into Scenes values('%@','%@','%@','%@',%@,'%@','%@','%@','%@',%ld,%ld,%d)",sId,sName,rName,urlImg,NULL,strEids,startTime,astronomicalTime,weakValue,weekRepeat,rId,sType];
                BOOL result = [db executeUpdate:sql];
                if(result)
                {
                    NSLog(@"insert 成功");
                }else{
                    NSLog(@"insert 失败");
                }

                
            }

        }
    }
    
       [db close];
    
}
//写电视频道配置信息到SQL
-(void)writeTVChannelsConfigDataToSQL:(NSDictionary *)responseObject withParent:(NSString *)parent
{
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if([db open])
    {
        NSArray *messageInfo = responseObject[@"messageInfo"];
       
        for(NSDictionary *dicInfo in messageInfo)
        {
            int eqId = [dicInfo[@"eqId"] intValue];
            NSString *eqNumber = dicInfo[@"eqNumber"];
            NSArray *channelInfo = dicInfo[@"channelInfo"];
            if(channelInfo == nil || channelInfo .count == 0 )
            {
                return;
            }
            
            for(NSDictionary *channel in channelInfo)
            {
                
                NSString *sql = [NSString stringWithFormat:@"insert into Channels values(%d,%d,%d,'%@','%@','%@',%d,'%@')",[channel[@"cId"] intValue],eqId,[channel[@"cNumber"] intValue],channel[@"cName"],channel[@"imgUrl"],parent,1,eqNumber];
                BOOL result = [db executeUpdate:sql];
                if(result)
                {
                    NSLog(@"insert 成功");
                }else{
                    NSLog(@"insert 失败");
                }
                
            }
            
        }
    }
    [db close];
}


-(void) httpHandler:(id) responseObject tag:(int)tag
{
    if(tag == 1)
    {
        if ([responseObject[@"Result"] intValue]==0) {
            [IOManager writeUserdefault:responseObject[@"AuthorToken"] forKey:@"AuthorToken"];
            NSArray *hostList = responseObject[@"HostList"];
            DeviceInfo *info=[DeviceInfo defaultManager];
            
            for(NSDictionary *hostID in hostList)
            {
                
                [self.hostIDS addObject:hostID[@"hostId"]];
            }
            
            NSString *mid = self.hostIDS[0];
            info.masterID =[PackManager NSDataToUint16:mid];
            NSInteger count = self.hostIDS.count;
            
            if(count == 1)
            {
               
                //直接登录主机
                [self sendRequestToHostWithTag:2 andRow:0];
                //[self goToViewController];
            }else{
                self.tableView.hidden = NO;
                self.coverView.hidden = NO;
                [self.tableView reloadData];
            }
            
            
         
            

            
        }else{
                [MBProgressHUD showError:responseObject[@"Msg"]];
            }
        
    }else if(tag == 2 || tag == 3 )
    {
        if ([responseObject[@"Result"] intValue]==0)
        {
            
           // [IOManager writeUserdefault:responseObject[@"AuthorToken"] forKey:@"AuthorToken"];
            self.tableView.hidden = YES;
            self.coverView.hidden = YES;
            
            //检查版本号
            [self sendRequestForGettingConfigInfos:@"GetConfigVersion.aspx" withTag:4];
        }
        
    }else if(tag == 4){
        if([responseObject[@"Result"] intValue]==0)
        {
            //判断版本号
            [self judgeVersion:(responseObject) tag:tag];
        }
        
    }else if (tag == 5){
        if([responseObject[@"Result"] intValue] == 0)
        {
            //写设备配置信息到sql
            [self writDevicesConfigDatesToSQL:responseObject];
            //判断房间版本
            [self judgeVersion:(responseObject) tag:tag];
            
        }else{
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }
        
    }else if (tag == 6){
        if([responseObject[@"Result"] intValue] == 0)
        {
            //写房间配置信息到sql
            [self writeRoomsConfigDataToSQL:responseObject];
            
            [self judgeVersion:(responseObject) tag:tag];
        }else{
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }
        
    }else if(tag == 7)
    {
        if([responseObject[@"Result"] intValue] == 0)
        {
            //写场景信息到sql
            [self writeScensConfigDataToSQL:responseObject];
            
            [self judgeVersion:(responseObject) tag:tag];
        }else{
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }
    }else if(tag == 8)
    {
        if([responseObject[@"Result"] intValue] == 0)
        {
            //写TV频道信息到sql
            [self writeTVChannelsConfigDataToSQL:responseObject withParent:@"TV"];
            
            [self judgeVersion:(responseObject) tag:tag];
        }else{
            [MBProgressHUD showError:responseObject[@"Msg"]];
            
        }
    }else if(tag == 9)
    {
        if([responseObject[@"Result"] intValue] == 0)
        {
            //写FM频道信息到sql
           
            
            [self writeTVChannelsConfigDataToSQL:responseObject withParent:@"FM"];
            
            [self goToViewController];
        }else{
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }
    }
    
}



-(void)goToViewController;
{
    ECloudTabBarController *ecloudVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ECloudTabBarController"];
    [self presentViewController:ecloudVC animated:YES completion:nil];

}
-(void)sendRequestToHostWithTag:(int)tag andRow:(int)row
{
    NSString *url = [NSString stringWithFormat:@"%@UserLoginHost.aspx",[IOManager httpAddr]];

    NSDictionary *dict = @{@"AuthorToken":[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"],@"HostID":self.hostIDS[row]};
    
    [[NSUserDefaults standardUserDefaults] setObject:self.user.text forKey:@"Account"];
    HttpManager *http=[HttpManager defaultManager];
    http.delegate=self;
    http.tag = tag;
    [http sendPost:url param:dict];
}

- (BOOL)isMobileNumber:(NSString *)mobileNum
{
    NSString *regex=@"^1[3|4|5|7|8]\\d{9}$";
    return [mobileNum isMatchedByRegex:regex];
}

- (IBAction)forgotPWD:(id)sender
{
    [WebManager show:@"http://115.28.151.85:8088/forgotpwd/Index.aspx"];
}

//注册
- (IBAction)registerAccount:(id)sender {
    self.coverView.hidden = NO;
    self.registerView.hidden = NO;
}

- (IBAction)cancelRegister:(id)sender {
    self.coverView.hidden = YES;
    self.registerView.hidden = YES;
}
- (IBAction)scanCodeForRegistering:(id)sender {
    if ([QRCodeReader supportsMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]]) {
        static QRCodeReaderViewController *vc = nil;
        static dispatch_once_t onceToken;
        
        dispatch_once(&onceToken, ^{
            QRCodeReader *reader = [QRCodeReader readerWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
            vc = [QRCodeReaderViewController readerWithCancelButtonTitle:@"取消" codeReader:reader startScanningAtLoad:YES showSwitchCameraButton:YES showTorchButton:YES];
            vc.modalPresentationStyle = UIModalPresentationFormSheet;
        });
        vc.delegate = self;
        
        [vc setCompletionWithBlock:^(NSString *resultAsString) {
            NSLog(@"Completion with result: %@", resultAsString);
        }];
        
        [self presentViewController:vc animated:YES completion:NULL];
    }
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"标题" message:@"不能打开摄像头，请确认授权使用摄像头" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
    }
    
}


- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result
{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RegisterPhoneNumController *registVC = [story instantiateViewControllerWithIdentifier:@"RegisterPhoneNumController"];
    [self dismissViewControllerAnimated:YES completion:^{
        
         NSArray* list = [result componentsSeparatedByString:@"@"];
            if([list count] > 1)
            {
                self.masterId = list[0];
                [registVC setValue:self.masterId forKey:@"masterStr"];
                                if ([@"1" isEqualToString:list[1]]) {
                    self.role=@"主人";
                }else{
                    self.role=@"客人";
                }
                [registVC setValue:self.role forKey:@"suerTypeStr"];
            }
            else
            {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"非法的二维码" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
                [alert addAction:okAction];
                [self presentViewController:alert animated:YES completion:nil];
            }

    }];
    [self presentViewController:registVC animated:YES completion:nil];
    
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.coverView.hidden = YES;
    self.registerView.hidden = YES;
}

#pragma  mark -UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.hostIDS.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.hostIDS[indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row =(int)indexPath.row;
    [self sendRequestToHostWithTag:3 andRow:row];
}
- (void)readerDidCancel:(QRCodeReaderViewController *)reader
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
