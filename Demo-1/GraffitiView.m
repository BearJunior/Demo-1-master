//
//  GraffitiView.m
//  Demo-1
//
//  Created by admin on 16/11/15.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "GraffitiView.h"
#import "LineModel.h"

@interface GraffitiView ()


@property (nonatomic, strong) NSMutableArray *points;

/** 当前颜色*/
@property (nonatomic, strong) UIColor *lineColor;
/** 当前宽度*/
@property (nonatomic, assign) float lineWidth;

@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) NSMutableArray *buttons;

@end

@implementation GraffitiView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        //[self prepareUI];
        self.paths = [NSMutableArray array];
        self.points = [NSMutableArray array];
        self.lineWidth = 11;
        self.lineColor = [UIColor redColor];
        
        self.buttons = [NSMutableArray array];
    }
    return self;
}

- (void)removeFromSuperview
{
    [super removeFromSuperview];
    [self.slider removeFromSuperview];
    for (UIButton *button in self.buttons) {
        [button removeFromSuperview];
    }
}

- (void)prepareUI
{
    self.slider = [[UISlider alloc]initWithFrame:CGRectMake(30, CGRectGetMaxY(self.frame) , 150, 40)];
    [self.superview addSubview:self.slider];
    self.slider.value = 0.5;
    [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    NSArray *colors = @[[UIColor redColor],[UIColor yellowColor],[UIColor greenColor]];
    for (NSInteger i = 0; i < 3; i ++) {
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(230 + 50 * i, CGRectGetMaxY(self.frame) + 5, 30, 30)];
        [button setBackgroundColor:colors[i]];
        [self.superview addSubview:button];
        [button addTarget:self action:@selector(chooseColor:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.cornerRadius = 15;
        [self.buttons addObject:button];
    }
}


- (void)drawRect:(CGRect)rect
{
    for (LineModel *lineModel  in self.paths) {
        [self creatPathWithLineModel:lineModel];
    }
}
#pragma mark - 描绘贝塞尔曲线
- (void)creatPathWithLineModel:(LineModel *)lineModel
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = lineModel.lineWidth;
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineCapRound;
    [lineModel.lineColor  set];
    NSArray *array = lineModel.points;
    [path moveToPoint:[[array[0] point] CGPointValue]];
    for (NSInteger i = 1; i < array.count ; i ++) {
        [path addLineToPoint:[[array[i] point] CGPointValue]];
    }
    [path stroke];
    
    //[self.cutPaths addObject:path];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.points removeAllObjects];
    //将曲线模型放进数组
    LineModel *linModel = [LineModel new];
    linModel.lineColor = self.lineColor;
    linModel.lineWidth = self.lineWidth;
    [self.paths addObject:linModel];
    
}


- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    PointModel *model = [PointModel new];
    model.point = [NSValue valueWithCGPoint:[touch locationInView:self]];
    LineModel *lineModel = [self.paths lastObject];
    [self.points addObject:model];
    lineModel.points = [NSArray arrayWithArray:self.points];
    [self setNeedsDisplay];
}


#pragma mark - 改变线段宽度
- (void)sliderValueChanged:(UISlider *)sender
{
    self.lineWidth = sender.value * 20 + 1;
}

#pragma mark - 改变颜色
- (void)chooseColor:(UIButton *)sender
{
    self.lineColor = sender.backgroundColor;
}

@end

