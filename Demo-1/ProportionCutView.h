//
//  ProportionCutView.h
//  Demo-1
//
//  Created by admin on 16/10/13.
//  Copyright © 2016年 admin. All rights reserved.
//

typedef enum {
    /** 4：3*/
    FourThreeType = 666,
    /** 16：9*/
    SixteenNineType,
}ProportionType;

#import <UIKit/UIKit.h>

@interface ProportionCutView : UIView

//@property (nonatomic, assign) id <ProportionCutViewDelegate>delegate;
@property (nonatomic, assign) CGRect drawViewR;
@property (nonatomic, assign) ProportionType proportionType;

/** 根据类型创建视图*/
- (instancetype)initWithImageViewFrame:(CGRect)imageViewFrame
                        ImageViewImage:(UIImage *)image
                        ProportionType:(ProportionType)proportionType
                        WeakController:(UIViewController *)controller;

- (void)prepareUI;
- (void)proportionFrameChanged;

@end
