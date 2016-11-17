//
//  TouchImage.m
//  SmartHome
//
//  Created by Brustar on 16/5/25.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "TouchImage.h"
#import "UIImageView+WebCache.h"
#import "planeScene.h"
#import "SQLManager.h"


@interface TouchImage()
@property (nonatomic,assign) int deviceID;
@end
@implementation TouchImage

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];    //返回与当前接收者有关的所有的触摸对象
    UITouch *touch = [allTouches anyObject];   //视图中的所有对象
    CGPoint point = [touch locationInView:[touch view]]; //返回触摸点在视图中的当前坐标

    if (self.viewFrom==REAL_IMAGE) {
        [self realHandle:point];
    }
    
    if (self.viewFrom==PLANE_IMAGE) {
        [self planeHandle:point];
    }
    
}

-(void) realHandle:(CGPoint)point
{
    NSString *realScenePlistPath = [UD objectForKey:@"Real_Scene_PlistFile"];
    NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:realScenePlistPath];
    NSArray *rooms = plistDic[@"rects"];
    if ([rooms isKindOfClass:[NSArray class]] && rooms.count >0) {
        NSDictionary *room = rooms[0];
        if ([room isKindOfClass:[NSDictionary class]]) {
            NSArray *rects = room[@"rects"];
            if ([rects isKindOfClass:[NSArray class]] && rects.count >0) {
                NSDictionary *rectDict = rects[0];
                if ([rectDict isKindOfClass:[NSDictionary class]] && rectDict.count >0) {
                    NSString *rectStr = rectDict[@"rect"];
                    if (rectStr.length >0) {
                        CGRect rect = CGRectFromString(rectStr);
                        if (CGRectContainsPoint(rect,point)) {
                            NSString *nextImgURL = rectDict[@"nextImg"];
                            if (nextImgURL.length >0) {
                                [self sd_setImageWithURL:[NSURL URLWithString:nextImgURL] placeholderImage:[UIImage imageNamed:@"xxx.png"] options:SDWebImageRetryFailed];
                            }
                            
                        }
                    }
                    
                }
            }
        }
    }
}

-(void) planeHandle:(CGPoint)point
{

    NSString *path=[[NSBundle mainBundle] pathForResource:@"planeScene" ofType:@"plist"];
    NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:path];
    for (NSDictionary *rect in dic[@"rects"]) {
        NSString *rectstr=rect[@"rect"];
        
        CGRect rt=CGRectFromString(rectstr);
        if (CGRectContainsPoint(rt,point)) {
            ((planeScene *)self.delegate).deviceID=[rect[@"deviceID"] intValue];
            self.deviceID = [rect[@"deviceID"] intValue];
             NSString *typeName = [SQLManager deviceTypeNameByDeviceID:self.deviceID];
            NSString *segue;
            if([typeName isEqualToString:@"灯光"]){
                segue = @"plane_Light";
            }else if([typeName isEqualToString:@"窗帘"]){
                segue = @"pane_Curtain";
            }else if([typeName isEqualToString:@"网络电视"]){
                segue = @"plane_TV";
            }else if([typeName isEqualToString:@"空调"]){
                segue = @"plane_Air";
            }else if([typeName isEqualToString:@"DVD"]){
                segue = @"DVD";
            }else if([typeName isEqualToString:@"FM"]){
                segue = @"plane_FM";
            }else if([typeName isEqualToString:@"摄像头"]){
                segue = @"plane_Camera";
            }else if([typeName isEqualToString:@"智能插座"]) {
                segue = @"plane_Plugin";
            }
            else if([typeName isEqualToString:@"机顶盒"])
            {
                segue = @"plane_NetTv";
                
            }else if([typeName isEqualToString:@"DVD"]){
                segue = @"plane_DVD";
                
            }else if([typeName isEqualToString:@"功放"]){
                segue = @"pane_amplifer";
               
            }else{
                segue = @"plane_Guard";

            }

            [self.delegate performSegueWithIdentifier:segue sender:self.delegate];

        }
    }
    
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id theSegue = segue.destinationViewController;
    [theSegue setValue:[NSNumber numberWithInt:self.deviceID] forKey:@"deviceid"];
    
}
@end
