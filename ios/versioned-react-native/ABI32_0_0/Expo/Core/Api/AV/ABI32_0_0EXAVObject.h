// Copyright 2017-present 650 Industries. All rights reserved.

typedef NS_OPTIONS(NSUInteger, ABI32_0_0EXAVAudioSessionMode)
{
  // These are enumerated in ascending order of priority.
  // The ABI32_0_0EXAVAudioSessionMode of the current experience (managed by ABI32_0_0EXAV) should be
  // the maximum of the ABI32_0_0EXAVAudioSessionModes required by each of the live ABI32_0_0EXAVObjects.
  ABI32_0_0EXAVAudioSessionModeInactive    = 0,
  ABI32_0_0EXAVAudioSessionModeActiveMuted = 1,
  ABI32_0_0EXAVAudioSessionModeActive      = 2
};

@protocol ABI32_0_0EXAVObject <NSObject> // For ABI32_0_0EXAVPlayerData and ABI32_0_0EXVideoView to interact with the Audio Session properly

- (void)pauseImmediately;

- (ABI32_0_0EXAVAudioSessionMode)getAudioSessionModeRequired; // TODO (clarity): is needsAudioSession a better name?

- (void)bridgeDidForeground:(NSNotification *)notification;

- (void)bridgeDidBackground:(NSNotification *)notification;

- (void)handleAudioSessionInterruption:(NSNotification*)notification;

- (void)handleMediaServicesReset:(void (^)(void))finishCallback;

@end
