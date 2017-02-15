//
//  KakaLockView.m
//  KakaSlideUnlock
//
//  Created by Kaka on 2017/2/15.
//  Copyright © 2017年 Kaka. All rights reserved.
//

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#import "KakaLockView.h"
#import <CommonCrypto/CommonDigest.h>

@interface KakaLockView(){

    /** 判断是当设置密码用，还是解锁密码用*/
    PwdState Amode;

}

/** 解锁时手指经过的所有的btn集合*/
@property (nonatomic,strong)NSMutableArray * btnsArray;

/** 手指当前的触摸位置*/
@property (nonatomic,assign)CGPoint currentPoint;

@end

@implementation KakaLockView

-(NSMutableArray *)btnsArray{
    if (_btnsArray == nil) {
        _btnsArray = [NSMutableArray array];
    }
    return _btnsArray;
}

-(instancetype)initWithFrame:(CGRect)frame WithMode:(PwdState) mode{
    //不管是[[XXX alloc]initWithFrame:]还是[[XXX alloc]init],代码创建的时候都会调用这个方法
    self = [super initWithFrame: frame];
    if (self) {
        Amode = mode;
        self.backgroundColor = [UIColor clearColor];
        if (self.lineColor == nil) {
            self.lineColor = [UIColor greenColor];
        }
        //        1、创建九个btn
        for (int i = 0; i<9; i++) {
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = i;
            btn.userInteractionEnabled = NO;
            [self addSubview:btn];
        }
    }
    return self;
}


-(void)layoutSubviews{
    for (int index = 0; index<self.subviews.count; index ++) {
        //        拿到每个btn
        UIButton *btn = self.subviews[index];
        
        //        设置frame
        CGFloat btnW = 74;
        CGFloat btnH = 74;
        CGFloat margin = (SCREEN_WIDTH - (btnW *3))/4;
        //x = 间距 + 列号*（间距+btnW）
        CGFloat btnX = margin + (index % 3)*(margin + btnW);
        CGFloat btnY = margin + (index / 3)*(margin + btnH);
        
        btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self.btnsArray removeAllObjects];
    //获取当前手指的位置
    CGPoint point = [self getCurrentTouch:touches];
    //获取当前手指移动到了哪个btn
    UIButton *btn = [self getCurrentBtnWithPoint:point];
    
    if (btn && btn.selected != YES) {
        btn.selected = YES;
        [self.btnsArray addObject:btn];
    }
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    CGPoint movePoint = [self getCurrentTouch:touches];
    
    UIButton *btn = [self getCurrentBtnWithPoint:movePoint];
    if (btn && btn.selected != YES) {
        btn.selected = YES;
        [self.btnsArray addObject:btn];
    }
    self.currentPoint = movePoint;
    
    [self setNeedsDisplay];
}
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    for (UIButton *btn in self.subviews) {
        [btn setSelected:NO];
    }
    
    NSMutableString *result = [NSMutableString string];
    for (UIButton *btn in self.btnsArray) {
        [result appendString: [NSString stringWithFormat:@"%ld",(long)btn.tag]];
    }
    
    if (self.btnsArray.count > 0) {//如果选中的点大于0个才判断是不是正确密码
        
        //        判断是设置密码还是解锁密码
        switch (Amode) {
            case PwdStateResult:
                if (self.sendReaultData){
                    if (self.sendReaultData([self md5String:result]) == YES) {
                        
                        [self clear];
                    }else{
                        [self ErrorShow];
                    }
                }
                break;
            case PwdStateSetting:
                //如果是设置密码的话，直接调用Block传值
                if (self.setPwdData) {
                    self.setPwdData([self md5String:result]);
                    [self clear];
                }
                break;
                
            default:
                NSLog(@"不执行操作，类型不对");
                break;
        }
        
        
    }
    
//    [self clear];
    
    // 1.3 重绘
    [self setNeedsDisplay];
}


-(void)ErrorShow{  // 密码不正确处理方式
    
    // 1. 重绘成红色效果
    // 1.1 把selectedButtons中的每个按钮的selected = NO, enabled = NO
    for (UIButton *btn in self.btnsArray) {
        btn.selected = NO;
        btn.enabled = NO;
    }
    // 1.2 设置线段颜色为红色
    self.lineColor = [UIColor redColor];
    // 1.3 重绘
    [self setNeedsDisplay];
    // 禁用与用户的交互
    self.userInteractionEnabled = NO;
    // 2. 等待0.5秒中, 然后再清空
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (UIButton *btn in self.btnsArray) {
            btn.selected = NO;
            btn.enabled = YES;
        }
        
        [self clear];
    });
    
}

-(void)clear{//清空上下文
    [self.btnsArray removeAllObjects];
    self.currentPoint = CGPointZero;
    [self setNeedsDisplay];
    self.lineColor = [UIColor greenColor];
    self.userInteractionEnabled = YES;
}


-(void)drawRect:(CGRect)rect{
    //  每次调用这个方法的时候如果背景颜色是default会产生缓存，如果设置了颜色之后就没有缓存，绘制之前需要清除缓存
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextClearRect(ctx, rect);//清空上下文
    for (int i = 0; i<self.btnsArray.count; i++) {
        UIButton *btn = self.btnsArray[i];
        if (i == 0) {
            CGContextMoveToPoint(ctx, btn.center.x, btn.center.y);
        }else{
            CGContextAddLineToPoint(ctx, btn.center.x, btn.center.y);
        }
    }
    if (!CGPointEqualToPoint(self.currentPoint, CGPointZero)) {//如果起点不是CGPointZero的话才来划线
        CGContextAddLineToPoint(ctx, self.currentPoint.x, self.currentPoint.y);
    }
    
    CGContextSetLineWidth(ctx, 6);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    [self.lineColor set];
    CGContextStrokePath(ctx);
    
//    [self clear];
    
}




/**
 md5String
 
 @param str 需要进行MD5加密的字符串
 
 @return 加密后的字符串
 */
- ( NSString *)md5String:( NSString *)str
{
    //    md5加密原理：相同的密码通过md5加密后字符串是相同的
    const char *myPasswd = [str UTF8String ];
    
    unsigned char mdc[ 16 ];
    
    CC_MD5 (myPasswd, ( CC_LONG ) strlen (myPasswd), mdc);
    
    NSMutableString *md5String = [ NSMutableString string ];
    
    for ( int i = 0 ; i< 16 ; i++) {
        
        [md5String appendFormat : @"%02x" ,mdc[i]];
        
    }
    return md5String;
}





//获取触摸的点
-(CGPoint)getCurrentTouch:(NSSet<UITouch *> *)touches{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:touch.view];
    return point;
}

/**
 getCurrentBtnWithPoint
 
 @param currentPoint 触摸的点
 
 @return 触摸到的btn
 */
-(UIButton *)getCurrentBtnWithPoint:(CGPoint) currentPoint{
    for (UIButton *btn in self.subviews) {
        if (CGRectContainsPoint(btn.frame, currentPoint)) {
            return btn;
        }
    }
    return nil;
}



-(void)setBtnSelectdImgae:(UIImage *)btnSelectdImgae{
    for (UIButton *btn in self.subviews) {
        [btn setBackgroundImage:btnSelectdImgae forState:UIControlStateSelected];
    }
}
-(void)setBtnImage:(UIImage *)btnImage{
    for (UIButton *btn in self.subviews) {
        [btn setImage:btnImage forState:UIControlStateNormal];
    }
}
-(void)setBtnErrorImage:(UIImage *)btnErrorImage{
    for (UIButton *btn in self.subviews) {
        [btn setImage:btnErrorImage forState:UIControlStateDisabled];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
