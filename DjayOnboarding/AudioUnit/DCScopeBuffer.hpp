#ifndef DCScopeBuffer_h
#define DCScopeBuffer_h

//  DCScopeBuffer.hpp
//  Copyright © 2025 PalGranum. All rights reserved.

#ifndef __cplusplus
#else

#import <cmath>
#import <Accelerate/Accelerate.h>
#import <AudioToolbox/AudioToolbox.h>

#define BUFFER_LENGTH 4096
#define OVERLAP 4096

class DCScopeBuffer
{
private:
    bool isScoping = true;
    bool isCleared = true;
protected:
    float leftBuffer[BUFFER_LENGTH + OVERLAP];
    float rightBuffer[BUFFER_LENGTH + OVERLAP];
    int currentWritePos = 0;

public:
    //these pointers are always valid for writing at most OVERLAP frames
    float* leftWritePtr;
    float* rightWritePtr;

    long writePosition = 0;

    DCScopeBuffer() noexcept
    : leftWritePtr(this->leftBuffer), rightWritePtr(this->rightBuffer)
    {
        clearBuffer();
    }
    
    ~DCScopeBuffer() { }
    
    void enable() {
        this->isScoping = true;
    }
    
    void disable() {
        this->isScoping = false;
        clearBuffer();
    }

    void clearBuffer() {
        int byteSize = (BUFFER_LENGTH + OVERLAP) * sizeof(float);
        memset(this->leftBuffer, 0, byteSize);
        memset(this->rightBuffer, 0, byteSize);
        isCleared = true;
    }

    void bufferUp(const AudioBufferList* buffer, int nFrames, AudioUnitRenderActionFlags *renderFlags) {
        if (!isScoping)
            return;
        if (*renderFlags & kAudioUnitRenderAction_OutputIsSilence) {
            if (!isCleared)
                clearBuffer();
            return;
        }
        isCleared = false;
        if (buffer->mNumberBuffers > 1)
            writeStereo(buffer, nFrames);
        else
            writeMono(buffer, nFrames);
    }
    
    void writeStereo(const AudioBufferList* buffer, int nFrames) {
        assert(nFrames <= OVERLAP);
        currentWritePos = int(this->writePosition % BUFFER_LENGTH);
        this->leftWritePtr = this->leftBuffer + currentWritePos;
        this->rightWritePtr = this->rightBuffer + currentWritePos;

        memcpy(this->leftWritePtr,
               buffer->mBuffers[0].mData,
               nFrames * sizeof(float));
        memcpy(this->rightWritePtr,
               buffer->mBuffers[1].mData,
               nFrames * sizeof(float));
        
        if (currentWritePos < OVERLAP) {
            // any content at the very beginning must be duplicated at the overlap
            // area so that float pointers are contiguously valid at all positions
            int framesToCopy = MIN(nFrames, OVERLAP - currentWritePos);
            memcpy(this->leftWritePtr + BUFFER_LENGTH,
                   this->leftWritePtr,
                   framesToCopy * sizeof(float));
            memcpy(this->rightWritePtr + BUFFER_LENGTH,
                   this->rightWritePtr,
                   framesToCopy * sizeof(float));
        } else {
            // if the current writeposition + nFrames extends beyond BUFFER_LENGTH
            // those frames must be copied to the start of the buffer
            int overlappingFrames = int((currentWritePos + nFrames) - BUFFER_LENGTH);
            if (overlappingFrames > 0) {
                memcpy(this->leftBuffer,
                       this->leftBuffer + BUFFER_LENGTH,
                       overlappingFrames * sizeof(float));
                memcpy(this->rightBuffer,
                       this->rightBuffer + BUFFER_LENGTH,
                       overlappingFrames * sizeof(float));
            }
        }
        this->writePosition += nFrames;
    }
    
    void writeMono(const AudioBufferList* buffer, int nFrames) {
        assert(nFrames <= OVERLAP);
        currentWritePos = int(this->writePosition % BUFFER_LENGTH);
        this->leftWritePtr = this->leftBuffer + currentWritePos;
        this->rightWritePtr = this->leftWritePtr;

        memcpy(this->leftWritePtr,
               buffer->mBuffers[0].mData,
               nFrames * sizeof(float));

        if (currentWritePos < OVERLAP) {
            // any content at the very beginning must be duplicated at the overlap
            // area so that float pointers are contiguously valid at all positions
            int framesToCopy = MIN(nFrames, OVERLAP - currentWritePos);
            memcpy(this->leftWritePtr + BUFFER_LENGTH,
                   this->leftWritePtr,
                   framesToCopy * sizeof(float));
        } else {
            // if the current writeposition + nFrames extends beyond BUFFER_LENGTH
            // those frames must be copied to the start of the buffer
            int overlappingFrames = int((currentWritePos + nFrames) - BUFFER_LENGTH);
            if (overlappingFrames > 0) {
                memcpy(this->leftBuffer,
                       this->leftBuffer + BUFFER_LENGTH,
                       overlappingFrames * sizeof(float));
            }
        }
        this->writePosition += nFrames;
    }

    float* getLeftScope(int nFrames) {
        assert(nFrames > 0 && nFrames <= BUFFER_LENGTH);
        NSInteger pos = abs(this->writePosition - nFrames) % BUFFER_LENGTH;
        return this->leftBuffer + pos;
    }

    float* getRightScope(int nFrames) {
        assert(nFrames > 0 && nFrames <= BUFFER_LENGTH);
        NSInteger pos = abs(this->writePosition - nFrames) % BUFFER_LENGTH;
        return this->rightBuffer + pos;
    }
};

#endif

#endif
