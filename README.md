DrawerContainerController
=========================
A Container View Controller along the lines of the View Controller Programming Guide for iOS. 

Features
========

- Left and right drawers each with adjustable percentage of visibility.
- Adjustable velocity threshold (in points/ sec.) to switch from panning to swiping.
- Possibility to continuously pan from one drawer to the next (which might not be very useful, but hey, it's free).
- Notifications to signal each time a drawer becomes visible / hidden.
- Open drawers by 
  - panning
  - swiping
  - calling a toggle method
- Close drawers by:
  - panning
  - swiping
  - tapping
  - calling a toggle method

Usage
=====

1. **Alloc an instance of `DrawerContainerController` (if initializing with `- initWithContentController:` skip to step 3.)**
2. **Mandatory:** Assign a content view controller to the `contentController` property. This will be your main content (i.e.: UINavigationController,etc.). Note that in **DEBUG** builds, the container controller will throw an exception if a content view controller is not present by the time the container's view will appear.
3. **Optional:** Assign left / right drawers' view controllers to `leftDrawerController` and/or `rightDrawerController` (if you assign neither you are doing it wrong.)
4. **Optional:** Assign left / right drawers' visibility factors `leftDrawerControllerMaximumVisibilityFactor` and/or `rightDrawerControllerMaximumVisibilityFactor`. Values will be clamped to the range 0 ... 0.8 (the default is .8), where 0 means a drawer is 0% visible (hidden) and .8 means it's 80% visible.
5. **Optional:** Assign a velocity threshold to `panToSWipeVelocityThreshold` (in points/sec.) past which, the container controller will interpret a pan as a swipe. Swiping implies the drawer will animate fully open or shut, regardless of the rest of the gesture that triggered it. The default is 650 points/sec.
6. **Optional:** Register to receive notifications. These are sent every time a drawer controller becomes visible / hidden:
  - kLeftDrawerWillShowNotification
  - kLeftDrawerDidHideNotification
  - kRightDrawerWillShowNotification
  - kRightDrawerDidHideNotification
7. **Optional:** If you want to programatically toggle a drawer open / shut, you can do so by calling `-toggleVisibilityForDrawerController:completion:`. The method takes either of the drawer controllers and an optional completion block.
8. **Optional:** If you need to know which controller is visible at any time, query `visibleDrawerController`. Alternatively, you can query each drawer controller's `view.hidden` property.
