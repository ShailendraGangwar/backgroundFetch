//
//  NetworkProcessResponseProtocol.h
//  IPS
//
//  Created by Aricent on 5/26/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NetworkProcessResponseProtocol <NSObject>

@required

- (void) processResponse: (id)response RequestType:(NSInteger) requestType;
- (void) networkErrorHandling: (NSDictionary*) errorDict responseCode:(int) httpResponseCode;

@optional
- (void) errorHandling: (int)statusCode ErrorString:(NSString *) errorString;

@end
