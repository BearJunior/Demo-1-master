//
//  ViewController.m
//  Demo-1
//
//  Created by admin on 16/10/10.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "ViewController.h"
#import "DrawView.h"
#import "ProportionCutView.h"
#import "CurveToneView.h"
#import "GraffitiView.h"
#import "UIImage+Mask.h"

@interface ViewController ()
{
    //记录放大比例
    float _proportion;
}
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) DrawView *drawView;
@property (nonatomic, strong) ProportionCutView *proportionCutView;
@property (nonatomic, strong) CurveToneView *curveToneView;
@property (nonatomic, strong) GraffitiView *graffitiView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareUI];
    [self setImgWithImage:[UIImage imageNamed:@"bg2.jpg"]];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(buttonEnableNotification:) name:@"buttonAble" object:nil];
    
}

- (void)prepareUI
{
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.imageView];
    
    NSArray *titles = @[@"手势截图",@"任意",@"16:9",@"曲线",@"涂鸦"];
    float width = (kMainWidth - titles.count + 2)/titles.count;
    float height = 50;
    float y = kMainHeight - height;
    for (NSInteger i = 0; i < titles.count; i ++) {
        UIButton *button = [UIButton new];
        [button setTitle:titles[i] forState:0];
        button.tag = 100 + i;
        [button setBackgroundColor:[UIColor grayColor]];
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake((width + 1) * i, y, width, height);
        [self.view addSubview:button];
    }
    
    UIButton *resetBtn = [UIButton new];
    [self.view addSubview:resetBtn];
    resetBtn.layer.cornerRadius = 5.0f;
    resetBtn.tag = 1002;
    [resetBtn setTitle:@"Reset" forState:0];
    [resetBtn setBackgroundColor:[UIColor grayColor]];
    [resetBtn setTitleColor:[UIColor blackColor] forState:0];
    resetBtn.frame = CGRectMake(20, AUTO_MATE_HEIGHT(30), AUTO_MATE_WIDTH(80), 40);
    [resetBtn addTarget:self action:@selector(resetBtnAction) forControlEvents:UIControlEventTouchUpInside];
    resetBtn.enabled = NO;
    
    UIButton *clipBtn = [UIButton new];
    [self.view addSubview:clipBtn];
    clipBtn.tag = 1001;
    clipBtn.layer.cornerRadius = 5.0f;
    [clipBtn setTitle:@"clip" forState:0];
    [clipBtn setBackgroundColor:[UIColor grayColor]];
    [clipBtn setTitleColor:[UIColor blackColor] forState:0];
    clipBtn.frame = CGRectMake(kMainWidth - AUTO_MATE_WIDTH(80) - 20, AUTO_MATE_HEIGHT(30), AUTO_MATE_WIDTH(80), 40);
    clipBtn.enabled = NO;
    [clipBtn addTarget:self action:@selector(clipBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.imageView.userInteractionEnabled = YES;
}

#pragma mark - 懒加载
- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, AUTO_MATE_HEIGHT(80), kMainWidth, AUTO_MATE_HEIGHT(400))];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

- (DrawView *)drawView
{
    if (!_drawView) {
        _drawView = [[DrawView alloc]initWithFrame:self.imageView.bounds];
    }
    return _drawView;
}

- (CurveToneView *)curveToneView
{
    __weak typeof(self) weakSelf = self;
    if (!_curveToneView) {
        float x = self.imageView.frame.origin.x + 50;
        float width = self.imageView.frame.size.width - 100;
        float height = width * 4 / 5;
        float y = CGRectGetMaxY(self.imageView.frame) - height - 5;
        _curveToneView = [[CurveToneView alloc]initWithFrame:CGRectMake(x, y, width, height) weakController:weakSelf];
    }
    return _curveToneView;
}

- (GraffitiView *)graffitiView
{
    if (!_graffitiView) {
        _graffitiView = [[GraffitiView alloc]initWithFrame:self.imageView.frame];
    }
    return _graffitiView;
}

#pragma mark - 截图类型点击事件
- (void)buttonPressed:(UIButton *)sender
{
    //避免创建新的slideView
    if (_cutImgType == sender.tag - 100 && _cutImgType != CutImgGestureType) {
        if (_cutImgType == CureToneType && _curveToneView) {
            [self.curveToneView curveBtnPressed];
        }
        return;
    }
    [self resetBtnAction];
    //弱引用
    __weak __typeof(self) weakSelf = self;
    switch (sender.tag) {
        case 100:
        {
            _cutImgType = CutImgGestureType;
            [self.imageView addSubview:self.drawView];
        }
            break;
        case 101:
        {
            _cutImgType = CutImgfourType;
            self.proportionCutView = [[ProportionCutView alloc]initWithImageViewFrame:weakSelf.imageView.frame ImageViewImage:weakSelf.image ProportionType:FourThreeType WeakController:weakSelf];

            [self.view addSubview:self.proportionCutView];
            self.proportionCutView.drawViewR = self.imageView.frame;
            self.proportionCutView.center = self.imageView.center;
            [self.proportionCutView proportionFrameChanged];
        }
            break;
        case 102:
        {
            _cutImgType = CutImgSixteenType;
            self.proportionCutView = [[ProportionCutView alloc]initWithImageViewFrame:self.imageView.frame ImageViewImage:weakSelf.image ProportionType:SixteenNineType WeakController:weakSelf];
            [self.view addSubview:self.proportionCutView];
            self.proportionCutView.drawViewR = self.imageView.frame;
            self.proportionCutView.center = self.imageView.center;
            [self.proportionCutView proportionFrameChanged];
        }
            break;
        case 103:
        {
            _cutImgType = CureToneType;
            [self.view addSubview:self.curveToneView];
            [self.curveToneView curveBtnPressed];
        }
            break;
        case 104:
        {
            _cutImgType = GraffitiType;
            [self.view addSubview:self.graffitiView];
            [self.graffitiView prepareUI];
        }
        default:
            break;
    }
    
    if (_cutImgType != CutImgGestureType) {
        //截图按钮可点击
        [self buttonEnable];
    }else
    {
        [self enableButton];
    }
    
    for (NSInteger i = 0; i < 5; i ++) {
        UIButton *button = [self.view viewWithTag:100 + i];
        [button setBackgroundColor:[UIColor grayColor]];
        [button setTitleColor:[UIColor whiteColor] forState:0];
    }
    [sender setBackgroundColor:[UIColor whiteColor]];
    [sender setTitleColor:[UIColor grayColor] forState:0];
    
}

#pragma mark - 按钮截图监听事件
- (void)buttonEnableNotification:(NSNotification *)nf
{
    NSString *result = nf.userInfo[@"button"];
    if ([result isEqualToString:@"0"]) {
        [self enableButton];
    }else
    {
        [self buttonEnable];
    }
}

#pragma mark - 截图按钮可点击
- (void)buttonEnable
{
    UIButton *button = [self.view viewWithTag:1001];
    [button setTitleColor:[UIColor cyanColor] forState:0];
    button.enabled = YES;
}
//不可点击
- (void)enableButton
{
    UIButton *button = [self.view viewWithTag:1001];
    [button setTitleColor:[UIColor blackColor] forState:0];
    button.enabled = NO;
}

#pragma mark - 还原按钮可点击
- (void)resetEnable
{
    UIButton *button = [self.view viewWithTag:1002];
    [button setTitleColor:[UIColor cyanColor] forState:0];
    button.enabled = YES;
}
- (void)enableReset
{
    UIButton *button = [self.view viewWithTag:1002];
    [button setTitleColor:[UIColor blackColor] forState:0];
    button.enabled = NO;
}


#pragma mark - 还原按钮点击事件
- (void)resetBtnAction
{
    for (NSInteger i = 0; i < 5; i ++) {
        UIButton *button = [self.view viewWithTag:100 + i];
        [button setBackgroundColor:[UIColor grayColor]];
        [button setTitleColor:[UIColor whiteColor] forState:0];
    }
    if (_curveToneView) {
        [self.curveToneView removeFromSuperview];
        self.curveToneView = nil;
    }
    
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    if (_drawView) {
        [self.drawView removeFromSuperview];
        self.drawView = nil;
    }
    
    [self.proportionCutView removeFromSuperview];
    
    if (_graffitiView) {
        [self.graffitiView removeFromSuperview];
        self.graffitiView = nil;
    }
    
    self.imageView.image = self.image;
    self.cutImgType = 100;
    [self enableReset];
}

#pragma mark - 截图点击事件
- (void)clipBtnAction:(UIButton *)sender
{
    switch (_cutImgType) {
        case CutImgGestureType:
        {
            NSDictionary *dic = [self.drawView cutImage];
            if (nil == dic) {
                break;
            }
            [self areaCutImgWithDic:dic];
        }
            break;
        case CutImgfourType:
            [self proportionCutImg];
            break;
        case CutImgSixteenType:
            [self proportionCutImg];
            break;
        case GraffitiType:
            [self graffitiCutImg];
            break;
        default:
            break;
    }

    [self.drawView removeFromSuperview];
    self.drawView = nil;
    [self.proportionCutView removeFromSuperview];
    [self enableButton];
    [self resetEnable];
}

#pragma mark - 设置图片
- (void)setImgWithImage:(UIImage *)img
{
    self.image = img;
    self.imageView.image = img;

    //根据imageView的高度计算出image宽高比的宽度
    float imageViewW;
    float imageViewH;
    imageViewW = self.imageView.frame.size.height *img.size.width / img.size.height;
    if (imageViewW > kMainWidth) {
        imageViewW = kMainWidth;
        imageViewH = kMainWidth * img.size.height / img.size.width;
    }else
    {
        imageViewH = self.imageView.frame.size.height;
    }
    float imageViewX = self.view.center.x - imageViewW/2;
    self.imageView.frame = CGRectMake(imageViewX, self.imageView.frame.origin.y, imageViewW, imageViewH);
}

#pragma mark - 比例截取图片
- (void)proportionCutImg
{
    CGFloat cutX = CGRectGetMinX(self.proportionCutView.frame) - CGRectGetMinX(self.imageView.frame);
    CGFloat cutY = CGRectGetMinY(self.proportionCutView.frame) - CGRectGetMinY(self.imageView.frame);
    //计算出缩放比例
    float proportion = self.imageView.image.size.width/self.imageView.frame.size.width;
    CGRect cutRect = CGRectMake(cutX * proportion, cutY * proportion, self.proportionCutView.frame.size.width * proportion, self.proportionCutView.frame.size.height * proportion);
    
    UIImage *newImage = [self imageFromImage:self.imageView.image inRect:cutRect];
    self.imageView.contentMode = UIViewContentModeCenter;
    CATransition *transition = [CATransition animation];
    transition.duration = 2;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    transition.type = kCATransitionFade;
    [self.imageView.layer addAnimation:transition forKey:@"a"];
    [self.imageView setImage:newImage];
    
}

#pragma mark - 截取图片的一部分
- (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect {
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    return newImage;
}

#pragma mark - 根据封闭空间截图
- (void)areaCutImgWithDic:(NSDictionary *)dic
{
    float proportion = self.imageView.image.size.width/self.imageView.frame.size.width;
    
    NSArray *xArr = dic[@"xArr"];
    NSArray *yArr = dic[@"yArr"];
    CGFloat width = self.image.size.width;
    CGFloat height = self.image.size.height;
    //开始绘制图片
    UIGraphicsBeginImageContext(self.imageView.image.size);
    CGContextRef gc = UIGraphicsGetCurrentContext();
    
    CGContextMoveToPoint(gc, [xArr[0] floatValue] * proportion, [yArr[0] floatValue] * proportion);
    for (int i = 1; i < xArr.count - 1; i ++) {
        CGContextAddLineToPoint(gc, [xArr[i] floatValue] * proportion, [yArr[i] floatValue] * proportion);
    }
    CGContextClip(gc);
    
    //坐标系转换
    //因为CGContextDrawImage会使用Quartz内的以左下角为(0,0)的坐标系
    CGContextTranslateCTM(gc, 0, height);
    CGContextScaleCTM(gc, 1, -1);
    CGContextDrawImage(gc, CGRectMake(0, 0, width, height), [self.image CGImage]);
    //结束绘画
    UIImage *destImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    CATransition *transition = [CATransition animation];
    transition.duration = 1;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    transition.type = kCATransitionFade;
    [self.imageView.layer addAnimation:transition forKey:@"a"];
    [self.imageView setImage:destImg];
    
}

#pragma mark - 涂鸦截图
- (void)graffitiCutImg
{
    UIGraphicsBeginImageContextWithOptions(self.imageView.frame.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.graffitiView.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImage *newImage = [self.imageView.image maskWithImage:image];
    [self.graffitiView.paths removeAllObjects];
    [self.graffitiView setNeedsDisplay];
    
    CATransition *transition = [CATransition animation];
    transition.duration = 1;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    transition.type = kCATransitionFade;
    [self.imageView.layer addAnimation:transition forKey:@"a"];
    [self.imageView setImage:newImage];
    self.graffitiView.userInteractionEnabled = NO;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

@end
