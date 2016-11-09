//
//  Slide.m
//  SlideView
//
//  Created by admin on 16/10/21.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "Slide.h"

@interface Slide ()
{
    //记录滑动条当前位置
    int _position;
}

@property (nonatomic, strong) UIView *slideView;
@property (nonatomic, strong) NSArray *colorArr;

@end

@implementation Slide

- (instancetype)initWithFrame:(CGRect)frame NameArr:(NSArray *)names ColorArr:(NSArray *)colors
{
    if (self = [super initWithFrame:frame]) {
        _position = 0;
        self.colorArr = colors;
        [self prepareUIWithNameArr:names];
    }
    return self;
}

- (UIView *)slideView
{
    if (!_slideView) {
        _slideView = [UIView new];
    }
    return _slideView;
}

#pragma mark - 设置UI
- (void)prepareUIWithNameArr:(NSArray *)names
{
    float width = self.frame.size.width/names.count;
    float height = self.frame.size.height;
    self.slideView.frame = CGRectMake(0, 0, width, height);
    [self addSubview:self.slideView];
    for (NSInteger i = 0; i < names.count; i ++) {
        UIButton *button = [UIButton new];
        button.frame = CGRectMake(width * i, 0, width, height);
        [self addSubview:button];
        button.tag = 100 + i;
        button.backgroundColor = [UIColor clearColor];
        [button setTitle:names[i] forState:0];
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    self.slideView.backgroundColor = self.colorArr[_position];
    
}

#pragma mark - 按钮点击事件
- (void)buttonPressed:(UIButton *)sender
{
    //判断可移动View的当前位置是否是按钮的所在位置
    if (sender.tag == _position + 100) {
        return;
    }
    
    //获得按钮的frame,移动slideView,并改变颜色
    CGRect newFrame = sender.frame;
    
    _position = (int)sender.tag - 100;
    __weak typeof (self)weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        weakSelf.slideView.backgroundColor = weakSelf.colorArr[_position];
        weakSelf.slideView.frame = newFrame;
    }];
    
    //发送通知，改变曲线颜色
    [[NSNotificationCenter defaultCenter]postNotificationName:@"changeColor" object:nil userInfo:@{@"color":self.colorArr[sender.tag - 100],@"index":[NSNumber numberWithLong:sender.tag - 100]}];
    
}

@end
