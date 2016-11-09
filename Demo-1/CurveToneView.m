//
//  CurveToneView.m
//  Demo-1
//
//  Created by admin on 16/10/21.
//  Copyright © 2016年 admin. All rights reserved.
//

typedef enum{
    HeadType = 200,
    MidType,
}BesselType;

#define ArbitrarilyA (float)7.0/40

#import "CurveToneView.h"
#import "Slide.h"

@interface CurveToneView ()
{
    //当前区域
    int _nowArea;
    //当前曲线颜色下标
    int _nowColorIndex;
    //定时器
    NSTimer *_timer;
}

@property (nonatomic, assign) BesselType besselType;
@property (nonatomic, assign) CGPoint firstPoint;
@property (nonatomic, assign) CGPoint secondPoint;
@property (nonatomic, assign) CGPoint thirdPoint;
@property (nonatomic, assign) CGPoint fourthPoint;
@property (nonatomic, assign) CGPoint fifthPoint;

/** 当前存放的五个坐标点*/
@property (nonatomic, strong) NSMutableArray *points;
/** 存放四个模块的数组*/
@property (nonatomic, strong) NSMutableArray *arrs;
/** 记录切换之后最终的坐标点数组*/
@property (nonatomic, strong) NSArray *resultPoints;
/** 存放各个坐标点移动的速率*/
@property (nonatomic, strong) NSMutableArray *rateArr;
/** 保存动画前的坐标点数组*/
@property (nonatomic, strong) NSArray *originPoints;

@property (nonatomic, strong) UIView *lightView;

/** 存放百分比label数组*/
@property (nonatomic, strong) NSMutableArray *labelArr;
/** RGB*/
@property (nonatomic, strong) UIView *rgbView;

@end

@implementation CurveToneView

- (instancetype)initWithFrame:(CGRect)frame weakController:(UIViewController *)controller
{
    self = [super initWithFrame:frame];
    if (self) {

        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeCurveColor:) name:@"changeColor" object:nil];
        self.curveColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor clearColor];
        self.points = [NSMutableArray arrayWithCapacity:5];
        self.arrs = [NSMutableArray arrayWithCapacity:4];
        self.rateArr = [NSMutableArray arrayWithCapacity:5];
        _nowColorIndex = 0;
        
        float width = frame.size.width;
        float height = frame.size.height;
        
        CGPoint point1 = CGPointMake(0, height);
        CGPoint point2 = CGPointMake(width * 6 / 25, height * 19 / 25);
        CGPoint point3 = CGPointMake(width/2, height/2);
        CGPoint point4 = CGPointMake(width * 19 / 25, height * 6 / 25);
        CGPoint point5 = CGPointMake(width, 0);
        NSValue *value1 = [NSValue valueWithCGPoint:point1];
        NSValue *value2 = [NSValue valueWithCGPoint:point2];
        NSValue *value3 = [NSValue valueWithCGPoint:point3];
        NSValue *value4 = [NSValue valueWithCGPoint:point4];
        NSValue *value5 = [NSValue valueWithCGPoint:point5];
        
        for (NSInteger i = 0 ; i < 4; i ++) {
            NSArray *array = @[value1,value2,value3,value4,value5];
            [self.arrs addObject:array];
        }
        self.points = [self.arrs[_nowColorIndex] mutableCopy];
        self.originPoints = [NSArray arrayWithArray:self.points];
        [self prepareUIWithController:controller];
        
    }
    return self;
}

- (void)removeFromSuperview
{
    [super removeFromSuperview];
    [self.rgbView removeFromSuperview];
    self.rgbView = nil;
}

#pragma mark - 设置UI
- (void)prepareUIWithController:(UIViewController *)controller
{
    self.labelArr = [NSMutableArray array];
    NSArray *textArr = @[@"Blacks",@"Shadouws",@"Midtones",@"Highlights",@"Whites"];
    float width = self.frame.size.width/5;
    float height = 10;
    float y = self.frame.size.height - height + 5;
    for (NSInteger i = 0; i < 5; i ++) {
        UILabel *label = [UILabel new];
        label.frame = CGRectMake(width * i, y, width, height);
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        label.numberOfLines = 0;
        label.text = textArr[i];
        label.textColor = [UIColor lightGrayColor];
        label.adjustsFontSizeToFitWidth = YES;
//        label.font = [UIFont systemFontOfSize:AUTO_MATE_WIDTH(7)];
    }
    
    y = y - 10;
   // NSArray *array = @[@"0%",@"25%",@"50%",@"75%",@"100%"];
    for (NSInteger i = 0; i < 5; i ++) {
        UILabel *label = [UILabel new];
        label.frame = CGRectMake(width * i, y, width, height);
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        label.numberOfLines = 0;
        //label.text = array[i];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:AUTO_MATE_WIDTH(7)];
        [self.labelArr addObject:label];
    }
    self.resultPoints = self.points;
    [self modifyAllNumber];
    
    [controller.view addSubview:self.rgbView];
    
    [self addSubview:self.lightView];
    self.lightView.hidden = YES;
}


#pragma mark - 绘图
- (void)drawRect:(CGRect)rect
{
    self.firstPoint = [self.points[0] CGPointValue];
    self.secondPoint = [self.points[1] CGPointValue];
    self.thirdPoint = [self.points[2] CGPointValue];
    self.fourthPoint = [self.points[3] CGPointValue];
    self.fifthPoint = [self.points[4] CGPointValue];
    

    //根据关键点获取控制点
    NSDictionary *dic1 = [self getTwoControlWithPoint1:self.firstPoint Point2:self.secondPoint point3:self.thirdPoint point4:CGPointZero BesselType:HeadType];
    CGPoint controlA1 = CGPointMake([dic1[@"controlAx"] floatValue], [dic1[@"controlAy"] floatValue]);
    CGPoint controlB1 = CGPointMake([dic1[@"controlBx"] floatValue], [dic1[@"controlBy"] floatValue]);
    NSDictionary *dic2 = [self getTwoControlWithPoint1:self.firstPoint Point2:self.secondPoint point3:self.thirdPoint point4:self.fourthPoint BesselType:MidType];
    CGPoint controlA2 = CGPointMake([dic2[@"controlAx"] floatValue], [dic2[@"controlAy"] floatValue]);
    CGPoint controlB2 = CGPointMake([dic2[@"controlBx"] floatValue], [dic2[@"controlBy"] floatValue]);
    
    NSDictionary *dic3 = [self getTwoControlWithPoint1:self.secondPoint Point2:self.thirdPoint point3:self.fourthPoint point4:self.fifthPoint BesselType:MidType];
    CGPoint controlA3 = CGPointMake([dic3[@"controlAx"] floatValue], [dic3[@"controlAy"] floatValue]);
    CGPoint controlB3 = CGPointMake([dic3[@"controlBx"] floatValue], [dic3[@"controlBy"] floatValue]);
    
    NSDictionary *dic4 = [self getTwoControlWithPoint1:self.fifthPoint Point2:self.fourthPoint point3:self.thirdPoint point4:CGPointZero BesselType:HeadType];
    CGPoint controlA4 = CGPointMake([dic4[@"controlAx"] floatValue], [dic4[@"controlAy"] floatValue]);
    CGPoint controlB4 = CGPointMake([dic4[@"controlBx"] floatValue], [dic4[@"controlBy"] floatValue]);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(ctx, self.firstPoint.x, self.firstPoint.y);
    CGContextAddCurveToPoint(ctx, controlA1.x, controlA1.y, controlB1.x, controlB1.y, self.secondPoint.x, self.secondPoint.y);
    CGContextAddCurveToPoint(ctx, controlA2.x, controlA2.y, controlB2.x, controlB2.y, self.thirdPoint.x, self.thirdPoint.y);
    CGContextAddCurveToPoint(ctx, controlA3.x, controlA3.y, controlB3.x, controlB3.y, self.fourthPoint.x, self.fourthPoint.y);
    [_curveColor set];
    CGContextStrokePath(ctx);
    CGContextMoveToPoint(ctx, self.fifthPoint.x, self.fifthPoint.y);
    CGContextAddCurveToPoint(ctx, controlA4.x, controlA4.y, controlB4.x, controlB4.y, self.fourthPoint.x, self.fourthPoint.y);
    
    [_curveColor set];
    
    CGContextStrokePath(ctx);
    
    CGContextMoveToPoint(ctx, 0, self.frame.size.height);
    CGContextAddLineToPoint(ctx, self.frame.size.width, 0);
    [[UIColor whiteColor]set];
    CGContextSetLineWidth(ctx, 0.2f);
    CGContextStrokePath(ctx);
    
}


#pragma mark - touch
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //确定区域
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    _nowArea = location.x / (self.frame.size.width/5);
    
    self.lightView.hidden = NO;
    self.lightView.frame = CGRectMake(self.frame.size.width/5 * _nowArea, 0, self.frame.size.width/5, self.frame.size.height);
    
    //判断动画是否完成
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
        [self.rateArr removeAllObjects];
        //self.points = self.resultPoints;
        [self.points removeAllObjects];
        [self.points addObjectsFromArray:self.resultPoints];
        [self setNeedsDisplay];
    }
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.firstPoint = [self.points[0] CGPointValue];
    self.secondPoint = [self.points[1] CGPointValue];
    self.thirdPoint = [self.points[2] CGPointValue];
    self.fourthPoint = [self.points[3] CGPointValue];
    self.fifthPoint = [self.points[4] CGPointValue];
    

    UITouch *touch = [touches anyObject];
    CGPoint star = [touch previousLocationInView:self];
    CGPoint end = [touch locationInView:self];
    CGPoint change = CGPointMake((end.x - star.x)/3, (end.y - star.y)/3);
    CGPoint temp;
    float newY;
    //修改关键点的位置并限制
    switch (_nowArea) {
        case 0:{
            temp = self.firstPoint;
            newY = temp.y;
            if (temp.y + change.y > self.frame.size.height || temp.y + change.y < 0) {
                break;
            }
            self.firstPoint = CGPointMake(temp.x, temp.y + change.y);
            newY = self.firstPoint.y;
            [self.points replaceObjectAtIndex:0 withObject:[NSValue valueWithCGPoint:self.firstPoint]];
        }
            break;
        case 1:{
            temp = self.secondPoint;
            newY = temp.y;
            if (temp.y + change.y > self.frame.size.height || temp.y + change.y < 0) {
                break;
            }
            self.secondPoint = CGPointMake(temp.x, temp.y + change.y);
            newY = self.secondPoint.y;
            [self.points replaceObjectAtIndex:1 withObject:[NSValue valueWithCGPoint:self.secondPoint]];        }
            break;
        case 2:
        {
            temp = self.thirdPoint;
            newY = temp.y;
            if (temp.y + change.y > self.frame.size.height || temp.y + change.y < 0) {
                break;
            }
            self.thirdPoint = CGPointMake(temp.x, temp.y + change.y);
            newY = self.thirdPoint.y;
            [self.points replaceObjectAtIndex:2 withObject:[NSValue valueWithCGPoint:self.thirdPoint]];
        }
            break;
        case 3:
        {
            temp = self.fourthPoint;
            newY = temp.y;
            if (temp.y + change.y > self.frame.size.height || temp.y + change.y < 0) {
                break;
            }
            self.fourthPoint = CGPointMake(temp.x, temp.y + change.y);
            newY = self.fourthPoint.y;
            [self.points replaceObjectAtIndex:3 withObject:[NSValue valueWithCGPoint:self.fourthPoint]];
        }
            break;
        case 4:
        {
            temp = self.fifthPoint;
            newY = temp.y;
            if (temp.y + change.y > self.frame.size.height || temp.y + change.y < 0) {
                break;
            }
            self.fifthPoint = CGPointMake(temp.x, temp.y + change.y);
            newY = self.fifthPoint.y;
            [self.points replaceObjectAtIndex:4 withObject:[NSValue valueWithCGPoint:self.fifthPoint]];
        }
            break;
        default:
        break;
    }
    self.originPoints = [NSArray arrayWithArray:self.points];
    [self saveNewPoints];
    [self setNeedsDisplay];
    
    [self modifyNumberByNewY:newY];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.lightView.hidden = YES;
}


#pragma mark - 修改百分比数值
- (void)modifyNumberByNewY:(float)y
{
    UILabel *label = self.labelArr[_nowArea];
    int new =  (self.frame.size.height - y) * 100 / self.frame.size.height;
    if (y < 1) {
        new = 100;
    }
    label.text = [NSString stringWithFormat:@"%d%%",new];
}

#pragma mark - 切换时修改全部的百分比数值
- (void)modifyAllNumber
{
    for (NSInteger i = 0; i < 5; i ++) {
        UILabel *label = self.labelArr[i];
        CGPoint newPoint = [self.resultPoints[i] CGPointValue];
        int new =  (self.frame.size.height - newPoint.y) * 100 / self.frame.size.height;
        if (newPoint.y < 1) {
            new = 100;
        }
        label.text = [NSString stringWithFormat:@"%d%%",new];
    }
}

#pragma mark - 计算中间贝塞尔曲线的控制点
- (NSDictionary *)getTwoControlWithPoint1:(CGPoint)point1
                                   Point2:(CGPoint)point2
                                   point3:(CGPoint)point3
                                   point4:(CGPoint)point4
                               BesselType:(BesselType)besselType
{
    CGPoint pointA;
    CGPoint pointB;
    if (besselType == HeadType) {
        pointA = CGPointMake(point1.x + ArbitrarilyA *(point2.x - point1.x), point1.y + ArbitrarilyA * (point2.y - point1.y));
        pointB = CGPointMake(point2.x - ArbitrarilyA * (point3.x - point1.x), point2.y - ArbitrarilyA * (point3.y - point1.y));
    }else
    {
        pointA = CGPointMake(point2.x + ArbitrarilyA * (point3.x - point1.x), point2.y + ArbitrarilyA * (point3.y - point1.y));
        pointB = CGPointMake(point3.x - ArbitrarilyA * (point4.x - point2.x), point3.y - ArbitrarilyA * (point4.y - point2.y));
    }
    
    
    if (pointB.y >= self.frame.size.height) {
        pointB = CGPointMake(pointB.x, self.frame.size.height);
    }
    if (pointB.y <= 0) {
        pointB = CGPointMake(pointB.x, 0);
    }
    
    if (pointA.y >= self.frame.size.height) {
        pointA = CGPointMake(pointA.x, self.frame.size.height);
    }
    if (pointA.y <= 0) {
        pointA = CGPointMake(pointA.x, 0);
    }
    return @{@"controlAx":[NSNumber numberWithFloat:pointA.x],@"controlAy":[NSNumber numberWithFloat:pointA.y],@"controlBx":[NSNumber numberWithFloat:pointB.x],@"controlBy":[NSNumber numberWithFloat:pointB.y]};
}

#pragma mark - 懒加载
- (UIView *)lightView
{
    if (!_lightView) {
        _lightView = [UIView new];
        _lightView.frame = CGRectMake(0, 0, self.frame.size.width/5, self.frame.size.height);
        _lightView.backgroundColor = [UIColor whiteColor];
        _lightView.alpha = 0.2;
    }
    return _lightView;
}

- (UIView *)rgbView
{
    if (!_rgbView) {
        _rgbView = [[UIView alloc]initWithFrame:CGRectMake(kMainWidth, kMainHeight - 80, kMainWidth, 80)];
        _rgbView.backgroundColor = [UIColor blackColor];
        //还原按钮和返回按钮
        UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(kMainWidth/2, 0, kMainWidth/2, 20)];
        [backBtn setTitle:@"Back" forState:0];
        [backBtn addTarget:self action:@selector(backBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_rgbView addSubview:backBtn];
        
        UIButton *curveResetBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, kMainWidth/2, 20)];
        [curveResetBtn addTarget:self action:@selector(curveResetBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [curveResetBtn setTitle:@"CurveReset" forState:0];
        [_rgbView addSubview:curveResetBtn];
        
        Slide *slide = [[Slide alloc]initWithFrame:CGRectMake(0, 20, kMainWidth, 60) NameArr:@[@"RGB",@"R",@"G",@"B"] ColorArr:@[[UIColor darkGrayColor],[UIColor redColor],[UIColor greenColor],[UIColor blueColor]]];
        [_rgbView addSubview:slide];
    }
    return _rgbView;
}

#pragma mark - 显示rgbView
- (void)curveBtnPressed
{
    [UIView animateWithDuration:0.5 animations:^{
        self.rgbView.frame = CGRectMake(0, kMainHeight - 80, kMainWidth, 80);
    }];
}

#pragma mark - 隐藏rgbView
- (void)hiddenRGBView
{
    [UIView animateWithDuration:0.5 animations:^{
        self.rgbView.frame = CGRectMake(kMainWidth, kMainHeight - 80, kMainWidth, 80);
    }];
}

#pragma mark - 返回按钮
- (void)backBtnAction:(UIButton *)sender
{
    [self hiddenRGBView];
}

#pragma mark - 还原按钮
- (void)curveResetBtnAction:(UIButton *)sender
{
    float width = self.frame.size.width;
    float height = self.frame.size.height;

    CGPoint point1 = CGPointMake(0, height);
    CGPoint point2 = CGPointMake(width * 6 / 25, height * 19 / 25);
    CGPoint point3 = CGPointMake(width/2, height/2);
    CGPoint point4 = CGPointMake(width * 19 / 25, height * 6 / 25);
    CGPoint point5 = CGPointMake(width, 0);
    NSValue *value1 = [NSValue valueWithCGPoint:point1];
    NSValue *value2 = [NSValue valueWithCGPoint:point2];
    NSValue *value3 = [NSValue valueWithCGPoint:point3];
    NSValue *value4 = [NSValue valueWithCGPoint:point4];
    NSValue *value5 = [NSValue valueWithCGPoint:point5];
    
    self.resultPoints = @[value1,value2,value3,value4,value5];
    [self changeCureveAnimotionToPoins];
}

#pragma mark - 改变曲线的颜色和关键点
- (void)changeCurveColor:(NSNotification *)nf
{
  
    
    UIColor *color = nf.userInfo[@"color"];
    int index = [nf.userInfo[@"index"] floatValue];
    if (color == [UIColor darkGrayColor]) {
        color = [UIColor whiteColor];
    }
    self.curveColor = color;
    self.resultPoints = [NSArray arrayWithArray:self.arrs[index]];
    //未防止动画未完成，切换时关闭定时器
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
        [self.rateArr removeAllObjects];
        [self.arrs replaceObjectAtIndex:_nowColorIndex withObject:self.originPoints];
    }else
    {
        
        [self saveNewPoints];
    }
    self.originPoints = [NSArray arrayWithArray:self.resultPoints];
    
    [self modifyAllNumber];
    _nowColorIndex = index;
    [self changeCureveAnimotionToPoins];
}

#pragma mark - 切换/还原时保存新的关键点
- (void)saveNewPoints
{
    NSArray *array = [NSArray arrayWithArray:self.points];
    [self.arrs replaceObjectAtIndex:_nowColorIndex withObject:array];
}

#pragma mark - 切换/还原时动画
- (void)changeCureveAnimotionToPoins
{
    //计算各个关键点移动的速率
    for (NSInteger i = 0; i < 5; i ++) {
        CGPoint oldPoint = [self.points[i] CGPointValue];
        CGPoint newPoint = [self.resultPoints[i] CGPointValue];
        float rate = (newPoint.y - oldPoint.y)/20;
        [self.rateArr addObject:[NSNumber numberWithFloat:rate]];
    }
    
    
    if (_timer == nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(timeAction) userInfo:nil repeats:YES];
    }
}

- (void)timeAction
{
    float flg = 0;
    for (NSInteger i = 0; i < 5; i ++) {
        CGPoint oldPoint = [self.points[i] CGPointValue];
        float newY = oldPoint.y + [self.rateArr[i] floatValue];
        CGPoint newPoint = CGPointMake(oldPoint.x, newY);
        
        CGPoint resultPoint = [self.resultPoints[i] CGPointValue];
        if ((int)resultPoint.y  == (int)oldPoint.y) {
            flg ++;
            if (flg == 5) {
                [self.rateArr removeAllObjects];
                [_timer invalidate];
                _timer = nil;
                [self setNeedsDisplay];
                return;
            }
            
            
            continue;
        }
        
        [self.points replaceObjectAtIndex:i withObject:[NSValue valueWithCGPoint:newPoint]];
    }
    [self setNeedsDisplay];
}


@end
