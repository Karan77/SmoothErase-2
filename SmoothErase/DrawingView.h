//
//  DrawingView.h
//  DrawingDemoErase
//
//  Created by SOTSYS171 on 9/15/15.
//  Copyright (c) 2015 SOTSYS171. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrawingView : UIView{
    CGContextRef context;
    CGRect contextBounds;
}

@property (nonatomic, retain) UIImage *backgroundImage;
@property (nonatomic, retain) UIImage *foregroundImage;
@property (nonatomic, assign) CGFloat touchWidth;
@property (nonatomic, assign) BOOL touchRevealsImage;

- (void)resetDrawing;

- (void)createBitmapContext;
- (void)drawImageScaled:(UIImage *)image;

@end
