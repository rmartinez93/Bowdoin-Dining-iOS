//
//  SplashView.m
//  Bowdoin Dining
//
//  Created by Ruben on 7/16/14.
//
//

#import <Foundation/Foundation.h>
#import "SplashView.h"

@implementation SplashView

UIColor *trueBlue;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame: frame];
    if(self) {
        trueBlue = [UIColor colorWithRed: 0.0 green:0.50 blue:1 alpha:1];
    }
    return self;
}

+ (Class)layerClass {
    return [CAShapeLayer class];
}

- (void)layoutSubviews {
    [self setLayerProperties];
    [self animate];
}

- (void)setLayerProperties {
    CAShapeLayer *layer = (CAShapeLayer *)self.layer;
    float size = 128;
    CGRect centerRect = CGRectMake(self.bounds.size.width/2 - size/2, self.bounds.size.height/2 - size/2, size, size);
    layer.path = [UIBezierPath bezierPathWithOvalInRect:centerRect].CGPath;
    layer.fillColor = trueBlue.CGColor;
}

- (void)animate {
    CABasicAnimation *animation = [self animationWithKeyPath:@"path"];
    [animation setValue:@"grow" forKey:@"id"];
    CGRect encompassingRect = CGRectMake(self.bounds.size.width/2-self.bounds.size.height,
                                         self.bounds.size.height/2-self.bounds.size.height,
                                         self.bounds.size.height*2,
                                         self.bounds.size.height*2);
    animation.toValue = (__bridge id)[UIBezierPath bezierPathWithOvalInRect:CGRectInset(encompassingRect, 4, 4)].CGPath;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.layer addAnimation:animation forKey:animation.keyPath];
}

- (CABasicAnimation *)animationWithKeyPath:(NSString *)keyPath {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;

    animation.autoreverses = NO;
    animation.repeatCount = 0;
    animation.duration = 0.5;
    [animation setDelegate:self];
    return animation;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if([[anim valueForKey:@"id"] isEqualToString:@"grow"] && flag) {
        [UIView animateWithDuration:0.5
                         animations:^{
                             self.alpha = 0;
                         }
                         completion:^(BOOL finished){
                             [self removeFromSuperview];
                         }];
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    UIImage *splashImage = [UIImage imageNamed:@"splash.png"];
    UIImageView *splashView = [[UIImageView alloc] initWithImage: splashImage];
    splashView.contentMode  = UIViewContentModeScaleAspectFit;
    splashView.clipsToBounds = YES;
    [self addSubview:splashView];
}

@end