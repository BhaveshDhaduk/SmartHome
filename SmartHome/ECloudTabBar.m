//
//  ECloudTabBar.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/21.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#define bgColour [UIColor colorWithRed:248/255.0 green:248/255.0 blue:250/255.0 alpha:1]
#define ECloudTabBarItemCount  8


#import "ECloudTabBar.h"
#import "ECloudButton.h"
#import "ECloudMoreView.h"
#import "RoomManager.h"
#import "Room.h"

@interface ECloudTabBar () <ECloudMoreViewDelegate>
@property (nonatomic, weak) UIView *rightView;

@property (nonatomic, weak) UIView *leftView;

@property (nonatomic, weak) UIView *separatorLine;

@property (nonatomic, strong) ECloudMoreView *moreView;

@property (nonatomic,strong) NSArray *rooms;
@end

@implementation ECloudTabBar

- (instancetype)init
{
    if (self = [super init]) {
        self.userInteractionEnabled = YES;
        [self setUpView];
    }
    return self;
}


- (ECloudMoreView *)moreView
{
    if (_moreView == nil) {
        _moreView = [[ECloudMoreView alloc] init];
        _moreView.delegate = self;
    }
    return _moreView;
}

-(void)setUpView{
    
    UIView *leftView = [[UIView alloc] init];
    leftView.backgroundColor = bgColour;
    self.leftView = leftView;
    self.leftView.userInteractionEnabled = YES;
    [self addSubview:_leftView];
    [self setUpLeftView];
    
    UIView *separatorLine = [[UIView alloc] init];
    separatorLine.backgroundColor = [UIColor lightGrayColor];
    self.separatorLine = separatorLine;
    [self addSubview:_separatorLine];
    
    
    UIView *rightView = [[UIView alloc]init];
    rightView.backgroundColor = bgColour;
    self.rightView = rightView;;
    [self addSubview: _rightView];
    [self setUpRightView];
}

-(void)setUpLeftView
{
   
  
    
    self.rooms = [RoomManager getAllRoomsInfo];
    
    for (int i = 0; i < self.rooms.count; i++) {
        Room *room = self.rooms[i];
        ECloudButton *button = [[ECloudButton alloc] initWithTitle:room.rName  normalImage:room.imgUrl selectImage:room.imgUrl];
        
        button.highlighted = YES;
        if (0 == i) {
            self.selectButton = button;
        }
        button.type = 0;
        button.subType = room.rId;
        
        [self setUpButtonParams:button];
        
        if (i == ECloudTabBarItemCount - 1 && self.rooms.count > 8) {
            ECloudButton *lastButton = [[ECloudButton alloc] initWithTitle:@"更多" normalImage:@"more" selectImage:@"more"];
            [lastButton setTitleColor:[UIColor colorWithRed:97/255.0 green:176/255.0 blue:162/255.0 alpha:1] forState:UIControlStateNormal];
            lastButton.titleLabel.font = [UIFont systemFontOfSize:16];
            
            [lastButton addTarget:self action:@selector(moreButtonOnClick) forControlEvents:UIControlEventTouchUpInside];
            
            [self.leftView addSubview:lastButton];
            
            [self.moreView addItemWith:button];
            continue;
        }
        else if (i >= ECloudTabBarItemCount){
            [self.moreView addItemWith:button];
            continue;
        }
        
        [button addTarget:self action:@selector(buttonOnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.leftView addSubview:button];
    }
}
-(void)setUpButtonParams:(UIButton *)button
{
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
}

- (void)moreViewDidSelectWithType:(NSInteger)type subType:(NSInteger)subType
{
    if ([self.delegate respondsToSelector:@selector(tabBarDidSelectButtonWithType:subType:)]) {
        [self.delegate tabBarDidSelectButtonWithType:type subType:subType];
    }
}

- (void)moreButtonOnClick
{
    NSLog(@"moreButtonOnClick");
    
    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    
    self.moreView.frame = [UIScreen mainScreen].bounds;
    
    [window addSubview:self.moreView];
}


-(void)setUpRightView
{
    NSArray *str = @[@"我的家",@"我的",@"实景"];
    NSArray *imgs = @[@"myHome",@"my",@"objectPic"];
    for (int i = 0; i < 3; i++) {
        ECloudButton *button = [[ECloudButton alloc] initWithTitle:str[i] normalImage:imgs[i] selectImage:imgs[i]];
        button.type = i + 1;
        [self setUpButtonParams:button];
        [button addTarget:self action:@selector(buttonOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.rightView addSubview:button];
    }
    
}



- (void)buttonOnClick:(ECloudButton *)button
{
    if ([self.delegate respondsToSelector:@selector(tabBarDidSelectButtonWithType:subType:)]) {
        [self.delegate tabBarDidSelectButtonWithType:button.type subType:button.subType];
    }
    
    self.selectButton = button;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat height = self.frame.size.height;
    CGFloat viewWidth = self.frame.size.width  - 300 - 2;
    CGFloat y = 0;
    
    CGFloat leftX = 0;
    self.leftView.frame = CGRectMake(leftX, y, viewWidth, height);
    for(int i = 0; i < self.leftView.subviews.count; i++)
    {
        UIButton *button = self.leftView.subviews[i];
        CGFloat buttonW = self.leftView.frame.size.width/self.leftView.subviews.count;
        CGFloat buttonX = i *buttonW;
        button.frame = CGRectMake(buttonX, y,buttonW, height);
    }
    
    CGFloat rightX = self.frame.size.width  - 300 ;
    self.rightView.frame = CGRectMake(rightX, y, 300, height);
    for(int i = 0 ;i < self.rightView.subviews.count ; i++)
    {
        UIButton *button = self.rightView.subviews[i];
        CGFloat buttonW = self.rightView.frame.size.width / self.rightView.subviews.count;
        CGFloat buttonX = i * buttonW;
        button.frame = CGRectMake(buttonX, y, buttonW, height);
    }
    
    
    
    self.separatorLine.frame = CGRectMake(self.leftView.frame.size.width, y, 2, height);
}


@end
