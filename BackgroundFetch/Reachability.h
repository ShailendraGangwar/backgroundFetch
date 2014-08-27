//
//  Reachability.h
//  IPS
//
//  Created by Aricent on 5/26/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

extern NSString *const kReachabilityChangedNotification;
//Defining Enum
typedef enum
{
	// Apple NetworkStatus Compatible Names.
	NotReachable     = 0,
	ReachableViaWiFi = 2,
	ReachableViaWWAN = 1
} NetworkStatus;

@class Reachability;

typedef void (^NetworkReachable)(Reachability * reachability);
typedef void (^NetworkUnreachable)(Reachability * reachability);

@interface Reachability : NSObject

//Properties to allow variables to be accessed by external objects
@property (nonatomic, copy) NetworkReachable            reachableBlock;
@property (nonatomic, copy) NetworkUnreachable          unreachableBlock;
@property (nonatomic, assign) SCNetworkReachabilityRef  reachabilityRef;
@property (nonatomic, strong) dispatch_queue_t          reachabilitySerialQueue;
@property (nonatomic, assign) BOOL                      reachableOnWWAN;
@property (nonatomic, assign) BOOL                      isProcessingNetworkAlert;
@property (nonatomic, strong) id                        reachabilityObject;


//Methods used in Interface Builder
+(Reachability*)reachabilityWithHostname:(NSString*)hostname;
+(Reachability*)reachabilityForInternetConnection;
+(Reachability*)reachabilityWithAddress:(const struct sockaddr_in*)hostAddress;
+(Reachability*)reachabilityForLocalWiFi;

-(Reachability *)initWithReachabilityRef:(SCNetworkReachabilityRef)ref;
-(BOOL)startNotifier;
-(void)stopNotifier;
-(BOOL)isReachable;
-(BOOL)isReachableViaWWAN;
-(BOOL)isReachableViaWiFi;

// WWAN may be available, but not active until a connection has been established.
// WiFi may require a connection for VPN on Demand.
-(BOOL)isConnectionRequired; // Identical DDG variant.
-(BOOL)connectionRequired; // Apple's routine.

// Dynamic, on demand connection?
-(BOOL)isConnectionOnDemand;
// Is user intervention required?
-(BOOL)isInterventionRequired;

-(NetworkStatus)currentReachabilityStatus;
-(SCNetworkReachabilityFlags)reachabilityFlags;
-(NSString*)currentReachabilityString;
-(NSString*)currentReachabilityFlags;

@end

