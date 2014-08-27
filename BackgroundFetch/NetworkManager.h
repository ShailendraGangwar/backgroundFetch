//
//  NetworkManager.h
//  IPS
//
//  Created by Aricent on 5/26/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import "NetworkProcessResponseProtocol.h"

@interface NetworkManager : NSObject
{
    Reachability            *reach;
}

@property (nonatomic, strong) NSMutableData         *responseData;
@property (nonatomic, strong) NSURLConnection       *urlConnection;
@property (nonatomic, assign) NSInteger             httpRequestType;
@property (nonatomic, strong) NSURLRequest          *requestUrl;
@property (nonatomic, strong) NSHTTPURLResponse     *httpUrlResponse;
@property (nonatomic, weak) id<NetworkProcessResponseProtocol> mNetworkDelegate;
@property (nonatomic) NSUInteger totalBytes;
@property (nonatomic) NSUInteger receivedBytes;

-(void) cancelNetworkRequest;
-(void) networkRequest:(NSInteger)requestType RequestBody:(NSDictionary*)requestBody isRequestAsynchronous:(BOOL)isAsyncReq;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

@end
