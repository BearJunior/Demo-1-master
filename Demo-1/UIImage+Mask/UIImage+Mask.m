//
//  UIImage+mask.m
//  PocoCamera2
//
//  Created by admin on 15-7-3.
//
//

#import "UIImage+Mask.h"



static CGContextRef CreateRGBABitmapContext (CGImageRef inImage)// 返回一个使用RGBA通道的位图上下文
{
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    void *bitmapData; //内存空间的指针，该内存空间的大小等于图像使用RGB通道所占用的字节数。
    int bitmapByteCount;
    int bitmapBytesPerRow;
    
    size_t pixelsWide = CGImageGetWidth(inImage); //获取横向的像素点的个数
    size_t pixelsHigh = CGImageGetHeight(inImage); //纵向
    
    bitmapBytesPerRow	= (pixelsWide * 4); //每一行的像素点占用的字节数，每个像素点的ARGB四个通道各占8个bit(0-255)的空间
    bitmapByteCount	= (bitmapBytesPerRow * pixelsHigh); //计算整张图占用的字节数
    
    colorSpace = CGColorSpaceCreateDeviceRGB();//创建依赖于设备的RGB通道
    
    bitmapData = malloc(bitmapByteCount); //分配足够容纳图片字节数的内存空间
    
    memset(bitmapData, 0, bitmapByteCount);
    
    context = CGBitmapContextCreate (bitmapData, pixelsWide, pixelsHigh, 8, bitmapBytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast);
    //创建CoreGraphic的图形上下文，该上下文描述了bitmaData指向的内存空间需要绘制的图像的一些绘制参数
    
    CGColorSpaceRelease( colorSpace );
    //Core Foundation中通过含有Create、Alloc的方法名字创建的指针，需要使用CFRelease()函数释放
    
    return context;
}

static unsigned char *RequestImagePixelData(UIImage *inImage)
// 返回一个指针，该指针指向一个数组，数组中的每四个元素都是图像上的一个像素点的RGBA的数值(0-255)，用无符号的char是因为它正好的取值范围就是0-255
{
    CGImageRef img = [inImage CGImage];
    CGSize size = [inImage size];
    
    CGContextRef cgctx = CreateRGBABitmapContext(img); //使用上面的函数创建上下文
    
    CGRect rect = {{0,0},{size.width, size.height}};
    
    CGContextDrawImage(cgctx, rect, img); //将目标图像绘制到指定的上下文，实际为上下文内的bitmapData。
    unsigned char *data = CGBitmapContextGetData (cgctx);
    
    CGContextRelease(cgctx);//释放上面的函数创建的上下文
    return data;
}

@implementation UIImage(Masking)

+ (UIImage *)imageChangeBlackToTransparent:(UIImage *)maskImage
{
    if (!maskImage) {
        return nil;
    }
    
    unsigned char *sourcePixel = RequestImagePixelData(maskImage);
    //    unsigned char *imgPixel = RequestImagePixelData(maskImage);
    CGImageRef inImageRef = [maskImage CGImage];
    GLuint w = CGImageGetWidth(inImageRef);
    GLuint h = CGImageGetHeight(inImageRef);
    
    int wOff = 0;
    int pixOff = 0;
    
    
    for(GLuint y = 0;y< h;y++)//双层循环按照长宽的像素个数迭代每个像素点
    {
        pixOff = wOff;
        
        for (GLuint x = 0; x<w; x++)
        {
            
            unsigned char pixelAlpha = sourcePixel[pixOff+3];
            //            if(pixelAlpha != 0){
//            sourcePixel[pixOff+3] = 255-pixelAlpha;
            //            }else{
            //                sourcePixel[pixOff+3] = 255;
            //            }
            sourcePixel[pixOff] = 0;
            sourcePixel[pixOff+1] = 0;
            sourcePixel[pixOff+2] = 0;
            pixOff += 4; //将数组的索引指向下四个元素
        }
        
        wOff += w * 4;
    }
    
    NSInteger dataLength = w * h * 4;
    
    //下面的代码创建要输出的图像的相关参数
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, sourcePixel, dataLength, NULL);
    
    int bitsPerComponent = 8;
    int bitsPerPixel = 32;
    int bytesPerRow = 4 * w;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaLast;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    
    CGImageRef imageRef = CGImageCreate(w, h, bitsPerComponent, bitsPerPixel, bytesPerRow,colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);//创建要输出的图像
    
    UIImage *myImage = [UIImage imageWithCGImage:imageRef];
    
    CFRelease(imageRef);
    CGColorSpaceRelease(colorSpaceRef);
    CGDataProviderRelease(provider);
    return myImage;
}

+(UIImage*)maskWithImage:(UIImage*)maskImage withScale:(float)scale{
    
    maskImage = [UIImage imageChangeBlackToTransparent:maskImage];
    
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"51072015102317393283430654.png" ofType:@""]];
    
    const size_t originalWidth = (size_t)(image.size.width * scale);
    const size_t originalHeight = (size_t)(image.size.height * scale);
    CGContextRef bmContext = CGBitmapContextCreate(NULL, image.size.width*scale, image.size.height*scale, 8, 0, CGColorSpaceCreateDeviceRGB(), kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    if (!bmContext)
        return nil;
    
    /// Image quality
    CGContextSetShouldAntialias(bmContext, false);
    CGContextSetAllowsAntialiasing(bmContext, false);
    CGContextSetInterpolationQuality(bmContext, kCGInterpolationHigh);
    
    /// Image mask
    CGImageRef cgMaskImage = maskImage.CGImage;
    CGImageRef mask = CGImageMaskCreate((size_t)maskImage.size.width, (size_t)maskImage.size.height, CGImageGetBitsPerComponent(cgMaskImage), CGImageGetBitsPerPixel(cgMaskImage), CGImageGetBytesPerRow(cgMaskImage), CGImageGetDataProvider(cgMaskImage), NULL, false);
    
    /// Draw the original image in the bitmap context
    const CGRect r = (CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size.width = originalWidth, .size.height = originalHeight};
    CGContextClipToMask(bmContext, r, cgMaskImage);
    CGContextDrawImage(bmContext, r, image.CGImage);
    
    /// Get the CGImage object
    CGImageRef imageRefWithAlpha = CGBitmapContextCreateImage(bmContext);
    /// Apply the mask
    CGImageRef maskedImageRef = CGImageCreateWithMask(imageRefWithAlpha, mask);
    
    
    UIImage* result = [UIImage imageWithCGImage:maskedImageRef scale:1 orientation:image.imageOrientation];
    
    /// Cleanup
    CGImageRelease(maskedImageRef);
    CGImageRelease(imageRefWithAlpha);
    CGContextRelease(bmContext);
    CGImageRelease(mask);
    
    return result;
    
}


- (UIImage *)maskImage:(UIImage*)maskImage
{
    UIGraphicsBeginImageContext(self.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    
    CGImageRef maskRef = maskImage.CGImage;
    
    CGImageRef tmpMaskImage = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                                CGImageGetHeight(maskRef),
                                                CGImageGetBitsPerComponent(maskRef),
                                                CGImageGetBitsPerPixel(maskRef),
                                                CGImageGetBytesPerRow(maskRef),
                                                CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef masked = CGImageCreateWithMask([self CGImage], tmpMaskImage);
    CGImageRelease(tmpMaskImage);
    CGImageRelease(maskRef);
    
    CGContextDrawImage(ctx, area, masked);
    CGImageRelease(masked);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}



-(UIImage*)maskWithImage:(UIImage*)maskImage{
    const size_t originalWidth = (size_t)(self.size.width * self.scale);
    const size_t originalHeight = (size_t)(self.size.height * self.scale);
    CGContextRef bmContext = CGBitmapContextCreate(NULL, self.size.width, self.size.height, 8, 0, CGColorSpaceCreateDeviceRGB(), kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    if (!bmContext)
        return nil;
    
    /// Image quality
    CGContextSetShouldAntialias(bmContext, false);
    CGContextSetAllowsAntialiasing(bmContext, false);
    CGContextSetInterpolationQuality(bmContext, kCGInterpolationHigh);
    
    /// Image mask
    CGImageRef cgMaskImage = maskImage.CGImage;
    
    CGImageRef mask = CGImageMaskCreate((size_t)maskImage.size.width, (size_t)maskImage.size.height, CGImageGetBitsPerComponent(cgMaskImage), CGImageGetBitsPerPixel(cgMaskImage), CGImageGetBytesPerRow(cgMaskImage), CGImageGetDataProvider(cgMaskImage), NULL, false);
    
    /// Draw the original image in the bitmap context
    const CGRect r = (CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size.width = originalWidth, .size.height = originalHeight};
    CGContextClipToMask(bmContext, r, cgMaskImage);
    //CGContextDrawImage(bmContext, r, self.CGImage);
    UIGraphicsPushContext( bmContext );
    CGContextTranslateCTM(bmContext, 0, originalHeight);
    CGContextScaleCTM(bmContext, 1.0, -1.0);

    [self drawInRect:r];
    UIGraphicsPopContext();

    
    /// Get the CGImage object
    CGImageRef imageRefWithAlpha = CGBitmapContextCreateImage(bmContext);
    /// Apply the mask
    CGImageRef maskedImageRef = CGImageCreateWithMask(imageRefWithAlpha, mask);
    
    UIImage *result = [UIImage imageWithCGImage:maskedImageRef scale:self.scale orientation:UIImageOrientationUp];
    //UIImage* result = [UIImage imageWithCGImage:maskedImageRef scale:self.scale orientation:self.imageOrientation];
    
    /// Cleanup
    CGImageRelease(maskedImageRef);
    CGImageRelease(imageRefWithAlpha);
    CGContextRelease(bmContext);
    CGImageRelease(mask);
    
    return result;
    
}




- (UIImage *)maskImageColor:(UIColor *)maskColor
{
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextClipToMask(context, rect, self.CGImage);
    CGContextSetFillColorWithColor(context, maskColor.CGColor);
    CGContextFillRect(context, rect);
    
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return smallImage;
}



@end
