//
//  Inverter.h
//  Inverter
//
//  Created by NSDex on 12/16/12.
//
//

#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>
#import "CGSPrivate.h"

#if DEBUG
#   define DLog    NSLog
#else
#   define DLog(STRING, ...)
#endif

@interface Inverter : NSObject {
    NSString *_appName;
    CGSConnection _serverConnection;
    
    /// Things for IB
    IBOutlet NSMenuItem *_invertMenuItem;
    IBOutlet NSMenuItem *_invertOptionsMenuItem;
}

+ (instancetype)sharedInstance;

@property (nonatomic, readonly) NSString *appName;
@property (nonatomic, readonly) CGSConnection serverConnection;

@end
