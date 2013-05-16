//
//  NSWindow+Invert.m
//  Inverter
//
//  Created by NSDex on 5/15/13.
//
//

#import "NSWindow+Invert.h"
#import "Inverter.h"

static char const * const Key = "WindowHelper";


@interface WindowHelper : NSObject {
@public
    NSWindow *_window;
    CGSWindowFilterRef _invertFilter;
}
+ (instancetype)windowHelperForWindow:(NSWindow*)window;
@end
@implementation WindowHelper
+ (instancetype)windowHelperForWindow:(NSWindow*)window
{
    WindowHelper *ret = objc_getAssociatedObject(window, Key);
    if (!ret) {
        ret = [[WindowHelper alloc] init];
        ret->_window = window;
        objc_setAssociatedObject(window, Key, ret, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return ret;
}
- (void)dealloc
{
    // Cleanup Invert Filter
    if (_invertFilter)
        CGSRemoveWindowFilter([Inverter sharedInstance].serverConnection, (CGSWindowID)[_window windowNumber], _invertFilter);
    
    [super dealloc];
}
@end



@implementation NSWindow (Invert)

- (BOOL)isInverted
{ return [WindowHelper windowHelperForWindow:self]->_invertFilter != NULL; }
- (void)setInverted:(BOOL)inverted
{
    CGSConnection connection = [Inverter sharedInstance].serverConnection;
    WindowHelper *helper = [WindowHelper windowHelperForWindow:self];
    
    /*
	 Compositing Types
	 Under the window   = 1 <<  0
	 Over the window    = 1 <<  1
	 On the window      = 1 <<  2
	 */
	NSInteger compositingType = 1 << 2; // On the window
    
    if (inverted && helper->_invertFilter == NULL) {
        DLog(@"+++ Inverter[%@]: Applying invert filter to window %li", [Inverter sharedInstance].appName, (long)[self windowNumber]);
        // Create a CoreImage filter and set it up
        CGSNewCIFilterByName(connection, (CFStringRef)@"CIColorInvert", &helper->_invertFilter);
        
        NSDictionary *options = [NSDictionary dictionary];
        CGSSetCIFilterValuesFromDictionary(connection, helper->_invertFilter, (CFDictionaryRef)options);
        
        // Now apply the filter to the window
        CGSAddWindowFilter(connection, (CGSWindowID)[self windowNumber], helper->_invertFilter, (int)compositingType);
    } else if (!inverted && helper->_invertFilter != NULL) {
        DLog(@"+++ Inverter[%@]: Removing invert filter to window %li", [Inverter sharedInstance].appName, (long)[self windowNumber]);
        CGSRemoveWindowFilter(connection, (CGSWindowID)[self windowNumber], helper->_invertFilter);
        helper->_invertFilter = NULL;
    }
}

@end
