//
//  ViewController.m
//  SmoothErase
//
//  Created by SOTSYS026 on 07/06/16.
//  Copyright © 2016 SOTSYS026. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
     NSArray *arrAnimalImages;
    ZDStickerView *stickerview, *currentStickerview;
    DrawingView *objDrawingView;
    int intStickerTag ,intCurrentTag;
    CGRect rectSelectedImageFrame;
    CGAffineTransform transformSelectedImage;
    CGPoint pointSelectedImage;
    UIImage *imgselectedImage,*imgErasedimage;
    BOOL boolDefaultFrame;
    
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    arrAnimalImages = [[NSArray alloc]initWithObjects:@"Animals_5.jpg",@"Animals_6.jpg",@"Animals_7.jpg",@"Animals_8.jpg",@"Animals_9.jpg",@"Animals_9.jpg",@"Animals_8.jpg",@"Animals_7.jpg",@"Animals_6.jpg",@"Animals_5.jpg",nil];
    intStickerTag = 101;
    viewEraseOption.hidden = YES;
    // Do any additional setup after loading the view, typically from a nib.
}
#pragma mark - CollectionView Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return arrAnimalImages.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    UIImageView *imgview =(UIImageView *)[cell viewWithTag:101];
    imgview.image=[UIImage imageNamed:[arrAnimalImages objectAtIndex:indexPath.row]];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self SetImages:[arrAnimalImages objectAtIndex:indexPath.row] SelectedImageindex:(int)indexPath.row];
    imgselectedImage = [UIImage imageNamed:[arrAnimalImages objectAtIndex:indexPath.row]];
}
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.view.frame.size.width/6, colllviewImages.frame.size.height);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - General Methods
-(void)SetImages:(NSString *)imgName SelectedImageindex:(int)index
{
    for (UIView *v in self.view.subviews)
    {
        if ([v isKindOfClass:[ZDStickerView class]])
        {
             [(ZDStickerView*)v hideEditingHandles];
        }
    }
    CGRect gripFrame1 = CGRectMake(100, 100, 100, 100);
    UIImageView *imgview = [[UIImageView alloc]initWithFrame:gripFrame1];
    imgview.image = [UIImage imageNamed:imgName];
    imgview.userInteractionEnabled = YES;
    
    UIView* contentView = [[UIView alloc] initWithFrame:gripFrame1];
    [contentView setBackgroundColor:[UIColor clearColor]];
    [contentView addSubview:imgview];

    stickerview=[[ZDStickerView alloc]initWithFrame:gripFrame1];
    stickerview.preventsCustomButton = NO;
    stickerview.contentView=imgview;
    stickerview.tag = intStickerTag;
    imgview.tag = intStickerTag;
    intCurrentTag = intStickerTag;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchInsideInImage:)];
    tap.numberOfTapsRequired = 1;
    [stickerview addGestureRecognizer:tap];
    [self.view addSubview:stickerview];
    currentStickerview = stickerview;
    [stickerview  showEditingHandles];
    colllviewImages.hidden =YES;
    viewEraseOption.hidden = NO;
}
-(UIImage *) imageWithView:(UIView *)view
{
    UIImage * img;
    //Hide All Editing Handles
    for (UIView *v in self.view.subviews)
    {
        if ([v isKindOfClass:[ZDStickerView class]])
        {
            [((ZDStickerView*)v) hideEditingHandles];
        }
    }
    //Hide All Sticker Without Currentsticker
    for (UIView *v in self.view.subviews)
    {
        if ([v isKindOfClass:[ZDStickerView class]])
        {
            if (v.tag != intCurrentTag) {
                [v setHidden:YES];
            }
        }
    }
    self.view.backgroundColor = [UIColor clearColor];
    //Take Erasedimage Screenshot
    img = [UIImage snapshotOfView:view rect:currentStickerview.frame scale:2.0];
    self.view.backgroundColor = [UIColor whiteColor];
    //Show All Stickers
    for (UIView *v in self.view.subviews)
    {
        if ([v isKindOfClass:[ZDStickerView class]])
        {
            [v setHidden:NO];
        }
    }
    //Show Current Sticker Handler
    for (UIView *v in self.view.subviews)
    {
        if ([v isKindOfClass:[ZDStickerView class]])
        {
            if (v.tag == intCurrentTag) {
                [(ZDStickerView*)v showEditingHandles];
            }
        }
    }
    return img;
}
-(void)touchInsideInImage:(UITapGestureRecognizer *)recognizer
{
    currentStickerview=(ZDStickerView*)recognizer.view;
    NSLog(@"currentStickerview tag %ld",(long)currentStickerview.tag);
    for (UIView *v in self.view.subviews)
    {
        if ([v isKindOfClass:[ZDStickerView class]])
        {
            if (v.tag == currentStickerview.tag)
            {
                NSLog(@"Touched tag %ld",((ZDStickerView*)v).tag);
                [(ZDStickerView*)v showEditingHandles];
                [self.view bringSubviewToFront:(ZDStickerView*)v];
                intCurrentTag = (int)((ZDStickerView*)v).tag;
                NSLog(@"Upadted Tag %ld",(long)intCurrentTag);
                UIImage *img = [self imageWithView:self.view];
                imgselectedImage = img;
            }
            else
            {
                [(ZDStickerView*)v hideEditingHandles];
            }
        }
    }
}
-(void)addDrawingView:(UIImage*)image :(BOOL)isEraseMode :(CGRect)frame :(CGAffineTransform)transform :(CGPoint)point
{
    
    for(UIView *v in self.view.subviews)
    {
        if([v isKindOfClass:[ZDStickerView class]])
        {
            if (v.tag==intCurrentTag)
            {
                [(ZDStickerView*)v removeFromSuperview];
            }
        }
    }
    
    objDrawingView = [[DrawingView alloc] initWithFrame:frame];
    objDrawingView.tag = intCurrentTag;
    objDrawingView.transform = transform;
    objDrawingView.center = point;
    objDrawingView.userInteractionEnabled = YES;
    objDrawingView.backgroundColor = [UIColor clearColor];
    objDrawingView.touchWidth = 10;
    objDrawingView.touchRevealsImage = isEraseMode;
    if (objDrawingView.foregroundImage == nil)
    {
        objDrawingView.foregroundImage = image;
    }
    [self.view addSubview:objDrawingView];
}
-(void)addStickerAfterEdit:(UIImage *)image :(CGRect)rect
{
    
    [objDrawingView removeFromSuperview];
    for(UIView *v in self.view.subviews)
    {
        if([v isKindOfClass:[ZDStickerView class]])
        {
            [(ZDStickerView*)v hideEditingHandles];
        }
    }
    stickerview = nil;
    UIImageView *imageView1 = [[UIImageView alloc] initWithImage:image];
    CGRect gripFrame = CGRectMake(rect.origin.x, rect.origin.y , rect.size.width, rect.size.height);
    imageView1.frame = gripFrame;
    
    UIView* contentView = [[UIView alloc] initWithFrame:rect];
    [contentView setBackgroundColor:[UIColor clearColor]];
    [contentView addSubview:imageView1];
    
    stickerview = [[ZDStickerView alloc] initWithFrame:gripFrame];
    stickerview.stickerViewDelegate = self;
    stickerview.contentView = contentView;
    stickerview.tag = intStickerTag;
    imageView1.tag = intStickerTag;
    intCurrentTag = intStickerTag;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchInsideInImage:)];
    tap.numberOfTapsRequired = 1;
    [stickerview addGestureRecognizer:tap];
    [self.view addSubview:stickerview];
    [stickerview showEditingHandles];
}
#pragma mark - Button Action
- (IBAction)btnEraseClicked:(id)sender {
    
    for (UIView *v in self.view.subviews)
    {
        if ([v isKindOfClass:[ZDStickerView class]])
        {
             NSLog(@"CurrenSelected Tag %ld",(long)v.tag);
            if (v.tag == intCurrentTag)
            {
                NSLog(@"CurrenSelected frame %@ And Tag %ld",NSStringFromCGRect(v.frame),(long)intCurrentTag);
                rectSelectedImageFrame = v.frame;
                transformSelectedImage = v.transform;
                pointSelectedImage = v.center;
                [self addDrawingView:imgselectedImage :NO :rectSelectedImageFrame :transformSelectedImage :pointSelectedImage];
            }
        }
    }
    for (UIView *v in self.view.subviews)
    {
        if ([v isKindOfClass:[ZDStickerView class]])
        {
            [v setUserInteractionEnabled:NO];
        }
    }
}
- (IBAction)btnDoneClicked:(id)sender {
    for(UIView *v in self.view.subviews)
    {
        if([v isKindOfClass:[DrawingView class]])
        {
            if (v.tag==intCurrentTag)
            {
                NSLog(@"This is Selected Tag %ld",(long)v.tag);
                for (UIView *v in self.view.subviews)
                {
                    if ([v isKindOfClass:[ZDStickerView class]])
                    {
                        NSLog(@"CurrenSelected Tag %ld",(long)v.tag);
                        if (v.tag != intCurrentTag)
                        {
                            v.hidden = YES;
                        }
                    }
                }
                self.view.backgroundColor = [UIColor clearColor];
                imgErasedimage = [UIImage snapshotOfView:self.view rect:objDrawingView.frame scale:2.0];
                self.view.backgroundColor = [UIColor whiteColor];
                for (UIView *v in self.view.subviews)
                {
                    if ([v isKindOfClass:[ZDStickerView class]])
                    {
                        NSLog(@"CurrenSelected Tag %ld",(long)v.tag);
                        if (v.tag != intCurrentTag)
                        {
                            v.hidden = NO;
                        }
                    }
                }
                [self addStickerAfterEdit:imgErasedimage :objDrawingView.frame];
                
            }
        }
    }
    for (UIView *v in self.view.subviews)
    {
        if ([v isKindOfClass:[ZDStickerView class]])
        {
            [v setUserInteractionEnabled:YES];
        }
    }
    intStickerTag++;
    colllviewImages.hidden = NO;
}
- (IBAction)btnRemoveAll:(id)sender {
    for (UIView *v in self.view.subviews)
    {
        if ([v isKindOfClass:[ZDStickerView class]])
        {
            [v removeFromSuperview];
        }
    }
    for (UIView *v in self.view.subviews)
    {
        if ([v isKindOfClass:[DrawingView class]])
        {
            [v removeFromSuperview];
        }
    }
    intStickerTag = 101;
    viewEraseOption.hidden = NO;
    colllviewImages.hidden = NO;
}
#pragma mark - StickerView Delegate
-(void)stickerViewDidClose:(ZDStickerView *)sticker
{
    for (UIView *v in self.view.subviews)
    {
        if (![v isKindOfClass:[ZDStickerView class]])
        {
            colllviewImages.hidden = NO;
            viewEraseOption.hidden = YES;
        }
    }
}
@end
