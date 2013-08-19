
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


@interface DrawerContainerController : UIViewController

/*  Threshold in points/sec. at which a pan is interpreted as a swipe, 
    causing the appropriate drawer to snap open or shut.
    Set to 650 points/sec. by default.*/
@property (nonatomic,assign)CGFloat panToSWipeVelocityThreshold;
@property (nonatomic, strong)UIViewController *contentController;
@property (nonatomic, strong)UIViewController *leftDrawerController;
@property (nonatomic, assign)CGFloat leftDrawerControllerMaximumVisibilityFactor;
@property (nonatomic, strong)UIViewController *rightDrawerController;
@property (nonatomic, assign)CGFloat rightDrawerControllerMaximumVisibilityFactor;
@property (nonatomic, assign, readonly)UIViewController *visibleDrawerController;

- (id)initWithContentController:(UIViewController*)contentController;
- (void)toggleVisibilityForDrawerController:(UIViewController*)drawerController completion:(void(^)(void))completionBlock;

@end
