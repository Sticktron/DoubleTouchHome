//
//  Double-Touch Home Button : Activator Event
//	Requires TouchID.
//
//  Created by Sticktron, 2014.
//
//

#import <Foundation/Foundation.h>
#import <libactivator/libactivator.h>
#include <dispatch/dispatch.h>
#include <objc/runtime.h>

#define DEBUG_PREFIX @"😈 [DoubleTouchHome]"
#import "DebugLog.h"

#define TouchIDFingerUp    	0
#define TouchIDFingerDown  	1
#define TouchIDFingerHeld  	2
#define TouchIDMatched     	3
#define TouchIDNotMatched  	9

#define MAX_DELAY			0.5

#define LASendEventWithName(eventName) \
	[LASharedActivator sendEventToListener:[LAEvent eventWithName:eventName mode:[LASharedActivator currentEventMode]]]


static NSString *kDoubleTouchHome_eventName = @"DoubleTouchHomeEvent";
static CFTimeInterval timeOfLastFingerUpEvent;



//
// Private Interfaces
//

@interface BiometricKit : NSObject //<BiometricKitDelegate>
+ (id)manager;
@end

@interface SBUIBiometricEventMonitor : NSObject //<BiometricKitDelegate>
- (void)addObserver:(id)arg1;
- (void)removeObserver:(id)arg1;
@end



//
// Event DataSource
//

@interface DoubleTouchHomeDataSource : NSObject <LAEventDataSource>
+ (id)sharedInstance;
@end

@implementation DoubleTouchHomeDataSource
+ (id)sharedInstance {
	static id sharedInstance = nil;
	static dispatch_once_t token = 0;
	dispatch_once(&token, ^{
		sharedInstance = [self new];
	});
	return sharedInstance;
}
+ (void)load {
	[self sharedInstance];
}
- (id)init {
	if (self = [super init]) {
		DebugLog0;
		
		// Register our event
		[LASharedActivator registerEventDataSource:self forEventName:kDoubleTouchHome_eventName];
	}
	return self;
}
- (NSString *)localizedTitleForEventName:(NSString *)eventName {
	return @"Double Touch Home";
}
- (NSString *)localizedGroupForEventName:(NSString *)eventName {
	return @"Fingerprint Sensor";
}
- (NSString *)localizedDescriptionForEventName:(NSString *)eventName {
	return @"Double touch on the fingerprint sensor.";

}
- (void)dealloc {
	[LASharedActivator unregisterEventDataSourceWithEventName:kDoubleTouchHome_eventName];
	[super dealloc];
}
@end



//
// Event Dispatcher
//

%hook SBLockScreenManager
- (void)biometricEventMonitor:(SBUIBiometricEventMonitor *)arg1 handleBiometricEvent:(unsigned long long)event {
	DebugLog(@"biometric event: %llu", event);
	
	if (event == TouchIDFingerUp) {
		// check time since last TouchIDFingerUp event...
		
		CFTimeInterval timeNow = CACurrentMediaTime();
		DebugLog(@"last touch: %f | time now: %f", (double)timeOfLastFingerUpEvent, (double)timeNow);
		
		CFTimeInterval delta = timeNow - timeOfLastFingerUpEvent;
		DebugLog(@"time since last touch = %f", (double)delta);
		
		if (delta <= MAX_DELAY) {
			DebugLog(@"double touch detected >>> telling Activator ...");
			LASendEventWithName(kDoubleTouchHome_eventName);
		} else {
			DebugLog(@"too much time has passed, cancel.");
		}
		
		timeOfLastFingerUpEvent = timeNow;
	}
	
	%orig;
}
%end



//
// Init
//
%ctor {
	NSLog(@" DoubleTouchHome Activator Event loaded.");
	timeOfLastFingerUpEvent = 0;
}

