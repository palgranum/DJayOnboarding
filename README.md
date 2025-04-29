# DJay Onboarding Engineering Task
by Pål Granum

A small app with a 4 step onboarding flow for an iPhone application.

Steps 1-3 follow designs as specified in Figma.

Step 4 was open for my own custom implementation of a congratulations style page.
It shows appropriate messages based on the users selected skill level over a background of animated music notes.
To showcase some basic realtime audio capabilities, there is a loopPlayer that plays an audio segment.
A custom audioUnit was added that tracks the current (stereo) stream of audio and copies it into a circular buffer.
The UI is running a CADisplayLink that visualizes an audio scope based on the most recent frames of audio in the buffer.
There is also a simple EQ effect that can be manipulated with a UIPanGestureRecognizer which affects filter frequency and bandwidth.

The app supports iOS 15 and newer, and all UI is based on (programmatic) UIKit.
There are no 3rd party dependencies.
