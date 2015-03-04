//
//  UIViewController+Animator.m
//  iTotemFramework
//
//  Created by Rick on 2/20/14.
//  Copyright (c) 2014 iTotemStudio. All rights reserved.
//

#import "UIViewController+Animator.h"
#import <objc/runtime.h>

@implementation UIViewController (Animator)
- (id)animator
{
	return objc_getAssociatedObject(self, "animator");
}

- (void)setAnimator:(id)animator
{
	objc_setAssociatedObject(self, "animator", animator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
