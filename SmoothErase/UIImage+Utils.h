//
//  UIImage+Utils.h
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface UIImage (Utils) 

+ (UIImage *)snapshotOfView:(UIView *)view;
+ (UIImage *)snapshotOfView:(UIView *)view rect:(CGRect)contentRect;
+ (UIImage *)snapshotOfView:(UIView *)view scale:(float)scaleFactor;
+ (UIImage *)snapshotOfView:(UIView *)view rect:(CGRect)contentRect scale:(float)scaleFactor;
+ (UIImage *)snapshotOfLayer:(CALayer *)layer rect:(CGRect)contentRect scale:(float)scaleFactor;
- (UIImage *)fixOrientation;
- (UIImage *)rotateOnAngle:(float)angleInRadians;
- (UIImage *)flipVertically;
- (UIImage *)serialize;
- (UIImage *)resizeToSize:(CGSize)newSize;
- (UIImage *)resizeToSize:(CGSize)newSize backgroundColor:(UIColor *)backgroundColor;
- (UIImage *)resizeToHalfSize;
- (UIImage *)cropToRect:(CGRect)cropRect;
- (UIImage *)previewWithSize:(CGSize)size;
- (UIImage *)mixWithImage:(UIImage *)image;
- (UIImage *)mixWithImage:(UIImage *)image rect:(CGRect)contentRect;
- (UIImage *)maskWithImage:(UIImage *)maskImage;
- (UIImage *)maskWithImage:(UIImage *)maskImage rect:(CGRect)maskRect;
- (UIImage *)makeBlackAndWhite;
- (UIImage *)makeRoundCornersWithCornerWidth:(float)cornerWidth cornerHeight:(float)cornerHeight;
- (UIImage *)maskWithPath:(CGPathRef)path;
- (UIImage *)maskFromPath:(CGPathRef)path blur:(CGFloat)blur;
- (UIImage *)adjustHue:(float)hue saturation:(float)sat brightness:(float)brt;
+ (NSArray *)getRGBAFromImage:(UIImage *)image atX:(int)xx andY:(int)yy count:(int)count andScaleX:(CGFloat)scaleX andScaleY:(CGFloat)scaleY;

@end
