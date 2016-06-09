//
//  UIImage+Utils.m
//

#import "UIImage+Utils.h"


@implementation UIImage (Utils)

+ (UIImage *)snapshotOfView:(UIView *)view {
  return [self snapshotOfView:view rect:view.bounds scale:2.0f];
}

+ (UIImage *)snapshotOfView:(UIView *)view rect:(CGRect)contentRect {
  return [self snapshotOfView:view rect:contentRect scale:2.0f];
}

+ (UIImage *)snapshotOfView:(UIView *)view scale:(float)scaleFactor {
  return [self snapshotOfView:view rect:view.bounds scale:scaleFactor];
}

+ (UIImage *)snapshotOfView:(UIView *)view rect:(CGRect)contentRect scale:(float)scaleFactor {
  return [UIImage snapshotOfLayer:view.layer rect:contentRect scale:scaleFactor];
}

+ (UIImage *)snapshotOfLayer:(CALayer *)layer rect:(CGRect)contentRect scale:(float)scaleFactor
{
    contentRect = CGRectMake(contentRect.origin.x+10, contentRect.origin.y+10, contentRect.size.width-20, contentRect.size.height-20);
    
  float w = scaleFactor * contentRect.size.width;
  float h = scaleFactor * contentRect.size.height;
  
  UIGraphicsBeginImageContext(CGSizeMake(w, h));
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  if (scaleFactor != 1.0f)
  CGContextScaleCTM(context, scaleFactor, scaleFactor);
  CGContextTranslateCTM(context,-contentRect.origin.x,-contentRect.origin.y);
  [layer renderInContext:context];
  UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
  
  UIGraphicsEndImageContext();
  
  return result;
}

- (UIImage *)fixOrientation
{
  // No-op if the orientation is already correct
  if (self.imageOrientation == UIImageOrientationUp)
    return self;
  
  // We need to calculate the proper transformation to make the image upright.
  // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
  CGAffineTransform transform = CGAffineTransformIdentity;
  
  switch ((int)self.imageOrientation) {
    case UIImageOrientationDown:
    case UIImageOrientationDownMirrored:
      transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
      transform = CGAffineTransformRotate(transform, M_PI);
      break;
      
    case UIImageOrientationLeft:
    case UIImageOrientationLeftMirrored:
      transform = CGAffineTransformTranslate(transform, self.size.width, 0);
      transform = CGAffineTransformRotate(transform, M_PI_2);
      break;
      
    case UIImageOrientationRight:
    case UIImageOrientationRightMirrored:
      transform = CGAffineTransformTranslate(transform, 0, self.size.height);
      transform = CGAffineTransformRotate(transform, -M_PI_2);
      break;
  }
  
  switch ((int)self.imageOrientation) {
    case UIImageOrientationUpMirrored:
    case UIImageOrientationDownMirrored:
      transform = CGAffineTransformTranslate(transform, self.size.width, 0);
      transform = CGAffineTransformScale(transform, -1, 1);
      break;
      
    case UIImageOrientationLeftMirrored:
    case UIImageOrientationRightMirrored:
      transform = CGAffineTransformTranslate(transform, self.size.height, 0);
      transform = CGAffineTransformScale(transform, -1, 1);
      break;
  }
  
  // Now we draw the underlying CGImage into a new context, applying the transform
  // calculated above.
  CGContextRef ctx = CGBitmapContextCreate(NULL,
                                           self.size.width,
                                           self.size.height,
                                           CGImageGetBitsPerComponent(self.CGImage),
                                           0,
                                           CGImageGetColorSpace(self.CGImage),
                                           CGImageGetBitmapInfo(self.CGImage));
  CGContextConcatCTM(ctx, transform);
  switch (self.imageOrientation) {
    case UIImageOrientationLeft:
    case UIImageOrientationLeftMirrored:
    case UIImageOrientationRight:
    case UIImageOrientationRightMirrored:
      // Grr...
      CGContextDrawImage(ctx, CGRectMake(0, 0, self.size.height, self.size.width), self.CGImage);
      break;
      
    default:
      CGContextDrawImage(ctx, CGRectMake(0, 0, self.size.width, self.size.height), self.CGImage);
      break;
  }
  
  // And now we just create a new UIImage from the drawing context
  CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
  UIImage *img = [UIImage imageWithCGImage:cgimg];
  CGContextRelease(ctx);
  CGImageRelease(cgimg);
  return img;
}

- (UIImage *)rotateOnAngle:(float)angleInRadians
{
  int w = CGImageGetWidth(self.CGImage);
  int h = CGImageGetHeight(self.CGImage);
  
  if (w == 0 || h == 0) {
    return nil;
  }
  
  CGRect rect = {0, 0, w, h};
  
  UIGraphicsBeginImageContext(rect.size);
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGContextTranslateCTM(context, 0.5 * rect.size.width, 0.5 * rect.size.height);
  CGContextRotateCTM(context, angleInRadians);
  CGContextTranslateCTM(context,-0.5 * rect.size.width,-0.5 * rect.size.height);
  CGContextScaleCTM(context, 1.0, -1.0);
  CGContextTranslateCTM(context, 0.0, -rect.size.height);
  
  CGContextDrawImage(context, rect, self.CGImage);
  
  UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return result;
}

- (UIImage *)flipVertically
{
  int w = CGImageGetWidth(self.CGImage);
  int h = CGImageGetHeight(self.CGImage);
  
  if (w == 0 || h == 0) {
    return nil;
  }
  
  CGRect rect = {0, 0, w, h};
  
  UIGraphicsBeginImageContext(rect.size);
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGContextTranslateCTM(context, 0.0, 0.5 * rect.size.height);
  CGContextScaleCTM(context, 1.0, 1.0);
  CGContextTranslateCTM(context, 0.0, -0.5 * rect.size.height);
  
  CGContextDrawImage(context, rect, self.CGImage);
  
  UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return result;
}

- (UIImage *)serialize {
  int w = CGImageGetWidth(self.CGImage);
  int h = CGImageGetHeight(self.CGImage);
  return [self resizeToSize:CGSizeMake(w, h) backgroundColor:nil];
}

- (UIImage *)resizeToSize:(CGSize)newSize {
  return [self resizeToSize:newSize backgroundColor:nil];
}

- (UIImage *)resizeToHalfSize{
    CGSize newSize = CGSizeMake(self.size.width/2, self.size.height/2);
    return [self resizeToSize:newSize backgroundColor:nil];
}

- (UIImage *)resizeToSize:(CGSize)newSize backgroundColor:(UIColor *)backgroundColor
{
  int w = CGImageGetWidth(self.CGImage);
  int h = CGImageGetHeight(self.CGImage);
  
  if (w == 0 || h == 0) {
    return nil;
  }
  
  UIGraphicsBeginImageContext(newSize);
  
  CGRect rect = {0, 0, newSize.width, newSize.height};
  
  if (backgroundColor && !CGColorEqualToColor(backgroundColor.CGColor, [UIColor clearColor].CGColor))
  {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, backgroundColor.CGColor);
    CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
    CGContextFillRect(context, rect);
  }
  
  [self drawInRect:rect];
  
  UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return result;
}

- (UIImage *)cropToRect:(CGRect)cropRect
{
  int w = CGImageGetWidth(self.CGImage);
  int h = CGImageGetHeight(self.CGImage);
  
  if (w == 0 || h == 0) {
    return nil;
  }
  
  CGRect rect = CGRectIntersection(CGRectMake(0, 0, w, h), cropRect);
  
  if (CGRectIsNull(rect))
    return nil;
  
  UIGraphicsBeginImageContext(rect.size);
  
  CGRect drawRect = {-MAX(cropRect.origin.x, 0),-MAX(cropRect.origin.y, 0), w, h};
  [self drawInRect:drawRect];
  
  UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return result;
}

- (UIImage *)previewWithSize:(CGSize)size
{/*
  int w = CGImageGetWidth(self.CGImage);
  int h = CGImageGetHeight(self.CGImage);
  
  if (w == 0 || h == 0) {
    return nil;
  }

  CGSize fillSize = CGSizeScaledToFillSize(CGSizeMake(w, h), size);
  CGRect cropRect = CGRectMake(roundf(0.5*(fillSize.width-size.width)),
                               roundf(0.5*(fillSize.height-size.height)),
                               size.width,
                               size.height);
  
  UIImage *preview = self;
  preview = [preview resizeToSize:fillSize];
  preview = [preview cropToRect:cropRect];
  return preview;
  */
    return nil;
}

- (UIImage *)mixWithImage:(UIImage *)image {
  CGRect rect = CGRectMake(0, 0, CGImageGetWidth(self.CGImage), CGImageGetHeight(self.CGImage));
  return [self mixWithImage:image rect:rect];
}

- (UIImage *)mixWithImage:(UIImage *)image rect:(CGRect)contentRect
{
  int w = CGImageGetWidth(self.CGImage);
  int h = CGImageGetHeight(self.CGImage);
  
  if (w == 0 || h == 0) {
    return nil;
  }
  
  CGSize outputSize = CGSizeMake(w, h);
  UIGraphicsBeginImageContext(outputSize);
  [self drawInRect:contentRect];
  [image drawInRect:contentRect];
  
  UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return result;
}

- (UIImage *)maskWithImage:(UIImage *)maskImage
{
  int w = CGImageGetWidth(self.CGImage);
  int h = CGImageGetHeight(self.CGImage);
  
  if (w == 0 || h == 0) {
    return nil;
  }
  
  CGImageRef maskRef = maskImage.CGImage;
  CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                      CGImageGetHeight(maskRef),
                                      CGImageGetBitsPerComponent(maskRef),
                                      CGImageGetBitsPerPixel(maskRef),
                                      CGImageGetBytesPerRow(maskRef),
                                      CGImageGetDataProvider(maskRef), NULL, false);
  CGImageRef masked = CGImageCreateWithMask(self.CGImage, mask);
  CGImageRelease(mask);
  UIImage *result1 = [UIImage imageWithCGImage:masked];
  CGImageRelease(masked);
  
  CGSize outputSize = CGSizeMake(w, h);
  UIGraphicsBeginImageContext(outputSize);
  [result1 drawInRect:CGRectMake(0, 0, w, h)];
  UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return result;
}

CGImageRef copyImageAndRemoveAlphaChannel(CGImageRef imageRef)
{
  CGImageRef retVal = NULL;
  
  int w = CGImageGetWidth(imageRef);
  int h = CGImageGetHeight(imageRef);
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGContextRef offscreenContext = CGBitmapContextCreate(NULL, w, h, 8, 0, colorSpace, kCGImageAlphaNoneSkipLast);
  CGColorSpaceRelease(colorSpace);
  
  if (offscreenContext != NULL)
  {
    CGContextDrawImage(offscreenContext, CGRectMake(0, 0, w, h), imageRef);
    
    retVal = CGBitmapContextCreateImage(offscreenContext);
    CGContextRelease(offscreenContext);
  }
  
  return retVal;
}

- (UIImage *)maskWithImage:(UIImage *)maskImage rect:(CGRect)maskRect
{
  int w = CGImageGetWidth(self.CGImage);
  int h = CGImageGetHeight(self.CGImage);
  
  if (w == 0 || h == 0) {
    return nil;
  }
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGContextRef mainViewContentContext = CGBitmapContextCreate(NULL, maskRect.size.width, maskRect.size.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
  CGColorSpaceRelease(colorSpace);
  
  if (mainViewContentContext == NULL) {
    return nil;
  }
  
  CGRect rect = CGRectMake(0, 0, maskRect.size.width, maskRect.size.height);
  UIGraphicsBeginImageContext(rect.size);
  [maskImage drawInRect:rect];
  UIImage *fullMaskImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  CGImageRef maskImageRef = copyImageAndRemoveAlphaChannel(fullMaskImage.CGImage);
  CGContextClipToMask(mainViewContentContext, rect, maskImageRef);
  CGContextDrawImage(mainViewContentContext, CGRectMake(-rect.origin.x, -(h - rect.origin.y - rect.size.height), w, h), self.CGImage);
  CGImageRelease(maskImageRef);
  
  CGImageRef mainViewContentBitmapContext = CGBitmapContextCreateImage(mainViewContentContext);
  CGContextRelease(mainViewContentContext);
  
  UIImage *result = [UIImage imageWithCGImage:mainViewContentBitmapContext];
  CGImageRelease(mainViewContentBitmapContext);
  
  return result;
}

- (UIImage *)makeBlackAndWhite
{
  int w = CGImageGetWidth(self.CGImage);
  int h = CGImageGetHeight(self.CGImage);
  
  if (w == 0 || h == 0) {
    return nil;
  }
  
  CGRect rect = {0, 0, w, h};
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
  CGContextRef context = CGBitmapContextCreate(nil, w, h, 8, 0, colorSpace, kCGImageAlphaNone);
  CGColorSpaceRelease(colorSpace);
  
  if (context == NULL) {
    return nil;
  }
  
  CGContextDrawImage(context, rect, self.CGImage);
  
  CGImageRef imageRef = CGBitmapContextCreateImage(context);
  
  UIImage *result = [UIImage imageWithCGImage:imageRef];
  CGImageRelease(imageRef);
  CGContextRelease(context);
  
  return result;
}

static void addRoundedRectPathToContext(CGContextRef context, CGRect rect, float cornerWidth, float cornerHeight)
{
  float fw, fh;
  
  if (cornerWidth == 0 || cornerHeight == 0) {
    CGContextAddRect(context, rect);
    return;
  }
  
  CGContextSaveGState(context);
  CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
  CGContextScaleCTM(context, cornerWidth, cornerHeight);
  
  fw = CGRectGetWidth(rect) / cornerWidth;
  fh = CGRectGetHeight(rect) / cornerHeight;
  
  CGContextMoveToPoint(context, fw, fh/2);
  CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
  CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
  CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
  CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
  CGContextClosePath(context);
  CGContextRestoreGState(context);
}

- (UIImage *)makeRoundCornersWithCornerWidth:(float)cornerWidth cornerHeight:(float)cornerHeight
{
  int w = CGImageGetWidth(self.CGImage);
  int h = CGImageGetHeight(self.CGImage);
  
  if (w == 0 || h == 0) {
    return nil;
  }
  
  CGRect rect = {0, 0, w, h};
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
  
  CGContextBeginPath(context);
  addRoundedRectPathToContext(context, rect, cornerWidth, cornerHeight);
  CGContextClosePath(context);
  CGContextClip(context);
  
  CGContextDrawImage(context, rect, self.CGImage);
  
  CGImageRef imageMasked = CGBitmapContextCreateImage(context);
  CGContextRelease(context);
  CGColorSpaceRelease(colorSpace);
  
  UIImage *result = [UIImage imageWithCGImage:imageMasked];
  CGImageRelease(imageMasked);
  
  return result;
}

- (UIImage *)maskWithPath:(CGPathRef)path
{
  int w = CGImageGetWidth(self.CGImage);
  int h = CGImageGetHeight(self.CGImage);
  
  if (w == 0 || h == 0) {
    return nil;
  }
  
  CGRect rect = {0, 0, w, h};
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
  
  CGContextBeginPath(context);
  CGContextAddPath(context, path);
  CGContextClosePath(context);
  CGContextClip(context);
  
  CGContextDrawImage(context, rect, self.CGImage);
  
  CGImageRef imageMasked = CGBitmapContextCreateImage(context);
  CGContextRelease(context);
  CGColorSpaceRelease(colorSpace);
  
  UIImage *result = [UIImage imageWithCGImage:imageMasked];
  CGImageRelease(imageMasked);
  
  return result;
}

- (UIImage *)maskFromPath:(CGPathRef)path blur:(CGFloat)blur
{
  int w = CGImageGetWidth(self.CGImage);
  int h = CGImageGetHeight(self.CGImage);
  
  if (w == 0 || h == 0) {
    return nil;
  }
  
  CGRect rect = {0, 0, w, h};
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
  
  CGContextTranslateCTM(context, -w, 0);
  
  /// filling with white color
  CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
  CGContextFillRect(context, rect);
  
  /// draw with black
  CGContextSetStrokeColorWithColor(context, [[UIColor clearColor] CGColor]);
  CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
  CGContextSetShadowWithColor(context, CGSizeMake(w, 0), blur, [[UIColor blackColor] CGColor]);
  
  CGContextBeginPath(context);
  CGContextAddPath(context, path);
  CGContextClosePath(context);
  
  CGContextDrawPath(context, kCGPathFill);
  
  /// 
  CGImageRef maskImage = CGBitmapContextCreateImage(context);
  CGContextRelease(context);
  CGColorSpaceRelease(colorSpace);
  
  UIImage *result = [UIImage imageWithCGImage:maskImage];
  CGImageRelease(maskImage);
  
  return result;
}

#define SAFE_COLOR(color) MIN(255, MAX(0,color))

- (void)getHSLFromRGB:(float)r :(float)g :(float)b :(float *)h :(float *)s :(float *)l
{
	r *= 255.0;
	g *= 255.0;
	b *= 255.0;
  
	float hue = 0.0;
	float minRGB = MIN(MIN(r, g), b);
	float maxRGB = MAX(MAX(r, g), b);
	float delta = (maxRGB - minRGB);
	float brt = 0.5 * (maxRGB + minRGB);
	float sat = 0.0;
	if (maxRGB != 0.0)
		sat = 255.0 * delta / maxRGB;
	if (sat != 0.0) {
		if (r == maxRGB)
			hue = (g - b) / delta;
		else
			if (g == maxRGB)
				hue = 2.0 + (b - r) / delta;
			else
				if (b == maxRGB)
					hue = 4.0 + (r - g) / delta;
	} else
		hue = -1.0;
	hue = hue * 60;
	if (hue < 0.0)
		hue = hue + 360.0;
	
	*h = hue / 360.0;
	*s = sat / 255.0;
	*l = brt / 255.0;
}

- (float)hueToRGB :(float)m1 :(float)m2 :(float)h
{
	if (h < 0.0) h = h + 1.0;
	if (h > 1.0) h = h - 1.0;
	if (6.0 * h < 1.0)
		return (m1 + (m2 - m1) * h * 6.0);
	else
		if (2.0 * h < 1.0)
			return m2;
		else
			if (3.0 * h < 2.0)
				return (m1 + (m2 - m1) * ((2.0/3.0) - h) * 6.0);
			else
				return m1;
}

- (void)getRGBFromHSL:(float)h :(float)s :(float)l :(float *)r :(float *)g :(float *)b
{
	float m1, m2;
	
	if (s) {
		if (l < 0.5)
			m2 = l * (1.0 + s);
		else
			m2 = l + s - (l * s);
		m1 = 2.0 * l - m2;
		*r = [self hueToRGB:m1:m2:h+1.0/3.0];
		*g = [self hueToRGB:m1:m2:h];
		*b = [self hueToRGB:m1:m2:h-1.0/3.0];
	}
  else {
		*r = l;
		*g = l;
		*b = l;
  }
}

- (UIImage *)adjustHue:(float)hue saturation:(float)sat brightness:(float)brt
{
  float backupScale = self.scale;
  UIImageOrientation backupOrientation = self.imageOrientation;
  
//	CGImageRef inImage = self.CGImage;
//	CFDataRef dataRef = CGDataProviderCopyData(CGImageGetDataProvider(inImage));
//	UInt8 *buffer = (UInt8 *)CFDataGetBytePtr(dataRef);
//	
//	int length = CFDataGetLength(dataRef);
  
  
  int w = CGImageGetWidth(self.CGImage);
  int h = CGImageGetHeight(self.CGImage);
  
  NSInteger dataLength = w * h * 4;
	Byte *buffer = (Byte *)malloc(dataLength);
  
  
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
	// load image to buffer
	CGContextRef context = CGBitmapContextCreate(buffer, w, h, 8, w * 4, colorSpace, kCGImageAlphaPremultipliedLast);
	CGContextDrawImage(context, CGRectMake(0, 0, w, h), self.CGImage);
	CGContextRelease(context);
	
	CGColorSpaceRelease(colorSpace);
  
	for (int offset = 0; offset < dataLength; offset += 4)
	{
    float r = (float)buffer[offset+0] / 255.;
    float g = (float)buffer[offset+1] / 255.;
    float b = (float)buffer[offset+2] / 255.;
    //float a = (float)buffer[offset+3] / 255.;
    
    float h, s, l;
    [self getHSLFromRGB:r :g :b :&h :&s :&l];
    //UIColor *color1 = [[UIColor alloc] initWithRed:r green:g blue:b alpha:1.];
    //[color1 getHue:&h saturation:&s brightness:&l alpha:NULL];
    //[color1 release];
    
    s *= sat;
    l *= brt;
    h += hue;
    if (h > 1.0)
      h = h - 1.0;
    
    [self getRGBFromHSL:h :s :l :&r :&g :&b];
    //UIColor *color2 = [[UIColor alloc] initWithHue:h saturation:s brightness:l alpha:1.0];
    //[color2 getRed:&r green:&g blue:&b alpha:NULL];
    //[color2 release];
    
    buffer[offset+0] = SAFE_COLOR(r * 255.);
    buffer[offset+1] = SAFE_COLOR(g * 255.);
    buffer[offset+2] = SAFE_COLOR(b * 255.);
	}
	
//	CGContextRef ctx = CGBitmapContextCreate(pixelBuf,
//                                           CGImageGetWidth(inImage),
//                                           CGImageGetHeight(inImage),
//                                           CGImageGetBitsPerComponent(inImage),
//                                           CGImageGetBytesPerRow(inImage),
//                                           CGImageGetColorSpace(inImage),
//                                           CGImageGetBitmapInfo(inImage)
//                                           );
//	
//	CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
//	CGContextRelease(ctx);
//	UIImage *result = [UIImage imageWithCGImage:imageRef scale:backupScale orientation:backupOrientation];
//	CGImageRelease(imageRef);
//	CFRelease(dataRef);
  
  // create pre-result image from pixel buffer
	
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer, dataLength, NULL);
	
	int bitsPerComponent = 8;
	int bitsPerPixel = 32;
	int bytesPerRow = 4 * w;
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaLast;
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
	CGImageRef resultRef = CGImageCreate(w, h, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
	CGDataProviderRelease(provider);
	UIImage *result1 = [UIImage imageWithCGImage:resultRef scale:backupScale orientation:backupOrientation];
	CGImageRelease(resultRef);
	
	// get result image from context
	
	UIGraphicsBeginImageContext(CGSizeMake(w, h));
	
	[result1 drawAtPoint:CGPointZero];
	
	UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	free(buffer);
  
	return result;
}

+ (NSArray *)getRGBAFromImage:(UIImage *)image atX:(int)xx andY:(int)yy count:(int)count andScaleX:(CGFloat)scaleX andScaleY:(CGFloat)scaleY {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:count];
    
    // First get the image into your data buffer
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    // scale image
    CGContextScaleCTM(context, scaleX, scaleY);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    // Now your rawData contains the image data in the RGBA8888 pixel format.
    int byteIndex = (bytesPerRow * yy) + xx * bytesPerPixel;
    for (int ii = 0 ; ii < count ; ++ii)
    {
        CGFloat red   = (rawData[byteIndex]     * 1.0) / 255.0;
        CGFloat green = (rawData[byteIndex + 1] * 1.0) / 255.0;
        CGFloat blue  = (rawData[byteIndex + 2] * 1.0) / 255.0;
        CGFloat alpha = (rawData[byteIndex + 3] * 1.0) / 255.0;
        byteIndex += 4;
        
        UIColor *acolor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        [result addObject:acolor];
    }
    
    free(rawData);
    
    return result;
}

@end





