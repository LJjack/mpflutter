//
//  MPIOSEngine+Private.h
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/5/28.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#ifndef MPIOSEngine_Private_h
#define MPIOSEngine_Private_h

#import "MPIOSEngine.h"

@class JSContext, MPIOSApp, MPIOSComponentFactory, MPIOSDrawableStorage, MPIOSRouter, MPIOSDebugger, MPIOSMpkReader;

@interface MPIOSEngine (Private)

@property (nonatomic, readonly) MPIOSApp *app;
@property (nonatomic, readonly) BOOL started;
@property (nonatomic, readonly) JSContext *jsContext;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, id<MPIOSDataReceiver>> *managedViews;
@property (nonatomic, readonly) MPIOSComponentFactory *componentFactory;
@property (nonatomic, readonly) MPIOSDrawableStorage *drawableStorage;
@property (nonatomic, readonly) MPIOSRouter *router;
@property (nonatomic, readonly) MPIOSDebugger *debugger;
@property (nonatomic, readonly) MPIOSMpkReader *mpkReader;

- (void)clear;
- (void)didReceivedMessage:(NSString *)message;
- (void)sendMessage:(NSDictionary *)message;

@end

#endif /* MPIOSEngine_Private_h */
