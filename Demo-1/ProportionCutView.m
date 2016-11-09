//
//  ProportionCutView.m
//  Demo-1
//
//  Created by admin on 16/10/13.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "ProportionCutView.h"

@interface ProportionCutView ()
{
    //一个记录上次矩形中心点的变量
    CGPoint _squareCenterLast;
    //一个记录上次按钮中心点的变量
    CGPoint _btnCenterLast;
    //记录上次移动的点
    CGPoint _btnLast;
    //记录上次移动的按钮的tag
    int _tag;
    
    //imageView的frame和image
    CGRect _imageViewFrame;
    UIImage *_image;
    
    
    __weak UIViewController *_controller;
    UIPanGestureRecognizer *_panGesrure;
}

/** 毛玻璃效果*/
@property (nonatomic, strong) UIImageView *lightImageView;
@property (nonatomic, strong) UIVisualEffectView *effectView;
@property (nonatomic, strong) CAShapeLayer *maskLayer;

@end

@implementation ProportionCutView

#pragma mark - 移除
- (void)removeFromSuperview
{
    [super removeFromSuperview];
    [self.lightImageView removeFromSuperview];
    [self.effectView removeFromSuperview];
    self.lightImageView = nil;
    self.effectView = nil;
    [_controller.view removeGestureRecognizer:_panGesrure];
}

#pragma mark - 懒加载
- (UIVisualEffectView *)effectView
{
    if (!_effectView) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        //  毛玻璃view 视图
        _effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        //添加到要有毛玻璃特效的控件中
        _effectView.frame = _imageViewFrame;
        _effectView.alpha = 0.6f;
//        _effectView.hidden = YES;
    }
    return _effectView;
}

- (UIImageView *)lightImageView
{
    if (!_lightImageView) {
        _lightImageView = [[UIImageView alloc]initWithFrame:_imageViewFrame];
        _lightImageView.image = _image;
        
        CAShapeLayer *shapLayer = [CAShapeLayer layer];
        shapLayer.opacity = 0.9f;
        shapLayer.fillColor = [[UIColor blackColor]CGColor];
        _lightImageView.layer.mask = shapLayer;
        self.maskLayer = shapLayer;
    }
    return _lightImageView;
}


- (instancetype)initWithImageViewFrame:(CGRect)imageViewFrame
                        ImageViewImage:(UIImage *)image
                        ProportionType:(ProportionType)proportionType
                        WeakController:(UIViewController *)controller
{
    if (self = [super init]) {
        _imageViewFrame = imageViewFrame;
        _image = image;
        _proportionType = proportionType;
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 2.0f;
        _squareCenterLast = self.center;
        _btnCenterLast = CGPointZero;
        _btnLast.x = 0;
        self.backgroundColor = [UIColor clearColor];
        _panGesrure = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panAction:)];
        [controller.view addGestureRecognizer:_panGesrure];
        //设置frame
        float width = imageViewFrame.size.width;
        float height;
        switch (proportionType) {
            case FourThreeType:{
                height = width * 4 / 3;
                if (height > imageViewFrame.size.height) {
                    height = imageViewFrame.size.height - 2;
                    width = height * 3/4;
                }
            }
                break;
            case SixteenNineType:{
                height = width * 16 / 9;
                if (height > imageViewFrame.size.height) {
                    height = imageViewFrame.size.height - 2;
                    width = height * 9/16;
                }
            }
                break;
            default:
                break;
        }
        
        self.frame = CGRectMake(0, 0, width - 2 , height);
        [controller.view addSubview:self.effectView];
        [controller.view addSubview:self.lightImageView];
        _controller = controller;
        [self prepareUI];
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    for (int i = 1; i < 3; i ++) {
        CGContextMoveToPoint(ctx, 0, self.frame.size.height/3 * i);
        CGContextAddLineToPoint(ctx, self.frame.size.width, self.frame.size.height/3 * i);
        [[UIColor whiteColor] set];
        CGContextSetLineWidth(ctx, 1);
        CGContextStrokePath(ctx);
        
        CGContextMoveToPoint(ctx, self.frame.size.width/3 * i, 0);
        CGContextAddLineToPoint(ctx, self.frame.size.width/3 * i, self.frame.size.height);
        [[UIColor whiteColor] set];
        CGContextSetLineWidth(ctx, 1);
        CGContextStrokePath(ctx);
    }
}


#pragma mark - 设置UI
- (void)prepareUI
{
    //NSArray *images = @[@"clipCorner1",@"clipCorner2",@"clipCorner3",@"clipCorner4"];
    for (int i = 0; i < 4; i ++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = 100 + i;
        button.frame = CGRectMake(0, 0, 40, 40);
        UIImage *newImage;
        button.adjustsImageWhenHighlighted = NO;
        button.imageView.transform = CGAffineTransformMakeRotation(M_PI/2 * i);
        [self addSubview:button];
        if (i == 0) {
            button.center = CGPointMake(5, 5);
            newImage = [UIImage imageWithCGImage:[[UIImage imageNamed:@"clipCorner1"] CGImage] scale:1 orientation:UIImageOrientationUp];
        }else if (i == 1){
            button.center = CGPointMake(self.frame.size.width-5, 5);
            newImage = [UIImage imageWithCGImage:[[UIImage imageNamed:@"clipCorner1"] CGImage] scale:1 orientation:UIImageOrientationRight];
        }else if (i == 2){
            button.center = CGPointMake(self.frame.size.width-5, self.frame.size.height-5);
            newImage = [UIImage imageWithCGImage:[[UIImage imageNamed:@"clipCorner1"] CGImage] scale:1 orientation:UIImageOrientationDown];
        }else
        {
            button.center = CGPointMake(5, self.frame.size.height-5);
            newImage = [UIImage imageWithCGImage:[[UIImage imageNamed:@"clipCorner1"] CGImage] scale:1 orientation:UIImageOrientationLeft];
        }
        [button setBackgroundImage:newImage forState:0];
        UIPanGestureRecognizer *btnPan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(btnPanAction:)];
        [button addGestureRecognizer:btnPan];
    }
}

#pragma mark - 按钮手势
- (void)btnPanAction:(UIPanGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateChanged) {
        //16：9比例时,等比例缩放
        if (_proportionType == SixteenNineType) {
            CGPoint translation = [sender translationInView:sender.view];
            //记录正负号
            int symbolX = 1;
            int symbolY = 1;
            
            if (fabs(translation.x) > fabs(translation.y)) {
                symbolX = translation.x >= 0 ? 1 : -1;
                switch (sender.view.tag) {
                    case 100:
                        symbolY = symbolX;
                        break;
                    case 101:
                        symbolY = - 1 * symbolX;
                        break;
                    case 102:
                        symbolY = symbolX;
                        break;
                    case 103:
                        symbolY = - 1 * symbolX;
                        break;
                        
                    default:
                        break;
                }
            }else
            {
                symbolY = translation.y >= 0 ? 1 : -1;
                switch (sender.view.tag) {
                    case 100:
                        symbolX = symbolY;
                        break;
                    case 101:
                        symbolX = - 1 * symbolY;
                        break;
                    case 102:
                        symbolX = symbolY;
                        break;
                    case 103:
                        symbolX = - 1 * symbolY;
                        break;
                        
                    default:
                        break;
                }
            }
            
            //按比例计算移动的坐标
            float destenceX = fabs(translation.x) * symbolX;
            float destenceY = fabs(translation.y) * symbolY;
            if (fabsf(destenceX) * 16 / 9 >= fabsf(destenceY)) {
                destenceY = symbolY * fabsf(destenceX) * 16 / 9;
            }else
            {
                destenceX = symbolX * fabsf(destenceY) * 9 / 16;
            }
            //改变成按比例后的位移
            [sender setTranslation:CGPointMake(destenceX, destenceY) inView:sender.view];
        }
        
        CGPoint translation = [sender translationInView:sender.view];
        CGFloat deltaX = translation.x;
        CGFloat deltaY = translation.y;
        
        CGFloat width = self.frame.size.width;
        CGFloat height = self.frame.size.height;
        CGFloat originX = self.frame.origin.x;
        CGFloat originY = self.frame.origin.y;
        
            switch (sender.view.tag) {
                case 100:
                {
                    originX += deltaX;
                    originY += deltaY;
                    width -= deltaX;
                    height -= deltaY;
                }
                    break;
                case 101:
                {
                    originY += deltaY;
                    width += deltaX;
                    height -= deltaY;
                }
                    break;
                case 102:
                {
                    width += deltaX;
                    height += deltaY;
                }
                    break;
                case 103:
                {
                    originX += deltaX;
                    width -= deltaX;
                    height += deltaY;
                }
                    break;
                default:
                    break;
            }

        
        //判断是否超出
        if (NO == [self isOutOfDrawView:CGRectMake(originX + width/2, originY + height/2, width, height)] && width >= 60 && height >= 60) {
            self.frame = CGRectMake(originX, originY, width, height);
            [self changeFrame];
            [self proportionFrameChanged];
//            [self.delegate proportionFrameChanged:self.frame];
        }else
        {
            NSLog(@"超出");
        }
        //将translation数值置零
        [sender setTranslation:CGPointZero inView:sender.view];

    }
    
}

#pragma mark - 改变selfFrame
- (void)changeFrame
{
    UIButton *button1 = [self viewWithTag:100];
    UIButton *button2 = [self viewWithTag:101];
    UIButton *button3 = [self viewWithTag:102];
    UIButton *button4 = [self viewWithTag:103];
    //将控件改回初始frame
    button1.center = CGPointMake(5, 5);
    button2.center = CGPointMake(self.frame.size.width - 5, 5);
    button3.center = CGPointMake(self.frame.size.width - 5, self.frame.size.height-5);
    button4.center = CGPointMake(5, self.frame.size.height-5);
}

#pragma mark - View拖动手势
- (void)panAction:(UIPanGestureRecognizer *)sender
{
    CGPoint translation = [sender translationInView:sender.view];
    
    //判断点击的位置是否在范围内
    CGPoint tapPoint = [sender locationInView:sender.view];
    CGRect touchArea = CGRectMake(self.frame.origin.x - 40, self.frame.origin.y - 40, self.frame.size.width + 80, self.frame.size.height + 80);
    if (NO == CGRectContainsPoint(touchArea, tapPoint)) {
        return;
    }
    
    
    //判断：如果拖动手势是结束状态
    if (sender.state == UIGestureRecognizerStateBegan) {
        _squareCenterLast = self.center;
    }
    if (sender.state == UIGestureRecognizerStateChanged) {
        //推着拖动变化量改变矩形的中心点
        float newX = translation.x + self.center.x;
        float newY = translation.y + self.center.y;
        
        CGPoint squareCenterNew = CGPointMake(newX, newY);
        
        if (NO == [self isOutOfDrawView:CGRectMake(newX, newY, self.frame.size.width, self.frame.size.height)]) {
            self.center = squareCenterNew;
            [self proportionFrameChanged];
            //[self.delegate proportionFrameChanged:self.frame];
        }
        
        [sender setTranslation:CGPointZero inView:sender.view];
    }
    
}

#pragma mark - 判断是否超出(YES:超出)
- (BOOL)isOutOfDrawView:(CGRect)rect
{
    CGFloat frameHeight = rect.size.height;
    CGFloat frameWidth = rect.size.width;
    CGPoint topLeft = CGPointMake(rect.origin.x - frameWidth/2, rect.origin.y - frameHeight/2);
    CGPoint topRight = CGPointMake(rect.origin.x + frameWidth/2, rect.origin.y - frameHeight/2);
    CGPoint bottomLeft = CGPointMake(rect.origin.x - frameWidth/2, rect.origin.y + frameHeight/2);
    CGPoint bootmRight = CGPointMake(rect.origin.x + frameWidth/2, rect.origin.y + frameHeight/2);
    if (CGRectContainsPoint(_drawViewR, topLeft)&&CGRectContainsPoint(_drawViewR, topRight)
        &&CGRectContainsPoint(_drawViewR, bottomLeft)&&CGRectContainsPoint(_drawViewR, bootmRight)){
        return NO;
    }else
    {
        return YES;
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == nil) {
        for (UIView *subView in self.subviews) {
            CGPoint tp = [subView convertPoint:point fromView:self];
            if (CGRectContainsPoint(subView.bounds, tp)) {
                view = subView;
            }
        }
    }
    return view;
}


#pragma mark - 当view移动或者缩放时，改变mask
- (void)proportionFrameChanged
{
    //根据frame改变maskLayer
    CGMutablePathRef path = CGPathCreateMutable();
    _maskLayer.bounds = self.frame;
    CGPathAddRect(path, nil, self.frame);
    _maskLayer.path = path;
    CGFloat positionX = self.frame.origin.x - _imageViewFrame.origin.x + self.frame.size.width/2;
    CGFloat positionY = self.frame.origin.y - _imageViewFrame.origin.y + self.frame.size.height/2;
    _maskLayer.position = CGPointMake(positionX, positionY);
}

@end
