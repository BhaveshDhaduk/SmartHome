//
//  UserInfoViewController.m
//  SmartHome
//
//  Created by KobeBryant on 2017/4/25.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "UserInfoViewController.h"

@interface UserInfoViewController ()

@end

@implementation UserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNaviBarTitle:@"个人信息"];
    [self initUI];
    [self getUserInfoFromDB];
    [self fetchUserInfo];
}

- (void)initUI {
    NSInteger userType = [[UD objectForKey:@"UserType"] integerValue];
    if (userType == 1) {
        _userTypeStr = @"主人";
    }else {
        _userTypeStr = @"客人";
    }
    
    self.nameLabel.text = [NSString stringWithFormat:@"-- %@, %@身份 --", _userInfomation.nickName, _userTypeStr];
    
    self.headerBtn.layer.cornerRadius = self.headerBtn.frame.size.width/2;
    self.headerBtn.layer.masksToBounds = YES;
    self.userinfoTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    self.userinfoTableView.tableFooterView = [UIView new];
}

- (void)refreshUI {
    [self.headerBtn sd_setImageWithURL:[NSURL URLWithString:_userInfomation.headImgURL] forState:UIControlStateNormal placeholderImage:nil];
    
    self.nameLabel.text = [NSString stringWithFormat:@"-- %@, %@身份 --", _userInfomation.nickName, _userTypeStr];
    
    [self.userinfoTableView reloadData];
}

- (void)getUserInfoFromDB {
    int userID = [[UD objectForKey:@"UserID"] intValue];
    _userInfomation = [SQLManager getUserInfo:userID];
    [self refreshUI];
}

- (void)fetchUserInfo {
    
    NSInteger userID = [[UD objectForKey:@"UserID"] integerValue];
    NSString *auothorToken = [UD objectForKey:@"AuthorToken"];
    
    NSString *url = [NSString stringWithFormat:@"%@Cloud/user_info.aspx",[IOManager httpAddr]];
    
    
    if (auothorToken.length >0 ) {
        NSDictionary *dict = @{@"token":auothorToken,
                               @"user_id":@(userID),
                               @"optype":@(0)
                               };
        HttpManager *http = [HttpManager defaultManager];
        http.delegate = self;
        http.tag = 1;
        [http sendPost:url param:dict];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Http callback
- (void)httpHandler:(id)responseObject tag:(int)tag
{
    if(tag == 1) {
        if ([responseObject[@"result"] intValue] == 0) {
            
            UserInfo *info = [[UserInfo alloc] init];
            info.nickName = responseObject[@"nickname"];
            info.headImgURL = responseObject[@"portrait"];
            info.phoneNum = responseObject[@"phone"];
            _userInfomation = info;
            
            [self refreshUI];
        }
    }
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0.5f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, 0.5)];
    header.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"login_line"]];
    
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
   
    if (section == 0 || section == 1 || section == 2) {
        UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, 8.0)];
        footer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, 0.5)];
        line.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"login_line"]];
        [footer addSubview:line];
        
        return footer;
    }
    
    if (section == 4) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, 0.5)];
        line.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"login_line"]];
        
        return line;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (section == 0 || section == 1 || section == 2) {
        return 8.0f;
    }
    
    if (section == 4) {
        return 0.5f;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"userinfoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 2) {
        cell.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:29.0/255.0 blue:34.0/255.0 alpha:1];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    if (indexPath.section == 0) {
        cell.textLabel.text = @"VIP会员";
    }else if (indexPath.section == 1) {
        cell.textLabel.text = @"服务商城";
    }else if (indexPath.section == 2) {
        cell.textLabel.text = @"我的服务";
    }else if (indexPath.section == 3) {
        cell.textLabel.text = @"昵称";
        cell.detailTextLabel.text = _userInfomation.nickName;
    }else if (indexPath.section == 4) {
        cell.textLabel.text = @"电话";
        cell.detailTextLabel.text = _userInfomation.phoneNum;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        //VIP
    }else if (indexPath.section == 1) {
        //购物车
        [WebManager show:[[IOManager httpAddr] stringByAppendingString:@"/ui/GoodsList.aspx"]];
    }else if (indexPath.section == 2) {
        //服务
    }
}

- (IBAction)headerBtnClicked:(id)sender {
    
    UIAlertController * alerController = [UIAlertController alertControllerWithTitle:@"更换头像" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alerController addAction:[UIAlertAction actionWithTitle:@"拍一张" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [MBProgressHUD showError:@"无法使用系统相机"];
            return;
        }
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:NULL];
        
        
    }]];
    
    [alerController addAction:[UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [DeviceInfo defaultManager].isPhotoLibrary = YES;
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            [MBProgressHUD showError:@"无法使用系统相册"];
            return;
        }
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [picker shouldAutorotate];
        [picker supportedInterfaceOrientations];
        [self presentViewController:picker animated:YES completion:nil];
        
    }]];
    [alerController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [self presentViewController:alerController animated:YES completion:^{
        
    }];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [DeviceInfo defaultManager].isPhotoLibrary = NO;
    self.selectedImg = info[UIImagePickerControllerEditedImage];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@.png", str];
    
    [self saveImage:self.selectedImg withName:fileName];
    
    NSString *url = [NSString stringWithFormat:@"%@Cloud/user_info.aspx",[IOManager httpAddr]];
    NSString *authorToken = [UD objectForKey:@"AuthorToken"];
    NSDictionary *dic = @{
                          @"token":authorToken,
                          @"optype":@(2),
                          @"imgfile":fileName
                          };
    
    if (self.selectedImg && url && dic && fileName) {
    
        //上传头像
        [[UploadManager defaultManager] uploadImage:self.selectedImg url:url dic:dic fileName:fileName completion:^(id responseObject) {
            
            if ([responseObject[@"result"] intValue] == 0) {
                NSString *portrait = responseObject[@"portrait"];
                if (portrait.length >0) {
                    
                   BOOL succeed = [SQLManager updateUserPortraitUrlByID:(int)_userInfomation.userID url:portrait];//更新User表
                    if (succeed) {
                         [MBProgressHUD showSuccess:@"更新头像成功"];
                        [self.headerBtn sd_setImageWithURL:[NSURL URLWithString:portrait] forState:UIControlStateNormal placeholderImage:nil];
                        _userInfomation.headImgURL = portrait;
                        [NC postNotificationName:@"refreshPortrait" object:portrait];
                    }else {
                        [MBProgressHUD showError:@"更新头像失败"];
                    }
                }else {
                    [MBProgressHUD showError:@"更新头像失败"];
                }
                
                
            }else {
                [MBProgressHUD showError:@"更新头像失败"];
            }
            
        }];
    
   
    [picker dismissViewControllerAnimated:YES completion:nil];
 }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [DeviceInfo defaultManager].isPhotoLibrary = NO;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)saveImage:(UIImage *)currentImage withName:(NSString *)imageName
{
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 0.5);
    // 获取沙盒目录
    
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
    // 将图片写入文件
    [imageData writeToFile:fullPath atomically:NO];
}

@end