//
//  SelectPhotosTool.m
//  Demo-1
//
//  Created by admin on 16/11/15.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "SelectPhotosTool.h"

#import <MobileCoreServices/MobileCoreServices.h>


@implementation SelectPhotosTool

+(id)defaultSelsctPhotosTool
{
    static SelectPhotosTool *center;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        center = [[self alloc] init];
    });
    return center;
}

+(void)showAtController:(UIViewController *__weak)controller backImage:(SelectPhotosBlock)imageBlock
{
    SelectPhotosTool *photoTools = [SelectPhotosTool defaultSelsctPhotosTool];
    
    //创建一个活动卡
    UIActionSheet * actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:photoTools cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从手机相册",nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    
    photoTools.controller = controller;

    //设置活动卡显示在哪一个view上
    [actionSheet showInView:controller.view];
    photoTools.imageBlock = imageBlock;
}
//在点击活动卡上的按钮时，调用此方法
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    
    if (buttonIndex == 0) {
        
        //判断当前传入的这个多媒体类型是不是一个有效的类型
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            [self loadImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"调用相机失败" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [alertView show];
        }
    }
    else if(buttonIndex == 1)
    {
        
        //判断一下这个相册类型是不是有效类型
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            
            [self loadImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"调用相册失败" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [alertView show];
        }
        
    }
}

-(void)loadImagePickerWithSourceType:(UIImagePickerControllerSourceType) sourceType
{
    //在这个方法里，我们去创建一个UIImagePickerController对象
    //这是一个系统封装的相机和相册的使用逻辑的一个控制器
    
    //创建一下对象
    UIImagePickerController * pickerContoller = [[UIImagePickerController alloc]init];
    //设置一下代理
    pickerContoller.delegate = self;
    
    //设置类型
    pickerContoller.sourceType = sourceType;
    
    //判断一下是否可以进行后续的编辑
    //条件是当调用相册时，才进行后续编辑操作
    // if (sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
    pickerContoller.allowsEditing = YES;
    //}
    
    //因为UIImagePickerController是一个视图控制器
    //所以，我们在使用他的时候，需要使用模态化的形式把他呈现出来
    //  [self presentViewController:pickerContoller animated:YES completion:nil];
    
    if ([_controller isKindOfClass:[UIViewController class]] ) {
        
        pickerContoller.popoverPresentationController.sourceView = _controller.view;
        pickerContoller.popoverPresentationController.permittedArrowDirections  =UIPopoverArrowDirectionDown;
//        [_controller presentViewController:pickerContoller animated:YES completion:^{
//            NSLog(@"跳转成功");
//        }];
    }
    
}

#pragma mark - 实现UIImagePickerController协议的方法
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    //在这里一般会去模态进行消失处理
    //  [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([_controller isKindOfClass:[UIViewController class]]) {
        
        [_controller dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    
    
    
}
//这个方法是调用相册时，处理图片使用，info参数中，保存的是图片的信息
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //因为在相册里存的除了图片，可能还有视频
    //所以先判断一下，取出来的是什么类型
    NSString * imageType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([imageType isEqualToString: (NSString *)kUTTypeImage]) {
        //如果类型为图片，那么以编辑的模式，取出来图片
        UIImage * image = [info objectForKey:UIImagePickerControllerEditedImage];
        
        _image = image;
        
        //操作完成后，将相机或相册dismiss
        //[self dismissViewControllerAnimated:YES completion:nil];
        
        if ([_controller isKindOfClass:[UIViewController class]]) {
            
            
            [_controller dismissViewControllerAnimated:YES completion:^{
                
                
            }];
            
            if (_imageBlock) {
                
                _imageBlock(image);
            }
            SelectPhotosTool *photoTools = [SelectPhotosTool defaultSelsctPhotosTool];
            photoTools.image = nil;
            photoTools.controller = nil;
            photoTools.imageBlock = nil;
            
        }
    }
}
@end
