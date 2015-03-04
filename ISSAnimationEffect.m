//
//  ISSAnimationEffect.m
//  iTotemFramework
//
//  Created by Rick on 2/20/14.
//  Copyright (c) 2014 iTotemStudio. All rights reserved.
//

#import "ISSAnimationEffect.h"
#import <QuartzCore/QuartzCore.h> 
#import "UIViewController+Animator.h"

#define GHOSTANIMATION_TIME1 0.1
#define GHOSTANIMATION_TIME2 0.20
#define RANDOM_FLOAT(MIN,MAX) (((CGFloat)arc4random() / 0x100000000) * (MAX - MIN) + MIN);
#define OLDPUSHANIMATION_TIME 0.25
#define HLANIMATION_TIME1 0.01
#define HLANIMATION_TIME2 4.70
#define HLINEHEIGHT 4.0
#define VLINEWIDTH 4.0
#define VLANIMATION_TIME1 0.01
#define VLANIMATION_TIME2 4.0

static NSInteger const row = 5;
static NSInteger const column = 5;
@implementation ISSAnimationEffect
{
	NSMutableArray *views;
}
#pragma mark - Custom Animation

+ (void)showAnimationType:(NSString *)type
              withSubType:(NSString *)subType
                 duration:(CFTimeInterval)duration
           timingFunction:(NSString *)timingFunction
                     view:(UIView *)theView
{
    /** CATransition
     *
     *  @see http://www.dreamingwish.com/dream-2012/the-concept-of-coreanimation-programming-guide.html
     *  @see http://geeklu.com/2012/09/animation-in-ios/
     *
     *  CATransition 常用设置及属性注解如下:
     */
    
    CATransition *animation = [CATransition animation];
    
    /** delegate
     *
     *  动画的代理,如果你想在动画开始和结束的时候做一些事,可以设置此属性,它会自动回调两个代理方法.
     *
     *  @see CAAnimationDelegate    (按下command键点击)
     */
    
    animation.delegate = self;
    
    /** duration
     *
     *  动画持续时间
     */
    
    animation.duration = duration;
    
    /** timingFunction
     *
     *  用于变化起点和终点之间的插值计算,形象点说它决定了动画运行的节奏,比如是均匀变化(相同时间变化量相同)还是
     *  先快后慢,先慢后快还是先慢再快再慢.
     *
     *  动画的开始与结束的快慢,有五个预置分别为(下同):
     *  kCAMediaTimingFunctionLinear            线性,即匀速
     *  kCAMediaTimingFunctionEaseIn            先慢后快
     *  kCAMediaTimingFunctionEaseOut           先快后慢
     *  kCAMediaTimingFunctionEaseInEaseOut     先慢后快再慢
     *  kCAMediaTimingFunctionDefault           实际效果是动画中间比较快.
     */
    
    /** timingFunction
     *
     *  当上面的预置不能满足你的需求的时候,你可以使用下面的两个方法来自定义你的timingFunction
     *  具体参见下面的URL
     *
     *  @see http://developer.apple.com/library/ios/#documentation/Cocoa/Reference/CAMediaTimingFunction_class/Introduction/Introduction.html
     *
     *  + (id)functionWithControlPoints:(float)c1x :(float)c1y :(float)c2x :(float)c2y;
     *
     *  - (id)initWithControlPoints:(float)c1x :(float)c1y :(float)c2x :(float)c2y;
     */
    
    animation.timingFunction = [CAMediaTimingFunction functionWithName:timingFunction];
    
    /** fillMode
     *
     *  决定当前对象过了非active时间段的行为,比如动画开始之前,动画结束之后.
     *  预置为:
     *  kCAFillModeRemoved   默认,当动画开始前和动画结束后,动画对layer都没有影响,动画结束后,layer会恢复到之前的状态
     *  kCAFillModeForwards  当动画结束后,layer会一直保持着动画最后的状态
     *  kCAFillModeBackwards 和kCAFillModeForwards相对,具体参考上面的URL
     *  kCAFillModeBoth      kCAFillModeForwards和kCAFillModeBackwards在一起的效果
     */
    
    animation.fillMode = kCAFillModeForwards;
    
    /** removedOnCompletion
     *
     *  这个属性默认为YES.一般情况下,不需要设置这个属性.
     *
     *  但如果是CAAnimation动画,并且需要设置 fillMode 属性,那么需要将 removedOnCompletion 设置为NO,否则
     *  fillMode无效
     */
    
    //    animation.removedOnCompletion = NO;
    
    /** type
     *
     *  各种动画效果  其中除了'fade', `moveIn', `push' , `reveal' ,其他属于似有的API(我是这么认为的,可以点进去看下注释).
     *  ↑↑↑上面四个可以分别使用'kCATransitionFade', 'kCATransitionMoveIn', 'kCATransitionPush', 'kCATransitionReveal'来调用.
     *  @"cube"                     立方体翻滚效果
     *  @"moveIn"                   新视图移到旧视图上面
     *  @"reveal"                   显露效果(将旧视图移开,显示下面的新视图)
     *  @"fade"                     交叉淡化过渡(不支持过渡方向)             (默认为此效果)
     *  @"pageCurl"                 向上翻一页
     *  @"pageUnCurl"               向下翻一页
     *  @"suckEffect"               收缩效果，类似系统最小化窗口时的神奇效果(不支持过渡方向)
     *  @"rippleEffect"             滴水效果,(不支持过渡方向)
     *  @"oglFlip"                  上下左右翻转效果
     *  @"rotate"                   旋转效果
     *  @"push"
     *  @"cameraIrisHollowOpen"     相机镜头打开效果(不支持过渡方向)
     *  @"cameraIrisHollowClose"    相机镜头关上效果(不支持过渡方向)
     */
    
    /** type
     *
     *  kCATransitionFade            交叉淡化过渡
     *  kCATransitionMoveIn          新视图移到旧视图上面
     *  kCATransitionPush            新视图把旧视图推出去
     *  kCATransitionReveal          将旧视图移开,显示下面的新视图
     */
    
    animation.type = type;
    
    /** subtype
     *
     *  各种动画方向
     *
     *  kCATransitionFromRight;      同字面意思(下同)
     *  kCATransitionFromLeft;
     *  kCATransitionFromTop;
     *  kCATransitionFromBottom;
     */
    
    /** subtype
     *
     *  当type为@"rotate"(旋转)的时候,它也有几个对应的subtype,分别为:
     *  90cw    逆时针旋转90°
     *  90ccw   顺时针旋转90°
     *  180cw   逆时针旋转180°
     *  180ccw  顺时针旋转180°
     */
    
    /**
     *  type与subtype的对应关系(必看),如果对应错误,动画不会显现.
     *
     *  @see http://iphonedevwiki.net/index.php/CATransition
     */
    
    animation.subtype = subType;
    
    /**
     *  所有核心动画和特效都是基于CAAnimation,而CAAnimation是作用于CALayer的.所以把动画添加到layer上.
     *  forKey  可以是任意字符串.
     */
    
    [theView.layer addAnimation:animation forKey:nil];
}

#pragma mark - Preset Animation


+ (void)animationRevealFromBottom:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setType:kCATransitionReveal];
    [animation setSubtype:kCATransitionFromBottom];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    
    [view.layer addAnimation:animation forKey:nil];
}

+ (void)animationRevealFromTop:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setType:kCATransitionReveal];
    [animation setSubtype:kCATransitionFromTop];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    
    [view.layer addAnimation:animation forKey:nil];
}

+ (void)animationRevealFromLeft:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setType:kCATransitionReveal];
    [animation setSubtype:kCATransitionFromLeft];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [view.layer addAnimation:animation forKey:nil];
}

+ (void)animationRevealFromRight:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setType:kCATransitionReveal];
    [animation setSubtype:kCATransitionFromRight];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [view.layer addAnimation:animation forKey:nil];
}


+ (void)animationEaseIn:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setType:kCATransitionFade];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    
    [view.layer addAnimation:animation forKey:nil];
}

+ (void)animationEaseOut:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setType:kCATransitionFade];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    
    [view.layer addAnimation:animation forKey:nil];
}


/**
 *  UIViewAnimation
 *
 *  @see    http://www.cocoachina.com/bbs/read.php?tid=110168
 *
 *  @brief  UIView动画应该是最简单便捷创建动画的方式了,详解请猛戳URL.
 *
 *  @method beginAnimations:context 第一个参数用来作为动画的标识,第二个参数给代理代理传递消息.至于为什么一个使用
 *                                  nil而另外一个使用NULL,是因为第一个参数是一个对象指针,而第二个参数是基本数据类型.
 *  @method setAnimationCurve:      设置动画的加速或减速的方式(速度)
 *  @method setAnimationDuration:   动画持续时间
 *  @method setAnimationTransition:forView:cache:   第一个参数定义动画类型，第二个参数是当前视图对象，第三个参数是是否使用缓冲区
 *  @method commitAnimations        动画结束
 */

+ (void)animationFlipFromLeft:(UIView *)view
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.35f];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:view cache:NO];
    [UIView commitAnimations];
}

+ (void)animationFlipFromRigh:(UIView *)view
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.35f];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:view cache:NO];
    [UIView commitAnimations];
}


+ (void)animationCurlUp:(UIView *)view
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:0.35f];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:view cache:NO];
    [UIView commitAnimations];
}

+ (void)animationCurlDown:(UIView *)view
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.35f];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:view cache:NO];
    [UIView commitAnimations];
}

+ (void)animationPushUp:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromTop];
    
    [view.layer addAnimation:animation forKey:nil];
}

+ (void)animationPushDown:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromBottom];
    
    [view.layer addAnimation:animation forKey:nil];
}

+ (void)animationPushLeft:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromLeft];
    
    [view.layer addAnimation:animation forKey:nil];
}

+ (void)animationPushRight:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromRight];
    
    [view.layer addAnimation:animation forKey:nil];
}

// presentModalViewController
+ (void)animationMoveUp:(UIView *)view duration:(CFTimeInterval)duration
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:duration];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setType:kCATransitionMoveIn];
    [animation setSubtype:kCATransitionFromTop];
    
    [view.layer addAnimation:animation forKey:nil];
}

// dissModalViewController
+ (void)animationMoveDown:(UIView *)view duration:(CFTimeInterval)duration
{
    CATransition *transition = [CATransition animation];
    transition.duration =0.4;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromBottom;
    [view.layer addAnimation:transition forKey:nil];
}

+ (void)animationMoveLeft:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setType:kCATransitionMoveIn];
    [animation setSubtype:kCATransitionFromLeft];
    
    [view.layer addAnimation:animation forKey:nil];
}

+ (void)animationMoveRight:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setType:kCATransitionMoveIn];
    [animation setSubtype:kCATransitionFromRight];
    
    [view.layer addAnimation:animation forKey:nil];
}

+(void)animationRotateAndScaleEffects:(UIView *)view
{
    [UIView animateWithDuration:0.35f animations:^
     {
         /**
          *  @see       http://donbe.blog.163.com/blog/static/138048021201061054243442/
          *
          *  @param     transform   形变属性(结构体),可以利用这个属性去对view做一些翻转或者缩放.详解请猛戳↑URL.
          *
          *  @method    valueWithCATransform3D: 此方法需要一个CATransform3D的结构体.一些非详细的讲解可以看下面的URL
          *
          *  @see       http://blog.csdn.net/liubo0_0/article/details/7452166
          *
          */
         
         view.transform = CGAffineTransformMakeScale(0.001, 0.001);
         
         CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
         
         // 向右旋转45°缩小到最小,然后再从小到大推出.
         animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 0.70, 0.40, 0.80)];
         
         /**
          *     其他效果:
          *     从底部向上收缩一半后弹出
          *     animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 0.0, 1.0, 0.0)];
          *
          *     从底部向上完全收缩后弹出
          *     animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 1.0, 0.0, 0.0)];
          *
          *     左旋转45°缩小到最小,然后再从小到大推出.
          *     animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 0.50, -0.50, 0.50)];
          *
          *     旋转180°缩小到最小,然后再从小到大推出.
          *     animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 0.1, 0.2, 0.2)];
          */
         
         animation.duration = 0.45;
         animation.repeatCount = 1;
         [view.layer addAnimation:animation forKey:nil];
         
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:0.35f animations:^
          {
              view.transform = CGAffineTransformMakeScale(1.0, 1.0);
          }];
     }];
}

/** CABasicAnimation
 *
 *  @see https://developer.apple.com/library/mac/#documentation/cocoa/conceptual/CoreAnimation_guide/Articles/KVCAdditions.html
 *
 *  @brief                      便利构造函数 animationWithKeyPath: KeyPath需要一个字符串类型的参数,实际上是一个
 *                              键-值编码协议的扩展,参数必须是CALayer的某一项属性,你的代码会对应的去改变该属性的效果
 *                              具体可以填写什么请参考上面的URL,切勿乱填!
 *                              例如这里填写的是 @"transform.rotation.z" 意思就是围绕z轴旋转,旋转的单位是弧度.
 *                              这个动画的效果是把view旋转到最小,再旋转回来.
 *                              你也可以填写@"opacity" 去修改透明度...以此类推.修改layer的属性,可以用这个类.
 *
 *  @param toValue              动画结束的值.CABasicAnimation自己只有三个属性(都很重要)(其他属性是继承来的),分别为:
 *                              fromValue(开始值), toValue(结束值), byValue(偏移值),
 !                              这三个属性最多只能同时设置两个;
 *                              他们之间的关系如下:
 *                              如果同时设置了fromValue和toValue,那么动画就会从fromValue过渡到toValue;
 *                              如果同时设置了fromValue和byValue,那么动画就会从fromValue过渡到fromValue + byValue;
 *                              如果同时设置了byValue  和toValue,那么动画就会从toValue - byValue过渡到toValue;
 *
 *                              如果只设置了fromValue,那么动画就会从fromValue过渡到当前的value;
 *                              如果只设置了toValue  ,那么动画就会从当前的value过渡到toValue;
 *                              如果只设置了byValue  ,那么动画就会从从当前的value过渡到当前value + byValue.
 *
 *                              可以这么理解,当你设置了三个中的一个或多个,系统就会根据以上规则使用插值算法计算出一个时间差并
 *                              同时开启一个Timer.Timer的间隔也就是这个时间差,通过这个Timer去不停地刷新keyPath的值.
 !                              而实际上,keyPath的值(layer的属性)在动画运行这一过程中,是没有任何变化的,它只是调用了GPU去
 *                              完成这些显示效果而已.
 *                              在这个动画里,是设置了要旋转到的弧度,根据以上规则,动画将会从它当前的弧度专旋转到我设置的弧度.
 *
 *  @param duration             动画持续时间
 *
 *  @param timingFunction       动画起点和终点之间的插值计算,也就是说它决定了动画运行的节奏,是快还是慢,还是先快后慢...
 */

/** CAAnimationGroup
 *
 *  @brief                      顾名思义,这是一个动画组,它允许多个动画组合在一起并行显示.比如这里设置了两个动画,
 *                              把他们加在动画组里,一起显示.例如你有几个动画,在动画执行的过程中需要同时修改动画的某些属性,
 *                              这时候就可以使用CAAnimationGroup.
 *
 *  @param duration             动画持续时间,值得一提的是,如果添加到group里的子动画不设置此属性,group里的duration会统一
 *                              设置动画(包括子动画)的duration属性;但是如果子动画设置了duration属性,那么group的duration属性
 *                              的值不应该小于每个子动画中duration属性的值,否则会造成子动画显示不全就停止了动画.
 *
 *  @param autoreverses         动画完成后自动重新开始,默认为NO.
 *
 *  @param repeatCount          动画重复次数,默认为0.
 *
 *  @param animations           动画组(数组类型),把需要同时运行的动画加到这个数组里.
 *
 *  @note  addAnimation:forKey  这个方法的forKey参数是一个字符串,这个字符串可以随意设置.
 *
 *  @note                       如果你需要在动画group执行结束后保存动画效果的话,设置 fillMode 属性,并且把
 *                              removedOnCompletion 设置为NO;
 */

+ (void)animationRotateAndScaleDownUp:(UIView *)view
{
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:(2 * M_PI) * 2];
    rotationAnimation.duration = 0.35f;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.toValue = [NSNumber numberWithFloat:0.0];
    scaleAnimation.duration = 0.35f;
    scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = 0.35f;
    animationGroup.autoreverses = YES;
    animationGroup.repeatCount = 1;
    animationGroup.animations =[NSArray arrayWithObjects:rotationAnimation, scaleAnimation, nil];
    [view.layer addAnimation:animationGroup forKey:@"animationGroup"];
}



#pragma mark - Private API

+ (void)animationFlipFromTop:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setType:@"oglFlip"];
    [animation setSubtype:@"fromTop"];
    
    [view.layer addAnimation:animation forKey:nil];
}

+ (void)animationFlipFromBottom:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setType:@"oglFlip"];
    [animation setSubtype:@"fromBottom"];
    
    [view.layer addAnimation:animation forKey:nil];
}

+ (void)animationCubeFromLeft:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setType:@"cube"];
    [animation setSubtype:@"fromLeft"];
    
    [view.layer addAnimation:animation forKey:nil];
}

+ (void)animationCubeFromRight:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setType:@"cube"];
    [animation setSubtype:@"fromRight"];
    
    [view.layer addAnimation:animation forKey:nil];
}

+ (void)animationCubeFromTop:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setType:@"cube"];
    [animation setSubtype:@"fromTop"];
    
    [view.layer addAnimation:animation forKey:nil];
}

+ (void)animationCubeFromBottom:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setType:@"cube"];
    [animation setSubtype:@"fromBottom"];
    
    [view.layer addAnimation:animation forKey:nil];
}

+ (void)animationSuckEffect:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setType:@"suckEffect"];
    
    [view.layer addAnimation:animation forKey:nil];
}

+ (void)animationRippleEffect:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setType:@"rippleEffect"];
    
    [view.layer addAnimation:animation forKey:nil];
}

+ (void)animationCameraOpen:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setType:@"cameraIrisHollowOpen"];
    [animation setSubtype:@"fromRight"];
    
    [view.layer addAnimation:animation forKey:nil];
}

+ (void)animationCameraClose:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setType:@"cameraIrisHollowClose"];
    [animation setSubtype:@"fromRight"];
    
    [view.layer addAnimation:animation forKey:nil];
}

/*
 * 适用于iOS 7以及以后的系统
 */


- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    CGFloat time = 0;
    switch (_type) {
        case AnimatorTypeBricks:
        {
            time = 2.0;
        }
            break;
        case AnimatorTypeGhost:
        {
            time = GHOSTANIMATION_TIME1+GHOSTANIMATION_TIME2;
        }
            break;
        case AnimatorTypeHorizontal:
        {
            time = HLANIMATION_TIME1+HLANIMATION_TIME2;
        }
            break;
        case AnimatorTypeVertical:
        {
            time = VLANIMATION_TIME1+VLANIMATION_TIME2;
        }
            break;
        default:
            break;
    }
	return time;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    switch (_type) {
        case AnimatorTypeBricks:
        {
            if (!views) {
                views = [[NSMutableArray alloc] init];
            }
            
            UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
            UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
            UIView *containerView = [transitionContext containerView];
            CGFloat width = containerView.bounds.size.width / row;
            CGFloat height = containerView.bounds.size.height / column;
            NSInteger index = [toVC.view.subviews count];
            for (NSInteger i = 0; i < row; i++) {
                for (NSInteger j = 0; j < column; j++) {
                    CGRect aRect = CGRectMake(j * width, i * height, width, height);
                    UIView *aView = [fromVC.view resizableSnapshotViewFromRect:aRect
                                                            afterScreenUpdates:NO
                                                                 withCapInsets:UIEdgeInsetsZero];
                    aView.frame = aRect;
                    CGFloat angle = ((j + i) % 2 ? 1 : -1) * (rand() % 5 / 10.0);
                    aView.transform = CGAffineTransformMakeRotation(angle);
                    aView.layer.borderWidth = 0.5;
                    aView.layer.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
                    [views addObject:aView];
                    [toVC.view insertSubview:aView atIndex:index];
                }
            }
            [fromVC.view removeFromSuperview];
            [containerView addSubview:toVC.view];
            
            UIDynamicAnimator *animator = [[UIDynamicAnimator alloc] initWithReferenceView:toVC.view];
            UIDynamicBehavior *behaviour = [[UIDynamicBehavior alloc] init];
            UIGravityBehavior *gravityBehaviour = [[UIGravityBehavior alloc] initWithItems:views];
            UICollisionBehavior *collisionBehavior = [[UICollisionBehavior alloc] initWithItems:views];
            collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
            collisionBehavior.collisionMode = UICollisionBehaviorModeBoundaries;
            
            [behaviour addChildBehavior:gravityBehaviour];
            [behaviour addChildBehavior:collisionBehavior];
            
            for (UIView *aView in views) {
                UIDynamicItemBehavior *itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[aView]];
                itemBehaviour.elasticity = (rand() % 5) / 8.0;
                itemBehaviour.density = (rand() % 5 / 3.0);
                //		itemBehaviour.allowsRotation = YES;
                [behaviour addChildBehavior:itemBehaviour];
            }
            
            [animator addBehavior:behaviour];
            toVC.animator = animator;
            
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                for (UIView *aView in views) {
                    aView.alpha = 0.0;
                }
            } completion:^(BOOL finished) {
                for (UIView *view in views) {
                    [view removeFromSuperview];
                }
                [views removeAllObjects];
                [transitionContext completeTransition:YES];
            }];
        }
            break;
        case AnimatorTypeGhost:
        {
            UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
            UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
            
            CGRect endFrame = [transitionContext initialFrameForViewController:fromVC];
            
            
            
            if (self.presenting) {
                
                //lets get a snapshot of the outgoing view
                UIView *ghost = [fromVC.view snapshotViewAfterScreenUpdates:NO];
                
                //get the container view
                UIView *containerView = [transitionContext containerView];
                
                //put the ghost in the container
                [containerView addSubview:ghost];
                
                fromVC.view.frame = endFrame;
                [transitionContext.containerView addSubview:fromVC.view];
                
                UIView *toView = [toVC view];
                [transitionContext.containerView addSubview:toView];
                
                //get the original position of the frame
                CGRect startFrame = toView.frame;
                //save the unmodified frame as our end frame
                endFrame = startFrame;
                
                //now move the start frame to the left by our width
                startFrame.origin.x += CGRectGetWidth(startFrame);
                toView.frame = startFrame;
                
                //now set up the destination for the outgoing view
                UIView *fromView = [fromVC view];
                CGRect outgoingEndFrame = fromView.frame;
                outgoingEndFrame.origin.x -= CGRectGetWidth(outgoingEndFrame);
                
                [UIView animateKeyframesWithDuration:GHOSTANIMATION_TIME1 delay:0 options:UIViewKeyframeAnimationOptionBeginFromCurrentState animations:^{
                    CGRect ghostRect = ghost.frame;
                    ghostRect.origin.x += 25;
                    
                    [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.3 animations:^{
                        ghost.frame = ghostRect;
                    }];
                    ghostRect.origin.x -= 100;
                    [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.7 animations:^{
                        ghost.frame = ghostRect;
                    }];
                    
                    ghost.alpha = 0;
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:GHOSTANIMATION_TIME2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                        toView.frame = endFrame;
                        toView.alpha = 1;
                        fromView.frame = outgoingEndFrame;
                        fromView.alpha = 0;
                    } completion:^(BOOL finished) {
                        fromView.alpha = 1;
                        [toView setNeedsUpdateConstraints];
                        [transitionContext completeTransition:YES];
                        
                    }];
                }];
            }
            else {
                UIView *toView = [toVC view];
                
                //incoming view
                CGRect toFrame = endFrame;
                toFrame.origin.x -= CGRectGetWidth(toFrame);
                toView.frame = toFrame;
                toFrame = endFrame;
                
                [transitionContext.containerView addSubview:toView];
                [transitionContext.containerView addSubview:fromVC.view];
                
                //outgoing view
                endFrame.origin.x += CGRectGetWidth(endFrame);
                
                
                [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    toView.frame = toFrame;
                    toView.alpha = 1;
                    fromVC.view.frame = endFrame;
                    fromVC.view.alpha = 0;
                } completion:^(BOOL finished) {
                    fromVC.view.alpha = 1;
                    [transitionContext completeTransition:YES];
                }];
            }
        }
            break;
        case AnimatorTypeHorizontal:
        {
            UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
            UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
            
            //get the container view
            UIView *containerView = [transitionContext containerView];
            
            //lets get a snapshot of the outgoing view
            UIView *mainSnap = [fromVC.view snapshotViewAfterScreenUpdates:NO];
            //cut it into vertical slices
            NSArray *outgoingLineViews = [self cutView:mainSnap intoSlicesOfHeight:HLINEHEIGHT yOffset:fromVC.view.frame.origin.y];
            
            //add the slices to the content view.
            for (UIView *v in outgoingLineViews) {
                [containerView addSubview:v];
            }
            
            
            UIView *toView = [toVC view];
            toView.frame = [transitionContext finalFrameForViewController:toVC];
            [containerView addSubview:toView];
            
            
            CGFloat toViewStartX = toView.frame.origin.x;
            toView.alpha = 0;
            fromVC.view.hidden = YES;
            
            BOOL presenting = self.presenting;
            
            [UIView animateWithDuration:HLANIMATION_TIME1 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                //This is basically a hack to get the incoming view to render before I snapshot it.
            } completion:^(BOOL finished) {
                
                toVC.view.alpha = 1;
                UIView *mainInSnap = [toView snapshotViewAfterScreenUpdates:YES];
                //cut it into vertical slices
                NSArray *incomingLineViews = [self cutView:mainInSnap intoSlicesOfHeight:HLINEHEIGHT yOffset:toView.frame.origin.y];
                
                //move the slices in to start position (incoming comes from the right)
                [self repositionViewSlices:incomingLineViews moveLeft:!presenting];
                
                //add the slices to the content view.
                for (UIView *v in incomingLineViews) {
                    [containerView addSubview:v];
                }
                toView.hidden = YES;
                
                [UIView animateWithDuration:HLANIMATION_TIME2 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    [self repositionViewSlices:outgoingLineViews moveLeft:presenting];
                    [self resetViewSlices:incomingLineViews toXOrigin:toViewStartX];
                } completion:^(BOOL finished) {
                    fromVC.view.hidden = NO;
                    toView.hidden = NO;
                    [toView setNeedsUpdateConstraints];
                    for (UIView *v in incomingLineViews) {
                        [v removeFromSuperview];
                    }
                    for (UIView *v in outgoingLineViews) {
                        [v removeFromSuperview];
                    }
                    [transitionContext completeTransition:YES];
                }];
                
            }];
        }
            break;
        case AnimatorTypeVertical:
        {
            UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
            UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
            
            //get the container view
            UIView *containerView = [transitionContext containerView];
            
            //lets get a snapshot of the outgoing view
            UIView *mainSnap = [fromVC.view snapshotViewAfterScreenUpdates:NO];
            //cut it into vertical slices
            NSArray *outgoingLineViews = [self cutView:mainSnap intoSlicesOfWidth:VLINEWIDTH];
            
            //add the slices to the content view.
            for (UIView *v in outgoingLineViews) {
                [containerView addSubview:v];
            }
            
            
            UIView *toView = [toVC view];
            toView.frame = [transitionContext finalFrameForViewController:toVC];
            [containerView addSubview:toView];
            
            
            CGFloat toViewStartY = toView.frame.origin.y;
            toView.alpha = 0;
            fromVC.view.hidden = YES;
            
            
            [UIView animateWithDuration:VLANIMATION_TIME1 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                //This is basically a hack to get the incoming view to render before I snapshot it.
            } completion:^(BOOL finished) {
                
                toVC.view.alpha = 1;
                UIView *mainInSnap = [toView snapshotViewAfterScreenUpdates:YES];
                //cut it into vertical slices
                NSArray *incomingLineViews = [self cutView:mainInSnap intoSlicesOfWidth:VLINEWIDTH];
                
                //move the slices in to start position (mess them up)
                [self repositionViewSlices:incomingLineViews moveFirstFrameUp:NO];
                
                //add the slices to the content view.
                for (UIView *v in incomingLineViews) {
                    [containerView addSubview:v];
                }
                toView.hidden = YES;
                
                [UIView animateWithDuration:VLANIMATION_TIME2 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    [self repositionViewSlices:outgoingLineViews moveFirstFrameUp:YES];
                    [self resetViewSlices:incomingLineViews toYOrigin:toViewStartY];
                } completion:^(BOOL finished) {
                    fromVC.view.hidden = NO;
                    toView.hidden = NO;
                    [toView setNeedsUpdateConstraints];
                    for (UIView *v in incomingLineViews) {
                        [v removeFromSuperview];
                    }
                    for (UIView *v in outgoingLineViews) {
                        [v removeFromSuperview];
                    }
                    [transitionContext completeTransition:YES];
                }];
                
            }];
        }
            break;
        default:
            break;
    }
    
	
}

/**
 cuts a \a view into an array of smaller views of \a height
 @param view the view to be sliced up
 @param height The height of each slice
 @returns A mutable array of the sliced views with their frames representative of their position in the sliced view.
 */
-(NSMutableArray *)cutView:(UIView *)view intoSlicesOfHeight:(float)height yOffset:(float)yOffset{
    
    CGFloat lineWidth = CGRectGetWidth(view.frame);
    
    NSMutableArray *lineViews = [NSMutableArray array];
    
    for (int y=0; y<CGRectGetHeight(view.frame); y+=height) {
        CGRect subrect = CGRectMake(0, y, lineWidth, height);
        
        
        UIView *subsnapshot;
        subsnapshot = [view resizableSnapshotViewFromRect:subrect afterScreenUpdates:NO withCapInsets:UIEdgeInsetsZero];
        subrect.origin.y += yOffset;
        subsnapshot.frame = subrect;
        
        [lineViews addObject:subsnapshot];
    }
    return lineViews;
    
}

/**
 repositions an array of \a views to the left or right by their frames width
 @param views The array of views to reposition
 @param left should the frames be moved to the left
 */
-(void)repositionViewSlices:(NSArray *)views moveLeft:(BOOL)left{
    CGRect frame;
    float width;
    for (UIView *line in views) {
        frame = line.frame;
        width = CGRectGetWidth(frame) * RANDOM_FLOAT(1.0, 8.0);
        
        frame.origin.x += (left)?-width:width;
        
        //save the new position
        line.frame = frame;
    }
}

/**
 resets the views back to a specified x origin.
 @param views The array of uiview objects to reposition
 @param x The x origin to set all the views frames to.
 */
-(void)resetViewSlices:(NSArray *)views toXOrigin:(CGFloat)x{
    
    CGRect frame;
    for (UIView *line in views) {
        frame = line.frame;
        
        frame.origin.x = x;
        
        //save the new position
        line.frame = frame;
        
    }
}

/**
 cuts a \a view into an array of smaller views of \a width
 @param view the view to be sliced up
 @param width The width of each slice
 @returns A mutable array of the sliced views with their frames representative of their position in the sliced view.
 */
-(NSMutableArray *)cutView:(UIView *)view intoSlicesOfWidth:(float)width{
    
    CGFloat lineHeight = CGRectGetHeight(view.frame);
    
    NSMutableArray *lineViews = [NSMutableArray array];
    
    for (int x=0; x<CGRectGetWidth(view.frame); x+=width) {
        CGRect subrect = CGRectMake(x, 0, width, lineHeight);
        
        
        UIView *subsnapshot;
        subsnapshot = [view resizableSnapshotViewFromRect:subrect afterScreenUpdates:NO withCapInsets:UIEdgeInsetsZero];
        subsnapshot.frame = subrect;
        
        [lineViews addObject:subsnapshot];
    }
    return lineViews;
    
}

/**
 repositions an array of \a views alternatively up and down by their frames height
 @param views The array of views to reposition
 @param startUp start with the first view moving up (YES) or down (NO)
 */
-(void)repositionViewSlices:(NSArray *)views moveFirstFrameUp:(BOOL)startUp{
    
    BOOL up = startUp;
    CGRect frame;
    float height;
    for (UIView *line in views) {
        frame = line.frame;
        height = CGRectGetHeight(frame) * RANDOM_FLOAT(1.0, 4.0);
        
        frame.origin.y += (up)?-height:height;
        
        //save the new position
        line.frame = frame;
        
        up = !up;
    }
}
/**
 resets the views back to a specified y origin.
 @param views The array of uiview objects to reposition
 @param y The y origin to set all the views frames to.
 */
-(void)resetViewSlices:(NSArray *)views toYOrigin:(CGFloat)y{
    
    CGRect frame;
    for (UIView *line in views) {
        frame = line.frame;
        
        frame.origin.y = y;
        
        //save the new position
        line.frame = frame;
        
    }
}

@end
