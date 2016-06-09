//
//  ViewController.h
//  SmoothErase
//
//  Created by SOTSYS026 on 07/06/16.
//  Copyright © 2016 SOTSYS026. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZDStickerView.h"
#import "DrawingView.h"
#import "UIImage+Utils.h"
@interface ViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource,ZDStickerViewDelegate>
{
    IBOutlet UICollectionView *colllviewImages;
    IBOutlet UIView *viewEraseOption;
}

@end

