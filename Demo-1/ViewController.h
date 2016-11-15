//
//  ViewController.h
//  Demo-1
//
//  Created by admin on 16/10/10.
//  Copyright © 2016年 admin. All rights reserved.
//

typedef enum {
    CutImgGestureType = 0,
    CutImgfourType,
    CutImgSixteenType,
    CureToneType,
    GraffitiType,
}CutImgType;


#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (nonatomic, assign) CutImgType cutImgType;

@end

