//
//  Inverter.m
//  Inverter
//
//  Created by dexter0 on 12/16/12.
//
//

#import "Inverter.h"

#import <objc/runtime.h>

static char *iKey = "inverted";

#define CGSWindowID CGSWindow
typedef int CGSConnection;
typedef int CGSWindow;

typedef void *CGSWindowFilterRef;
extern CGError CGSNewCIFilterByName(CGSConnection cid, CFStringRef filterName, CGSWindowFilterRef *outFilter);
extern CGError CGSAddWindowFilter(CGSConnection cid, CGSWindowID wid, CGSWindowFilterRef filter, int flags);
extern CGError CGSRemoveWindowFilter(CGSConnection cid, CGSWindowID wid, CGSWindowFilterRef filter);
extern CGError CGSReleaseCIFilter(CGSConnection cid, CGSWindowFilterRef filter);
extern CGError CGSSetCIFilterValuesFromDictionary(CGSConnection cid, CGSWindowFilterRef filter, CFDictionaryRef filterValues);


@implementation Inverter

+ (void)load
{
    [[Inverter alloc] init];
}

- (id)init
{
    self = [super init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuItemAdded:) name:NSApplicationWillUpdateNotification object:nil];
    [self addMenuItem:nil];
    
    return self;
}

- (void)addMenuItem:(NSNotification*)aNotification
{
    NSApplication *application = [NSApplication sharedApplication];
    NSMenu *windowMenu = [application windowsMenu];
    if (windowMenu) NSLog(@"Got window menu ref.");
    
    if ([windowMenu itemWithTitle:@"Invert"] != nil)
        return;
    
    NSMenuItem *invertItem = [[NSMenuItem alloc] initWithTitle:@"Invert" action:@selector(invertAction:) keyEquivalent:[NSString string]];
    [invertItem setTarget:self];
    [windowMenu insertItem:invertItem atIndex:0];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)invertAction:(id)sender
{
    NSWindow *activeWindow = [[NSApplication sharedApplication] keyWindow];
    if (!activeWindow) return;
    
    CGSConnection thisConnection;
    CGSWindowFilterRef compositingFilter;
    /*
	 Compositing Types
	 Under the window   = 1 <<  0
	 Over the window    = 1 <<  1
	 On the window      = 1 <<  2
	 */
	NSInteger compositingType = 1 << 2; // On the window
    
    compositingFilter = [objc_getAssociatedObject(activeWindow, iKey) pointerValue];
    
    /* Make a new connection to CoreGraphics */
	CGSNewConnection(NULL, &thisConnection);
    
    if (!compositingFilter) {
        /* Create a CoreImage filter and set it up */
        CGSNewCIFilterByName(thisConnection, (CFStringRef)@"CIColorInvert", &compositingFilter);
        CGSSetCIFilterValuesFromDictionary(thisConnection, compositingFilter, NULL);
        /* Now apply the filter to the window */
        CGSAddWindowFilter(thisConnection, (CGSWindowID)[activeWindow windowNumber], compositingFilter, (int)compositingType);
        objc_setAssociatedObject(activeWindow, iKey, [NSValue valueWithPointer:compositingFilter], OBJC_ASSOCIATION_RETAIN);
    } else {
        CGSRemoveWindowFilter(thisConnection, (CGSWindowID)[activeWindow windowNumber], compositingFilter);
        objc_setAssociatedObject(activeWindow, iKey, [NSValue valueWithPointer:NULL], OBJC_ASSOCIATION_RETAIN);
    }
}

@end
