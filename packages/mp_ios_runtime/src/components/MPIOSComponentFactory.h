//
//  MPIOSComponentFactory.h
//  mp_ios_runtime
//
//  Created by PonyCui on 2021/6/8.
//  Copyright © 2021 MPFlutter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPIOSEngine.h"

NS_ASSUME_NONNULL_BEGIN

@class MPIOSComponentView, MPIOSAncestorView;

@interface MPIOSComponentFactory : NSObject

@property (nonatomic, weak) MPIOSEngine *engine;
@property (nonatomic, assign) BOOL disableCache;
@property (nonatomic, readonly) NSMutableDictionary<NSNumber *, MPIOSComponentView *> *cachedView;
@property (nonatomic, readonly) NSMutableDictionary<NSNumber *, NSDictionary *> *cachedElement;
@property (nonatomic, readonly) NSMutableDictionary<NSNumber *, NSAttributedString *> *cachedAttributedString;

- (MPIOSComponentView *)create:(NSDictionary *)data;
- (MPIOSAncestorView *)createAncestors:(NSDictionary *)data target:(MPIOSComponentView *)target;
- (void)callbackTextMeasureResult:(NSNumber *)measureId size:(CGSize)size;
- (void)flushTextMeasureResult;
- (void)clear;

@end

NS_ASSUME_NONNULL_END
