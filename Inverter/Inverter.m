//
//  Inverter.m
//  Inverter
//
//  Created by NSDex on 12/16/12.
//
//

#import "Inverter.h"
#import "NSWindow+Invert.h"

@implementation Inverter

@synthesize appName = _appName;
@synthesize serverConnection = _serverConnection;

+ (void)load
{
    [Inverter sharedInstance];
}

+ (instancetype)sharedInstance
{
    static Inverter *SharedInstance = NULL;
    if (SharedInstance == NULL)
        SharedInstance = [[Inverter alloc] init];
    return SharedInstance;
}

- (id)init
{
    self = [super init];
    
    // Get the app name
    _appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    // Make a new connection to CoreGraphics
	_serverConnection = _CGSDefaultConnection();
    if (!_serverConnection) {
        NSLog(@"+++ Inverter[%@]: Failed to connect to the WindowServer.", _appName);
        return nil;
    }
    
    // Unpack our menu items
    NSNib *menuItemXib = [[NSNib alloc] initWithNibNamed:@"MenuItems" bundle:[NSBundle bundleForClass:object_getClass(self)]];
    [menuItemXib instantiateNibWithOwner:self topLevelObjects:NULL];
    [menuItemXib release];
    if (!_invertMenuItem || !_invertOptionsMenuItem) {
        NSLog(@"+++ Inverter[%@]: Failed to load resources.", _appName);
        return nil;
    }
    
    // Try the menu injection now
    if ([self attemptMenuItemInjection] == NO) {
        [[NSNotificationCenter defaultCenter] addObserverForName:NSMenuDidAddItemNotification
                                                          object:[[NSApplication sharedApplication] menu]
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *note) {
            if ([self attemptMenuItemInjection])
                [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMenuDidAddItemNotification object:[[NSApplication sharedApplication] menu]];
        }];
    }
    
    return self;
}

#pragma mark - 
#pragma mark Menu Hacking
#pragma mark - 

- (BOOL)attemptMenuItemInjection
{
    DLog(@"+++ Inverter[%@]: Attempting Menu Injection...", _appName);
    NSMenu *windowMenu = nil;
    
    // Try and grab the Window menu directly
    windowMenu = [[NSApplication sharedApplication] windowsMenu];
    if (!windowMenu) {
        NSMenu *menuBar = [[NSApplication sharedApplication] menu];
        windowMenu = [[menuBar itemWithTitle:@"Window"] submenu];
        if (!windowMenu)
            return NO;
    }
    
    if (windowMenu.numberOfItems < 1)
        return NO;
    // This method may be called twice before we can unregister for the NSMenuDidAddItemNotification
    // so we must make sure we never add _invertMenuItem to a menu twice.
    if (_invertMenuItem.menu)
        return NO;

    // Add Menu Items
    //[windowMenu insertItem:_invertOptionsMenuItem atIndex:0];
    [windowMenu insertItem:_invertMenuItem atIndex:0];
    
    DLog(@"+++ Inverter[%@]: Success.", _appName);
    return YES;
}

#pragma mark -
#pragma mark Menu Actions
#pragma mark -

- (IBAction)invertAction:(id)sender
{
    NSWindow *activeWindow = [[NSApplication sharedApplication] keyWindow];
    if (!activeWindow) return;
    
    activeWindow.inverted = !activeWindow.inverted;
}

- (IBAction)invertOptionsAction:(id)sender
{
    
}

@end
