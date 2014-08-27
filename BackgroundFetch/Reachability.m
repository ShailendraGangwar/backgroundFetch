//
//  Reachability.m
//  IPS
//
//  Created by Aricent on 5/26/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import "Reachability.h"
#import "Constants.h"


NSString *const kReachabilityChangedNotification = @"kReachabilityChangedNotification";

@interface Reachability (private)

- (void)reachabilityChanged:(SCNetworkReachabilityFlags)flags;
- (BOOL)setReachabilityTarget:(NSString*)hostname;
- (BOOL)isReachableWithFlags:(SCNetworkReachabilityFlags)flags;

@end

static NSString *reachabilityFlags(SCNetworkReachabilityFlags flags)
{
    return [NSString stringWithFormat:@"%c%c %c%c%c%c%c%c%c",
#if	TARGET_OS_IPHONE
            (flags & kSCNetworkReachabilityFlagsIsWWAN)               ? 'W' : '-',
#else
            'X',
#endif
            (flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',
            (flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
            (flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
            (flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
            (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',
            (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',
            (flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
            (flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-'];
}

//Start listening for reachability notifications on the current run loop
static void TMReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
#pragma unused (target)
    Reachability *reachability = ((__bridge Reachability*)info);
    
    // we probably dont need an autoreleasepool here as GCD docs state each queue has its own autorelease pool
    // but what the heck eh?
    @autoreleasepool
    {
        [reachability reachabilityChanged:flags];
    }
}


@implementation Reachability

@synthesize reachabilityRef;
@synthesize reachabilitySerialQueue;
@synthesize reachableOnWWAN;
@synthesize reachableBlock;
@synthesize unreachableBlock;
@synthesize reachabilityObject;
@synthesize isProcessingNetworkAlert;

#pragma Sprint2_UAT_Ajay
static Reachability *reachability;


#pragma mark - class constructor methods
+(Reachability*)reachabilityWithHostname:(NSString*)hostname
{
    SCNetworkReachabilityRef ref = SCNetworkReachabilityCreateWithName(NULL, [hostname UTF8String]);
    if (ref)
    {
        id reachability = [[self alloc] initWithReachabilityRef:ref];
        
#if __has_feature(objc_arc)
        return reachability;
#else
        return [reachability autorelease];
#endif
        
    }
    
    return nil;
}

+(Reachability *)reachabilityWithAddress:(const struct sockaddr_in *)hostAddress
{
    SCNetworkReachabilityRef ref = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)hostAddress);
    if (ref)
    {
        if (!reachability)
        {
            reachability = [[self alloc] initWithReachabilityRef:ref];
        }
        
#if __has_feature(objc_arc)
        return reachability;
#else
        return [reachability autorelease];
#endif
    }
    
    return nil;
}


+(Reachability *)reachabilityForInternetConnection
{
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    return [self reachabilityWithAddress:&zeroAddress];
}


+(Reachability*)reachabilityForLocalWiFi
{
    struct sockaddr_in localWifiAddress;
    bzero(&localWifiAddress, sizeof(localWifiAddress));
    localWifiAddress.sin_len            = sizeof(localWifiAddress);
    localWifiAddress.sin_family         = AF_INET;
    // IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0
    localWifiAddress.sin_addr.s_addr    = htonl(IN_LINKLOCALNETNUM);
    
    return [self reachabilityWithAddress:&localWifiAddress];
}




-(Reachability *)initWithReachabilityRef:(SCNetworkReachabilityRef)ref
{
    self = [super init];
    if (self != nil)
    {
        self.reachableOnWWAN = YES;
        self.reachabilityRef = ref;
    }
    
    return self;
}


-(void)dealloc
{
    [self stopNotifier];
    if(self.reachabilityRef)
    {
        if (self.reachabilityRef)
        {
            CFRelease(self.reachabilityRef);
        }
        
        self.reachabilityRef = nil;
    }
#ifdef DEBUG
    
#endif
    
#if !(__has_feature(objc_arc))
    [super dealloc];
#endif
    
    
}

#pragma mark - notifier methods

// Notifier
// NOTE: this uses GCD to trigger the blocks - they *WILL NOT* be called on THE MAIN THREAD
// - In other words DO NOT DO ANY UI UPDATES IN THE BLOCKS.
//   INSTEAD USE dispatch_async(dispatch_get_main_queue(), ^{UISTUFF}) (or dispatch_sync if you want)

-(BOOL)startNotifier
{
    SCNetworkReachabilityContext    context = { 0, NULL, NULL, NULL, NULL };
    
    // this should do a retain on ourself, so as long as we're in notifier mode we shouldn't disappear out from under ourselves
    // woah
    self.reachabilityObject = self;
    
    context.info = (__bridge void *)self;
    
    if (!SCNetworkReachabilitySetCallback(self.reachabilityRef, TMReachabilityCallback, &context))
    {
#ifdef DEBUG
        
#endif
        return NO;
    }
    
    //create a serial queue
    self.reachabilitySerialQueue = dispatch_queue_create("com.tonymillion.reachability", NULL);
    
    // set it as our reachability queue which will retain the queue
    if(SCNetworkReachabilitySetDispatchQueue(self.reachabilityRef, self.reachabilitySerialQueue))
    {
        //dispatch_release(self.reachabilitySerialQueue);
        // refcount should be ++ from the above function so this -- will mean its still 1
        return YES;
    }
    
    //dispatch_release(self.reachabilitySerialQueue);
    self.reachabilitySerialQueue = nil;
    return NO;
}

-(void)stopNotifier
{
    // first stop any callbacks!
    SCNetworkReachabilitySetCallback(self.reachabilityRef, NULL, NULL);
    
    // unregister target from the GCD serial dispatch queue
    // this will mean the dispatch queue gets dealloc'ed
    if(self.reachabilitySerialQueue)
    {
        SCNetworkReachabilitySetDispatchQueue(self.reachabilityRef, NULL);
        self.reachabilitySerialQueue = nil;
    }
    
    self.reachabilityObject = nil;
}

#pragma mark - reachability tests


#define testcase (kSCNetworkReachabilityFlagsConnectionRequired | kSCNetworkReachabilityFlagsTransientConnection)

-(BOOL)isReachableWithFlags:(SCNetworkReachabilityFlags)flags
{
    BOOL connectionUP = YES;
    
    if(!(flags & kSCNetworkReachabilityFlagsReachable))
        connectionUP = NO;
    
    if( (flags & testcase) == testcase )
        connectionUP = NO;
    
#if	TARGET_OS_IPHONE
    if(flags & kSCNetworkReachabilityFlagsIsWWAN)
    {
        // we're on 3G
        if(!self.reachableOnWWAN)
        {
            // we dont want to connect when on 3G
            connectionUP = NO;
        }
    }
#endif
    
    return connectionUP;
}

-(BOOL)isReachable
{
    SCNetworkReachabilityFlags flags;
    
    if(!SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags))
        return NO;
    
    return [self isReachableWithFlags:flags];
}

-(BOOL)isReachableViaWWAN
{
#if	TARGET_OS_IPHONE
    
    SCNetworkReachabilityFlags flags = 0;
    
    if(SCNetworkReachabilityGetFlags(reachabilityRef, &flags))
    {
        // check we're REACHABLE
        if(flags & kSCNetworkReachabilityFlagsReachable)
        {
            // now, check we're on WWAN
            if(flags & kSCNetworkReachabilityFlagsIsWWAN)
            {
                return YES;
            }
        }
    }
#endif
    
    return NO;
}

-(BOOL)isReachableViaWiFi
{
    SCNetworkReachabilityFlags flags = 0;
    
    if(SCNetworkReachabilityGetFlags(reachabilityRef, &flags))
    {
        // check we're reachable
        if((flags & kSCNetworkReachabilityFlagsReachable))
        {
#if	TARGET_OS_IPHONE
            // check we're NOT on WWAN
            if((flags & kSCNetworkReachabilityFlagsIsWWAN))
            {
                return NO;
            }
#endif
            return YES;
        }
    }
    
    return NO;
}


// WWAN may be available, but not active until a connection has been established.
// WiFi may require a connection for VPN on Demand.
-(BOOL)isConnectionRequired
{
    return [self connectionRequired];
}

-(BOOL)connectionRequired
{
    SCNetworkReachabilityFlags flags;
	
	if(SCNetworkReachabilityGetFlags(reachabilityRef, &flags))
    {
		return (flags & kSCNetworkReachabilityFlagsConnectionRequired);
	}
    
    return NO;
}

// Dynamic, on demand connection?
-(BOOL)isConnectionOnDemand
{
	SCNetworkReachabilityFlags flags;
	
	if (SCNetworkReachabilityGetFlags(reachabilityRef, &flags))
    {
		return ((flags & kSCNetworkReachabilityFlagsConnectionRequired) &&
				(flags & (kSCNetworkReachabilityFlagsConnectionOnTraffic | kSCNetworkReachabilityFlagsConnectionOnDemand)));
	}
	
	return NO;
}

// Is user intervention required?
-(BOOL)isInterventionRequired
{
    SCNetworkReachabilityFlags flags;
	
	if (SCNetworkReachabilityGetFlags(reachabilityRef, &flags))
    {
		return ((flags & kSCNetworkReachabilityFlagsConnectionRequired) &&
				(flags & kSCNetworkReachabilityFlagsInterventionRequired));
	}
	
	return NO;
}


#pragma mark - reachability status stuff

-(NetworkStatus)currentReachabilityStatus
{
    if([self isReachable])
    {
        if([self isReachableViaWiFi])
            return ReachableViaWiFi;
        
#if	TARGET_OS_IPHONE
        return ReachableViaWWAN;
#endif
    }
    
    if (self.isProcessingNetworkAlert == NO)
    {
        self.isProcessingNetworkAlert = YES;
        //NSString *errMessageFotNet = NSLocalizedString(@"Your Internet connection seems to be off.Please try again", @"Your Internet connection seems to be off.Please try again");
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"OOPS!!!!!" message:errMessageFotNet delegate: self cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil, nil];
        //[alert show];
    }
    if(![self isReachable])
        self.isProcessingNetworkAlert = NO;
    
    return NotReachable;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    self.isProcessingNetworkAlert = NO;
    
    [self performSelectorOnMainThread: @selector(stopActivity:) withObject: self waitUntilDone: YES];
}

- (void) stopActivity : (id) sender
{
}


-(SCNetworkReachabilityFlags)reachabilityFlags
{
    SCNetworkReachabilityFlags flags = 0;
    
    if(SCNetworkReachabilityGetFlags(reachabilityRef, &flags))
    {
        return flags;
    }
    
    return 0;
}

-(NSString*)currentReachabilityString
{
	NetworkStatus temp = [self currentReachabilityStatus];
	
	if(temp == reachableOnWWAN)
	{
        // updated for the fact we have CDMA phones now!
		return NSLocalizedString(@"Cellular", EMPTY_STRING);
	}
	if (temp == ReachableViaWiFi)
	{
		return NSLocalizedString(@"WiFi", EMPTY_STRING);
	}
	
	return NSLocalizedString(@"No Connection", EMPTY_STRING);
}

-(NSString*)currentReachabilityFlags
{
    return reachabilityFlags([self reachabilityFlags]);
}

#pragma mark - callback function calls this method

-(void)reachabilityChanged:(SCNetworkReachabilityFlags)flags
{
#ifdef DEBUG
    
#endif
    
    if([self isReachableWithFlags:flags])
    {
        if(self.reachableBlock)
        {
#ifdef DEBUG
            
#endif
            self.reachableBlock(self);
        }
    }
    else
    {
        if(self.unreachableBlock)
        {
#ifdef DEBUG
            
#endif
            self.unreachableBlock(self);
        }
    }
    
    // this makes sure the change notification happens on the MAIN THREAD
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kReachabilityChangedNotification
                                                            object:self];
    });
}

@end

