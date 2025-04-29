//  ScopeUnit.mm
//  Copyright © 2025 PalGranum. All rights reserved.

#import "ScopeUnit.h"
#import "ScopeKernel.hpp"
#import <AudioToolbox/AudioToolbox.h>

@interface ScopeUnit ()

@property AUAudioUnitBusArray *outputBusArray;
@property AUAudioUnitBusArray *inputBusArray;

@end

@implementation ScopeUnit {
    ScopeKernel  _kernel;
}

- (instancetype)initWithComponentDescription:(AudioComponentDescription)componentDescription
                                       error:(NSError * _Nullable __autoreleasing *)outError
{
    OSStatus err = _kernel.setup();
    if (err != noErr) {
        return nil;
    }

    self = [super initWithComponentDescription:componentDescription
                                         error:outError];
    if (self == nil) { return nil; }

    _inputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self
                                                             busType:AUAudioUnitBusTypeInput
                                                              busses:@[_kernel.inputBus]];
    _outputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self
                                                             busType:AUAudioUnitBusTypeOutput
                                                              busses:@[_kernel.outputBus]];
    return self;
}

-(void)dealloc {    
}

- (AUAudioUnitBusArray *)inputBusses {
    return _inputBusArray;
}

- (AUAudioUnitBusArray *)outputBusses {
    return _outputBusArray;
}

- (AUInternalRenderBlock)internalRenderBlock {
    /*
     Capture in locals to avoid ObjC member lookups. If "self" is captured in
     render, we're doing it wrong.
     */
    __block ScopeKernel *state = &_kernel;
    
    return ^AUAudioUnitStatus(
                              AudioUnitRenderActionFlags *actionFlags,
                              const AudioTimeStamp       *timestamp,
                              AVAudioFrameCount           frameCount,
                              NSInteger                   outputBusNumber,
                              AudioBufferList            *outputData,
                              const AURenderEvent        *realtimeEventListHead,
                              AURenderPullInputBlock      pullInputBlock) {
        
        OSStatus err = state->render(actionFlags, timestamp, frameCount,
                                     outputData, pullInputBlock);
        return err;
    };
}

- (const float *)leftScope:(NSInteger)nFrames {
    return _kernel.scopeBuffer.getLeftScope((int)nFrames);
}
- (const float *)rightScope:(NSInteger)nFrames {
    return _kernel.scopeBuffer.getRightScope((int)nFrames);
}

@end
