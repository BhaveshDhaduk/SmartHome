//
//  PhotoGraphViewConteoller.m
//  SmartHome
//
//  Created by zhaona on 2017/5/5.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "PhotoGraphViewConteoller.h"

@interface PhotoGraphViewConteoller ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic,strong) NSArray *PhotoIcons;
@end

@implementation PhotoGraphViewConteoller

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.PhotoIcons = @[@"PhotoIcon1", @"PhotoIcon2", @"PhotoIcon3", @"PhotoIcon4", @"PhotoIcon5", @"PhotoIcon6", @"PhotoIcon7", @"PhotoIcon8", @"PhotoIcon9", @"PhotoIcon10",@"PhotoIcon11",@"PhotoIcon12",@"PhotoIcon13",@"PhotoIcon14",@"PhotoIcon15",@"PhotoIcon16",@"PhotoIcon17",@"PhotoIcon18",@"PhotoIcon19",@"PhotoIcon20",];
    //[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    self.automaticallyAdjustsScrollViewInsets = NO;
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.PhotoIcons.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:self.PhotoIcons[indexPath.row]]];
    
    return cell;
}

//定义每个UICollectionViewCell 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
         return CGSizeMake(160, 160);
    }
     return CGSizeMake(300, 300);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate PhotoIconController:self withImgName:self.PhotoIcons[indexPath.row]];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
