//
//  IpadDVDTableViewCell.h
//  SmartHome
//
//  Created by zhaona on 2017/6/5.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IpadDVDTableViewCellDelegate;

@interface IpadDVDTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *DVDNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *YLImageView;
@property (weak, nonatomic) IBOutlet UISlider *DVDSlider;
@property (weak, nonatomic) IBOutlet UIButton *DVDSwitchBtn;
@property (weak, nonatomic) IBOutlet UIButton *AddDvdBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@property (weak, nonatomic) IBOutlet UIButton *PreviousBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *DVDConstraint;
@property(nonatomic, strong)NSString * deviceid;
@property (nonatomic,weak) NSString *sceneid;
//房间id
@property (nonatomic,assign) int roomID;
@property (strong, nonatomic) Scene *scene;
@property (nonatomic, assign) id<IpadDVDTableViewCellDelegate>delegate;

@end


@protocol IpadDVDTableViewCellDelegate <NSObject>

@optional
- (void)onDVDSwitchBtnClicked:(UIButton *)btn;
- (void)onDVDSliderValueChanged:(UISlider *)slider;
@end