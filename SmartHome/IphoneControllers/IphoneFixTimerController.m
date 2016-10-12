//
//  IphoneFixTimerController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/26.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "IphoneFixTimerController.h"
#import "SceneManager.h"
#import "Scene.h"
#import "Schedule.h"


@interface IphoneFixTimerController ()<UIPickerViewDelegate,UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *astronomicalHight;
@property (weak, nonatomic) IBOutlet UIButton *astronomicalBut;
@property (weak, nonatomic) IBOutlet UIButton *customTimeBtn;
@property (weak, nonatomic) IBOutlet UIView *astronomicalView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *astronmicalTypes;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerTime;
@property (weak, nonatomic) IBOutlet UIButton *startTimeBtn;
@property (weak, nonatomic) IBOutlet UIButton *endTimeBtn;
@property (nonatomic,strong) NSArray *hours;
@property (nonatomic,strong) NSArray *minutes;
@property (weak, nonatomic) IBOutlet UIView *customView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *customViewHight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *repeatViewHight;

@property (weak, nonatomic) IBOutlet UILabel *repeatLabel;


@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *repeatBtns;
@property (nonatomic,strong) NSMutableDictionary *dic;
@property (nonatomic,strong) NSMutableString *repeatTime;
@property (nonatomic, assign) BOOL isSceneSetTime;
@property (nonatomic,strong) Scene *scene;
@property (weak, nonatomic) IBOutlet UILabel *astronomyStartTime;
@property (nonatomic,strong) Schedule *schedule;

@end

@implementation IphoneFixTimerController

-(Scene *)scene
{
    if(!_scene)
    {
        
        NSString *sceneFile = [NSString stringWithFormat:@"%@_0.plist",SCENE_FILE_NAME];
        NSString *scenePath=[[IOManager scenesPath] stringByAppendingPathComponent:sceneFile];
        NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:scenePath];
        
        _scene = [[Scene alloc] initWhithoutSchedule];
        if(plistDic)
        {
            [_scene setValuesForKeysWithDictionary:plistDic];
        }
        
        
    }
    return _scene;
}

-(NSMutableString *)repeatTime
{
    if(!_repeatTime)
    {
        _repeatTime = [NSMutableString string];
    }
    return _repeatTime;
}
-(NSMutableDictionary *)dic
{
    if(!_dic)
    {
        _dic =[NSMutableDictionary dictionary];
    }
    return _dic;
}
-(NSArray *)hours
{
    if(!_hours)
    {
        NSMutableArray *arr = [NSMutableArray array];
        for(int i = 0; i< 24; i++)
        {
            if(i < 10){
                [arr addObject:[NSString stringWithFormat:@"0%d",i]];
            }else{
                [arr addObject:[NSString stringWithFormat:@"%d",i]];
            }
            
        }
        _hours = [arr copy];
    }
    return _hours;
}

-(NSArray *)minutes
{
    if(!_minutes)
    {
        NSMutableArray *arr = [NSMutableArray array];
        for(int i = 0; i< 60; i++)
        {
            if(i < 10){
                [arr addObject:[NSString stringWithFormat:@"0%d",i]];
            }else{
                [arr addObject:[NSString stringWithFormat:@"%d",i]];
            }
            
        }
        _minutes = [arr copy];
        
    }
    return _minutes;
}

- (void)viewDidLoad {
    [super viewDidLoad];
        
    self.astronomicalHight.constant = 0;
    self.astronomicalView.hidden = YES;
    self.schedule = [[Schedule alloc]initWhithoutSchedule];
    for(UIButton *btn in self.astronmicalTypes)
    {
        btn.hidden = YES;
    }
    self.customView.hidden = YES;
    self.customViewHight.constant = 0;

    self.repeatViewHight.constant = [[UIScreen mainScreen] bounds].size.width / 7.0;
    for(UIButton *btn in self.repeatBtns)
    {
        btn.layer.cornerRadius = self.repeatViewHight.constant / 2.0;
        btn.layer.masksToBounds = YES;
    }
}
- (IBAction)selectedAstronomicalBtn:(id)sender {
    UIButton *btn = sender;
    btn.selected = !btn.selected;
    if(btn.selected)
    {
        [self.astronomicalBut setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateSelected];
        self.customTimeBtn.enabled = NO;
        self.astronomicalHight.constant = 80;
        self.astronomicalView.hidden = NO;
        for(UIButton *btn in self.astronmicalTypes)
        {
            btn.hidden = NO;
        }

    }else{
        [self.astronomicalBut setImage:[UIImage imageNamed:@"unselected"] forState:UIControlStateSelected];
        self.customTimeBtn.enabled = YES;
        self.astronomicalHight.constant = 0;
        self.astronomicalView.hidden = YES;
        self.schedule.astronomicalStartID = 0;
        for(UIButton *btn in self.astronmicalTypes)
        {
            btn.hidden = YES;
        }

    }
}
- (IBAction)selectedCustomTimeBtn:(id)sender {
    UIButton *btn = sender;
    btn.selected = !btn.selected;
    if(btn.selected)
    {
        [self.customTimeBtn setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateSelected];
        self.customView.hidden = NO;
        self.customViewHight.constant = 300;
        self.astronomicalBut.enabled = NO;
    }else{
        [self.customTimeBtn setImage:[UIImage imageNamed:@"unselected"] forState:UIControlStateSelected];
        self.customView.hidden = YES;
        self.customViewHight.constant = 0;
        self.astronomicalBut.enabled = YES;
        self.schedule.startTime = @"";
        self.schedule.endTime = @"";
    }
    
}
- (IBAction)selectedTypeOfAstronomical:(id)sender {
    
    UIButton *btn = sender;
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    self.astronomyStartTime.text = btn.titleLabel.text;
    if(self.astronomicalBut.selected)
    {
         self.schedule.astronomicalStartID = (int)btn.tag + 1;
    }
   
   
    
    
    
}

- (IBAction)selectedRepeatTime:(id)sender {
    UIButton *btn = sender;
    btn.selected = !btn.selected;
    

    NSArray *name = [NSArray arrayWithObjects:@"日", @"一", @"二", @"三", @"四", @"五", @"六", nil];
    
    BOOL isFirst = true;
    
    [self.repeatTime setString:@""];
    NSMutableArray *weekValue = [NSMutableArray array];
    
    for (UIButton *button in self.repeatBtns) {
        if (button.selected) {
            if (isFirst) {
                isFirst = false;
                
                [self.repeatTime appendString:name[button.tag]];
                [weekValue addObject:[NSNumber numberWithInteger:button.tag]];
            } else {
                [self.repeatTime appendString:@"、"];
                [self.repeatTime appendString:name[button.tag]];
                [weekValue addObject:[NSNumber numberWithInteger:button.tag]];
            }
        }
    }
    self.schedule.weekDays = [weekValue copy];
    self.repeatLabel.text = self.repeatTime;
    
}
- (IBAction)saveFixTime:(id)sender {
    
    self.scene.schedules = @[self.schedule];
    [[SceneManager defaultManager] addScene:self.scene withName:nil withImage:[UIImage imageNamed:@""]];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSString *startTime;
    NSString *endTime;
    if([self.astronomyStartTime.text isEqualToString:@""])
    {
        if([self.startTimeBtn.titleLabel.text isEqualToString:@"设置"])
        {
            startTime = @"无";
        }else{
            startTime = self.startTimeBtn.titleLabel.text;

        }
        
        if([self.endTimeBtn.titleLabel.text isEqualToString:@"设置"])
        {
            endTime = @"无";
        }else{
            endTime = self.endTimeBtn.titleLabel.text;
        }
        
    }else{
        startTime = self.astronomyStartTime.text;
        endTime = @"无";
    }
    NSDictionary *dic = @{@"startTime":startTime,@"endTime":endTime,@"repeat":self.repeatLabel.text};
    [center postNotificationName:@"time" object:nil userInfo:dic];
    
    [self.navigationController popViewControllerAnimated:YES];     

}

#pragma mark - UIPickerDelegate
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(component == 0)
    {
        return self.hours.count;
    }else
    {
        return self.minutes.count;
    }
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(component == 0 )
    {
        return self.hours[row];
    }else{
        return self.minutes[row];
    }
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *hour = self.hours[[self.pickerTime selectedRowInComponent:0]];
    NSString *min = self.minutes[[self.pickerTime selectedRowInComponent:1]];
   NSString *time = [NSString stringWithFormat:@"%@:%@", hour, min];
    if (self.startTimeBtn.selected) {
        [self.startTimeBtn setTitle:time forState:UIControlStateNormal];
    } else {
        [self.endTimeBtn setTitle:time forState:UIControlStateNormal];
    }
    
    
        if (self.startTimeBtn.selected) {
            self.schedule.startTime=time;
        } else {
            self.schedule.endTime = time;
        }



}
- (IBAction)setTimeOnClick:(id)sender {
    if (sender == self.startTimeBtn)
    {
        if (self.startTimeBtn.selected)
        {
            self.startTimeBtn.selected = NO;
        }else
        {
            self.startTimeBtn.selected = YES;
            self.endTimeBtn.selected = NO;
        }

    }else
    {
    if (self.endTimeBtn.selected) {
        self.endTimeBtn.selected = NO;
    }else {
            self.startTimeBtn.selected = NO;
            self.endTimeBtn.selected = YES;
        }
    }
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



@end
