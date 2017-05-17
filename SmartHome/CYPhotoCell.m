//
//  CYPhotoCell.m
//  自定义流水布局
//
//  Created by 葛聪颖 on 15/11/13.
//  Copyright © 2015年 聪颖不聪颖. All rights reserved.
//

#import "CYPhotoCell.h"
#import "SceneManager.h"
#import "Scene.h"


@interface CYPhotoCell()<UIGestureRecognizerDelegate,UIActionSheetDelegate>

@end

@implementation CYPhotoCell

- (void)awakeFromNib {
    [super awakeFromNib];

}
//删除
- (IBAction)doDeleteBtn:(id)sender {
    
    self.deleteBtn.selected = !self.deleteBtn.selected;
    if (self.deleteBtn.selected) {
         [self.deleteBtn setBackgroundImage:[UIImage imageNamed:@"delete_white"] forState:UIControlStateSelected];
    }else{
         [self.deleteBtn setBackgroundImage:[UIImage imageNamed:@"delete_white"] forState:UIControlStateSelected];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(sceneDeleteAction:)]) {
          [self.delegate sceneDeleteAction:self];
    }
}

//开关
- (IBAction)powerBtn:(id)sender {
    
    self.powerBtn.selected = !self.powerBtn.selected;
    if (self.powerBtn.selected) {
        [self.powerBtn setBackgroundImage:[UIImage imageNamed:@"close_red"] forState:UIControlStateSelected];
        [[SceneManager defaultManager] startScene:self.sceneID];
        
    }else{
        [self.powerBtn setBackgroundImage:[UIImage imageNamed:@"close_white"] forState:UIControlStateNormal];
        [[SceneManager defaultManager] poweroffAllDevice:self.sceneID];
    }
}
//定时
- (IBAction)timingBtn:(id)sender {
    
    self.seleteSendPowBtn.selected = !self.seleteSendPowBtn.selected;
    
    if (self.seleteSendPowBtn.selected) {
        
        [self.seleteSendPowBtn setBackgroundImage:[UIImage imageNamed:@"alarm clock2"] forState:UIControlStateSelected];
    }else{
        [self.seleteSendPowBtn setBackgroundImage:[UIImage imageNamed:@"alarm clock1"] forState:UIControlStateNormal];
    }
}

@end
