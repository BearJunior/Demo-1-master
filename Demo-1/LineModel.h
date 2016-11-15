//
//  LineModel.h
//  Demo-1
//
//  Created by admin on 16/11/15.
//  Copyright © 2016年 admin. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LineModel : NSObject

/** 坐标集合*/
@property (nonatomic, strong) NSArray *points;
/** 宽度*/
@property (nonatomic, assign) float lineWidth;
/** 颜色*/
@property (nonatomic, strong) UIColor *lineColor;

@end


@interface PointModel : NSObject

@property (nonatomic, strong) NSNumber *x;
@property (nonatomic, strong) NSNumber *y;

@property (nonatomic, strong) NSValue *point;

+ (instancetype)drawPoint:(CGPoint)point;

@end