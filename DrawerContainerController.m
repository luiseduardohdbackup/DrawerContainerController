
//
//  DrawerContainerController.m
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


#import "DrawerContainerController.h"
#import <QuartzCore/QuartzCore.h>


//------------------------------------------------------------------------------------------------------------------------------------------

NSString *const kLeftDrawerWillShowNotification = @"kLeftDrawerWillShowNotification";
NSString *const kLeftDrawerDidHideNotification = @"kLeftDrawerDidHideNotification";
NSString *const kRightDrawerWillShowNotification = @"kRightDrawerWillShowNotification";
NSString *const kRightDrawerDidHideNotification = @"kRightDrawerDidHideNotification";

typedef enum {
    ControllerIdentifierLeft,
    ControllerIdentifierRight,
    ControllerIdentifierContent
} ControllerIdentifier;


@interface ControllerContainer : NSObject
@property (nonatomic, strong)UIViewController *controller;
@property (nonatomic, assign)CGFloat maximumVisibilityFactor;
@property (nonatomic, assign)NSString *showNotification;
@property (nonatomic, assign)NSString *hideNotification;

@end

@implementation ControllerContainer;
@end

//------------------------------------------------------------------------------------------------------------------------------------------

@interface DrawerContainerController ()

- (void)replaceContainedController:(UIViewController *)newViewController forIdentifier:(ControllerIdentifier)identifier;
- (void)translateContentContainerViewToPosition:(CGFloat)toPosition animated:(BOOL)animated completion:(void(^)(void))completionBlock;
- (void)didTapContent:(UIGestureRecognizer *)recognizer;
- (void)didPanContent:(UIPanGestureRecognizer *)recognizer;

@end


//------------------------------------------------------------------------------------------------------------------------------------------

@implementation DrawerContainerController
{
    NSMutableArray *_containedControllers;
    UITapGestureRecognizer *_tapContentRecognizer;
    UIPanGestureRecognizer *_panContentRecognizer;
    UIView *_contentContainerView;
    ControllerIdentifier _visibleControllerIdentifier;
    GLfloat _maximumXOffsetAllowedForCurrentDrawer;
    GLfloat _lastXToPosition;
    BOOL _contentAnimationInProgress;
}

@dynamic contentController;
@dynamic leftDrawerController;
@dynamic rightDrawerController;
@dynamic leftDrawerControllerMaximumVisibilityFactor;
@dynamic rightDrawerControllerMaximumVisibilityFactor;

#pragma mark - Lifecycle

- (id)initWithContentController:(UIViewController *)contentController
{
    self = [super init];
    if (self) {
        self.contentController = contentController;
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        _panToSWipeVelocityThreshold = 650.f;
        _visibleControllerIdentifier = ControllerIdentifierContent;
        _containedControllers = @[[[ControllerContainer alloc] init],
                                  [[ControllerContainer alloc] init],
                                  [[ControllerContainer alloc] init]].mutableCopy;

        [_containedControllers[ControllerIdentifierLeft] setShowNotification:kLeftDrawerWillShowNotification];
        [_containedControllers[ControllerIdentifierLeft] setHideNotification:kLeftDrawerDidHideNotification];
        [_containedControllers[ControllerIdentifierLeft] setMaximumVisibilityFactor:.8f];

        [_containedControllers[ControllerIdentifierRight] setShowNotification:kRightDrawerWillShowNotification];
        [_containedControllers[ControllerIdentifierRight] setHideNotification:kRightDrawerDidHideNotification];
        [_containedControllers[ControllerIdentifierRight] setMaximumVisibilityFactor:-.8f];
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _contentContainerView = [[UIView alloc] initWithFrame:self.view.bounds];
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:_contentContainerView.bounds];
    _contentContainerView.layer.shadowPath = path.CGPath;
    _contentContainerView.layer.shadowRadius = 5.f;
    _contentContainerView.layer.shadowOpacity = 0.5f;
    
    _panContentRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanContent:)];
    [_contentContainerView addGestureRecognizer:_panContentRecognizer];
    
    _tapContentRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapContent:)];
    _tapContentRecognizer.enabled = NO;
    [_contentContainerView addGestureRecognizer:_tapContentRecognizer];
    
    [self.view addSubview:_contentContainerView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSAssert([_containedControllers[ControllerIdentifierContent] controller], @"property 'hostController' must be set by the time DrawerNavigationController is displayed");
}


#pragma mark - Public Interface

- (UIViewController *)leftDrawerController
{
    return [_containedControllers[ControllerIdentifierLeft] controller];
}

- (void)setLeftDrawerController:(UIViewController *)leftDrawerController
{
    [self replaceContainedController:leftDrawerController forIdentifier:ControllerIdentifierLeft];
}

- (CGFloat)leftDrawerControllerMaximumVisibilityFactor
{
    return [_containedControllers[ControllerIdentifierLeft] maximumVisibilityFactor];
}

- (void)setLeftDrawerControllerMaximumVisibilityFactor:(CGFloat)leftDrawerControllerMaximumVisibilityFactor
{
    CGFloat clampedFactor = MIN(MAX(0.f, leftDrawerControllerMaximumVisibilityFactor), .8f);
    [_containedControllers[ControllerIdentifierLeft] setMaximumVisibilityFactor:clampedFactor];
}

- (CGFloat)RightDrawerControllerMaximumVisibilityFactor
{
    return [_containedControllers[ControllerIdentifierRight] maximumVisibilityFactor];
}

- (void)setRightDrawerControllerMaximumVisibilityFactor:(CGFloat)rightDrawerControllerMaximumVisibilityFactor
{
    CGFloat clampedFactor = MIN(MAX(0.f, rightDrawerControllerMaximumVisibilityFactor), .8f);
    [_containedControllers[ControllerIdentifierRight] setMaximumVisibilityFactor:-clampedFactor];
}

- (UIViewController *)rightDrawerController
{
    return [_containedControllers[ControllerIdentifierRight] controller];
}

- (void)setRightDrawerController:(UIViewController *)rightDrawerController
{
    [self replaceContainedController:rightDrawerController forIdentifier:ControllerIdentifierRight];
}

- (UIViewController *)contentController
{
    return [_containedControllers[ControllerIdentifierContent] controller];
}

- (void)setContentController:(UIViewController *)contentController
{
    [self replaceContainedController:contentController forIdentifier:ControllerIdentifierContent];
}

- (void)toggleVisibilityForDrawerController:(UIViewController *)drawerController completion:(void (^)(void))completionBlock
{
    NSAssert(drawerController && (drawerController == self.leftDrawerController || drawerController == self.rightDrawerController),
             @"%@ must only be invoked for the left or right drawer controllers.", NSStringFromSelector(_cmd));
    if (!_contentAnimationInProgress) {
        void (^toggleDrawer)() = ^{
            if (drawerController == self.leftDrawerController) {
                [self translateContentContainerViewToPosition:self.view.frame.size.width * [_containedControllers[ControllerIdentifierLeft] maximumVisibilityFactor]
                                                     animated:YES
                                                   completion:completionBlock];
            }
            else {
                [self translateContentContainerViewToPosition:self.view.frame.size.width * [_containedControllers[ControllerIdentifierRight] maximumVisibilityFactor]
                                                     animated:YES
                                                   completion:completionBlock];
            }
        };
        
        if (_visibleDrawerController) {
            UIViewController *lastVisibleController = _visibleDrawerController;
            [self translateContentContainerViewToPosition:0.f animated:YES completion:^{
                if (lastVisibleController != drawerController) {
                    toggleDrawer();
                }
            }];
        }
        else {
            toggleDrawer();
        }
    }
}


#pragma mark - Private Interface

- (void)replaceContainedController:(UIViewController *)newViewController forIdentifier:(ControllerIdentifier)identifier
{
    UIViewController *previousViewController = [_containedControllers[identifier] controller];
    if (previousViewController) {
        [previousViewController willMoveToParentViewController:nil];
        [previousViewController.view removeFromSuperview];
        [previousViewController removeFromParentViewController];
    }
    
    [_containedControllers[identifier] setController:newViewController];
    if (newViewController) {
        [self addChildViewController:newViewController];
        newViewController.view.frame = self.view.bounds;
        
        switch (identifier) {
            case ControllerIdentifierLeft:
            case ControllerIdentifierRight: {
                [self.view insertSubview:newViewController.view belowSubview:self.view.subviews.lastObject];
                newViewController.view.hidden = YES;
                break;
            }
                
            case ControllerIdentifierContent: {
                [_contentContainerView addSubview:newViewController.view];
                break;
            }
        }
        
        [newViewController didMoveToParentViewController:self];
    }
}

- (void)translateContentContainerViewToPosition:(CGFloat)toPosition animated:(BOOL)animated completion:(void(^)(void))completionBlock
{
    if (toPosition) {
        ControllerIdentifier visibleDrawer = (ControllerIdentifier)(((NSInteger)(ABS(toPosition) / -toPosition) + 1) / 2);
        ControllerIdentifier hiddenDrawer = visibleDrawer == ControllerIdentifierLeft ? ControllerIdentifierRight : ControllerIdentifierLeft;
        if ([[_containedControllers[visibleDrawer] controller] view].hidden) {
            if ([_containedControllers[hiddenDrawer] controller] && ![[_containedControllers[hiddenDrawer] controller] view].hidden) {
                [[_containedControllers[hiddenDrawer] controller] view].hidden = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:[_containedControllers[hiddenDrawer] hideNotification] object:self];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:[_containedControllers[visibleDrawer] showNotification] object:self];
            [[_containedControllers[visibleDrawer] controller] view].hidden = NO;
        }
        
        _lastXToPosition = toPosition;
        _visibleDrawerController = [_containedControllers[visibleDrawer] controller];
        _visibleControllerIdentifier = visibleDrawer;
    }
    
    CGRect toFrame = _contentContainerView.frame;
    toFrame.origin.x = toPosition;
    _panContentRecognizer.enabled = !animated;
    _contentAnimationInProgress = animated;
    [UIView animateWithDuration:animated ? .15f : 0.f animations:^{
        _contentContainerView.frame = toFrame;
    } completion:^(BOOL finished) {
        if (!toPosition) {
            [[_containedControllers[_visibleControllerIdentifier] controller] view].hidden = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:[_containedControllers[_visibleControllerIdentifier] hideNotification] object:self];
            
            _lastXToPosition = toPosition;
            [[_containedControllers[ControllerIdentifierContent] controller] view].userInteractionEnabled = YES;
            _tapContentRecognizer.enabled = NO;
        }
        else if (toPosition == _maximumXOffsetAllowedForCurrentDrawer) {
            [[_containedControllers[ControllerIdentifierContent] controller] view].userInteractionEnabled = NO;
            _tapContentRecognizer.enabled = YES;
        }
        
        _panContentRecognizer.enabled = YES;
        _contentAnimationInProgress = NO;
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (void)didTapContent:(UIGestureRecognizer *)recognizer
{
    [self translateContentContainerViewToPosition:0 animated:YES completion:nil];
}

- (void)didPanContent:(UIPanGestureRecognizer *)recognizer
{
    static BOOL canInterpretPanAsSwipe = YES;
    static BOOL shouldContinue = YES;
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateChanged: {
            CGFloat xOffset = _contentContainerView.frame.origin.x + [recognizer translationInView:recognizer.view].x;
            if (!xOffset) {
                break;
            }
            
            ControllerIdentifier identifier = (ControllerIdentifier)(((NSInteger)(ABS(xOffset) / -xOffset) + 1) / 2);
            if (shouldContinue) {
                if (canInterpretPanAsSwipe) {
                    shouldContinue = !self.delegate || [self.delegate DrawerContainerController:self shouldPanOrSwipeForDrawerControllerType:(DrawerControllerType)identifier];
                    if (!shouldContinue) {
                        break;
                    }
                }
                
                if ([_containedControllers[identifier] controller]) {
                    shouldContinue = YES;
                    _maximumXOffsetAllowedForCurrentDrawer = self.view.frame.size.width * [_containedControllers[identifier] maximumVisibilityFactor];
                    CGFloat finalXOffset = _maximumXOffsetAllowedForCurrentDrawer;
                    
                    if (canInterpretPanAsSwipe && ABS([recognizer velocityInView:recognizer.view].x) > _panToSWipeVelocityThreshold) {
                        if (ABS(xOffset) < ABS(_lastXToPosition)) {
                            finalXOffset = 0.f;
                        }
                        [self translateContentContainerViewToPosition:finalXOffset animated:YES completion:nil];
                        break;
                    }
                    else {
                        canInterpretPanAsSwipe = NO;
                        if (ABS(xOffset) < ABS(_maximumXOffsetAllowedForCurrentDrawer)) {
                            finalXOffset = xOffset;
                        }
                        
                        [self translateContentContainerViewToPosition:finalXOffset animated:NO completion:nil];
                        [recognizer setTranslation:CGPointZero inView:recognizer.view];
                    }
                }
                else {
                    shouldContinue = NO;
                }
            }
            
            break;
        }
            
        case UIGestureRecognizerStateEnded: {
            if (shouldContinue) {
                CGFloat absoluteContentXPosition = ABS(_contentContainerView.frame.origin.x);
                CGFloat absoluteMaxiumXOffsetAllowedForCurrentDrawer = ABS(_maximumXOffsetAllowedForCurrentDrawer);
                if (absoluteContentXPosition < absoluteMaxiumXOffsetAllowedForCurrentDrawer / 2.f) {
                    [self translateContentContainerViewToPosition:0.f
                                                         animated:(BOOL)absoluteContentXPosition
                                                       completion:^{canInterpretPanAsSwipe = YES; shouldContinue = YES;}];
                }
                else {
                    [self translateContentContainerViewToPosition:_maximumXOffsetAllowedForCurrentDrawer
                                                         animated:(absoluteContentXPosition != absoluteMaxiumXOffsetAllowedForCurrentDrawer)
                                                       completion:^{canInterpretPanAsSwipe = YES; shouldContinue = YES;}];
                }
            }
            else {
                canInterpretPanAsSwipe = YES;
                shouldContinue = YES;
            }
            
            break;
        }
            
        default: {
            return;
        }
    }
}

@end
