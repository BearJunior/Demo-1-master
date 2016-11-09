//
//  DrawView.m
//  Demo-1
//
//  Created by admin on 16/10/13.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "DrawView.h"

@interface DrawView ()

@property (nonatomic, strong) NSMutableArray *lineArr;
//@property (nonatomic, strong) NSMutableArray *subPointX;
//@property (nonatomic, strong) NSMutableArray *subPointY;


@end

@implementation DrawView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _pointXrr = [NSMutableArray array];
        _pointYArr = [NSMutableArray array];
        _segmentArr = [NSMutableArray array];
        _lineArr = [NSMutableArray  array];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{

    if (self.lineArr.count == 0) {
        return;
    }
    //1 取得和当前视图相关联的图形上下文(因为图形上下文决定绘制的输出目标)
    CGContextRef ctx = UIGraphicsGetCurrentContext();//不需要*
    //如果是在drawRect方法中调用UIGraphicsGetCurrentContext方法获取出来的就是Layer的上下文
    for (NSInteger i = 0; i < self.lineArr.count; i ++) {
        NSDictionary *dic = self.lineArr[i];
        NSArray *pointXs = dic[@"pointX"];
        NSArray *pointYs = dic[@"pointY"];
        
        //2 绘图（绘制直线），保存绘图信息
        CGContextMoveToPoint(ctx, [pointXs[0] floatValue], [pointYs[0] floatValue]);
        for (int i = 1; i < pointXs.count - 1; i ++) {
            CGContextAddLineToPoint(ctx, [pointXs[i] floatValue], [pointYs[i] floatValue]);
        }
        
        //设置绘图的状态
        //设置线条的颜色为蓝色
        CGContextSetRGBStrokeColor(ctx, 0, 1.0, 0, 1.0);
        //3 渲染（绘制出一条空心的线）
        CGContextStrokePath(ctx);

    }
    
}


- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch preciseLocationInView:self];
    CGPoint previous = [touch precisePreviousLocationInView:self];
    [_pointXrr addObject:[NSNumber numberWithFloat:previous.x]];
    [_pointYArr addObject:[NSNumber numberWithFloat:previous.y]];
    
    NSArray *array = @[[NSValue valueWithCGPoint:previous],[NSValue valueWithCGPoint:location]];
    [_segmentArr addObject:array];
    
    
    NSArray *pointX = [NSArray arrayWithArray:_pointXrr];
    NSArray *pointY = [NSArray arrayWithArray:_pointYArr];
    NSArray *segment = [NSArray arrayWithArray:_segmentArr];
    NSDictionary *dic = @{@"pointX":pointX,@"pointY":pointY,@"segment":segment};
    [self.lineArr replaceObjectAtIndex:self.lineArr.count - 1 withObject:dic];
    
    [self setNeedsDisplay];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSDictionary *dic = @{@"pointX":@"",@"pointY":@"",@"segment":@""};
    [self.lineArr addObject:dic];

    //[self clear];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    [_pointXrr removeAllObjects];
    [_pointYArr removeAllObjects];
    [_segmentArr removeAllObjects];
    
    //截图按钮可点击
    if (nil != [self cutImage]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"buttonAble" object:nil userInfo:@{@"button":@"1"}];
    }else
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"buttonAble" object:nil userInfo:@{@"button":@"0"}];
    }
}


#pragma mark - 获取封闭空间的坐标数组
- (NSDictionary *)cutImage
{
    //一笔，只有一个焦点；两笔，有两个焦点
    
    BOOL flg = NO;
    NSMutableArray *closeXArr = [NSMutableArray array];
    NSMutableArray *closeYArr = [NSMutableArray array];
    
    
    if (self.lineArr.count == 1) {
        NSDictionary *dic = self.lineArr[0];
        NSArray *pointX = dic[@"pointX"];
        NSArray *pointY = dic[@"pointY"];
        NSArray *segment = dic[@"segment"];
        for (int i = 0; i < pointX.count; i ++) {
            for (int j = i + 2; j < pointX.count - 1; j ++) {
                NSArray *array1 = segment[i];
                NSArray *array2 = segment[j];
                CGPoint isIntersect = [self isIntersectWithPoint1:[array1[0] CGPointValue] Point2:[array1[1] CGPointValue] Point3:[array2[0] CGPointValue] Point4:[array2[1] CGPointValue]];
                if (isIntersect.x != 0 || isIntersect.y != 0) {
                    [closeXArr addObject:[NSNumber numberWithFloat:isIntersect.x]];
                    [closeYArr addObject:[NSNumber numberWithFloat:isIntersect.y]];
                    
                    flg = YES;
                    NSArray *xArr = [pointX subarrayWithRange:NSMakeRange(i, j - i + 1)];
                    NSArray *yArr = [pointY subarrayWithRange:NSMakeRange(i, j - i + 1)];
                    [closeXArr addObjectsFromArray:xArr];
                    [closeYArr addObjectsFromArray:yArr];
                    break;
                }
            }
            if (flg == YES) {
                break;
            }
        }

        if (flg == YES) {
            return @{@"xArr":closeXArr,@"yArr":closeYArr};
        }else
        {
            return nil;
        }
    }else if (self.lineArr.count == 2){
        NSDictionary *dic1 = self.lineArr[0];
        NSDictionary *dic2 = self.lineArr[1];
        NSArray *pointX1 = dic1[@"pointX"];
        NSArray *pointY1 = dic1[@"pointY"];
        NSArray *segment1 = dic1[@"segment"];
        NSArray *pointX2 = dic2[@"pointX"];
        NSArray *pointY2 = dic2[@"pointY"];
        NSArray *segment2 = dic2[@"segment"];
        //交点
        int point = 0;
        //第一次焦点
        CGPoint firstPoint;
        for (NSInteger i = 0; i < pointX1.count; i ++) {
            for (NSInteger j = 0; j < pointX2.count; j ++) {
                NSArray *array1 = segment1[i];
                NSArray *array2 = segment2[j];
                CGPoint isIntersect = [self isIntersectWithPoint1:[array1[0] CGPointValue] Point2:[array1[1] CGPointValue] Point3:[array2[0] CGPointValue] Point4:[array2[1] CGPointValue]];
                if (isIntersect.x != 0 || isIntersect.y != 0) {
                    point ++;
                    
                    if (point == 1) {
                        firstPoint = CGPointMake(i, j);
                    }
                    
                    if (point == 2) {
                        [closeXArr addObject:[NSNumber numberWithFloat:isIntersect.x]];
                        [closeYArr addObject:[NSNumber numberWithFloat:isIntersect.y]];
                        flg = YES;
                        
                        
                        NSArray *xArr2 = [pointX2 subarrayWithRange:NSMakeRange(firstPoint.y < j ? firstPoint.y + 1: j + 1, fabs(j - firstPoint.y) + 1)];
                        NSArray *yArr2 = [pointY2 subarrayWithRange:NSMakeRange(firstPoint.y < j ? firstPoint.y + 1: j + 1, fabs(j - firstPoint.y) + 1)];
                        //倒叙
                        NSArray *dXArr2 = [[xArr2 reverseObjectEnumerator] allObjects];
                        NSArray *dYArr2 = [[yArr2 reverseObjectEnumerator] allObjects];
                        
                        [closeXArr addObjectsFromArray:firstPoint.y < j ? dXArr2 : xArr2];
                        [closeYArr addObjectsFromArray:firstPoint.y < j ? dYArr2 : yArr2];
                        
                        
                        NSArray *xArr1 = [pointX1 subarrayWithRange:NSMakeRange(firstPoint.x < i ? firstPoint.x + 1: i + 1, fabs(i - firstPoint.x) + 1)];
                        NSArray *yArr1 = [pointY1 subarrayWithRange:NSMakeRange(firstPoint.x < i ? firstPoint.x + 1: i + 1, fabs(i - firstPoint.x) + 1)];
                        [closeXArr addObjectsFromArray:xArr1];
                        [closeYArr addObjectsFromArray:yArr1];
                        
                        [closeXArr addObject:[NSNumber numberWithFloat:isIntersect.x]];
                        [closeYArr addObject:[NSNumber numberWithFloat:isIntersect.y]];
                        
                        break;
                    }
                }

            }
            if (flg == YES) {
                break;
            }
        }
        
        
        if (flg == YES) {
            return @{@"xArr":closeXArr,@"yArr":closeYArr};
        }else
        {
            return nil;
        }    }else
    {
        return nil;
    }
    
}


#pragma mark - 判断两条线段是否相交
- (CGPoint)isIntersectWithPoint1:(CGPoint)point1
                       Point2:(CGPoint)point2
                       Point3:(CGPoint)point3
                       Point4:(CGPoint)point4
{
    //先判断是否平行
    float a1 = (point1.y - point2.y)/(point1.x - point2.x);
    float a2 = (point3.y - point4.y)/(point3.x - point4.x);
    float b1 = point1.y - a1 * point1.x;
    float b2 = point3.y - a2 * point3.x;
    if (a1 * b2 == a2 * b1) {
        return CGPointZero;
    }else
    {
        float x = (b2 - b1)/(a1 - a2);
        float point12min = point1.x >= point2.x ? point2.x : point1.x;
        float point12max = point1.x <= point2.x ? point2.x : point1.x;
        float point34min = point3.x >= point4.x ? point4.x : point3.x;
        float point34max = point3.x <= point4.x ? point4.x : point3.x;
        
        float xmin = point12min >= point34min ? point12min : point34min;
        float xmax = point12max >= point34max ? point34max : point12max;
        if (x >= xmin && x <= xmax) {
            return CGPointMake(x, a1 * x + b1);
        }else
        {
            return CGPointZero;
        }
    }
}




#pragma mark - 清空操作
- (void)clear
{
    [self.lineArr removeAllObjects];
    [self.pointXrr removeAllObjects];
    [self.pointYArr removeAllObjects];
    [self.segmentArr removeAllObjects];
}


@end
