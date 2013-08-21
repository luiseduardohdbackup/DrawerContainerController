
//
//  DrawerContainerController.h
//  https://github.com/saldavonschwartz/DrawerContainerController
//
/*
 The MIT License (MIT)
 
 Copyright (c) 2013 Federico Saldarini
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated documentation files (the "Software"), to deal in
 the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 the Software, and to permit persons to whom the Software is furnished to do so,
 subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */


//  Listen for these notifications to be updated on which drawer is visible or hidden:
extern NSString *const kLeftDrawerWillShowNotification;
extern NSString *const kLeftDrawerDidHideNotification;
extern NSString *const kRightDrawerWillShowNotification;
extern NSString *const kRightDrawerDidHideNotification;


@class DrawerContainerController;

@protocol DrawerContainerControllerDelegate <NSObject>
- (BOOL)DrawerContainerController:(DrawerContainerController*)drawerContainerController shouldBeginTransitionForDrawerController:(UIViewController*)drawerController;
@end


@interface DrawerContainerController : UIViewController

@property (nonatomic, weak)id<DrawerContainerControllerDelegate> delegate;

/*  What percentage of the content view do both gesture-sensitive edges take up.
    i.e.: 0.5 = each edge if 50% of the view, meaning the whole content view is gesture-sensitive.
    Clamped to [0.2 ... 0.5]. Default is 0.35. */
@property (nonatomic, assign)CGFloat gestureSensitiveAreaFactor;

/*  Past what velocity (in points/sec.) is a pan gesture instead interpreted as a swipe.
    If the gesture is recognized as a swipte, the appropriate drawer will toggle fully open/shut regardless
    of the rest of the gesture. Default is 650 points/sec.  */
@property (nonatomic, assign)CGFloat panToSWipeVelocityThreshold;

/*  Visibility factors determine what percentage of each drawer is visible when in its open state.
    i.e.: 0.8 = 80% of a drawer is visible, leaving 20% of the content visible too (necessary for panning, swiping, taping it shut.)
    Clamped to [0 ... 0.8]. Default is 0.8. */
@property (nonatomic, assign)CGFloat leftDrawerControllerMaximumVisibilityFactor;
@property (nonatomic, assign)CGFloat rightDrawerControllerMaximumVisibilityFactor;

@property (nonatomic, strong)UIViewController *contentController;
@property (nonatomic, strong)UIViewController *leftDrawerController;
@property (nonatomic, strong)UIViewController *rightDrawerController;
@property (nonatomic, assign, readonly)UIViewController *visibleDrawerController;

- (id)initWithContentController:(UIViewController*)contentController;
- (void)toggleVisibilityForDrawerController:(UIViewController*)drawerController completion:(void(^)(void))completionBlock;

@end
