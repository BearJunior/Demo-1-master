//
//  UIImage+mask.h
//  PocoCamera2
//
//  Created by admin on 15-7-3.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (Masking)

-(UIImage*)maskWithImage:(UIImage*)maskImage;

+(UIImage*)maskWithImage:(UIImage*)maskImage withScale:(float)scale;

@end
