//
//  KakaLockViewController.m
//  KakaSlideUnlock
//
//  Created by Kaka on 2017/2/15.
//  Copyright © 2017年 Kaka. All rights reserved.
//
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#import "KakaLockViewController.h"
#import "KakaSetLockViewController.h"
#import "WSProgressHUD.h"
#import "KakaLockView.h"
@interface KakaLockViewController ()

@end

@implementation KakaLockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    设置背景图
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    imageView.image = [UIImage imageNamed:@"Home_refresh_bg"];
    [self.view addSubview:imageView];
    
    CGFloat RightButtonX = [UIScreen mainScreen].bounds.size.width -160;
    UIButton * _navRightButton  = [[UIButton alloc]initWithFrame:CGRectMake(RightButtonX, 30, 150, 50)];
    [_navRightButton setTitle:@"重新设置密码" forState:UIControlStateNormal];
    _navRightButton.titleLabel.font = [UIFont systemFontOfSize:20];
    [_navRightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_navRightButton addTarget:self action:@selector(popView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_navRightButton];
    
    
    
    //解锁界面
    KakaLockView *lockView = [[KakaLockView alloc]initWithFrame:CGRectMake(0, (SCREEN_HEIGHT-SCREEN_WIDTH)*0.5,SCREEN_WIDTH,SCREEN_WIDTH) WithMode:PwdStateResult];
    
    [lockView setBtnImage:[UIImage imageNamed:@"gesture_node_normal"]];
    [lockView setBtnSelectdImgae:[UIImage imageNamed:@"selected"]];
    [lockView setBtnErrorImage:[UIImage imageNamed:@"gesture_node_error"]];
    [self.view addSubview:lockView];
    
    //解锁手势完成之后判断密码是否正确
    lockView.sendReaultData = ^(NSString *resultPwd){
        //        从本地获取保存的密码
        NSString *savePwd = [[NSUserDefaults standardUserDefaults]objectForKey:@"passWord"];
        
        if ([savePwd isEqualToString:resultPwd]) {//密码相同，解锁成功
            
            [WSProgressHUD showSuccessWithStatus:@"解锁成功！"];
            
            return YES;
        }else{
            
            [WSProgressHUD showErrorWithStatus:@"解锁失败！"];
            
            return NO;
        }
    };
    
}
-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
}

-(void)popView{
    KakaSetLockViewController *vc = [[KakaSetLockViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
    
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
