//  ScopeKernel.hpp
//  Copyright © 2025 PalGranum. All rights reserved.

#ifndef ScopeKernel_hpp
#define ScopeKernel_hpp

#import "DCScopeBuffer.hpp"

class ScopeKernel {
    
private:
    const UInt32 maxFrames = 4096;
    bool isBypassed = false;

public:
    AUAudioUnitBus* inputBus = nullptr;
    AUAudioUnitBus* outputBus = nullptr;
    DCScopeBuffer scopeBuffer;

    ScopeKernel() {
    }

    void initializeBuses(const bool isStereo) {
        double sampleRate = [AVAudioSession sharedInstance].sampleRate;
        AVAudioFormat *format = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:sampleRate channels:isStereo ? 2 : 1];
        inputBus = [[AUAudioUnitBus alloc] initWithFormat:format error:nil];
        inputBus.maximumChannelCount = 2;
        outputBus = [[AUAudioUnitBus alloc] initWithFormat:format error:nil];
        outputBus.maximumChannelCount = 2;
    }
    
    bool updateBusFormat(AVAudioFormat* format, OSStatus& err) {
        if ([inputBus setFormat:format error:nil] && [outputBus setFormat:format error:nil])
            return true;
        else {
            err = kAudioUnitErr_FormatNotSupported;
            return false;
        }
    }

    OSStatus setup() {
        const bool isStereo = false;
        this->initializeBuses(isStereo);
        return noErr;
    }

	void reset() {
        scopeBuffer.clearBuffer();
	}

    OSStatus setNewFormat(AVAudioFormat* format) {
        OSStatus err = noErr;
        return this->updateBusFormat(format, err);
    }

    OSStatus render(AudioUnitRenderActionFlags *renderFlags,
                    AudioTimeStamp const* timestamp,
                    AUAudioFrameCount frameCount,
                    AudioBufferList* outBuffer,
                    AURenderPullInputBlock pullInputBlock) {
        OSStatus err = pullInputBlock(renderFlags, timestamp, frameCount, 0, outBuffer);
        if (err == noErr) {
            scopeBuffer.bufferUp(outBuffer, frameCount, renderFlags);
        } else {
            #if DEBUG
            printf("ERROR: Audio render error: %i", (int)err);
            #endif
        }
        return err;
    }
};

#endif /* ScopeKernel */
