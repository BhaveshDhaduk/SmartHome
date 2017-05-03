//
//  AirController.m
//  SmartHome
//
//  Created by Brustar on 16/6/17.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "AirController.h"
#import "SceneManager.h"
#import "Aircon.h"
#import "YALContextMenuTableView.h"
#import "ContextMenuCell.h"
#import "SocketManager.h"
#import "PackManager.h"
#import "SQLManager.h"
#import "UIImageView+Badge.h"
#import "ORBSwitch.h"

#define MAX_TEMP_ROTATE_DEGREE 330
#define MIX_TEMP_ROTATE_DEGREE 120


static NSString *const airCellIdentifier = @"airCell";
@interface AirController ()<UITableViewDataSource,UITableViewDelegate,ORBSwitchDelegate,YALContextMenuTableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *showTemLabel;
@property (weak, nonatomic) IBOutlet UILabel *wetLabel;
@property (weak, nonatomic) IBOutlet UILabel *pmLabel;
@property (weak, nonatomic) IBOutlet UILabel *noiseLabel;
@property (strong, nonatomic) IBOutlet YALContextMenuTableView *paramView;
@property (weak, nonatomic) IBOutlet UIImageView *pm_clock_hand;
@property (weak, nonatomic) IBOutlet UIImageView *humidity_hand;
@property (weak, nonatomic) IBOutlet UIButton *disk;
@property (weak, nonatomic) IBOutlet UILabel *tempretureLbl;

@property (weak, nonatomic) IBOutlet UIView *container;

@property (weak, nonatomic) IBOutlet UIImageView *tempreturePan;
@property (nonatomic,strong) ORBSwitch *switcher;
@property (nonatomic,strong) NSMutableArray *visitedBtns;

@end

@implementation AirController

- (void)setRoomID:(int)roomID
{
    _roomID = roomID;
    if(roomID)
    {
        self.deviceid = [SQLManager singleDeviceWithCatalogID:air byRoom:self.roomID];;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNaviBarTitle:@"空调"];
    self.disk.enabled = NO;
    [self initSwitch];
    self.tempreturePan.transform = CGAffineTransformMakeRotation(MIX_TEMP_ROTATE_DEGREE);
    self.visitedBtns = [NSMutableArray new];
    self.params=@[@[@"speed_fast",@"speed_middle",@"speed_slow"],@[@"speed_dir_down",@"speed_dir_up"]];
    self.paramView.scrollEnabled=NO;
    
    _scene=[[SceneManager defaultManager] readSceneByID:[self.sceneid intValue]];
    if ([self.sceneid intValue]>0) {
        for(int i=0;i<[_scene.devices count];i++)
        {
            if ([[_scene.devices objectAtIndex:i] isKindOfClass:[Aircon class]]) {
                
                self.showTemLabel.text = [NSString stringWithFormat:@"%d°C", ((Aircon*)[_scene.devices objectAtIndex:i]).temperature];
                self.currentMode=((Aircon*)[_scene.devices objectAtIndex:i]).mode;
                self.currentLevel=((Aircon*)[_scene.devices objectAtIndex:i]).WindLevel;
                self.currentDirection=((Aircon*)[_scene.devices objectAtIndex:i]).Windirection;
                self.currentTiming=((Aircon*)[_scene.devices objectAtIndex:i]).timing;
            }
        }
    }
    
    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate=self;
    
    NSData *data = [[DeviceInfo defaultManager] query:self.deviceid];
    [sock.socket writeData:data withTimeout:1 tag:1];
    
    NSString *pmID = [SQLManager singleDeviceWithCatalogID:55 byRoom:self.roomID];
    data = [[DeviceInfo defaultManager] query:pmID];
    [sock.socket writeData:data withTimeout:1 tag:1];
    NSString *humidityID = [SQLManager singleDeviceWithCatalogID:50 byRoom:self.roomID];
    data = [[DeviceInfo defaultManager] query:humidityID];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

-(void) initSwitch
{
    self.switcher = [[ORBSwitch alloc] initWithCustomKnobImage:[UIImage imageNamed:@"air_control_off"] inactiveBackgroundImage:nil activeBackgroundImage:nil frame:CGRectMake(0, 0, 122, 122)];
    
    self.switcher.knobRelativeHeight = 1.0f;
    self.switcher.delegate = self;

    [self.container addSubview:self.switcher];
}

-(IBAction)save:(id)sender
{
    if ([sender isEqual:self.switcher]) {
        NSData *data=[[DeviceInfo defaultManager] toogle:self.switcher.isOn deviceID:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
    }
    Aircon *device = [[Aircon alloc]init];
    [device setDeviceID:[self.deviceid intValue]];
    
    [device setMode:self.currentMode];
    [device setWindLevel:self.currentLevel];
    [device setWindirection:self.currentDirection];
    [device setTiming:self.currentTiming];
    
    [device setTemperature:[self.showTemLabel.text intValue]];
    
    
    [_scene setSceneID:[self.sceneid intValue]];
    [_scene setRoomID:self.roomID];
    [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
    [_scene setReadonly:NO];
    
    NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:_scene withDeivce:device withId:device.deviceID];
    [_scene setDevices:devices];
    
    [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""]];
    
}

#pragma mark - TCP recv delegate
-(void)recv:(NSData *)data withTag:(long)tag
{
    Proto proto=protocolFromData(data);
    
    if (CFSwapInt16BigToHost(proto.masterID) != [[DeviceInfo defaultManager] masterID]) {
        return;
    }
    
    if (tag==0) {
        if (proto.action.state==0x7A) {
            self.showTemLabel.text = [NSString stringWithFormat:@"%d°C",proto.action.RValue];
        }
        if (proto.action.state==0x8A) {
            NSString *valueString = [NSString stringWithFormat:@"%d %%",proto.action.RValue];
            self.wetLabel.text = valueString;
            [self.humidity_hand rotate:30+proto.action.RValue*100/300];
        }
        if (proto.action.state==0x7F) {
            NSString *valueString = [NSString stringWithFormat:@"%d ug/m³",proto.action.RValue];
            self.pmLabel.text = valueString;
            [self.pm_clock_hand rotate:30+proto.action.RValue*500/300];
        }
        if (proto.action.state==0x7E) {
            NSString *valueString = [NSString stringWithFormat:@"%d db",proto.action.RValue];
            self.noiseLabel.text = valueString;
        }
    }
}
- (IBAction)changeMode:(id)sender {
    uint8_t cmd=0;
    NSArray *imgBlue = @[@"cool",@"heat",@"wet",@"wind",@""];
    NSArray *imgRed = @[@"cool_red",@"heat_red",@"wet_red",@"wind_red",@""];
    UIButton *btn = (UIButton *)sender;
    self.currentMode=(int)btn.tag;
    [btn setTitleColor:[UIColor colorWithRed:215/255.0 green:57/255.0 blue:78/255.0 alpha:1.0] forState:UIControlStateNormal];
    
    [btn setImage:[UIImage imageNamed:[imgRed objectAtIndex:self.currentMode]] forState:UIControlStateNormal];
    for (UIButton *b in self.visitedBtns) {
        if(b.tag!=self.currentMode){
            [b setImage:[UIImage imageNamed:[imgBlue objectAtIndex:b.tag]] forState:UIControlStateNormal];
            [b setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }
    
    if (self.currentMode == 1) {
        self.showTemLabel.textColor = [UIColor colorWithRed:215/255.0 green:57/255.0 blue:78/255.0 alpha:1.0];
        self.airMode = self.currentMode;
    }
    
    if (self.currentMode == 0){
        self.showTemLabel.textColor = [UIColor colorWithRed:33/255.0 green:119/255.0 blue:175/255.0 alpha:1.0];
        self.airMode = self.currentMode;
    }
    
    if (self.currentMode < 2){
        for (int i=1; i<16; i++) {
            UIView *viewblue = [self.view viewWithTag:i+100];
            viewblue.hidden = self.airMode == 1;
            UIView *viewred = [self.view viewWithTag:i+200];
            viewred.hidden = self.airMode == 0;
        }
    }
    
    if (self.currentMode<1) {
        cmd = 0x39+self.currentMode;
    }else{
        cmd = 0x3F+self.currentMode;
    }
    if (![self.visitedBtns containsObject:sender]) {
        [self.visitedBtns addObject:sender];
    }
    
    NSData *data=[self createCmd:cmd];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
    
    [self save:nil];
}

-(IBAction)changeButton:(id)sender
{
    self.currentButton=(int)((UIButton *)sender).tag;
    [self.paramView reloadData];
    
    if (!self.paramView) {
        self.paramView = [[YALContextMenuTableView alloc]initWithTableViewDelegateDataSource:self];
        self.paramView.animationDuration = 0.15;
        //optional - implement custom YALContextMenuTableView custom protocol
        self.paramView.yalDelegate = self;
        //optional - implement menu items layout
        self.paramView.menuItemsSide = Left;
        self.paramView.menuItemsAppearanceDirection = FromBottomToTop;
        
        //register nib
        UINib *cellNib = [UINib nibWithNibName:@"AirMenuCell" bundle:nil];
        [self.paramView registerNib:cellNib forCellReuseIdentifier:airCellIdentifier];
    }
    
    // it is better to use this method only for proper animation
    [self.paramView showInView:self.view withEdgeInsets:UIEdgeInsetsMake(0,0,-70,0) animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSData *)createCmd:(uint8_t) cmd
{
    return [[DeviceInfo defaultManager] changeMode:cmd
                                                  deviceID:self.deviceid];
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    id theSegue = segue.destinationViewController;
    [theSegue setValue:self.deviceid forKey:@"deviceid"];
}


- (void)changedCurrentTemperature:(CGFloat)currentValue {
    NSInteger value = round(currentValue);
    
    NSString *valueString = [NSString stringWithFormat:@"%d ℃", (int)value];
    
    self.showTemLabel.text = valueString;
    
    NSData *data=[[DeviceInfo defaultManager] changeTemperature:0x6A deviceID:self.deviceid value:value];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
    
    [self save:nil];
}

#pragma mark - ORBSwitchDelegate
- (void)orbSwitchToggled:(ORBSwitch *)switchObj withNewValue:(BOOL)newValue {
    NSLog(@"Switch toggled: new state is %@", (newValue) ? @"ON" : @"OFF");
    [self save:self.switcher];
}

- (void)orbSwitchToggleAnimationFinished:(ORBSwitch *)switchObj {
    NSString *img = @"air_control_cool";
    if (self.airMode == 0) {
        img = @"air_control_cool";
    }
    if (self.airMode == 1) {
        img = @"air_control_heat";
    }
    [switchObj setCustomKnobImage:[UIImage imageNamed:(switchObj.isOn) ? img : @"air_control_off"]
          inactiveBackgroundImage:nil
            activeBackgroundImage:nil];
    
}

#pragma mark - UITouchDelegate
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch = [touches anyObject];
    
    NSUInteger toucheNum = [[event allTouches] count];//有几个手指触摸屏幕
    if ( toucheNum > 1 ) {
        return;//多个手指不执行旋转
    }
    
    CGFloat radius = atan2f(self.tempreturePan.transform.b, self.tempreturePan.transform.a);
    CGFloat degree = radius * (180 / M_PI)+180;
    
    /**
     CGRectGetHeight 返回控件本身的高度
     CGRectGetMinY 返回控件顶部的坐标
     CGRectGetMaxY 返回控件底部的坐标
     CGRectGetMinX 返回控件左边的坐标
     CGRectGetMaxX 返回控件右边的坐标
     CGRectGetMidX 表示得到一个frame中心点的X坐标
     CGRectGetMidY 表示得到一个frame中心点的Y坐标
     */
    
    CGPoint center = CGPointMake(CGRectGetMidX([touch.view bounds]), CGRectGetMidY([touch.view bounds]));
    CGPoint currentPoint = [touch locationInView:touch.view];//当前手指的坐标
    CGPoint previousPoint = [touch previousLocationInView:touch.view];//上一个坐标
    
    /**
     求得每次手指移动变化的角度
     atan2f 是求反正切函数 参考:http://blog.csdn.net/chinabinlang/article/details/6802686
     */
    CGFloat angle = atan2f(currentPoint.y - center.y, currentPoint.x - center.x) - atan2f(previousPoint.y - center.y, previousPoint.x - center.x);
    NSLog(@"degree:%f",degree)
    if (degree<MIX_TEMP_ROTATE_DEGREE) {
        if (angle<0) {
            return;
        }
    }else if (degree>MAX_TEMP_ROTATE_DEGREE) {
        if (angle>0) {
            return;
        }
    }
    self.tempreturePan.transform = CGAffineTransformRotate(self.tempreturePan.transform, angle);
    
    for (int i=1; i<16; i++) {
            UIView *viewblue = [self.view viewWithTag:i+100];
            viewblue.hidden = (degree <= MIX_TEMP_ROTATE_DEGREE+(i)*14) || self.airMode == 1;
            UIView *viewred = [self.view viewWithTag:i+200];
            viewred.hidden = (degree <= MIX_TEMP_ROTATE_DEGREE+(i)*14) || self.airMode == 0;
    }
    
    
    int tempreture = ((int)degree-MIX_TEMP_ROTATE_DEGREE)/14 + 15;
    tempreture = tempreture < 16 ? 16 : tempreture;
    tempreture = tempreture > 30 ? 30 : tempreture;
    self.showTemLabel.text = [NSString stringWithFormat:@"%d°C",tempreture];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self save:nil];
}

#pragma mark - YALContextMenuTableViewDelegate
- (void)contextMenuTableView:(YALContextMenuTableView *)contextMenuTableView didDismissWithIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"Menu dismissed with indexpath = %@", indexPath);
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (void)tableView:(YALContextMenuTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    uint8_t cmd=0;
    if (self.currentButton == speed) {
        cmd = 0x35+(int)indexPath.row;
    }
    if (self.currentButton == direction) {
        cmd = 0x43+(int)indexPath.row;
    }
    NSData *data=[self createCmd:cmd];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
    
    [self save:nil];
    [tableView dismisWithIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 39;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.params[self.currentButton-1] count];
}

- (UITableViewCell *)tableView:(YALContextMenuTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ContextMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:airCellIdentifier forIndexPath:indexPath];
    
    if (cell) {
        cell.backgroundColor = [UIColor clearColor];
        cell.icon.image = [UIImage imageNamed:[self.params[self.currentButton-1] objectAtIndex:indexPath.row]];
        [cell setContraint:self.currentButton];
    }
    
    return cell;
}

@end
