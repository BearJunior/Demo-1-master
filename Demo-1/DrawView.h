//
//  DrawView.h
//  Demo-1
//
//  Created by admin on 16/10/13.
//  Copyright © 2016年 admin. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface DrawView : UIView

/** 存放坐标x*/
@property (nonatomic, strong) NSMutableArray *pointXrr;
/** 存放坐标y*/
@property (nonatomic, strong) NSMutableArray *pointYArr;
/** 存放线段*/
@property (nonatomic, strong) NSMutableArray *segmentArr;
/** 获取封闭空间坐标*/
- (NSDictionary *)cutImage;

@end
