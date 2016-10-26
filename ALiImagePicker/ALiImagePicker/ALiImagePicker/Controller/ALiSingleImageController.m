//
//  ALiSingleImageController.m
//  ALiImagePicker
//
//  Created by LeeWong on 2016/10/19.
//  Copyright © 2016年 LeeWong. All rights reserved.
//

#import "ALiSingleImageController.h"
#import "ALiAsset.h"

@interface ALiSingleImageController () <UIScrollViewDelegate>

@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIImageView *imageView;

@property (nonatomic,strong) UITapGestureRecognizer *singleTap;

@end

@implementation ALiSingleImageController

#pragma mark - Custom Method

- (void)setAsset:(ALiAsset *)asset
{
    _asset = asset;
    
    CGSize imageSize = CGSizeMake(asset.asset.pixelWidth, asset.asset.pixelHeight);
    
    WEAKSELF(weakSelf);
    [[PHImageManager defaultManager] requestImageForAsset:asset.asset targetSize:imageSize contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//        NSLog(@"%@",info);
        weakSelf.imageView.center = weakSelf.view.center;
//        self.scrollView.contentSize = imageSize;
        weakSelf.imageView.size = CGSizeMake(asset.asset.pixelWidth, asset.asset.pixelHeight);
        [weakSelf setCenterImage:result];
    }];
}



#pragma mark - Load View

- (void)buildUI
{
    self.scrollView.frame = self.view.bounds;
    self.view.backgroundColor = [UIColor whiteColor];
    //    [self.view addGestureRecognizer:self.singleTap];
}


#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self buildUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}


- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer{
    
    //    if ([self.delegate respondsToSelector:@selector(imageScrollViewTap:)]) {
    //        [self.delegate imageScrollViewTap:self];
    //    }
}


- (void)setCenterImage:(UIImage *)aImage
{
    CGSize boundsSize = self.view.bounds.size;// self.scrollView.bounds.size;
    CGSize aspectSize = [self aspectImage:self.asset];
    self.imageView.bounds = (CGRect) {{0.f, 0.f}, aspectSize};
    self.imageView.center = CGPointMake(boundsSize.width/2., boundsSize.height/2.);
    [self.scrollView addSubview:self.imageView];
    self.imageView.image = aImage;
    //保证新的图片按照原来放大比例
    self.scrollView.zoomScale = 1.0;
    self.scrollView.contentSize = [self aspectImage:self.asset];
}

- (CGSize)aspectImage:(ALiAsset *)imageInfo
{
    CGSize imageSize = CGSizeMake(imageInfo.asset.pixelWidth, imageInfo.asset.pixelHeight);
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = CGRectGetHeight(self.view.frame);
    CGSize aspectSize = CGSizeZero;
    if (imageSize.width/width > imageSize.height / height) {
        aspectSize = CGSizeMake(width, width * imageSize.height / imageSize.width);
    } else {
        aspectSize = CGSizeMake(height * imageSize.width / imageSize.height, height);
    }
    return aspectSize;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}


- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGSize boundsSize = scrollView.bounds.size;
    CGRect imgFrame = self.imageView.frame;
    CGSize contentSize = scrollView.contentSize;
    CGPoint centerPoint = CGPointMake(contentSize.width/2, contentSize.height/2);
    // center horizontally
    if (imgFrame.size.width <= boundsSize.width)
    {
        centerPoint.x = boundsSize.width/2;
    }
    // center vertically
    if (imgFrame.size.height <= boundsSize.height)
    {
        centerPoint.y = boundsSize.height/2;
    }
    self.imageView.center = centerPoint;
}

#pragma mark - Lazy Load

- (UIImageView *)imageView
{
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.userInteractionEnabled = YES;
    }
    return _imageView;
}

-(UIScrollView *)scrollView
{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.maximumZoomScale = 2.0;
        _scrollView.minimumZoomScale = 0.5;
        _scrollView.delegate = self;
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

- (UITapGestureRecognizer *)singleTap
{
    if (!_singleTap) {
        _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        _singleTap.numberOfTapsRequired = 1;
        _singleTap.numberOfTouchesRequired = 1;
    }
    return _singleTap;
}


@end
