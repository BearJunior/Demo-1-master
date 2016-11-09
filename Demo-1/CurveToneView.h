//
//  CurveToneView.h
//  Demo-1
//
//  Created by admin on 16/10/21.
//  Copyright © 2016年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CurveToneView : UIView

/** 曲线颜色*/
@property (nonatomic, strong) UIColor *curveColor;

- (instancetype)initWithFrame:(CGRect)frame weakController:(UIViewController *)controller;

/** 点击按钮时触发*/
- (void)curveBtnPressed;



@end
