//
//  ENenViewController.m
//  SmartHome
//
//  Created by zhaona on 2017/1/5.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "ENenViewController.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
#import "EnenCell.h"

@interface ENenViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray * dateArr;
@property (nonatomic,strong) NSMutableArray * startTimeArr;
@property (nonatomic,strong) NSMutableArray * endTimeArr;


@end

@implementation ENenViewController
-(NSMutableArray *)dateArr
{
    if (!_dateArr) {
        _dateArr = [NSMutableArray array];
    }
    
    return _dateArr;
}
-(NSMutableArray *)startTimeArr
{
    if (!_startTimeArr) {
        _startTimeArr = [NSMutableArray array];
    }

    return _startTimeArr;
}
-(NSMutableArray *)endTimeArr
{
    if (!_endTimeArr) {
        _endTimeArr = [NSMutableArray array];
    }
    return _endTimeArr;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

       [self sendRequestToGetEenrgyWithEqid:self.eqid];
       self.title = self.titleName;
    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor clearColor]];
    self.tableView.tableFooterView = view;
}
-(void)sendRequestToGetEenrgyWithEqid:(int)eqid
{
    NSString *url = [NSString stringWithFormat:@"%@Cloud/energy_list.aspx",[IOManager httpAddr]];
    NSString *authorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    if (authorToken) {
        NSDictionary *dic = @{@"token":authorToken,@"optype":[NSNumber numberWithInteger:3],@"eqid":[NSNumber numberWithInt:eqid]};
        HttpManager *http = [HttpManager defaultManager];
        http.delegate = self;
        http.tag =1;
        [http sendPost:url param:dic];
    }
}
-(void)httpHandler:(id)responseObject tag:(int)tag
{
    if(tag == 1)
    {
        if([responseObject[@"result"] intValue] == 0)
        {
            NSArray *message = responseObject[@"eq_energy_list"];
            for(NSDictionary *dic in message)
            {
                NSDictionary *energy = @{@"minute_time":dic[@"minute_time"],@"energy":dic[@"energy"],@"dateflag":dic[@"dateflag"]};
                NSArray * array = dic[@"switch_list"];
                for (NSDictionary * timeDict in array) {
                    [self.startTimeArr addObject:timeDict[@"starttimne"]];
                    [self.endTimeArr addObject:timeDict[@"endtimne"]];
                }
                NSLog(@"---%@----",array);
                [self.dateArr addObject:energy];
                
            }
            [self.tableView reloadData];
        }else {
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.dateArr.count;
//    return 7;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   EnenCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        NSDictionary * dict = self.dateArr[indexPath.row];
        cell.dateLabel.text = [NSString stringWithFormat:@"%@",dict[@"dateflag"]];
        cell.energyLabel.text = [NSString stringWithFormat:@"%.1fhr",[dict[@"minute_time"] floatValue]/60];
    cell.weekLabel.text = [self getTheDayOfTheWeekByDateString:cell.dateLabel.text];
//    cell.ViewSubViewLabel.hidden = NO;
    CGFloat x = cell.ViewSubViewLabel.bounds.origin.x;
//    CGFloat y = cell.ViewSubViewLabel.bounds.origin.y;
    CGFloat width = cell.ViewSubViewLabel.bounds.size.width/24 * [dict[@"minute_time"] floatValue]/60;
//    CGFloat width = cell.ViewSubViewLabel.bounds.size.width/24 * [cell.energyLabel.text intValue];

//    cell.subViewWidth.constant = width;
    cell.subViewX.constant = x;
    return cell;
}
///根据用户输入的时间(dateString)确定当天是星期几,输入的时间格式 yyyy-MM-dd ,如 2015-12-18
-(NSString *)getTheDayOfTheWeekByDateString:(NSString *)dateString{
    
    NSDateFormatter *inputFormatter=[[NSDateFormatter alloc]init];
    
    [inputFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *formatterDate=[inputFormatter dateFromString:dateString];
    
    NSDateFormatter *outputFormatter=[[NSDateFormatter alloc]init];
    
    [outputFormatter setDateFormat:@"EEEE-MMMM-d"];
    
    NSString *outputDateStr=[outputFormatter stringFromDate:formatterDate];
    
    NSArray *weekArray=[outputDateStr componentsSeparatedByString:@"-"];
    
    return [weekArray objectAtIndex:0];
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

@end