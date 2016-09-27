//
//  IphoneFMController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/24.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "IphoneFMController.h"
#import "TXHRrettyRuler.h"
#import "FMCollectionViewCell.h"
#import "ChannelManager.h"
#import "SQLManager.h"
#import "TVChannel.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"

@interface IphoneFMController ()<UICollectionViewDelegate,UICollectionViewDataSource,TXHRrettyRulerDelegate,UIGestureRecognizerDelegate,FMCollectionViewCellDelegate>
@property (weak, nonatomic) IBOutlet UILabel *hzLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISlider *volumn;
@property (weak, nonatomic) IBOutlet UIView *fmView;
@property (weak, nonatomic) IBOutlet UILabel *numberOfChannel;
@property (nonatomic,strong) FMCollectionViewCell *cell;
@property (nonatomic,strong) NSMutableArray *allFavouriteChannels;
@property (nonatomic,strong) NSString *eNumber;
@end

@implementation IphoneFMController

-(NSMutableArray *)allFavouriteChannels
{
    if(!_allFavouriteChannels)
    {
        _allFavouriteChannels = [NSMutableArray array];
        _allFavouriteChannels = [ChannelManager getAllChannelForFavoritedForType:@"FM" deviceID:[self.deviceid intValue]];
        if(_allFavouriteChannels == nil || _allFavouriteChannels.count == 0)
        {
            
            
        }
        
    }
    return _allFavouriteChannels;
}
- (void)setRoomID:(int)roomID
{
    _roomID = roomID;
    if(roomID)
    {
        self.deviceid = [SQLManager deviceIDWithRoomID:self.roomID withType:@"FM"];
    }
    
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hzLabel.transform = CGAffineTransformMakeRotation(M_PI/2 + M_PI);
    self.eNumber = [SQLManager getENumber:[self.deviceid intValue]];
    [self setRuleForFMChannel];
}
-(void)setRuleForFMChannel
{
    CGFloat rule = [self.numberOfChannel.text floatValue];
    NSLog(@"\n\n\n\n\n rule = %f",rule);
    TXHRrettyRuler *ruler = [[TXHRrettyRuler alloc] initWithFrame:CGRectMake(50, 50, self.fmView.frame.size.width - 50, 120)];
    ruler.rulerDelegate = self;
    [ruler showRulerScrollViewWithCount:205 average:[NSNumber numberWithFloat:0.1] currentValue:rule smallMode:NO];
    [self.fmView addSubview:ruler];
    
}

- (void)txhRrettyRuler:(TXHRulerScrollView *)rulerScrollView {
    self.numberOfChannel.text = [NSString stringWithFormat:@"%.1f",rulerScrollView.rulerValue];
    
    //  [self save:nil];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id theSegue = segue.destinationViewController;
    [theSegue setValue:self.deviceid forKey:@"deviceid"];
    [theSegue setValue:self.numberOfChannel.text forKey:@"numberOfChannel"];
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.allFavouriteChannels.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FMCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionCell" forIndexPath:indexPath];
    cell.delegate = self;
    [cell hiddenBtns];
    TVChannel *channel = self.allFavouriteChannels[indexPath.row];
    cell.chanelNum.text = [NSString stringWithFormat:@"%ld",channel.channel_id];
    cell.channelName.text = [NSString stringWithFormat:@"%@",channel.channel_name];
    [cell useLongPressGesture];
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FMCollectionViewCell *cell =(FMCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    [cell hiddenBtns];
    [cell useLongPressGesture];
}


#pragma mark - -(void)unUseLongPressGesture
//删除FM频道
-(void)FmDeleteAction:(FMCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    self.cell = cell;
    
    TVChannel *channel = [self.allFavouriteChannels objectAtIndex: indexPath.row];
    //发送删除频道请求
    NSString *url = [NSString stringWithFormat:@"%@FMChannelRemove.aspx",[IOManager httpAddr]];
    NSString *authorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    NSDictionary *dic = @{@"AuthorToken":authorToken,@"RecordID":[NSNumber numberWithInteger:channel.channel_id]};
    HttpManager *http = [HttpManager defaultManager];
    http.delegate = self;
    http.tag = 1;
    [http sendPost:url param:dic];
    
}

-(void) httpHandler:(id) responseObject tag:(int)tag
{
    if(tag == 2)
    {
        if([responseObject[@"Result"] intValue] == 0)
        {
            NSIndexPath *indexPath = [self.collectionView indexPathForCell:self.cell];
            TVChannel *channel = self.allFavouriteChannels[indexPath.row];
            BOOL isSuccess = [ChannelManager deleteChannelForChannelID:channel.channel_id];
            if(!isSuccess)
            {
                [MBProgressHUD showError:@"删除失败，请稍后再试"];
                return;
            }
            [self.allFavouriteChannels removeObject:channel];
            [self.collectionView reloadData];
            
        }else{
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }
        
    }

}










- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end