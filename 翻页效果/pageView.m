//
//  pigeView.m
//  翻页效果
//
//  Created by Neo on 15/6/24.
//  Copyright (c) 2015年 KuBao. All rights reserved.
//

#import "pageView.h"
#import <CoreGraphics/CoreGraphics.h>
@interface pageView()
@property(nonatomic,strong)CAGradientLayer * leftShadowLayer;
@property(nonatomic,strong)CAGradientLayer * rightShadowLayer;
@property(nonatomic,strong)UIImageView *leftImageView;
@property(nonatomic,strong)UIImageView *rightImageView;
@property(nonatomic) NSUInteger initialLocation;
@property(nonatomic,strong)UIImageView * rightBackView;
@end
@implementation pageView
-(void)awakeFromNib
{
    [self config];
}
-(void)config{
    UIImage * image = [UIImage imageNamed:@"雨滴"];
    self.leftImageView = [[UIImageView alloc]init];
    self.rightImageView = [[UIImageView alloc]init];
    self.leftImageView.userInteractionEnabled = YES;
    self.rightImageView.userInteractionEnabled =  YES;
    self.leftImageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds));
    self.rightImageView.layer.anchorPoint = CGPointMake(0,0.5);
    self.rightImageView.frame = CGRectMake(CGRectGetMidX(self.bounds), 0, CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds));
    self.leftImageView.image = [self clipImageWithImage:image isLeftImage:YES];
    self.rightImageView.image = [self clipImageWithImage:image isLeftImage:NO];
    
    self.leftImageView.layer.mask = [self getCornerRidusMashWithIsLeft:YES Rect:self.leftImageView.bounds];
    self.rightImageView.layer.mask = [self getCornerRidusMashWithIsLeft:NO Rect:self.rightImageView.bounds];
    self.rightBackView = [[UIImageView alloc]init];
    self.rightBackView.frame = self.rightImageView.bounds;
    self.rightBackView.image = [self getBlurAndReversalImage:[self clipImageWithImage:image isLeftImage:NO]];
    self.rightBackView.alpha = 0;
    [self.rightImageView addSubview:self.rightBackView];
    
    self.leftShadowLayer = [CAGradientLayer layer];
    self.leftShadowLayer.opacity = 0;
    self.leftShadowLayer.colors = @[(id)[UIColor clearColor].CGColor,(id)[UIColor blackColor].CGColor];
    self.leftShadowLayer.frame = self.leftImageView.bounds;
    self.leftShadowLayer.startPoint = CGPointMake(1, 1);
    self.leftShadowLayer.startPoint = CGPointMake(0, 1);
    [self.leftImageView.layer addSublayer:self.leftShadowLayer];
    
    self.rightShadowLayer = [CAGradientLayer layer];
    self.rightShadowLayer.opacity = 0;
    self.rightShadowLayer.colors = @[(id)[UIColor clearColor].CGColor,(id)[UIColor blackColor].CGColor];
    self.rightShadowLayer.frame = self.rightImageView.bounds;
    self.rightShadowLayer.startPoint = CGPointMake(0, 1);
    self.rightShadowLayer.startPoint = CGPointMake(1, 1);
    [self.rightImageView.layer addSublayer:self.rightShadowLayer];
    [self addSubview:self.leftImageView];
    [self addSubview:self.rightImageView];
    self.rightImageView.layer.transform = [self getTransForm3DWithAngle:0];
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panHandle:)];
    [self.rightImageView addGestureRecognizer:pan];
}
-(CATransform3D)getTransForm3DWithAngle:(CGFloat)angle{
    CATransform3D  transform = CATransform3DIdentity;
    transform.m34 = 4.5/-2000;
    transform  = CATransform3DRotate(transform,angle, 0, 1, 0);
    return transform;
}
-(UIImage *)clipImageWithImage:(UIImage * )image isLeftImage:(BOOL)isLeft{
    CGRect imageRect = CGRectMake(0, 0, image.size.width/2, image.size.height);
    if (!isLeft) {
        imageRect.origin.x = image.size.width/2;
    }
    CGImageRef  imgRef = CGImageCreateWithImageInRect(image.CGImage, imageRect);
    UIImage * clipImage = [UIImage imageWithCGImage:imgRef];
    CGImageRelease(imgRef);
    return clipImage;
}
-(CAShapeLayer *)getCornerRidusMashWithIsLeft:(BOOL)isLeft Rect:(CGRect)rect{
    CAShapeLayer * layer = [CAShapeLayer layer];
    UIRectCorner corner = isLeft ? UIRectCornerTopLeft|UIRectCornerBottomLeft:UIRectCornerTopRight|UIRectCornerBottomRight;
    layer.path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corner cornerRadii:CGSizeMake(10, 10)].CGPath;
    return layer;
}
-(void)panHandle:(UIPanGestureRecognizer *)pan{
    
    CGPoint location = [pan locationInView:self];
    if (pan.state == UIGestureRecognizerStateBegan) {
        self.initialLocation = location.x;
    }
     NSLog(@"y:%@",[self.rightImageView.layer valueForKeyPath:@"transform.rotation.y"]);
    NSLog(@"x:%@",[self.rightImageView.layer valueForKeyPath:@"transform.rotation.x"]);

    
    if ([[self.rightImageView.layer valueForKeyPath:@"transform.rotation.y"] floatValue] > -M_PI_2&&([[self.rightImageView.layer valueForKeyPath:@"transform.rotation.x"] floatValue] != 0)) {
         NSLog(@"------------%@",[self.rightImageView.layer valueForKeyPath:@"transform.rotation.y"]);
        self.rightBackView.alpha = 1;
        self.rightShadowLayer.opacity = 0;
        CGFloat opacity = (location.x-self.initialLocation)/(CGRectGetWidth(self.bounds)-self.initialLocation);
        self.leftShadowLayer.opacity =fabs(opacity);
    }
    else if(([[self.rightImageView.layer valueForKeyPath:@"transform.rotation.y"] floatValue] > -M_PI_2)&&([[self.rightImageView.layer valueForKeyPath:@"transform.rotation.y"] floatValue]<0)&&([[self.rightImageView.layer valueForKeyPath:@"transform.rotation.x"] floatValue] == 0))
    {
        self.rightBackView.alpha = 0;
        CGFloat opacity = (location.x-self.initialLocation)/(CGRectGetWidth(self.bounds)-self.initialLocation);
        //self.rightShadowLayer.opacity = 0 ;
        self.rightShadowLayer.opacity =fabs(opacity)*0.5 ;
        self.leftShadowLayer.opacity =fabs(opacity)*0.5;
    }
    if ([self isLocation:location inView:self]) {
        CGFloat conversioFactor = M_PI/(CGRectGetWidth(self.bounds)-self.initialLocation);
        self.rightImageView.layer.transform = [self getTransForm3DWithAngle:(location.x-self.initialLocation)*conversioFactor];
    }
    else
    {
        pan.enabled=NO;
        pan.enabled=YES;
    }
    if (pan.state == UIGestureRecognizerStateEnded||pan.state == UIGestureRecognizerStateCancelled) {
        ;
    }
}
-(BOOL)isLocation:(CGPoint)location inView:(UIView *)view{
    if ((location.x>0 && location.x<CGRectGetWidth(view.frame))&&(location.y>0&&location.y<CGRectGetHeight(view.frame))) {
        return YES;
    }
    else
    {
        return NO;
    }
}
-(UIImage *)getBlurAndReversalImage:(UIImage *)image{
    CIContext * context = [CIContext contextWithOptions:nil];
    CIImage * inputImage = [CIImage imageWithCGImage:image.CGImage];
    CIFilter * filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:10.0f] forKey:@"inputRadius"];
    CIImage * result = [filter valueForKey:kCIOutputImageKey];
   result = [result imageByApplyingTransform:CGAffineTransformMakeTranslation(-1, 1)];
    CGImageRef ref = [context createCGImage:result fromRect:[inputImage extent]];
    UIImage * returnImage = [UIImage imageWithCGImage:ref];
    CGImageRelease(ref);
    return returnImage;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
