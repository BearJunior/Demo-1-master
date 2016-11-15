//
//  GraffitiView.h
//  Demo-1
//
//  Created by admin on 16/11/15.
//  Copyright © 2016年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GraffitiView : UIView
/** 路径数组*/
@property (nonatomic, strong) NSMutableArray *paths;

- (void)prepareUI;

@end
