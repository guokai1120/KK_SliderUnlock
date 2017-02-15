//
//  KakaSetLockViewController.m
//  KakaSlideUnlock
//
//  Created by Kaka on 2017/2/15.
//  Copyright © 2017年 Kaka. All rights reserved.
//
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#import "KakaSetLockViewController.h"
#import "KakaLockView.h"
#import "KakaLockViewController.h"
#import "WSProgressHUD.h"

@interface KakaSetLockViewController ()
{
    NSString *pwdStr1;
    NSString *pwdStr2;
    BOOL isFirst;
}

@end

@implementation KakaSetLockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isFirst = YES;
    self.title = @"设置解锁密码";
    self.view.backgroundColor = [UIColor whiteColor];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    imageView.image = [UIImage imageNamed:@"Home_refresh_bg"];
    [self.view addSubview:imageView];
    
    
    //    YJLockView *lockView = [[YJLockView alloc]initWithFrame:CGRectMake(0, (SCREEN_HEIGHT-SCREEN_WIDTH)*0.5,SCREEN_WIDTH,SCREEN_WIDTH)];
    KakaLockView *lockView = [[KakaLockView alloc]initWithFrame:CGRectMake(0, (SCREEN_HEIGHT-SCREEN_WIDTH)*0.5,SCREEN_WIDTH,SCREEN_WIDTH) WithMode:PwdStateSetting];
    
    [lockView setBtnImage:[UIImage imageNamed:@"gesture_node_normal"]];
    [lockView setBtnSelectdImgae:[UIImage imageNamed:@"selected"]];
    [lockView setBtnErrorImage:[UIImage imageNamed:@"gesture_node_error"]];
    
    
    __weak typeof (self)vcs = self;
    lockView.setPwdData = ^(NSString *resultPwd){
        
        if (isFirst == YES) {
            pwdStr1 = resultPwd;
            isFirst = NO;
            vcs.title = @"请再次设置解锁密码";
            return;
        }else{
            pwdStr2 = resultPwd;
        }
        if ([pwdStr1 isEqualToString:pwdStr2]) {
            [[NSUserDefaults standardUserDefaults] setObject:resultPwd forKey:@"passWord"];
            if (self.navigationController.viewControllers.count > 1) {
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                KakaLockViewController *vc = [[KakaLockViewController alloc]init];
                [vcs.navigationController pushViewController:vc animated:YES];
            }
        }else{
            [WSProgressHUD showErrorWithStatus:@"两次设置的密码不一致"];
            vcs.title = @"设置解锁密码";
            isFirst = YES;
            pwdStr2 = @"";
            pwdStr1 = @"";
        }
    };
    
    [self.view addSubview:lockView];
    

    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = NO;
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
