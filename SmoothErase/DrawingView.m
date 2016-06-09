//
//  DrawingView.m
//  DrawingDemoErase
//
//  Created by SOTSYS171 on 9/15/15.
//  Copyright (c) 2015 SOTSYS171. All rights reserved.
//

#import "DrawingView.h"

@implementation DrawingView

@synthesize touchRevealsImage=_touchRevealsImage, backgroundImage=_backgroundImage, foregroundImage=_foregroundImage, touchWidth=_touchWidth;


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)createBitmapContext
{
    // create a grayscale colorspace
    CGColorSpaceRef grayscale=CGColorSpaceCreateDeviceGray();
    
    /* TO DO: instead of saving the bounds at the moment of creation,
     override setFrame:, create a new context with the right
     size, draw the previous on the new, and replace the old
     one with the new one.
     */
    contextBounds=self.bounds;
    
    // create a new 8 bit grayscale bitmap with no alpha (the mask)
    context=CGBitmapContextCreate(NULL,
                                  (size_t)contextBounds.size.width,
                                  (size_t)contextBounds.size.height,
                                  8,
                                  (size_t)contextBounds.size.width,
                                  grayscale,
                                  kCGImageAlphaNone);
    
    // make it white (touchRevealsImage==NO)
    CGFloat white[]={1., 1.};
    CGContextSetFillColor(context, white);
    
    CGContextFillRect(context, contextBounds);
    
    // setup drawing for that context
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    CGColorSpaceRelease(grayscale);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch=(UITouch *)[touches anyObject];
    
    // the new line that will be drawn
    CGPoint points[]={
        [touch previousLocationInView:self],
        [touch locationInView:self]
    };
    
    // setup width and color
    CGContextSetLineWidth(context, 10);
    CGFloat color[]={(self.touchRevealsImage ? 1. : 0.), 1.};
    CGContextSetStrokeColor(context, color);
    
    // stroke
    CGContextStrokeLineSegments(context, points, 2);
    
    [self setNeedsDisplay];
    
}

- (void)drawRect:(CGRect)rect
{
    if (self.foregroundImage==nil ) return;
    
    // draw background image
   // [self drawImageScaled:self.backgroundImage];
    
    // create an image mask from the context
    CGImageRef mask=CGBitmapContextCreateImage(context);
    
    // set the current clipping mask to the image
    CGContextRef ctx=UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    CGContextClipToMask(ctx, contextBounds, mask);
    
    // now draw image (with mask)
    [self drawImageScaled:self.foregroundImage];
    
    
    CGContextRestoreGState(ctx);
    
    CGImageRelease(mask);
    
}

- (void)resetDrawing
{
    // draw black or white
    CGFloat color[]={(self.touchRevealsImage ? 0. : 1.), 1.};
    
    CGContextSetFillColor(context, color);
    CGContextFillRect(context, contextBounds);
    
    [self setNeedsDisplay];
}

#pragma mark - Helper methods -

- (void)drawImageScaled:(UIImage *)image
{
    // just draws the image scaled down and centered
    
//    CGFloat selfRatio=self.frame.size.width/self.frame.size.height;
//    CGFloat imgRatio=image.size.width/image.size.height;
    
    CGRect rect={0,0,self.bounds.size.width,self.bounds.size.height};
    
//    if (selfRatio>imgRatio) {
//        // view is wider than img
//        rect.size.height=self.frame.size.height;
//        rect.size.width=imgRatio*rect.size.height;
//    } else {
//        // img is wider than view
//        rect.size.width=self.frame.size.width;
//        rect.size.height=rect.size.width/imgRatio;
//    }
//    
//    rect.origin.x=.5*(self.frame.size.width-rect.size.width);
//    rect.origin.y=.5*(self.frame.size.height-rect.size.height);
    
    [image drawInRect:rect];
}

#pragma mark - Initialization and properties -

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self=[super initWithCoder:aDecoder])) {
        [self createBitmapContext];
        _touchWidth=self.touchWidth;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self=[super initWithFrame:frame])) {
        [self createBitmapContext];
        _touchWidth=self.touchWidth;
    }
    return self;
}

- (void)dealloc
{
    CGContextRelease(context);
   // [super dealloc];
}

- (void)setBackgroundImage:(UIImage *)value
{
    if (value!=_backgroundImage) {
     //   [_backgroundImage release];
        _backgroundImage=value ;
        [self setNeedsDisplay];
    }
}

- (void)setForegroundImage:(UIImage *)value
{
    if (value!=_foregroundImage) {
      //  [_foregroundImage release];
        _foregroundImage=value ;
        [self setNeedsDisplay];
    }
}

- (void)setTouchRevealsImage:(BOOL)value
{
    if (value!=_touchRevealsImage) {
        _touchRevealsImage=value;
        [self setNeedsDisplay];
    }
}


@end
