//  ScopeUnit.h
//  Copyright © 2025 PalGranum. All rights reserved.

#ifndef ScopeUnit_h
#define ScopeUnit_h

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface ScopeUnit : AUAudioUnit

NS_ASSUME_NONNULL_BEGIN

- (const float*)leftScope:(NSInteger)nFrames;
- (const float*)rightScope:(NSInteger)nFrames;

NS_ASSUME_NONNULL_END

@end

#endif /* ScopeUnit_h */
