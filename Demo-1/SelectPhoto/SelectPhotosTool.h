//
//  SelectPhotosTool.h
//  Demo-1
//
//  Created by admin on 16/11/15.
//  Copyright © 2016年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^SelectPhotosBlock)(UIImage *image);

/** 选择相片*/
@interface SelectPhotosTool : NSObject<UINavigationControllerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate>

@property (nonatomic,strong) UIImage *image;

@property (nonatomic,weak) UIViewController *controller;

@property (nonatomic,copy) SelectPhotosBlock imageBlock;

@property (nonatomic,copy) void(^disMissBlock)();


/**
 *  从相机或相册获取图片
 *
 *  @param controler  控制器
 *  @param imageBlock 选择图片后的回调
 */
+(void)showAtController:(__weak UIViewController *)controller
              backImage:(SelectPhotosBlock)imageBlock;


@end
