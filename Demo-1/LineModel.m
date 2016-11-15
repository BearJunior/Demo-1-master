//
//  LineModel.m
//  Demo-1
//
//  Created by admin on 16/11/15.
//  Copyright © 2016年 admin. All rights reserved.
//


#import "LineModel.h"

@implementation LineModel

@end


@implementation PointModel

+ (instancetype)drawPoint:(CGPoint)point
{
    PointModel *model = [PointModel new];
    model.x = @(point.x);
    model.y = @(point.y);
    return model;
}

@end