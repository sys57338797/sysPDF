//
//  httpServerContext.m
//  test
//
//  Created by mutouren on 12/23/15.
//  Copyright © 2015 mutouren. All rights reserved.
//

#import "httpServerContext.h"
#import "NSNotificationCenter+Extra.h"

@implementation httpServerContext


#pragma mark - public methods
+ (instancetype)sharedInstance
{
    static httpServerContext *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[httpServerContext alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
//        [NSNotificationCenter addObserverExt:self selector:@selector(receiveDidUpdateUserLocation:) msgName:kDidReceiveDidUpdateUserLocation object:nil];
    }
    
    return self;
}

- (void)dealloc
{
//    [NSNotificationCenter removeObserverExt:self msgName:kDidReceiveDidUpdateUserLocation object:nil];
}

//- (void)receiveDidUpdateUserLocation:(NSNotification*)notification
//{
//    self.cityName = [COCLLocationCoordinateManager sharedInstance].city;
//    if ([[COCLLocationCoordinateManager sharedInstance] userLocation].latitude > 0) {
//        self.lat = [NSString stringWithFormat:@"%.14f",[[COCLLocationCoordinateManager sharedInstance] userLocation].latitude];
//    }
//    if ([[COCLLocationCoordinateManager sharedInstance] userLocation].longitude > 0) {
//        self.lon = [NSString stringWithFormat:@"%.14f",[[COCLLocationCoordinateManager sharedInstance] userLocation].longitude];
//    }
//}

- (NSString*)keyfrom
{
    if (!_keyfrom) {
        _keyfrom = @"wuming78564";
    }
    
    return _keyfrom;
}

- (NSString*)key
{
    if (!_key) {
        _key = @"103834335";
    }
    
    return _key;
}

- (NSString*)type
{
    if (!_type) {
        _type = @"data";
    }
    
    return _type;
}

- (NSString*)doctype
{
    if (!_doctype) {
        _doctype = @"json";
    }
    
    return _doctype;
}

- (NSString*)version
{
    if (!_version) {
        _version = @"1.1";
    }
    
    return _version;
}

@end
